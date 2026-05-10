#!/usr/bin/env python3
"""Flutter Widget Inspector helper for Neovim.

Connects to the Flutter VM service, queries the selected widget from the
Widget Inspector, and prints a formatted summary to stdout.

Handles DDS (Dart Development Service) redirects automatically.

Exit codes:
  0 = widget found and printed
  1 = connection/protocol error
  2 = missing dependency
  3 = no widget currently selected
"""
import argparse
import asyncio
import json
import os
import re
import sys
from typing import Any, Dict, List, Optional

try:
    import websockets
    from websockets.exceptions import InvalidStatus, InvalidURI
except Exception:
    print(
        "ERROR: missing python package 'websockets'. "
        "Install with: python3 -m pip install websockets",
        file=sys.stderr,
    )
    sys.exit(2)


def normalize_ws_url(url: str) -> str:
    url = url.strip()
    if url.startswith("http://"):
        url = "ws://" + url[len("http://"):]
    elif url.startswith("https://"):
        url = "wss://" + url[len("https://"):]
    if not url.endswith("/ws"):
        url = url.rstrip("/") + "/ws"
    return url


async def connect_with_redirect(ws_url: str):
    """Connect to WS URL, following DDS HTTP 302 redirects."""
    try:
        ws = await websockets.connect(ws_url, open_timeout=5)
        return ws
    except (InvalidStatus, InvalidURI) as exc:
        location = None
        if isinstance(exc, InvalidStatus):
            response = exc.response
            if response.status_code in (301, 302, 307, 308):
                for header_name, header_value in response.headers.raw_items():
                    if header_name.lower() == "location":
                        location = header_value
                        break
        elif isinstance(exc, InvalidURI):
            uri_str = str(exc)
            match = re.search(r"(https?://[^\s'\"]+)", uri_str)
            if match:
                location = match.group(1)

        if location:
            redirected = normalize_ws_url(location)
            try:
                return await websockets.connect(redirected, open_timeout=5)
            except (InvalidStatus, InvalidURI) as exc2:
                if isinstance(exc2, InvalidStatus) and exc2.response.status_code in (301, 302, 307, 308):
                    for h, v in exc2.response.headers.raw_items():
                        if h.lower() == "location":
                            return await websockets.connect(normalize_ws_url(v), open_timeout=5)
                raise
        raise


def pick_main_isolate(isolates: List[Dict]) -> Optional[str]:
    """Pick the main UI isolate."""
    for iso in isolates:
        iso_id = iso.get("id") or iso.get("isolateId")
        name = iso.get("name", "")
        if "main" in name.lower():
            return iso_id
    if isolates:
        return isolates[0].get("id") or isolates[0].get("isolateId")
    return None


class RpcClient:
    def __init__(self, ws):
        self.ws = ws
        self._next_id = 1

    async def call(self, method: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        msg_id = self._next_id
        self._next_id += 1
        payload = {
            "jsonrpc": "2.0",
            "id": msg_id,
            "method": method,
            "params": params or {},
        }
        await self.ws.send(json.dumps(payload))
        while True:
            raw = await asyncio.wait_for(self.ws.recv(), timeout=8)
            data = json.loads(raw)
            if data.get("id") == msg_id:
                return data


def extract_widget_info(resp: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """Extract widget data from a VM service response, handling nesting."""
    if "error" in resp:
        return None
    result = resp.get("result")
    if not result or not isinstance(result, dict):
        return None
    inner = result.get("result", result)
    if inner is None or not isinstance(inner, dict):
        return None
    if inner.get("widgetRuntimeType") or inner.get("description"):
        return inner
    return None


def format_widget(widget: Dict[str, Any]) -> str:
    """Format widget info into a useful summary for Avante."""
    widget_type = widget.get("widgetRuntimeType") or widget.get("description", "Unknown")
    description = widget.get("description", widget_type)
    stateful = widget.get("stateful", False)

    location = widget.get("creationLocation", {})
    file_path = location.get("file", "")
    line = location.get("line", "?")
    column = location.get("column", "?")

    if file_path.startswith("file://"):
        file_path = file_path[len("file://"):]

    children = widget.get("children", [])
    child_types = []
    for c in children[:5]:
        if isinstance(c, dict):
            child_types.append(c.get("widgetRuntimeType") or c.get("description", "?"))

    lines = []
    lines.append(f"## Selected Widget: {description}")
    lines.append(f"- **Type**: `{widget_type}`")
    lines.append(f"- **Stateful**: {stateful}")
    if file_path:
        lines.append(f"- **File**: `{file_path}`")
        lines.append(f"- **Line**: {line}, Column: {column}")
    if child_types:
        lines.append(f"- **Children**: {', '.join(child_types)}")
    lines.append("")
    return "\n".join(lines)


async def try_get_selected_widget(rpc: RpcClient, isolate_id: str) -> Optional[Dict[str, Any]]:
    """Try multiple methods to get the selected widget."""
    obj_group = f"avante_{os.getpid()}"

    # Method 1: Direct extension calls (works on raw VM service)
    for method in [
        "ext.flutter.inspector.getSelectedSummaryWidget",
        "ext.flutter.inspector.getSelectedWidget",
    ]:
        try:
            resp = await rpc.call(method, {
                "isolateId": isolate_id,
                "objectGroup": obj_group,
            })
            widget = extract_widget_info(resp)
            if widget:
                return widget
        except (asyncio.TimeoutError, Exception):
            continue

    # Method 2: Via callServiceExtension (works on DDS)
    for method in [
        "ext.flutter.inspector.getSelectedSummaryWidget",
        "ext.flutter.inspector.getSelectedWidget",
    ]:
        try:
            resp = await rpc.call("callServiceExtension", {
                "isolateId": isolate_id,
                "method": method,
                "params": {"objectGroup": obj_group},
            })
            widget = extract_widget_info(resp)
            if widget:
                return widget
        except (asyncio.TimeoutError, Exception):
            continue

    return None


async def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--ws", required=True, help="VM Service WebSocket URL")
    args = parser.parse_args()

    ws_url = normalize_ws_url(args.ws)

    try:
        ws = await connect_with_redirect(ws_url)
    except ConnectionRefusedError:
        print("CONNECTION_REFUSED", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"ERROR: Connection failed: {e}", file=sys.stderr)
        return 1

    try:
        rpc = RpcClient(ws)

        # Get VM and isolates
        vm = await rpc.call("getVM")
        vm_result = vm.get("result", {})
        isolates = vm_result.get("isolates", [])
        isolate_id = pick_main_isolate(isolates)
        if not isolate_id:
            print("ERROR: No isolates found in VM", file=sys.stderr)
            return 1

        widget = await try_get_selected_widget(rpc, isolate_id)

        if widget:
            print(format_widget(widget))
            return 0
        else:
            print("NO_WIDGET_SELECTED", file=sys.stderr)
            return 3

    except asyncio.TimeoutError:
        print("ERROR: Timeout waiting for VM service response", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1
    finally:
        await ws.close()


if __name__ == "__main__":
    raise SystemExit(asyncio.run(main()))

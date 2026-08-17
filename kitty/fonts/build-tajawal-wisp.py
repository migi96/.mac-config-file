#!/usr/bin/env python3
"""Build "Tajawal Wisp": Tajawal with complete Arabic Presentation Forms.

Why this exists
---------------
kitty does no Arabic shaping, so wisp pre-shapes text into Presentation Forms
(U+FB50-FDFF / U+FE70-FEFF) and the terminal font must have *cmap entries* for
those codepoints. Tajawal maps the initial/medial/final forms but — like most
modern fonts — omits every ISOLATED form (the isolated glyph is just the base
letter's default glyph, so designers skip the duplicate cmap entry). Mapping
kitty's Arabic ranges to raw Tajawal would therefore render isolated letters
(every standalone alef, dal, meem, ...) in a DIFFERENT fallback font: a mixed
mess — the same class of failure as the public Geeza Pro (which has no
presentation forms at all).

The fix is lossless: for each missing `<isolated>`-decomposition codepoint,
add a cmap entry pointing at the glyph the font already uses for the base
letter. No glyphs are added or modified; only the character map grows. The
result is renamed "Tajawal Wisp" so it never collides with the stock family.

Usage:  build-tajawal-wisp.py <src.ttf> <dst.ttf> [family-name | --keep-name]
(family-name defaults to "Tajawal Wisp". Pass --keep-name to leave the name
table completely untouched and patch only the cmap — REQUIRED for CFF/OTF
fonts: their PostScript name also lives inside the CFF table, and a name-table
rename that doesn't match it makes CoreText refuse to register the font, so
the renamed family silently never resolves. Patch OTFs in place instead.)
Prints a report and, on the last line, `RANGES: <kitty symbol_map ranges>` —
the exact codepoint ranges the built font covers within the Arabic blocks.
"""

import sys
import unicodedata
from fontTools.ttLib import TTFont

FAMILY = sys.argv[3] if len(sys.argv) > 3 else "Tajawal Wisp"
# The Unicode blocks wisp's output can touch (base Arabic + both PF blocks).
BLOCKS = [(0x0600, 0x06FF), (0x0750, 0x077F), (0xFB50, 0xFDFF), (0xFE70, 0xFEFF)]


def patch(src: str, dst: str) -> set[int]:
    font = TTFont(src)
    best = font.getBestCmap()
    unicode_tables = [t for t in font["cmap"].tables if t.isUnicode()]

    added, skipped = [], []
    for lo, hi in [(0xFB50, 0xFDFF), (0xFE70, 0xFEFF)]:
        for cp in range(lo, hi + 1):
            if cp in best:
                continue
            decomp = unicodedata.decomposition(chr(cp))
            if not decomp.startswith("<"):
                continue  # no compatibility decomposition — nothing to derive
            tag, *hexes = decomp.split()
            bases = [int(h, 16) for h in hexes]
            # Only the isolated single-letter forms are safely identical to the
            # base glyph. (Missing initial/medial/final or multi-char ligatures
            # would need real shaping — the report shows if any turn up.)
            if tag != "<isolated>" or len(bases) != 1 or bases[0] not in best:
                skipped.append(cp)
                continue
            glyph = best[bases[0]]
            for t in unicode_tables:
                t.cmap[cp] = glyph
            added.append(cp)

    # Rename so the patched family exists alongside the stock one — unless the
    # caller asked to keep the identity (mandatory for CFF/OTF, see docstring).
    if FAMILY != "--keep-name":
        name = font["name"]
        sub = name.getDebugName(17) or name.getDebugName(2) or "Regular"
        ps = FAMILY.replace(" ", "") + "-" + sub.replace(" ", "")
        for rec in list(name.names):
            val = {
                1: FAMILY,
                16: FAMILY,
                4: f"{FAMILY} {sub}",
                6: ps,
                3: f"{ps};wisp-pf-patch",
            }.get(rec.nameID)
            if val is not None:
                name.setName(val, rec.nameID, rec.platformID, rec.platEncID, rec.langID)

    font.save(dst)

    covered = set(best) | set(added)
    print(f"{src.rsplit('/', 1)[-1]}: +{len(added)} isolated forms", end="")
    real_skips = [c for c in skipped if 0xFE80 <= c <= 0xFEFC]
    if real_skips:  # gaps in the letter range would actually show on screen
        print(f"  UNRESOLVED letter forms: {[hex(c) for c in real_skips]}", end="")
    print()
    return covered


def to_ranges(cps: set[int]) -> str:
    keep = sorted(c for c in cps if any(lo <= c <= hi for lo, hi in BLOCKS))
    spans, start, prev = [], None, None
    for c in keep:
        if start is None:
            start = prev = c
        elif c == prev + 1:
            prev = c
        else:
            spans.append((start, prev))
            start = prev = c
    if start is not None:
        spans.append((start, prev))
    return ",".join(
        f"U+{a:04X}" if a == b else f"U+{a:04X}-U+{b:04X}" for a, b in spans
    )


if __name__ == "__main__":
    src, dst = sys.argv[1], sys.argv[2]
    covered = patch(src, dst)
    # Verify the letter range is now gap-free before anyone maps a terminal to it.
    missing = [hex(c) for c in range(0xFE80, 0xFEFD) if c not in covered]
    print("FE80-FEFC complete:", "YES" if not missing else f"NO {missing}")
    print("RANGES:", to_ranges(covered))

#!/usr/bin/env python3
"""Re-proportion an Arabic font so one letter exactly fills one kitty cell.

kitty's REAL model on macOS (verified against kitty v0.45.0 source):
  * A symbol_map font is rendered at the MAIN font's point size
    (core_text.m:514 — the "fit to cell height" argument is UNUSED on macOS).
    So at font_size S on a 1x display, 1 em = S px. Full stop.
  * Text is shaped by HarfBuzz, then split into per-cell render groups; glyphs
    are positioned by cumulative advances *within* a group and every group is
    anchored at its cell origin (fonts.c:1528-1628, core_text.m:1025-1033).
    => the advance must equal cell_width EXACTLY or letters drift/gap.
  * If a group's ink extends past canvas_width + 1 px, kitty SHRINKS that
    glyph's font copy by canvas_width/right — per glyph! (core_text.m:1011-24)
    ...except for bold/italic faces, which are hard-CLIPPED instead.
    => ink may overshoot the cell by at most 1px, in every weight.
  * Vertical overflow is silently clipped; the glyph sits on the MAIN font's
    baseline. => all ink must fit between -descent_px and +baseline_px.

Consequences for the transform:
  X: scale outlines so joining ink spans the full cell width (touching both
     edges, overshooting the right edge by < 1px), and set EVERY nonzero
     advance to exactly cell_width-in-units.
  Y: scale + shift so the tallest/deepest rendered ink fits the baseline
     budget. This is anisotropic (letters widen) — inherent: Arabic is
     wide-and-short, a terminal cell is tall-and-narrow.

Usage:
  fit-arabic-to-cell.py <src> <dst> --font-size 20 --cell 13x24 --baseline 19
                        [--dpi-scale 1.0]
The cell and baseline come from `kitty --debug-font-fallback` ("cell_height,
baseline") and screen_px / columns. Re-run this if font_size or the main font
ever changes.
"""

import argparse

from fontTools.misc.transform import Transform
from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.t2CharStringPen import T2CharStringPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont

# What wisp actually puts on screen: presentation forms + the base-block
# characters shaping leaves alone (digits, punctuation, harakat, tatweel).
RENDERED = [(0x0600, 0x06FF), (0xFB50, 0xFDFF), (0xFE70, 0xFEFF)]


def ink_bounds(font, ranges):
    gs, cmap = font.getGlyphSet(), font.getBestCmap()
    lo, hi, right = 10**9, -(10**9), 0
    for a, b in ranges:
        for cp in range(a, b + 1):
            g = cmap.get(cp)
            if not g:
                continue
            bp = BoundsPen(gs)
            gs[g].draw(bp)
            if not bp.bounds:
                continue
            x0, y0, x1, y1 = bp.bounds
            lo, hi, right = min(lo, y0), max(hi, y1), max(right, x1)
    return lo, hi, right


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("src")
    ap.add_argument("dst")
    ap.add_argument("--font-size", type=float, required=True)
    ap.add_argument("--cell", required=True, help="WxH in px, e.g. 13x24")
    ap.add_argument("--baseline", type=float, required=True, help="px from cell top")
    ap.add_argument("--dpi-scale", type=float, default=1.0,
                    help="(dpi_x+dpi_y)/144 as kitty computes it; 1.0 on standard macOS")
    args = ap.parse_args()

    cell_w, cell_h = (float(v) for v in args.cell.split("x"))
    font = TTFont(args.src)
    upm = font["head"].unitsPerEm
    hmtx = font["hmtx"]

    px_per_unit = args.font_size * args.dpi_scale / upm       # 0.02 at 20pt/1000upm
    adv_units = round(cell_w / px_per_unit)                   # 13px -> 650u
    max_right_units = (cell_w + 1) / px_per_unit              # shrink/clip threshold
    asc_budget = args.baseline / px_per_unit                  # ink above baseline
    desc_budget = (cell_h - args.baseline) / px_per_unit      # ink below baseline

    ink_lo, ink_hi, ink_right = ink_bounds(font, RENDERED)

    # X: joining strokes must reach the cell edge; overshoot the advance a
    # touch (guaranteed pixel adjacency) but stay clear of the shrink/clip
    # threshold in EVERY weight. The scale is anchored to the font's STANDARD
    # letter advance (joining ink spans exactly 0..advance in Kawkab), NOT the
    # global max ink — a couple of ornamental ligatures (Allah, ornate parens)
    # have ink far wider than their advance and would otherwise crush every
    # normal letter; those few outliers are left to kitty's per-glyph shrink.
    from collections import Counter
    base_adv = Counter(
        hmtx[g][0] for g in font.getGlyphOrder() if hmtx[g][0] > 0
    ).most_common(1)[0][0]
    target_right = min(adv_units + 0.4 / px_per_unit, max_right_units - 10)
    sx = target_right / base_adv

    # Y: compress the total ink into the baseline budget and shift so nothing
    # crosses either edge (kitty clips silently).
    sy = min(1.0, (asc_budget + desc_budget - 4) / (ink_hi - ink_lo))
    dy = -desc_budget - ink_lo * sy + 2
    dy = min(dy, asc_budget - ink_hi * sy - 2)

    print(f"src {args.src.rsplit('/', 1)[-1]}: upm={upm} base_adv={base_adv} "
          f"ink x..{ink_right:.0f} y {ink_lo:.0f}..{ink_hi:.0f}")
    print(f"cell {cell_w:.0f}x{cell_h:.0f}@{args.font_size:.0f}pt -> adv={adv_units}u "
          f"ink_right<={max_right_units:.0f}u asc<={asc_budget:.0f}u desc<={desc_budget:.0f}u")
    print(f"transform: sx={sx:.4f} sy={sy:.4f} dy={dy:+.0f}u")

    glyph_set = font.getGlyphSet()
    cff = font["CFF "].cff
    top = cff.topDictIndex[0]
    charstrings, private = top.CharStrings, top.Private
    xform = Transform(sx, 0, 0, sy, 0, dy)

    bounds = [10**9, 10**9, -(10**9), -(10**9)]
    for name in font.getGlyphOrder():
        old_adv, _ = hmtx[name]
        # Combining marks keep zero advance; everything else gets one cell.
        new_adv = 0 if old_adv == 0 else adv_units
        pen = T2CharStringPen(new_adv, glyph_set)
        glyph_set[name].draw(TransformPen(pen, xform))
        charstrings[name] = pen.getCharString(private=private, globalSubrs=cff.GlobalSubrs)

        bp = BoundsPen(glyph_set)
        glyph_set[name].draw(TransformPen(bp, xform))
        lsb = round(bp.bounds[0]) if bp.bounds else 0
        hmtx[name] = (new_adv, lsb)
        if bp.bounds:
            x0, y0, x1, y1 = bp.bounds
            bounds = [min(bounds[0], x0), min(bounds[1], y0), max(bounds[2], x1), max(bounds[3], y1)]

    private.defaultWidthX = adv_units
    private.nominalWidthX = 0

    # Cosmetic on macOS/kitty (sizing ignores these) but keeps other renderers
    # and font pickers sane.
    hhea, os2, head = font["hhea"], font["OS/2"], font["head"]
    hhea.ascent, hhea.descent, hhea.lineGap = round(asc_budget), -round(desc_budget), 0
    hhea.advanceWidthMax = adv_units
    os2.sTypoAscender, os2.sTypoDescender, os2.sTypoLineGap = round(asc_budget), -round(desc_budget), 0
    os2.usWinAscent, os2.usWinDescent = round(asc_budget), round(desc_budget)
    if os2.version < 4:
        os2.version = 4
    os2.fsSelection |= 1 << 7
    os2.xAvgCharWidth = adv_units
    fb = [round(v) for v in bounds]
    head.xMin, head.yMin, head.xMax, head.yMax = fb
    top.FontBBox = fb

    font.save(args.dst)

    # Verify against kitty's actual rules — pass/fail on the LETTER forms
    # (U+FE80-FEFC is everything wisp emits for Arabic words); ornamental
    # ligatures wider than a cell are reported but non-fatal (kitty shrinks
    # those individually, which is fine for standalone symbols).
    chk = TTFont(args.dst)
    lo2, hi2, right2 = ink_bounds(chk, [(0xFE80, 0xFEFC)])
    adv2 = chk["hmtx"][chk.getBestCmap()[0xFEE4]][0]
    ok_adv = adv2 == adv_units
    ok_right = right2 <= max_right_units
    ok_v = lo2 >= -desc_budget - 1 and hi2 <= asc_budget + 1
    reach = right2 >= adv_units
    print(f"VERIFY letters: adv={adv2}({'OK' if ok_adv else 'BAD'}) "
          f"ink_right={right2:.0f} ({'reaches edge' if reach else 'SHORT!'}, "
          f"{'no shrink/clip' if ok_right else 'TRIPS SHRINK!'}) "
          f"y {lo2:.0f}..{hi2:.0f} ({'fits cell' if ok_v else 'CLIPS!'})")
    gs2, cmap2 = chk.getGlyphSet(), chk.getBestCmap()
    wide = []
    for a, b in RENDERED:
        for cp in range(a, b + 1):
            g = cmap2.get(cp)
            if not g:
                continue
            bp = BoundsPen(gs2)
            gs2[g].draw(bp)
            if bp.bounds and bp.bounds[2] > max_right_units:
                wide.append(f"U+{cp:04X}")
    if wide:
        print(f"  note: {len(wide)} ornamental glyph(s) wider than a cell "
              f"(kitty shrinks each individually): {' '.join(wide[:8])}")
    if not (ok_adv and ok_right and ok_v and reach):
        raise SystemExit(1)


if __name__ == "__main__":
    main()

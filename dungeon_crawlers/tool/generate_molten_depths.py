"""Generates the art and map for Level 2, "The Molten Depths".

Run from the `dungeon_crawlers` folder:

    python tool/generate_molten_depths.py [--preview path/to/preview.png]

Writes (overwriting) into `assets/images/molten_depths/`:
  - spritesheet.png    Night Vault tiles recolored to basalt, plus new lava tiles
  - map.json           SpriteFusion-format map built from LAYOUT below

Lava is a solid (collider) layer, so it blocks the player like a wall. Its
texture spans 2x2 tiles (ids 8-11) so the pattern doesn't repeat on every tile.

Wall and floor tiles are picked automatically. The script learns from the
Night Vault map which tile goes with each 3x3 floor/wall pattern, so the new
map follows the same tiling rules. To change the level, edit LAYOUT and run
the script again. Only the Python standard library is needed.
"""
import colorsys
import json
import math
import os
import random
import struct
import sys
import zlib
from collections import Counter, defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC_DIR = os.path.join(ROOT, 'assets', 'images', 'night_vault')
OUT_DIR = os.path.join(ROOT, 'assets', 'images', 'molten_depths')
T = 24  # tile size in pixels

# ---------------------------------------------------------------------------
# Layout. North is up; the player starts at '@' and works north.
#
#   #  wall / solid rock          .  floor          ,  obsidian floor
#   ~  lava (solid)               v  floor vent grate (decoration)
#   @  spawn (floor)
#   Props (solid):  T torch   B red banner   P pillar top   p pillar base
#                   U brazier bowl   C chest   R barrel   K crate
#                   F forge fire (top half)  f forge fire (bottom half)
# ---------------------------------------------------------------------------
LAYOUT = r"""
########################################################
########################################################
########################################################
####################T..B..T....FF....T..B..T############
####################~~......C..ff..C......~~############
####################~~~..................~~~############
####################~~~..P.....v......P..~~~############
####################~~~..p...v....v...p..~~~############
####################~~~..................~~~############
####################~~~.......U..U.......~~~############
####################~~~....v........v....~~~############
####################~~~..................~~~############
####################~~~..P............P..~~~############
####################~~~..p...v....v...p..~~~############
####################~~~.........v........~~~############
####################~~~..................~~~############
####################~~~..................~~~############
###############################..#######################
###############################..#######################
###############################..#######################
##############################....######################
####.T......T......T......T.........T.##################
####~~~~~~~~~~~~~~~~~~~~~~~~~~~..~~~~~##################
####~~~~~~~~~~~~~~~~~~~~~~~~~~~..~~~~~##################
####~~~~~~~~~~~~~~~~.............~~~~~##################
####~~~~~~~~~~~~~~~~.............~~~~~##################
####~~~~~~~~~..C..~~..~~~~~~~~~~~~..~~##################
####~~~~~~~~~.........~~~~~~~~~~~~..~~##################
####~~~~~~~~~R...K....~~~~~~~~~~~~~~~~##################
####~~~~~~~~~~~~~~~~...........~~~~~~~##################
####~~~~~~~..~~~~~~~...........~~~~~~~##################
####~~~~~~~..~~~~~~~~~~~~~~~~..~~~~~~~##################
####~~~~~~~~~~~~~~~~~~~~~~~~~..~~~~~~~##################
####~~~~.......................~~~~~~~##################
####~~~~.......................~~~~~~~##################
####~~~~..~~~~~~~~~~~~~~~~~~~~~~~~~~~~##################
####~~~~..~~~~~~~~~~~~~~~..~~~~~~~~~~~##################
####~~~~..~~~~~~~~~~~~~~~..~~~~~~~~~~~##################
####~~~~..~~~~~~~~~~~~~~~~~~~~~~~~~~~~##################
########..##############################################
########..##############################################
########..##############################################
########..##############################################
#######....#############################################
####.T.........T.......T.......T..........T.############
####........v...v...v...v...v...v...v.......############
####........v...v...v...v...v...v...v.......############
####........v...v...v...v...v...v...v.......############
####........v...v...v...v...v...v...v.......############
#######################################..###############
#######################################..###############
#######################################..###############
#######################################..###############
######################################....##############
############################..B.....T.......T....B..####
############################~~....................~~####
############################~~....................~~####
############################~~~~~..~~~~~~~~~~~~~~~~~####
############################~~~~~..~~~~~~~~~~~~~~~~~####
############################~~~~~..~~~~~~~~~~~~~~~~~####
############################~~~~~..~~~~~~~~~~~~~~~~~####
############################~......................~####
############################........................####
############################R......................K####
##############################################..########
##############################################..########
##############################################..########
#############################################....#######
##########################################T,B,,,,B,T####
##########################################,,,,,,,,,R####
##########################################,,,,,,,,,,####
##########################################,,,,,,,,,,####
##########################################,,,,@,,,,,####
##########################################,,,,,,,,,,####
##########################################,,,,,,,,,,####
##########################################K,,,,,,,,R####
########################################################
########################################################
"""

PROP_IDS = {
    'T': 0, 'B': 4, 'P': 5, 'p': 6, 'U': 7, 'C': 13,
    'F': 14, 'f': 15, 'K': 16, 'R': 17,
}
WALKABLE = set('.,~v@') | set(PROP_IDS)

# New tiles drawn into spritesheet slots this map doesn't use. The lava texture
# covers 2x2 tiles: ids 8 9 on top, 10 11 below (the Night Vault's trap slots).
LAVA_IDS = (8, 9, 10, 11)
VENT_ID, OBSIDIAN_ID = 59, 61
CRACKED_IDS = (60, 62, 63)  # glowing-crack floor variants, used beside lava
# Night Vault tiles that get the basalt recolor (terrain + stone props).
RECOLOR_IDS = set(range(20, 58)) | {5, 6, 7}
# Plain interior floor tiles (eligible for cracked/obsidian swaps).
PLAIN_FLOOR = {30, 32, 33, 41, 43}


# --------------------------------------------------------------------- PNG io
def read_png(path):
    """Reads an 8-bit RGBA, non-interlaced PNG into rows of (r, g, b, a)."""
    data = open(path, 'rb').read()
    i, idat, w, h = 8, b'', 0, 0
    while i < len(data):
        n, = struct.unpack('>I', data[i:i + 4])
        kind, body = data[i + 4:i + 8], data[i + 8:i + 8 + n]
        if kind == b'IHDR':
            w, h, depth, color, _, _, interlace = struct.unpack('>IIBBBBB', body)
            if (depth, color, interlace) != (8, 6, 0):
                sys.exit(f'{path}: only 8-bit RGBA non-interlaced PNGs are supported')
        elif kind == b'IDAT':
            idat += body
        i += 12 + n
    raw, stride, rows = zlib.decompress(idat), w * 4, []
    prev, p = bytearray(stride), 0
    for _ in range(h):
        f, line = raw[p], bytearray(raw[p + 1:p + 1 + stride])
        p += 1 + stride
        for x in range(stride):
            a = line[x - 4] if x >= 4 else 0
            c = prev[x - 4] if x >= 4 else 0
            b = prev[x]
            if f == 1:
                line[x] = (line[x] + a) & 255
            elif f == 2:
                line[x] = (line[x] + b) & 255
            elif f == 3:
                line[x] = (line[x] + ((a + b) >> 1)) & 255
            elif f == 4:
                pp = a + b - c
                pa, pb, pc = abs(pp - a), abs(pp - b), abs(pp - c)
                line[x] = (line[x] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
        rows.append([tuple(line[k:k + 4]) for k in range(0, stride, 4)])
        prev = line
    return rows


def write_png(path, rows):
    raw = b''.join(b'\x00' + bytes(v for px in r for v in px) for r in rows)

    def chunk(kind, body):
        return struct.pack('>I', len(body)) + kind + body + struct.pack('>I', zlib.crc32(kind + body))

    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n'
                + chunk(b'IHDR', struct.pack('>IIBBBBB', len(rows[0]), len(rows), 8, 6, 0, 0, 0))
                + chunk(b'IDAT', zlib.compress(raw, 9))
                + chunk(b'IEND', b''))


def blank(w, h):
    return [[(0, 0, 0, 0)] * w for _ in range(h)]


def get_tile(sheet, tid):
    r, c = divmod(tid, 8)
    return [row[c * T:(c + 1) * T] for row in sheet[r * T:(r + 1) * T]]


def put_tile(sheet, tid, tile):
    r, c = divmod(tid, 8)
    for y in range(T):
        sheet[r * T + y][c * T:(c + 1) * T] = tile[y]


def blend(dst, src):
    a = src[3] / 255
    if a == 0:
        return dst
    return tuple(round(src[k] * a + dst[k] * (1 - a)) for k in range(3)) + (max(dst[3], src[3]),)


# ------------------------------------------------------------------ the art
LAVA_RAMP = [(92, 14, 10), (150, 28, 12), (206, 62, 16), (242, 118, 28), (255, 186, 64), (255, 236, 150)]
LAVA_PERIOD = 2 * T  # lava texture repeats every 2x2 tiles


def recolor(px, floor_like):
    """Shifts a Night Vault pixel to warm basalt; red floor flecks become embers."""
    r, g, b, a = px
    if a == 0:
        return px
    h, l, s = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
    if floor_like and s > 0.25 and (h < 0.05 or h > 0.85) and l > 0.25:
        return (236, 104, 34, a)  # ember fleck
    if floor_like:
        h2, l2, s2 = 0.025, l * 0.78, min(1.0, s * 0.35 + 0.14)
    else:
        h2, l2, s2 = 0.04, l * 0.86, min(1.0, s * 0.45 + 0.20)
    r2, g2, b2 = colorsys.hls_to_rgb(h2, l2, s2)
    return (round(r2 * 255), round(g2 * 255), round(b2 * 255), a)


def lava_texture():
    """Seamless 48x48 lava. Every wave has a whole number of periods across the
    texture, so neighbouring tiles join up."""
    t = 0.0
    p = LAVA_PERIOD
    tex = []
    for y in range(p):
        row = []
        for x in range(p):
            v = 2 * math.pi * y / p
            u = 2 * math.pi * x / p + 0.55 * math.sin(2 * v + t)  # slow sideways warp
            n = (math.sin(u + v + t)
                 + 0.75 * math.sin(2 * u - v + 1.7 - t)
                 + 0.45 * math.sin(u - 2 * v + 4.1 + t)
                 + 0.2 * math.sin(3 * u + 2 * v + 0.9 - 2 * t))
            n = (n + 2.4) / 4.8  # roughly 0..1
            # Mostly orange, dark crust in the troughs, hot spots on the peaks.
            idx = 0 if n < 0.2 else 1 if n < 0.3 else 2 if n < 0.47 else 3 if n < 0.68 else 4 if n < 0.84 else 5
            row.append(LAVA_RAMP[idx] + (255,))
        tex.append(row)
    return tex


def vent_tile():
    """Iron floor grate in a stone ring, with a few embers glowing inside."""
    cx = cy = (T - 1) / 2
    tile = blank(T, T)
    for y in range(T):
        for x in range(T):
            d = math.hypot(x - cx, y - cy)
            if d > 10.5:
                continue
            if d > 8.5:
                shade = (112 if (x + y) % 5 else 132) + (18 if y < cy - 4 else 0)
                tile[y][x] = (shade, shade - 26, shade - 34, 255)
            elif x % 4 in (0, 1) or y % 4 in (0, 1):
                tile[y][x] = (60, 41, 38, 255)  # grate bars
            else:
                tile[y][x] = (24, 10, 10, 255)  # dark holes
    for x, y in ((10, 11), (14, 11), (11, 14)):
        tile[y][x] = (190, 60, 20, 255)
    return tile


def cracked_tile(floor, seed):
    """Basalt floor with a glowing crack, used on floor next to lava."""
    tile = [row[:] for row in floor]
    rnd = random.Random(seed)
    for _ in range(rnd.randint(1, 2)):
        x, y = rnd.randint(3, 20), rnd.randint(3, 20)
        step = rnd.choice((-1, 1))
        for _ in range(rnd.randint(7, 12)):
            tile[y][x] = (232, 100, 32, 255)
            if y + 1 < T:
                tile[y + 1][x] = (120, 34, 16, 255)  # dim underside
            x = max(1, min(T - 2, x + rnd.choice((step, step, 0))))
            y = max(1, min(T - 2, y + rnd.choice((-1, 0, 1))))
    return tile


def obsidian_tile(floor):
    """Glassy cooled-lava floor for the safe spawn room."""
    rnd = random.Random(5)
    tile = [[(round((r + g + b) / 6) + 8, round((r + g + b) / 6) + 2, round((r + g + b) / 6) + 6, a)
             for r, g, b, a in row] for row in floor]
    for _ in range(4):  # a few short glassy glints
        x, y = rnd.randint(2, 19), rnd.randint(2, 21)
        for k in range(rnd.randint(2, 4)):
            r, g, b, a = tile[y][x + k]
            tile[y][x + k] = (r + 34, g + 30, b + 38, a)
    return tile


def build_art():
    sheet = read_png(os.path.join(SRC_DIR, 'spritesheet.png'))
    # Walkable tiles that show stone floor. The walkable brick wall-face tiles
    # (23, 24, 25, 34, 35, 37, 39) get the wall palette so they match the wall.
    floor_ids = {26, 27, 28, 29, 30, 31, 32, 33, 38, 41, 42, 43, 44}
    for tid in RECOLOR_IDS:
        tile = [[recolor(px, tid in floor_ids) for px in row] for row in get_tile(sheet, tid)]
        put_tile(sheet, tid, tile)
    for tid in (8, 9, 10, 11, 18, 19, *range(58, 64)):  # trap tiles aren't used here
        put_tile(sheet, tid, blank(T, T))
    lava = lava_texture()
    for i, tid in enumerate(LAVA_IDS):
        qx, qy = (i % 2) * T, (i // 2) * T
        put_tile(sheet, tid, [row[qx:qx + T] for row in lava[qy:qy + T]])
    put_tile(sheet, VENT_ID, vent_tile())
    for tid, seed in zip(CRACKED_IDS, (11, 23, 37)):
        put_tile(sheet, tid, cracked_tile(get_tile(sheet, 30), seed))
    put_tile(sheet, OBSIDIAN_ID, obsidian_tile(get_tile(sheet, 30)))
    return sheet


# ------------------------------------------------------------------ tiling
def learn_tiling():
    """Maps each 3x3 walkable pattern in the Night Vault to its (base, wall) tile pair."""
    nv = json.load(open(os.path.join(SRC_DIR, 'map.json')))
    layers = {l['name']: {(t['x'], t['y']): int(t['id']) for t in l['tiles']} for l in nv['layers']}
    base, walls = layers['Base'], layers['Layer_1']
    walk = {p for p in base if p not in walls}
    table = defaultdict(Counter)
    for y in range(int(nv['mapHeight'])):
        for x in range(int(nv['mapWidth'])):
            table[signature(walk, x, y)][(base.get((x, y), 51), walls.get((x, y)))] += 1
    return table


def signature(walk, x, y):
    return tuple((x + dx, y + dy) in walk for dy in (-1, 0, 1) for dx in (-1, 0, 1))


# Tiles that are left/right mirror images of each other.
MIRROR = {20: 22, 36: 40, 47: 48, 56: 57, 34: 35, 23: 25, 29: 31, 26: 28, 37: 39}
MIRROR.update({v: k for k, v in MIRROR.items()})


def mirrored(sig):
    return tuple(sig[r * 3 + 2 - c] for r in range(3) for c in range(3))


def pick_tiles(table, sig, rnd):
    counts = table.get(sig)
    fallback = False
    if counts is None and mirrored(sig) in table:
        # The Night Vault only has the mirror image of this pattern: flip its tiles.
        b, w = table[mirrored(sig)].most_common(1)[0][0]
        return (MIRROR.get(b, b), MIRROR.get(w, w) if w is not None else None), False
    if counts is None:
        # Closest learned pattern with the same centre cell.
        fallback = True
        best = min((s for s in table if s[4] == sig[4]),
                   key=lambda s: sum(a != b for a, b in zip(s, sig)))
        counts = table[best]
    if sig == (True,) * 9:
        # Open floor: mostly plain, with a few crack/rubble variants.
        choice = rnd.choices([30, 32, 33, 43, 41], weights=[1202, 52, 67, 29, 11])[0]
        return (choice, None), fallback
    if counts.keys() >= {(21, 21), (53, 53)} and sig[6:] == (True, True, True):
        # Top wall face: mix the two brick variants like the Night Vault does.
        choice = rnd.choices([21, 53], weights=[counts[(21, 21)], counts[(53, 53)]])[0]
        return (choice, choice), fallback
    return counts.most_common(1)[0][0], fallback


# How the Night Vault draws a 2-wide corridor entering a room through its top
# wall: the corridor widens by one tile on each side in the wall row, and the
# brick wall face ends in a clean edge either side. Keyed by (dx, dy) from the
# corridor's left column (dx=0) and the room's wall row (dy=0); values are
# (base tile, wall tile or None).
TOP_ENTRY_TILES = {
    (-2, -1): (51, 51), (-1, -1): (20, 20), (2, -1): (40, 40), (3, -1): (51, 51),
    (-2, 0): (53, 53), (-1, 0): (34, None), (0, 0): (29, None),
    (1, 0): (31, None), (2, 0): (35, None), (3, 0): (53, 53),
    (-2, 1): (24, None), (-1, 1): (37, None), (0, 1): (29, None),
    (1, 1): (31, None), (2, 1): (39, None), (3, 1): (24, None),
}


def find_top_entries(walk, width, height):
    """Finds widened corridor entries: corridor cells (x, y-1) and (x+1, y-1)
    open into a 4-wide gap (x-1..x+2) in the wall row y of a room below."""
    entries = []
    for y in range(1, height - 1):
        for x in range(2, width - 3):
            if ((x, y - 1) in walk and (x + 1, y - 1) in walk
                    and (x - 1, y - 1) not in walk and (x + 2, y - 1) not in walk
                    and all((x + d, y) in walk for d in (-1, 0, 1, 2))
                    and (x - 2, y) not in walk and (x + 3, y) not in walk
                    and (x - 2, y + 1) in walk and (x + 3, y + 1) in walk):
                entries.append((x, y))
    return entries


def build_map():
    rows = [r for r in LAYOUT.strip('\n').split('\n')]
    width = max(len(r) for r in rows)
    rows = [r.ljust(width, '#') for r in rows]
    height = len(rows)
    grid = {(x, y): ch for y, r in enumerate(rows) for x, ch in enumerate(r)}
    walk = {p for p, ch in grid.items() if ch in WALKABLE}
    table = learn_tiling()
    rnd = random.Random(2026)

    overrides = {}
    for ex, ey in find_top_entries(walk, width, height):
        for (dx, dy), tiles in TOP_ENTRY_TILES.items():
            overrides[(ex + dx, ey + dy)] = tiles

    base, walls, lava, vents, props = [], [], [], [], []
    spawn, fallbacks = None, 0
    for y in range(height):
        for x in range(width):
            ch = grid[(x, y)]
            (b, w), fb = pick_tiles(table, signature(walk, x, y), rnd)
            if (x, y) in overrides:
                (b, w), fb = overrides[(x, y)], False
            fallbacks += fb
            if ch in ',@' and b in PLAIN_FLOOR:
                b = OBSIDIAN_ID
            elif ch in WALKABLE and ch not in '~,' and b in PLAIN_FLOOR and any(
                    grid.get((x + dx, y + dy)) == '~' for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))
            ) and rnd.random() < 0.6:
                b = rnd.choice(CRACKED_IDS)
            base.append((b, x, y))
            if w is not None:
                walls.append((w, x, y))
            if ch == '~':
                lava.append((LAVA_IDS[x % 2 + 2 * (y % 2)], x, y))
            elif ch == 'v':
                vents.append((VENT_ID, x, y))
            elif ch in PROP_IDS:
                props.append((PROP_IDS[ch], x, y))
            elif ch == '@':
                spawn = (x, y)

    def layer(name, tiles, collider):
        return {'name': name, 'collider': collider,
                'tiles': [{'id': str(i), 'x': x, 'y': y} for i, x, y in tiles]}

    data = {
        'tileSize': T, 'mapWidth': width, 'mapHeight': height,
        'layers': [
            layer('Props', props, True),
            layer('Vents', vents, False),
            layer('Lava', lava, True),
            layer('Layer_1', walls, True),
            layer('Base', base, False),
        ],
    }
    return data, spawn, fallbacks


# ----------------------------------------------------------------- preview
def render_preview(data, sheet, path, scale=1):
    w, h = int(data['mapWidth']) * T, int(data['mapHeight']) * T
    img = [[(0, 0, 0, 255)] * w for _ in range(h)]
    for layer in reversed(data['layers']):
        for t in layer['tiles']:
            ox, oy = t['x'] * T, t['y'] * T
            tile = get_tile(sheet, int(t['id']))
            for y in range(T):
                for x in range(T):
                    img[oy + y][ox + x] = blend(img[oy + y][ox + x], tile[y][x])
    if scale != 1:
        img = [[img[y * h // (h * scale)][x // scale] for x in range(w * scale)] for y in range(h * scale)]
    write_png(path, img)


def main():
    sheet = build_art()
    data, spawn, fallbacks = build_map()
    write_png(os.path.join(OUT_DIR, 'spritesheet.png'), sheet)
    with open(os.path.join(OUT_DIR, 'map.json'), 'w') as f:
        json.dump(data, f, separators=(',', ':'))

    counts = {l['name']: len(l['tiles']) for l in data['layers']}
    print(f"map {data['mapWidth']}x{data['mapHeight']}  layers {counts}")
    print(f'spawn tile {spawn}  ->  Vector2(24 * {spawn[0]}, 24 * {spawn[1]})')
    if fallbacks:
        print(f'note: {fallbacks} cells used a nearest-match wall pattern')
    if '--preview' in sys.argv:
        out = sys.argv[sys.argv.index('--preview') + 1]
        render_preview(data, sheet, out)
        print(f'preview written to {out}')


if __name__ == '__main__':
    main()

"""Generate Magma / Shadow Tiled maps for the Flutter game.

Not used at runtime — run manually when you change ASCII layouts or tiles:

    python tool/generate_tiled_maps.py

Outputs (under assets/images/):

    magma.tmj / shadow.tmj   — orthogonal 16×12 maps Bonfire can load
    tilesets/dungeon_ii.*    — 0x72 Dungeon Tileset II + wall collisions
    tilesets/extras.*        — lava / void / rubble / stairs filler tiles

Why maps sit next to tilesets/ (not in magma/ or shadow/ subfolders):
Flutter's rootBundle does not resolve `../` in asset paths, so Tiled's
usual `../tilesets/foo.tsj` links would fail. Maps reference
`tilesets/dungeon_ii.tsj` from assets/images/ instead.

Bonfire only accepts Tiled JSON (.tmj / .json), not .tmx.
"""

from __future__ import annotations

import json
import os

from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
BASE = os.path.join(ROOT, "assets", "images")
TILESETS = os.path.join(BASE, "tilesets")


def write_extras_png() -> None:
    """Paint a 4-tile strip the 0x72 sheet does not provide (lava, void, etc.)."""
    # 64×16 = four 16×16 tiles side by side: [lava][void][rubble][stairs]
    extras = Image.new("RGBA", (64, 16), (0, 0, 0, 0))

    # Tile 0 — lava (hot orange noise)
    for y in range(16):
        for x in range(16):
            v = (x * 3 + y * 5) % 7
            if v < 3:
                c = (232, 93, 4, 255)
            elif v < 5:
                c = (255, 183, 3, 255)
            else:
                c = (157, 42, 2, 255)
            extras.putpixel((x, y), c)

    # Tile 1 — void pit (purple diamond for Shadow)
    for y in range(16):
        for x in range(16):
            d = abs(x - 7.5) + abs(y - 7.5)
            if d < 4:
                c = (20, 8, 40, 255)
            elif d < 7:
                c = (76, 29, 149, 255)
            else:
                c = (42, 31, 61, 255)
            extras.putpixel((16 + x, y), c)

    # Tile 2 — rubble / ash (walkable decor)
    for y in range(16):
        for x in range(16):
            base_c = (92, 64, 51, 255) if (x + y) % 3 else (72, 50, 40, 255)
            extras.putpixel((32 + x, y), base_c)

    # Tile 3 — stairs marker (gold plate; also mirrored by a Tiled object)
    for y in range(16):
        for x in range(16):
            if 2 <= x <= 13 and 2 <= y <= 13:
                c = (255, 183, 3, 255) if (y // 2) % 2 == 0 else (232, 150, 20, 255)
            else:
                c = (90, 70, 40, 255)
            extras.putpixel((48 + x, y), c)

    extras.save(os.path.join(TILESETS, "extras.png"))


def collision_objectgroup() -> dict:
    """Full-tile rectangle Bonfire turns into a wall [ShapeHitbox]."""
    return {
        "draworder": "index",
        "name": "",
        "objects": [
            {
                "height": 16,
                "id": 1,
                "name": "",
                "rotation": 0,
                "type": "",
                "visible": True,
                "width": 16,
                "x": 0,
                "y": 0,
            }
        ],
        "opacity": 1,
        "type": "objectgroup",
        "visible": True,
        "x": 0,
        "y": 0,
    }


def write_tilesets() -> None:
    """Write external .tsj files Tiled / Bonfire load alongside the maps."""
    # Local tile ids from 0x72 that look solid; collision boxes make them walls.
    wall_ids = [1, 2, 3, 33, 34, 35, 36, 37, 38]
    dungeon_tsj = {
        "columns": 32,
        "image": "dungeon_ii.png",
        "imageheight": 512,
        "imagewidth": 512,
        "margin": 0,
        "name": "dungeon_ii",
        "spacing": 0,
        "tilecount": 1024,
        "tiledversion": "1.10.2",
        "tileheight": 16,
        "tilewidth": 16,
        "type": "tileset",
        "version": "1.10",
        "tiles": [{"id": tid, "objectgroup": collision_objectgroup()} for tid in wall_ids],
    }
    with open(os.path.join(TILESETS, "dungeon_ii.tsj"), "w", newline="\n") as f:
        json.dump(dungeon_tsj, f, indent=1)
        f.write("\n")

    extras_tsj = {
        "columns": 4,
        "image": "extras.png",
        "imageheight": 16,
        "imagewidth": 64,
        "margin": 0,
        "name": "extras",
        "spacing": 0,
        "tilecount": 4,
        "tiledversion": "1.10.2",
        "tileheight": 16,
        "tilewidth": 16,
        "type": "tileset",
        "version": "1.10",
    }
    with open(os.path.join(TILESETS, "extras.tsj"), "w", newline="\n") as f:
        json.dump(extras_tsj, f, indent=1)
        f.write("\n")


# Global tile IDs (GIDs) used in layer data arrays.
# dungeon_ii is firstgid=1  → GID = local_id + 1
# extras     is firstgid=1025 → GID = 1025 + local_id (0..3)
FLOOR = 130  # dungeon local 129 — cracked stone floor
WALL = 34  # dungeon local 33 — brick mid-wall (has collision)
LAVA = 1025  # extras 0
VOID = 1026  # extras 1
RUBBLE = 1027  # extras 2
STAIRS = 1028  # extras 3

# Same symbol legend as lib/maps/dungeon_tiles.dart matrixFromArt:
#   # wall   . floor   ~/^ hazard   , rubble   X stairs
MAGMA_ART = [
    "################",
    "#..............#",
    "#..##..~~..##..#",
    "#......~~......#",
    "#..#..~~~~..#..#",
    "#..#..~~~~..#..#",
    "#......~~......#",
    "#..,,..~~..,,..#",
    "#..##......##..#",
    "#..............#",
    "#.......X......#",
    "################",
]

SHADOW_ART = [
    "################",
    "#......X.......#",
    "#..............#",
    "#..##......##..#",
    "#..............#",
    "#....^^..^^....#",
    "#..,,......,,..#",
    "#....^^..^^....#",
    "#..............#",
    "#..##......##..#",
    "#..............#",
    "################",
]


def layers_from_art(art: list[str], hazard_gid: int):
    """Turn ASCII rows into four tile layers + an optional stairs object.

    Walls always sit on floor so the brick tiles do not leave holes. Hazards
    and decor are separate layers so they can be tinted or wired to gameplay
    later without repainting the ground.
    """
    h, w = len(art), len(art[0])
    ground: list[int] = []
    walls: list[int] = []
    hazards: list[int] = []
    decor: list[int] = []
    stairs_obj = None
    for y, row in enumerate(art):
        for x, ch in enumerate(row):
            if ch == "#":
                ground.append(FLOOR)
                walls.append(WALL)
                hazards.append(0)
                decor.append(0)
            elif ch == ".":
                ground.append(FLOOR)
                walls.append(0)
                hazards.append(0)
                decor.append(0)
            elif ch in ("~", "^"):
                ground.append(FLOOR)
                walls.append(0)
                hazards.append(hazard_gid)
                decor.append(0)
            elif ch == ",":
                ground.append(FLOOR)
                walls.append(0)
                hazards.append(0)
                decor.append(RUBBLE)
            elif ch == "X":
                ground.append(FLOOR)
                walls.append(0)
                hazards.append(0)
                decor.append(STAIRS)
                # Object name "stairs" is what Bonfire objectsBuilder keys on.
                stairs_obj = {
                    "height": 16,
                    "id": 1,
                    "name": "stairs",
                    "rotation": 0,
                    "type": "",
                    "visible": True,
                    "width": 16,
                    "x": x * 16,
                    "y": y * 16,
                }
            else:
                raise ValueError(f"Unknown art symbol: {ch!r}")
    return w, h, ground, walls, hazards, decor, stairs_obj


def write_map(path: str, art: list[str], hazard_gid: int) -> None:
    """Write one .tmj map: ground / walls / hazards / decor + markers objects."""
    w, h, ground, walls, hazards, decor, stairs_obj = layers_from_art(art, hazard_gid)
    tmj = {
        "compressionlevel": -1,
        "height": h,
        "infinite": False,
        "layers": [
            {
                "data": ground,
                "height": h,
                "id": 1,
                "name": "ground",
                "opacity": 1,
                "type": "tilelayer",
                "visible": True,
                "width": w,
                "x": 0,
                "y": 0,
            },
            {
                "data": walls,
                "height": h,
                "id": 2,
                "name": "walls",
                "opacity": 1,
                "type": "tilelayer",
                "visible": True,
                "width": w,
                "x": 0,
                "y": 0,
            },
            {
                "data": hazards,
                "height": h,
                "id": 3,
                "name": "hazards",
                "opacity": 1,
                "type": "tilelayer",
                "visible": True,
                "width": w,
                "x": 0,
                "y": 0,
            },
            {
                "data": decor,
                "height": h,
                "id": 4,
                "name": "decor",
                "opacity": 1,
                "type": "tilelayer",
                "visible": True,
                "width": w,
                "x": 0,
                "y": 0,
            },
            {
                "draworder": "topdown",
                "id": 5,
                "name": "markers",
                "objects": [stairs_obj] if stairs_obj else [],
                "opacity": 1,
                "type": "objectgroup",
                "visible": True,
                "x": 0,
                "y": 0,
            },
        ],
        "nextlayerid": 6,
        "nextobjectid": 2,
        "orientation": "orthogonal",
        "renderorder": "right-down",
        "tiledversion": "1.10.2",
        "tileheight": 16,
        # Paths are relative to this .tmj (in assets/images/).
        "tilesets": [
            {"firstgid": 1, "source": "tilesets/dungeon_ii.tsj"},
            {"firstgid": 1025, "source": "tilesets/extras.tsj"},
        ],
        "tilewidth": 16,
        "type": "map",
        "version": "1.10",
        "width": w,
    }
    with open(path, "w", newline="\n") as f:
        json.dump(tmj, f, indent=1)
        f.write("\n")
    print("wrote", path, "stairs=", stairs_obj)


def main() -> None:
    os.makedirs(TILESETS, exist_ok=True)
    write_extras_png()
    write_tilesets()
    write_map(os.path.join(BASE, "magma.tmj"), MAGMA_ART, LAVA)
    write_map(os.path.join(BASE, "shadow.tmj"), SHADOW_ART, VOID)


if __name__ == "__main__":
    main()

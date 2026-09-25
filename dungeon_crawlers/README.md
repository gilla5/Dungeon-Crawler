# dungeon_crawlers

Flutter + [Bonfire](https://pub.dev/packages/bonfire) dungeon crawler with four
levels: Cave and Crypt (ASCII → matrix tiles) plus Magma and Shadow (Tiled
`.tmj` maps).

## Run

```bash
cd dungeon_crawlers
flutter pub get
flutter run
```

## Analyze and test

```bash
flutter analyze
flutter test
```

## Regenerate Magma / Shadow Tiled maps

Maps and filler tilesets are produced by a Python script (not used at runtime):

```bash
pip install -r tool/requirements.txt
python tool/generate_tiled_maps.py
```

Outputs land under `assets/images/` (`magma.tmj`, `shadow.tmj`, and
`tilesets/`). Bonfire resolves `WorldMapReader.fromAsset` paths relative to
`assets/images/`, so map files sit next to `tilesets/` (not in nested folders)
— Flutter's asset loader does not resolve `../` in Tiled tileset links.

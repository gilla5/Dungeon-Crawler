// App entry point for the Bonfire dungeon crawler.
import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  // Required before runApp when the tree (or plugins) touch platform channels
  // during startup — e.g. loading Tiled map assets via the asset bundle.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

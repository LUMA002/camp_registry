import 'package:flutter/material.dart';
import 'package:camp_registry/app/app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // for desktop (Windows, macOS, Linux)
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const MyApp());
}


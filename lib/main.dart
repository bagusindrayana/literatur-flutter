import 'dart:convert';
import 'dart:io';

import 'package:Literatur/models/Book.dart';
import 'package:Literatur/pages/ViewBookPage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:epubx/epubx.dart';
import 'package:logger/logger.dart';
import 'package:Literatur/pages/BookPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        print(settings.name);
        if (settings.name == "/view") {
          final args = settings.arguments as Book;
          return MaterialPageRoute(
            builder: (context) {
              return ViewBookPage(
                book: args,
              );
            },
          );
        }
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
      routes: {'/': (context) => const HomePage()},
    );
  }
}

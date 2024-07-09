import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:Literatur/models/Book.dart';
import 'package:Literatur/models/Translate.dart';
import 'package:Literatur/pages/EditTranslateBookPage.dart';
import 'package:Literatur/pages/TranslateBookPage.dart';
import 'package:Literatur/pages/ViewBookPage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:logger/logger.dart';
import 'package:Literatur/pages/BookPage.dart';

void main() {
  Gemini.init(apiKey: 'AIzaSyCijsbFwjSHKQpsNakJZWdlX6vNSS3DBfY');
  runApp(MyApp());
}

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
        } else if (settings.name == "/translate-book") {
          final args = settings.arguments as Book;
          return MaterialPageRoute(
            builder: (context) {
              return TranslateBookPage(
                book: args,
              );
            },
          );
        } else if (settings.name == "/edit-translate-book") {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return EditTranslateBookPage(
                book: args['book'] as Book,
                translate: args['translate'] as Translate,
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

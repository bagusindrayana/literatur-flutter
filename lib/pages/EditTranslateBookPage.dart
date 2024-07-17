import 'dart:io';
import 'dart:math';

import 'package:Literatur/helpers/TranslateHelper.dart';
import 'package:Literatur/helpers/UIHelper.dart';
import 'package:Literatur/models/Book.dart';
import 'package:Literatur/models/Translate.dart';
import 'package:Literatur/repositories/BookRepository.dart';
import 'package:Literatur/repositories/TranslateRepository.dart';
import 'package:Literatur/widgets/ChapterContentList.dart';
import 'package:flutter/material.dart';
import 'package:jieba_flutter/analysis/jieba_segmenter.dart';
import 'package:logger/logger.dart';
import 'package:japanese_word_tokenizer/japanese_word_tokenizer.dart'
    as jw_tokenizer;

enum TranslateStatus { loading, finish, error, none }

class EditTranslateBookPage extends StatefulWidget {
  final Book book;
  final Translate translate;
  const EditTranslateBookPage(
      {super.key, required this.book, required this.translate});

  @override
  State<EditTranslateBookPage> createState() => _EditTranslateBookPageState();
}

class _EditTranslateBookPageState extends State<EditTranslateBookPage> {
  TranslateRepository _translateRepository = TranslateRepository();
  BookRepository _bookRepository = BookRepository();
  TranslateStatus _status = TranslateStatus.none;
  List<String> providers = Translatehelper.providers;

  String provider = 'Gemini';

  void deleteTranslate() async {
    await _translateRepository.deleteTranslate(widget.translate.id);
    //remove chapters from book with translateId
    List<Chapter> chapters = [];
    chapters.addAll(widget.book.chapters);
    chapters
        .removeWhere((element) => element.translateId == widget.translate.id);
    widget.book.chapters = chapters;
    await _bookRepository.updateBook(widget.book.id, widget.book);

    Navigator.of(context).pop();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit : ${widget.book.title}'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              deleteTranslate();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
                "From ${widget.translate.fromLanguage} to ${widget.translate.toLanguage}"),
          ),
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Provider :"),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: Text('Provider'),
                    value: provider,
                    items: providers.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        provider = value!;
                      });
                    },
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          ChapterContentList(
            provider: provider,
            book: widget.book,
            translate: widget.translate,
            onTranslate: () {
              setState(() {
                _status = TranslateStatus.loading;
              });
            },
            onSuccess: (v) {
              setState(() {
                _status = TranslateStatus.finish;
              });
            },
            onError: (e) {
              setState(() {
                _status = TranslateStatus.error;
              });
            },
          ),
          const SizedBox(
            height: 8,
          ),
        ],
      )),
    );
  }
}

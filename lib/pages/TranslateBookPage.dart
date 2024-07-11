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
import 'package:epubx/epubx.dart';
import 'package:html/parser.dart';
import 'package:logger/logger.dart';
import 'package:japanese_word_tokenizer/japanese_word_tokenizer.dart'
    as jw_tokenizer;
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;

enum TranslateStatus { loading, finish, error, none }

class TranslateBookPage extends StatefulWidget {
  final Book book;
  const TranslateBookPage({super.key, required this.book});

  @override
  State<TranslateBookPage> createState() => _TranslateBookPageState();
}

class _TranslateBookPageState extends State<TranslateBookPage> {
  List<String> language = Translatehelper.languages;

  List<String> providers = Translatehelper.providers;
  String fromLanguage = 'English';
  String toLanguage = 'Indonesian';
  String provider = 'Gemini';
  TextEditingController _prePromptController = TextEditingController();

  BookRepository _bookRepository = BookRepository();
  TranslateRepository _translateRepository = TranslateRepository();
  Translate newTranslate = Translate();

  TranslateStatus _translateStatus = TranslateStatus.none;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      newTranslate.bookId = widget.book.id;
      newTranslate.fromLanguage = fromLanguage;
      newTranslate.toLanguage = toLanguage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Translate : ${widget.book.title}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("From Language :"),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text('From Language'),
                      value: fromLanguage,
                      items: language.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          fromLanguage = value!;
                          newTranslate.fromLanguage = fromLanguage;
                        });
                      },
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Text("To Language :"),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text('To Language'),
                      value: toLanguage,
                      items: language.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          toLanguage = value!;
                          newTranslate.toLanguage = toLanguage;
                        });
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              const Text("Pre Prompt :"),
              const Text(
                "this prompt will be shown to the translator AI. if using google translate, you can use wordlist to prevent the word from being translated with format word1=word2,word3=word4",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              TextField(
                readOnly: _translateStatus == TranslateStatus.loading,
                controller: _prePromptController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                onChanged: (value) {
                  setState(() {
                    newTranslate.prePrompt = value;
                  });
                },
                decoration:
                    const InputDecoration(hintText: 'Input prompt here...'),
              ),
              const SizedBox(
                height: 8,
              ),
              Text("Provider :"),
              Row(
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
              SizedBox(
                height: 8,
              ),
              ChapterContentList(
                provider: provider,
                book: widget.book,
                translate: newTranslate,
                onTranslate: () {
                  setState(() {
                    _translateStatus = TranslateStatus.loading;
                  });
                },
                onSuccess: (v) {
                  setState(() {
                    _translateStatus = TranslateStatus.finish;
                  });
                },
                onError: (e) {
                  setState(() {
                    _translateStatus = TranslateStatus.error;
                  });
                },
              ),
              SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

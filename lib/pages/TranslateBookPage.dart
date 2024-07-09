import 'dart:io';
import 'dart:math';

import 'package:Literatur/helpers/TranslateHelper.dart';
import 'package:Literatur/models/Book.dart';
import 'package:Literatur/models/Translate.dart';
import 'package:Literatur/repositories/BookRepository.dart';
import 'package:Literatur/repositories/TranslateRepository.dart';
import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:html/parser.dart';
import 'package:logger/logger.dart';
import 'package:japanese_word_tokenizer/japanese_word_tokenizer.dart'
    as jw_tokenizer;
import 'package:translator/translator.dart';

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
  Book book = Book();
  List<Chapter> chapters = [];

  Future<List<EpubChapter>> subChapter(EpubChapter epubChapter) async {
    List<EpubChapter> _chapters = [];
    if (epubChapter.SubChapters != null &&
        epubChapter.SubChapters!.isNotEmpty) {
      for (var sub in epubChapter.SubChapters!) {
        _chapters.addAll(await subChapter(sub));
      }
    } else {
      _chapters.add(epubChapter);
    }
    return _chapters;
  }

  Future<List<EpubChapter>> getChapter() async {
    var targetFile = File(widget.book.filePath!);
    var bytes = await targetFile.readAsBytes();
    EpubBook epubBook = await EpubReader.readBook(bytes);

    List<EpubChapter> _chapters = [];
    for (var _chapter in epubBook.Chapters!) {
      _chapters.addAll(await subChapter(_chapter));
    }

    print(chapters.length);

    return _chapters;
  }

  void addTranslate() async {
    _translateStatus = TranslateStatus.loading;
    newTranslate.bookId = book.id;
    newTranslate.prePrompt = _prePromptController.text;
    newTranslate.fromLanguage = fromLanguage;
    newTranslate.toLanguage = toLanguage;
    await _translateRepository.addTranslate(newTranslate);

    var originalChapters = await getChapter();
    var texts = "";
    int order = 0;
    for (var chapter in originalChapters) {
      final document = parse(chapter.HtmlContent);
      final String parsedString =
          parse(document.body!.text).documentElement!.text.trim();

      if (parsedString != "") {
        texts += "${chapter.Title!.trim()} \n";
        final index = book.chapters.indexWhere((element) =>
            element.translateId == newTranslate.id &&
            element.title == chapter.Title);
        if (index != -1) {
          Chapter updateChapter = book.chapters[index];
          updateChapter.order = order;
          updateChapter.prePrompt = _prePromptController.text;
          updateChapter.statusTranslation = 0;
          updateChapter.fromLanguage = fromLanguage;
          // updateChapter.statusTranslation = 0;
          updateChapter.toLanguage = toLanguage;
          _bookRepository.updateChapter(book.id, updateChapter);
        } else {
          Chapter newChapter = Chapter();
          newChapter.order = order;
          newChapter.translateId = newTranslate.id;
          newChapter.title = chapter.Title;
          newChapter.originalContent = parsedString;
          newChapter.prePrompt = _prePromptController.text;
          newChapter.statusTranslation = 0;
          newChapter.fromLanguage = fromLanguage;
          newChapter.toLanguage = toLanguage;
          book.chapters = [...book.chapters, newChapter];
          _bookRepository.addChapter(book.id, newChapter);
        }
      }
      order++;
    }
    getTranslateChapters();
    if (texts == "") {
      _translateStatus = TranslateStatus.error;
      setState(() {});
      return;
    }

    setState(() {});
    Future.delayed(Duration(seconds: 1), () {
      translateTitle(texts);
    });
  }

  void translateTitle(String texts) async {
    int total = chapters.length;
    await Translatehelper.translate(provider, texts, newTranslate.fromLanguage!,
        newTranslate.toLanguage!, "", (String? value) {
      if (value != null) {
        var arr = value.trim().split("\n");
        if (arr.length == total) {
          for (var i = 0; i < total; i++) {
            var chapter = chapters[i];
            chapter.translatedTitle = arr[i];
            _bookRepository.updateChapter(book.id, chapter);
          }
        } else {
          Logger().i(texts);
        }
      }
      setState(() {});
      doTranslate(0, true);
    }, (e) {
      Logger().e(e);
      setState(() {});
      doTranslate(0, true);
    });
  }

  void getTranslateChapters() {
    setState(() {
      chapters = book.chapters
          .where((element) => element.translateId == newTranslate.id)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    });
  }

  void doTranslate(int index, bool next) async {
    int total = chapters.length;

    if (index >= total) {
      setState(() {
        _translateStatus = TranslateStatus.finish;
      });
      return;
    }

    var chapter = chapters[index];

    if (((chapter.statusTranslation == 1 && next) ||
            chapter.originalContent == null ||
            chapter.originalContent == "") &&
        next) {
      doTranslate(index + 1, next);
      return;
    }

    if (!next) {
      setState(() {
        _translateStatus = TranslateStatus.loading;
        chapter.statusTranslation = 0;
      });
    }
    bool chunk = false;
    int maxlength = 2000;
    if (chapter.fromLanguage == "Japanese") {
      maxlength = 1000;
      if (provider != "Gemini") {
        maxlength = 500;
      }
      List<dynamic> tokens = jw_tokenizer.tokenize(chapter.originalContent!);
      if (tokens.length > maxlength) {
        chunk = true;
        //loop
        String resultTranslation = "";
        bool berhasil = false;
        for (var i = 0; i < tokens.length / maxlength; i++) {
          //substring
          int start = i * maxlength;
          int end = ((i + 1) * maxlength);
          print("Start : ${start} End : ${end}");
          String contents = tokens
              .sublist(start, end > tokens.length ? tokens.length : end)
              .join(" ");

          await Translatehelper.translate(
              provider,
              contents,
              chapter.fromLanguage!,
              chapter.toLanguage!,
              chapter.prePrompt!, (String? value) {
            if (value != null) {
              resultTranslation += value;
              berhasil = true;
            } else {
              Logger().e("Null Response");
              berhasil = false;
            }
          }, (e) {
            Logger().e(e);
            berhasil = false;
          });
          Random random = new Random();
          int randomMilisecond = random.nextInt(1000) + 1000;
          await Future.delayed(Duration(milliseconds: randomMilisecond));
        }
        // print("Berhasil : ${berhasil}");
        if (berhasil) {
          // Logger().i("Result Translation : ${resultTranslation}");
          chapter.translatedContent = resultTranslation;
          chapter.statusTranslation = 1;
          _bookRepository.updateChapter(book.id, chapter);
          setState(() {});
          if (next) {
            doTranslate(index + 1, next);
          } else {
            setState(() {
              _translateStatus = TranslateStatus.finish;
            });
          }
        } else {
          chapter.statusTranslation = 2;
          setState(() {});
          if (next) {
            doTranslate(index + 1, next);
          } else {
            setState(() {
              _translateStatus = TranslateStatus.error;
            });
          }
        }
      }
    }

    if (!chunk) {
      await Future.delayed(Duration(seconds: 1));
      await Translatehelper.translate(
          provider,
          chapter.originalContent!,
          chapter.fromLanguage!,
          chapter.toLanguage!,
          chapter.prePrompt!, (String? value) {
        String resultTranslation = "";
        if (value != null) {
          resultTranslation = value;
          chapter.translatedContent = resultTranslation;
          chapter.statusTranslation = 1;
          _bookRepository.updateChapter(book.id, chapter);
        } else {
          Logger().e("Null Response");
          chapter.statusTranslation = 2;
        }
        setState(() {});
        if (next) {
          doTranslate(index + 1, next);
        } else {
          setState(() {
            _translateStatus = TranslateStatus.finish;
          });
        }
      }, (e) {
        Logger().e(e);
        chapter.statusTranslation = 2;
        setState(() {});
        if (next) {
          doTranslate(index + 1, next);
        } else {
          setState(() {
            _translateStatus = TranslateStatus.error;
          });
        }
      });
    }

    int _index = chapters.indexOf(chapter);
    if (_index != -1) {
      setState(() {
        chapters[_index] = chapter;
      });
    }
  }

  void updateChapter(Chapter chapter) {
    _bookRepository.updateChapter(book.id, chapter);
  }

  void detailChapter(Chapter chapter) {
    int index = chapters.indexOf(chapter);

    showDialog(
        context: context,
        //context: _scaffoldKey.currentContext,
        builder: (context) {
          TextEditingController _contentController =
              TextEditingController(text: chapter.translatedContent);
          return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: EdgeInsets.all(6),
                child: DefaultTabController(
                  length: 2,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text("${chapter.translatedTitle ?? chapter.title}"),
                        Container(
                          height: 50,
                          child: TabBar(
                            isScrollable: true,
                            tabs: [
                              Tab(child: Text('Translated')),
                              Tab(child: Text('Original')),
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height / 2,
                          child: TabBarView(
                            children: <Widget>[
                              TextField(
                                readOnly:
                                    _translateStatus == TranslateStatus.loading,
                                controller: _contentController,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                decoration: InputDecoration(
                                    hintText: 'Edit Result Translation',
                                    label: Text('Result Translation')),
                              ),
                              SingleChildScrollView(
                                child: SelectableText(
                                    "${chapter.originalContent}"),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  child: Text("Save"),
                                  onPressed: () {
                                    chapter.translatedContent =
                                        _contentController.text;
                                    updateChapter(chapter);
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text("Translate Again"),
                                  onPressed: () {
                                    doTranslate(index, false);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                            TextButton(
                              child: Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ));
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      getTranslateChapters();
      setState(() {
        book = widget.book;
      });
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
                        });
                      },
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Text("Pre Prompt :"),
              Text(
                "this prompt will be shown to the translator AI. if using google translate, you can use wordlist to prevent the word from being translated with format word1=word2,word3=word4",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              TextField(
                readOnly: _translateStatus == TranslateStatus.loading,
                controller: _prePromptController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(hintText: 'Input prompt here...'),
              ),
              SizedBox(
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
              (_translateStatus != TranslateStatus.loading)
                  ? Center(
                      child: ElevatedButton(
                        onPressed: () {
                          addTranslate();
                        },
                        child: Text('Translate'),
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
              SizedBox(
                height: 8,
              ),
              if (_translateStatus != TranslateStatus.none)
                Column(
                  children: chapters.map((chapter) {
                    return ListTile(
                      onTap: () {
                        detailChapter(chapter);
                      },
                      title: Text(chapter.translatedTitle ?? chapter.title!),
                      subtitle: (chapter.statusTranslation == 0)
                          ? Text('Translating...')
                          : (chapter.statusTranslation == 1)
                              ? Text('Translated')
                              : Text('Error'),
                      trailing: (chapter.statusTranslation == 1)
                          ? Icon(Icons.check)
                          : (chapter.statusTranslation == 2)
                              ? Icon(Icons.error)
                              : CircularProgressIndicator(),
                    );
                  }).toList(),
                )
            ],
          ),
        ),
      ),
    );
  }
}

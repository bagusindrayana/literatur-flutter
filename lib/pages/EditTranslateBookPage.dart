import 'dart:io';
import 'dart:math';

import 'package:Literatur/helpers/TranslateHelper.dart';
import 'package:Literatur/models/Book.dart';
import 'package:Literatur/models/Translate.dart';
import 'package:Literatur/repositories/BookRepository.dart';
import 'package:Literatur/repositories/TranslateRepository.dart';
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
  BookRepository _bookRepository = BookRepository();
  TranslateRepository _translateRepository = TranslateRepository();
  TranslateStatus _status = TranslateStatus.none;
  List<Chapter> chapters = [];

  List<String> language = Translatehelper.languages;

  List<String> providers = Translatehelper.providers;

  String provider = 'Gemini';

  void getTranslateChapters() {
    setState(() {
      chapters = widget.book.chapters.where(
        (element) {
          return element.translateId == widget.translate.id;
        },
      ).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    });
  }

  void doTranslate(int index, bool next) async {
    int total = chapters.length;
    print(total);

    if (index >= total) {
      print("Out of Index");
      return;
    }
    var chapter = chapters[index];

    if (!next) {
      setState(() {
        chapter.statusTranslation = -1;
      });
    }

    if ((chapter.statusTranslation == 1 ||
            chapter.originalContent == null ||
            chapter.originalContent == "") &&
        next) {
      doTranslate(index + 1, next);
      return;
    }
    int maxlength = 2000;
    List<String> tokens = [];
    print("From Language : ${chapter.fromLanguage}");
    bool chunk = false;
    if (chapter.fromLanguage == "Japanese") {
      maxlength = 1000;
      tokens = jw_tokenizer.tokenize(chapter.originalContent!);
    } else if (chapter.fromLanguage == "Chinese" ||
        chapter.fromLanguage == "Korean") {
      maxlength = 1000;
      await JiebaSegmenter.init().then((value) {
        var seg = JiebaSegmenter();
        tokens = seg
            .process(chapter.originalContent!, SegMode.INDEX)
            .map((e) => e.word)
            .toList();
      });
    } else {
      tokens = chapter.originalContent!.trim().split(" ");
    }

    if (provider != "Gemini") {
      maxlength = 500;
    }

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
        chapter.translatedContent = resultTranslation;
        chapter.statusTranslation = 1;
        _bookRepository.updateChapter(widget.book.id, chapter);
        setState(() {});
        if (next) {
          doTranslate(index + 1, next);
        }
      } else {
        chapter.statusTranslation = 2;
        setState(() {});
        if (next) {
          doTranslate(index + 1, next);
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
          _bookRepository.updateChapter(widget.book.id, chapter);
        } else {
          Logger().e("Null Response");
          chapter.statusTranslation = 2;
        }
        setState(() {});
        if (next) {
          doTranslate(index + 1, next);
        }
      }, (e) {
        Logger().e(e);
        chapter.statusTranslation = 2;
        setState(() {});
        if (next) {
          doTranslate(index + 1, next);
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
    _bookRepository.updateChapter(widget.book.id, chapter);
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
                        Text("${chapter.title}"),
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
                                readOnly: _status == TranslateStatus.loading,
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

  Widget getStatus(Chapter chapter) {
    if (chapter.statusTranslation == 0) {
      return Text("Not Translated");
    } else if (chapter.statusTranslation == 1) {
      return Text('Translated');
    } else if (chapter.statusTranslation == -1) {
      return Text('Translating...');
    } else {
      return Text('Error');
    }
  }

  Widget iconLoading(Chapter chapter) {
    if (chapter.statusTranslation == 0) {
      return Icon(Icons.warning);
    } else if (chapter.statusTranslation == 1) {
      return Icon(Icons.check);
    } else if (chapter.statusTranslation == -1) {
      return CircularProgressIndicator();
    } else {
      return Icon(Icons.error);
    }
  }

  void deleteTranslate() {
    _translateRepository.deleteTranslate(widget.translate.id);
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      getTranslateChapters();
    });
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
          SizedBox(
            height: 8,
          ),
          Column(
            children: chapters.map((chapter) {
              return ListTile(
                onTap: () {
                  detailChapter(chapter);
                },
                title: Text(chapter.translatedTitle ?? chapter.title!),
                subtitle: getStatus(chapter),
                trailing: iconLoading(chapter),
              );
            }).toList(),
          )
        ],
      )),
    );
  }
}

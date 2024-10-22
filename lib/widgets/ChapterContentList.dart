import 'dart:io';
import 'dart:math';

import 'package:Literatur/helpers/TranslateHelper.dart';
import 'package:Literatur/helpers/UIHelper.dart';
import 'package:Literatur/models/Book.dart';
import 'package:Literatur/models/Translate.dart';
import 'package:Literatur/repositories/BookRepository.dart';
import 'package:Literatur/repositories/TranslateRepository.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:logger/logger.dart';
import 'package:japanese_word_tokenizer/japanese_word_tokenizer.dart'
    as jw_tokenizer;
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;

enum TranslateStatus { loading, finish, error, none }

enum LoadDataStatus { loading, finish, error, none }

class ChapterContentList extends StatefulWidget {
  final Book book;
  final Translate translate;
  final String? provider;
  final Function? onTranslate;
  final Function? onSuccess;
  final Function? onError;
  const ChapterContentList(
      {super.key,
      required this.book,
      required this.translate,
      this.provider = "Gemini",
      this.onTranslate = null,
      this.onSuccess = null,
      this.onError = null});

  @override
  State<ChapterContentList> createState() => _ChapterContentListState();
}

class _ChapterContentListState extends State<ChapterContentList> {
  BookRepository _bookRepository = BookRepository();
  TranslateRepository _translateRepository = TranslateRepository();
  TranslateStatus _translateStatus = TranslateStatus.none;
  LoadDataStatus _loadDataStatus = LoadDataStatus.none;

  List<Chapter> chapters = [];
  List<bool> selected = [];

  void onSubmitTranslate() {
    setState(() {
      _translateStatus = TranslateStatus.loading;
    });
    if (widget.onTranslate != null) {
      widget.onTranslate!();
    }
    addTranslate();
  }

  void onSuccessful({dynamic v}) {
    setState(() {
      _translateStatus = TranslateStatus.finish;
    });
    if (widget.onSuccess != null) {
      widget.onSuccess!(v);
    }
  }

  void onError({dynamic e}) {
    setState(() {
      _translateStatus = TranslateStatus.error;
    });
    if (widget.onError != null) {
      widget.onError!(e);
    }
  }

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

  Future<List<Chapter>> getChapterContent() async {
    var targetFile = File(widget.book.filePath!);
    var bytes = await targetFile.readAsBytes();
    EpubBook epubBook = await EpubReader.readBook(bytes);
    EpubContent bookContent = epubBook.Content!;

    List<EpubChapter> _chapters = [];
    for (var _chapter in epubBook.Chapters!) {
      _chapters.addAll(await subChapter(_chapter));
    }

    var htmlFiles = bookContent.Html!;
    List<Chapter> contents = [];

    String title = "";
    htmlFiles.forEach((key, value) {
      if (key.contains('nav')) {
        return;
      }
      for (var _chapter in _chapters) {
        if (_chapter.ContentFileName != null &&
            key.contains(_chapter.ContentFileName!)) {
          title = _chapter.Title!;
        }
      }
      if (title == "") {
        title = key;
      }

      final document = parse(value.Content!);
      String parsedString = parse(document.body!.text).documentElement!.text;
      if (parsedString.trim() != "") {
        Chapter newChapter = Chapter();
        File file = new File(key);
        String basename = path.basename(file.path);
        newChapter.key = basename;
        newChapter.translateId = widget.translate.id;
        newChapter.title = title.trim();
        newChapter.originalContent = parsedString;
        newChapter.fromLanguage = widget.translate.fromLanguage;
        newChapter.toLanguage = widget.translate.toLanguage;
        newChapter.prePrompt = widget.translate.prePrompt;
        newChapter.statusTranslation = 0;
        contents.add(newChapter);
      }
    });

    return contents;
  }

  void addTranslate() async {
    _translateStatus = TranslateStatus.loading;
    widget.translate.bookId = widget.book.id;
    await _translateRepository.addTranslate(widget.translate);

    var originalChapters = await getChapterContent();
    var texts = "";
    int order = 0;

    List<Chapter> newChapters = [];

    originalChapters.forEach((Chapter c) {
      if (c.originalContent!.trim() != "") {
        texts += "${c.title!.trim()} \n";
        //find chapter by key
        var findChapter = chapters.firstWhereOrNull((element) =>
            element.key == c.key && element.title!.trim() == c.title!.trim());
        if (findChapter != null) {
          if (selected[chapters.indexOf(findChapter)]) {
            findChapter.order = order;
            // findChapter.statusTranslation = 0;
          }
          newChapters.add(findChapter);
        } else {
          Chapter newChapter = c;
          newChapter.order = order;
          newChapter.translateId = widget.translate.id;
          newChapter.prePrompt = widget.translate.prePrompt;
          newChapter.statusTranslation = 0;
          newChapter.fromLanguage = widget.translate.fromLanguage;
          newChapter.toLanguage = widget.translate.toLanguage;

          newChapters.add(newChapter);
        }
      }
      order++;
    });

    setState(() {
      chapters = newChapters;
    });
    saveBook();
    // getTranslateChapters();
    if (texts == "") {
      _translateStatus = TranslateStatus.error;
      setState(() {});
      return;
    }

    setState(() {});
    Future.delayed(Duration(seconds: 1), () async {
      await doTranslateTitle();
      doTranslate(0, true);
    });
  }

  Future<void> doTranslateTitle() async {
    if (_translateStatus != TranslateStatus.loading) {
      setState(() {
        _translateStatus = TranslateStatus.loading;
      });
    }
    var texts = "";

    var originalChapters = await getChapterContent();
    originalChapters.forEach((Chapter c) {
      if (c.originalContent!.trim() != "") {
        texts += "${c.title!.trim()} \n";
      }
    });
    await Translatehelper.translate(
        widget.provider!,
        texts,
        widget.translate.fromLanguage!,
        widget.translate.toLanguage!,
        "", (String? value) async {
      var arr = texts.trim().split("\n");
      if (value != null) {
        var arrTranslate = value.trim().split("\n");

        for (var i = 0; i < arr.length; i++) {
          if (i < arrTranslate.length) {
            var findChapters = chapters
                .where((element) => element.title!.trim() == arr[i].trim());
            findChapters.forEach((findChapter) async {
              findChapter.translatedTitle = arrTranslate[i];
              if (widget.translate.id > 0) {
                await _bookRepository.updateChapter(
                    widget.book.id, findChapter);
              }
            });
          } else {
            print("Not Found : ${arr[i]}");
          }
        }
      }
      setState(() {
        if (_translateStatus == TranslateStatus.loading) {
          setState(() {
            _translateStatus = TranslateStatus.finish;
          });
        }
      });
    }, (e, t) {
      Logger().e(t);
      setState(() {
        if (_translateStatus == TranslateStatus.loading) {
          setState(() {
            _translateStatus = TranslateStatus.finish;
          });
        }
      });
      UIHelper.showSnackBar(context, e.toString());
    });
  }

  void getTranslateChapters() async {
    setState(() {
      _loadDataStatus = LoadDataStatus.loading;
    });
    List<Chapter> newChapters = [];

    try {
      getChapterContent().then((originalChapters) {
        var bookChapters = [];
        if (widget.translate.id > 0) {
          bookChapters = widget.book.chapters.where((element) {
            return element.translateId == widget.translate.id;
          }).toList();
        }

        selected = List.generate(originalChapters.length, (index) => true);

        int order = 0;

        originalChapters.forEach((Chapter c) {
          if (c.originalContent!.trim() != "") {
            var findChapter = bookChapters.firstWhereOrNull((element) =>
                element.key == c.key &&
                element.title!.trim() == c.title!.trim());
            if (findChapter != null) {
              findChapter.order = order;
              // findChapter.statusTranslation = -1;
              findChapter.fromLanguage = widget.translate.fromLanguage;
              findChapter.toLanguage = widget.translate.toLanguage;
              findChapter.prePrompt = widget.translate.prePrompt;
              newChapters.add(findChapter);
            } else {
              Chapter newChapter = c;
              newChapter.order = order;
              newChapter.translateId = widget.translate.id;
              newChapter.prePrompt = widget.translate.prePrompt;
              newChapter.statusTranslation = -1;
              newChapter.fromLanguage = widget.translate.fromLanguage;
              newChapter.toLanguage = widget.translate.toLanguage;

              newChapters.add(newChapter);
            }
          }
          order++;
        });
        setState(() {
          chapters = newChapters;
          _loadDataStatus = LoadDataStatus.finish;
          //widget.book.chapters = chapters;
        });
      });
    } catch (e) {
      Logger().e(e);
      UIHelper.showSnackBar(context, "Failed load data : ${e.toString()}");
      setState(() {
        _loadDataStatus = LoadDataStatus.error;
      });
    }
  }

  void doTranslate(int index, bool next) async {
    int total = chapters.length;

    if (index >= total) {
      onSuccessful();
      return;
    }

    if (selected[index] == false && next) {
      doTranslate(index + 1, next);
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
    chapter.translateId = widget.translate.id;

    if (!next) {
      setState(() {
        _translateStatus = TranslateStatus.loading;
        chapter.statusTranslation = 0;
      });
    }
    bool chunk = false;
    int maxlength = 2000;
    if (widget.translate.fromLanguage == "Japanese") {
      maxlength = 1000;
      if (widget.provider != "Gemini") {
        maxlength = 500;
      }
      List<dynamic> tokens = jw_tokenizer.tokenize(chapter.originalContent!);
      if (tokens.length > maxlength) {
        chunk = true;
        //loop
        String resultTranslation = "";
        bool berhasil = false;
        bool stop = false;
        for (var i = 0; i < tokens.length / maxlength; i++) {
          if (stop) {
            break;
          }
          //substring
          int start = i * maxlength;
          int end = ((i + 1) * maxlength);
          print("Start : ${start} End : ${end}");
          String contents = tokens
              .sublist(start, end > tokens.length ? tokens.length : end)
              .join(" ");

          await Translatehelper.translate(
              widget.provider!,
              contents,
              widget.translate.fromLanguage!,
              widget.translate.toLanguage!,
              widget.translate.prePrompt ?? "-", (String? value) {
            if (value != null) {
              resultTranslation += value;
              berhasil = true;
            } else {
              Logger().e("Null Response");
              UIHelper.showSnackBar(context, "Null Response");
              berhasil = false;
              stop = true;
            }
          }, (e) {
            Logger().e(e);
            UIHelper.showSnackBar(context, e.toString());
            berhasil = false;
            stop = true;
          });
          Random random = new Random();
          int randomMilisecond = random.nextInt(1000) + 1000;
          await Future.delayed(Duration(milliseconds: randomMilisecond));
        }
        // print("Berhasil : ${berhasil}");
        if (berhasil) {
          // Logger().i("Translation Result : ${resultTranslation}");
          chapter.translatedContent = resultTranslation;
          chapter.statusTranslation = 1;
          _bookRepository.updateChapter(widget.book.id, chapter);
          setState(() {});
          if (next) {
            doTranslate(index + 1, next);
          } else {
            onSuccessful(v: resultTranslation);
          }
        } else {
          chapter.statusTranslation = 2;
          setState(() {});
          if (next) {
            doTranslate(index + 1, next);
          } else {
            onError();
          }
        }
      }
    }

    if (!chunk) {
      await Future.delayed(const Duration(seconds: 1));
      await Translatehelper.translate(
          widget.provider!,
          chapter.originalContent!,
          widget.translate.fromLanguage!,
          widget.translate.toLanguage!,
          widget.translate.prePrompt ?? "-", (String? value) {
        String resultTranslation = "";
        if (value != null) {
          resultTranslation = value;
          chapter.translatedContent = resultTranslation;
          chapter.statusTranslation = 1;
          _bookRepository.updateChapter(widget.book.id, chapter);
          // Logger().i("Translation Result : ${resultTranslation}");
        } else {
          Logger().e("Null Response");
          chapter.statusTranslation = 2;
        }
        setState(() {
          chapters[index] = chapter;
        });
        if (next) {
          doTranslate(index + 1, next);
        } else {
          if (value != null) {
            onSuccessful(v: resultTranslation);
          } else {
            onError();
          }
        }
      }, (e) {
        Logger().e(e);
        chapter.statusTranslation = 2;
        setState(() {});
        if (next) {
          doTranslate(index + 1, next);
        } else {
          onError(e: e);
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

  void saveChapter(Chapter chapter) {
    var index = chapters.indexOf(chapter);
    setState(() {
      chapters[index] = chapter;
    });

    saveBook();
  }

  void saveBook() async {
    setState(() {
      _translateStatus = TranslateStatus.loading;
    });
    await _translateRepository.addTranslate(widget.translate);
    for (var chapter in chapters) {
      chapter.fromLanguage = widget.translate.fromLanguage;
      chapter.toLanguage = widget.translate.toLanguage;
      chapter.translateId = widget.translate.id;
      chapter.prePrompt = widget.translate.prePrompt;
      await _bookRepository.updateChapter(widget.book.id, chapter);
    }
    // await _bookRepository.updateBook(widget.book.id, widget.book);
    setState(() {
      _translateStatus = TranslateStatus.finish;
    });
  }

  void detailChapter(Chapter chapter) {
    int index = chapters.indexOf(chapter);

    showDialog(
        context: context,
        //context: _scaffoldKey.currentContext,
        builder: (context) {
          TextEditingController _contentController =
              TextEditingController(text: chapter.translatedContent);
          TextEditingController _titleController = TextEditingController(
              text: "${chapter.translatedTitle ?? chapter.title}");
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
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                              hintText: 'Title', label: Text('Title')),
                        ),
                        const SizedBox(
                          height: 50,
                          child: TabBar(
                            isScrollable: true,
                            tabs: [
                              Tab(child: Text('Translated')),
                              Tab(child: Text('Original')),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 2,
                          child: TabBarView(
                            children: <Widget>[
                              TextField(
                                readOnly:
                                    _translateStatus == TranslateStatus.loading,
                                controller: _contentController,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                decoration: const InputDecoration(
                                    hintText: 'Edit Translation Result',
                                    label: Text('Translation Result')),
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
                                  child: const Text("Save"),
                                  onPressed: () {
                                    chapter.translatedContent =
                                        _contentController.text;
                                    chapter.translatedTitle =
                                        _titleController.text;
                                    saveChapter(chapter);
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text("Translate Chapter"),
                                  onPressed: () {
                                    doTranslate(index, false);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                            TextButton(
                              child: const Text("Cancel"),
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

  Widget iconLoading(Chapter chapter) {
    if (chapter.statusTranslation == 0 &&
        _translateStatus == TranslateStatus.loading &&
        selected[chapters.indexOf(chapter)]) {
      return CircularProgressIndicator();
    } else if (chapter.statusTranslation == 1) {
      return Icon(Icons.check);
    } else if (chapter.statusTranslation == 2) {
      return Icon(Icons.dangerous);
    } else {
      return SizedBox();
    }
  }

  // @override
  // void didUpdateWidget(ChapterContentList oldWidget) {
  //   super.didUpdateWidget(oldWidget);

  //   getTranslateChapters();
  // }

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
    return Column(
      children: [
        Text("Book Content : "),
        (_loadDataStatus == LoadDataStatus.loading)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: chapters.map((chapter) {
                  return ListTile(
                    onTap: () {
                      if (chapter.statusTranslation != 0) {
                        detailChapter(chapter);
                      }
                    },
                    leading: Checkbox(
                      value: selected[chapters.indexOf(chapter)],
                      onChanged: (bool? value) {
                        setState(() {
                          selected[chapters.indexOf(chapter)] = value!;
                        });
                      },
                    ),
                    title: Text(chapter.translatedTitle ?? chapter.title!),
                    subtitle: Text(chapter.key ?? "-"),
                    trailing: iconLoading(chapter),
                  );
                }).toList(),
              ),
        SizedBox(
          height: 8,
        ),
        (_translateStatus != TranslateStatus.loading)
            ? Center(
                child: ElevatedButton(
                  onPressed: () {
                    onSubmitTranslate();
                  },
                  child: Text('Translate All'),
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
        (_translateStatus != TranslateStatus.loading)
            ? Center(
                child: ElevatedButton(
                  onPressed: () {
                    doTranslateTitle();
                  },
                  child: Text('Translate Title'),
                ),
              )
            : SizedBox(),
        (_translateStatus != TranslateStatus.loading)
            ? Center(
                child: ElevatedButton(
                  onPressed: () {
                    saveBook();
                  },
                  child: Text('Save'),
                ),
              )
            : SizedBox(),
      ],
    );
  }
}

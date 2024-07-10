import 'dart:io';
import 'dart:typed_data';

import 'package:Literatur/models/Translate.dart';
import 'package:Literatur/repositories/BookRepository.dart';
import 'package:Literatur/repositories/TranslateRepository.dart';
import 'package:cached_memory_image/cached_memory_image.dart';
import 'package:Literatur/models/Book.dart';
import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:html/parser.dart';
import 'package:collection/collection.dart';

class ViewBookPage extends StatefulWidget {
  final Book book;
  const ViewBookPage({super.key, required this.book});

  @override
  State<ViewBookPage> createState() => _ViewBookPageState();
}

class _ViewBookPageState extends State<ViewBookPage> {
  List<EpubChapter> chapters = [];
  Map<String, EpubByteContentFile> images = {};
  Map<String, EpubTextContentFile> htmlFiles = {};
  TranslateRepository _translateRepository = TranslateRepository();
  BookRepository _bookRepository = BookRepository();
  List<Translate> translates = [];

  int translateId = 0;

  //get chapter from book
  // void getChapter() async {
  //   await DefaultCacheManager().emptyCache();
  //   var targetFile = File(widget.book.filePath!);
  //   var bytes = await targetFile.readAsBytes();
  //   EpubBook epubBook = await EpubReader.readBook(bytes);

  //   EpubContent bookContent = epubBook.Content!;

  //   if (mounted) {
  //     setState(() {
  //       images = bookContent.Images!;
  //       chapters = epubBook.Chapters!;
  //       htmlFiles = bookContent.Html!;
  //     });
  //   }
  // }
  Future<List<EpubChapter>> subChapter(EpubChapter epubChapter) async {
    List<EpubChapter> chapters = [];
    if (epubChapter.SubChapters != null &&
        epubChapter.SubChapters!.isNotEmpty) {
      for (var sub in epubChapter.SubChapters!) {
        chapters.addAll(await subChapter(sub));
      }
    } else {
      chapters.add(epubChapter);
    }
    return chapters;
  }

  Future<List<EpubChapter>> getChapter(EpubBook epubBook) async {
    List<EpubChapter> chapters = [];
    for (var chapter in epubBook.Chapters!) {
      chapters.addAll(await subChapter(chapter));
    }

    print(chapters.length);

    return chapters;
  }

  Future<void> getTranslate() async {
    translates = await _translateRepository.getTranslates(widget.book.id);
    setState(() {
      translates = translates;
    });
  }

  void getBookData() async {
    await DefaultCacheManager().emptyCache();
    var targetFile = File(widget.book.filePath!);
    var bytes = await targetFile.readAsBytes();
    EpubBook epubBook = await EpubReader.readBook(bytes);

    EpubContent bookContent = epubBook.Content!;
    List<EpubChapter> ch = await getChapter(epubBook);
    if (mounted) {
      setState(() {
        translateId = widget.book.lastTranslateId != null
            ? widget.book.lastTranslateId!
            : 0;
        images = bookContent.Images!;
        chapters = ch;
        htmlFiles = bookContent.Html!;
      });
    }
  }

  void openTransalteMenu() async {
    await getTranslate();
    //show alert dialog
    if (context.mounted) {
      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("Transalate Book"),
        contentPadding: EdgeInsets.only(right: 8, left: 8),
        scrollable: true,
        content: Container(
            height: MediaQuery.of(context).size.height / 3,
            child: SingleChildScrollView(
              child: (translates.length == 0)
                  ? Column(
                      children: [
                        Center(
                          child: Text(
                              "No translate found, please add translate first"),
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushNamed(context, '/translate-book',
                                  arguments: widget.book);
                            },
                            icon: Icon(Icons.add))
                      ],
                    )
                  : Column(
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/translate-book',
                                  arguments: widget.book);
                            },
                            icon: Icon(Icons.add)),
                        for (Translate translate in translates)
                          ListTile(
                            onTap: () {
                              selectTranslate(translate.id);
                              Navigator.of(context).pop();
                            },
                            title: Text(
                                "${translate.fromLanguage} to ${translate.toLanguage}"),
                            trailing: IconButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                Navigator.pushNamed(
                                    context, '/edit-translate-book',
                                    arguments: {
                                      "book": widget.book,
                                      "translate": translate,
                                    }).then((v) {
                                  getBookData();
                                });
                              },
                              icon: Icon(Icons.edit),
                            ),
                          ),
                      ],
                    ),
            )),
        actions: [
          TextButton(
            child: Text("Original"),
            onPressed: () {
              selectTranslate(0);
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }
  }

  void selectTranslate(int id) {
    _bookRepository.updateLastTranslateId(widget.book.id, id);
    setState(() {
      translateId = id;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      getBookData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.book.title}"),
        actions: [
          // IconButton(onPressed: () {}, icon: Icon(Icons.bookmark_border)),
          IconButton(
              onPressed: () {
                openTransalteMenu();
              },
              icon: Icon(Icons.translate_outlined)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PagingText(
          widget.book,
          chapters,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          images: images,
          htmlFiles: htmlFiles,
          onPageChange: (int index) {
            widget.book.lastReadPosition = index.toString();
            _bookRepository.updateLastReadPosition(
                widget.book.id, index.toString());
          },
          currentPage: widget.book.lastReadPosition != null
              ? int.parse(widget.book.lastReadPosition.toString())
              : 0,
          translateId: translateId,
        ),
      ),
    );
  }
}

class PagingChapter {
  final String title;
  final String content;
  final List<int>? image;

  PagingChapter({required this.title, required this.content, this.image});
}

//https://gist.github.com/ltvu93/36b249d1b5b5861a5ef58d958a50ad98
class PagingText extends StatefulWidget {
  final Book book;
  final List<EpubChapter> chapters;
  final TextStyle style;
  Function? onPageChange;
  int currentPage = 0;
  Map<String, EpubByteContentFile>? images;
  Map<String, EpubTextContentFile>? htmlFiles;
  int translateId = 0;

  PagingText(this.book, this.chapters,
      {this.style = const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
      this.images,
      this.htmlFiles,
      this.onPageChange,
      this.currentPage = 0,
      this.translateId = 0});

  @override
  _PagingTextState createState() => _PagingTextState();
}

class _PagingTextState extends State<PagingText> {
  List<PagingChapter> _pageTexts = [];
  int _currentIndex = 0;
  bool _needPaging = true;
  bool _isPaging = false;
  final _pageKey = GlobalKey();

  @override
  void didUpdateWidget(PagingText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if ((widget.chapters != oldWidget.chapters &&
            widget.images != oldWidget.images &&
            widget.htmlFiles != oldWidget.htmlFiles) ||
        widget.translateId != oldWidget.translateId) {
      setState(() {
        _pageTexts.clear();
        _currentIndex = 0;
        _needPaging = true;
        _isPaging = false;
      });
    }
  }

  Future<List<PagingChapter>> generatePaginateTexts(
      List<EpubChapter> chapters) {
    List<PagingChapter> responseData = [];
    Map<String, EpubByteContentFile> used = {};
    int index = 0;
    String title = "";
    widget.htmlFiles!.forEach((key, value) {
      if (key.contains('nav')) {
        return;
      }

      for (EpubChapter chapter in chapters) {
        if (chapter.ContentFileName != null &&
            key.contains(chapter.ContentFileName!)) {
          title = chapter.Title!;
        }
        // if (chapter.SubChapters != null) {
        //   for (EpubChapter subChapter in chapter.SubChapters!) {
        //     if (subChapter.ContentFileName != null &&
        //         key.contains(subChapter.ContentFileName!)) {
        //       title = subChapter.Title!;
        //     }

        //     if (subChapter.SubChapters != null) {
        //       for (EpubChapter subSubChapter in subChapter.SubChapters!) {
        //         if (subSubChapter.ContentFileName != null &&
        //             key.contains(subSubChapter.ContentFileName!)) {
        //           title = subSubChapter.Title!;
        //         }
        //       }
        //     }
        //   }
        // }
      }
      if (title == "") {
        title = key;
      }

      final document = parse(value.Content!);
      String parsedString = parse(document.body!.text).documentElement!.text;
      if (widget.translateId != 0) {
        Chapter? c = widget.book.chapters.firstWhereOrNull((element) =>
            element.translateId == widget.translateId &&
            key.contains(element.key!));
        if (c != null &&
            c.translatedContent != null &&
            parsedString.trim() != "") {
          parsedString = c.translatedContent!;
          if (c.translatedTitle != null) {
            title = c.translatedTitle!;
          }
        }
      }
      // if (parsedString == "") {
      //   parsedString = parse(document.body!.text).documentElement!.text;
      // }

      var haveImage = null;
      final allImages = document.querySelectorAll("img");
      allImages.forEach((element) {
        widget.images!.forEach((key, value) {
          if (element.attributes["src"]!.contains(key)) {
            haveImage = value.Content!;
            // used[key] = value;
          }
        });
      });

      final pageSize =
          (_pageKey.currentContext!.findRenderObject() as RenderBox).size;
      final textSpan = TextSpan(
        text: parsedString,
        style: widget.style,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: pageSize.width - 16,
      );

      final heightOffset = 150;

      // https://medium.com/swlh/flutter-line-metrics-fd98ab180a64
      List<LineMetrics> lines = textPainter.computeLineMetrics();
      double currentPageBottom = pageSize.height - heightOffset;
      int currentPageStartIndex = 0;
      int currentPageEndIndex = 0;

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];

        final left = line.left;
        final top = line.baseline - line.ascent;
        final bottom = line.baseline + line.descent;

        // Current line overflow page
        if (currentPageBottom < bottom) {
          // https://stackoverflow.com/questions/56943994/how-to-get-the-raw-text-from-a-flutter-textbox/56943995#56943995
          currentPageEndIndex =
              textPainter.getPositionForOffset(Offset(left, top)).offset;
          final pageText = parsedString.substring(
              currentPageStartIndex, currentPageEndIndex);
          responseData.add(
              PagingChapter(title: title, content: pageText, image: haveImage));

          currentPageStartIndex = currentPageEndIndex;
          currentPageBottom = top + (pageSize.height - heightOffset);
        }
      }

      final lastPageText = PagingChapter(
          title: title,
          content: parsedString.substring(currentPageStartIndex),
          image: haveImage);
      responseData.add(lastPageText);
      index++;
    });

    return Future.value(responseData);
  }

  void _paginate() async {
    if (_pageKey.currentContext == null) return;
    _pageTexts.clear();

    await Future.delayed(Duration(seconds: 1));
    //await paginateHtmlContent(widget.chapters);
    _pageTexts = await generatePaginateTexts(widget.chapters);
    await Future.delayed(Duration(seconds: 1));
    if (mounted) {
      setState(() {
        if (widget.currentPage > 0 && widget.currentPage < _pageTexts.length) {
          _currentIndex = widget.currentPage;
        } else {
          _currentIndex = 0;
        }
        _needPaging = false;
        _isPaging = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_needPaging && !_isPaging) {
      _isPaging = true;

      SchedulerBinding.instance.addPostFrameCallback((_) {
        _paginate();
      });
    }

    return Stack(
      children: [
        Column(
          children: [
            if (_pageTexts.length > 0) Text(_pageTexts[_currentIndex].title),
            Divider(),
            Expanded(
              child: SizedBox.expand(
                key: _pageKey,
                child: (_pageTexts.length > 0)
                    ? GestureDetector(
                        onHorizontalDragEnd: (dragDetail) {
                          if (dragDetail.primaryVelocity! < -5) {
                            //next
                            setState(() {
                              if (_currentIndex < _pageTexts.length - 1)
                                _currentIndex++;
                              if (widget.onPageChange != null)
                                widget.onPageChange!(_currentIndex);
                            });
                          } else if (dragDetail.primaryVelocity! > 5) {
                            //prev
                            setState(() {
                              if (_currentIndex > 0) _currentIndex--;
                              if (widget.onPageChange != null)
                                widget.onPageChange!(_currentIndex);
                            });
                          }
                        },
                        child: (_pageTexts[_currentIndex].image != null)
                            ? SingleChildScrollView(
                                child: Wrap(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              186,
                                          //maximum height set to 100% of vertical height

                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              16,
                                          //maximum width set to 100% of width
                                        ),
                                        child: CachedMemoryImage(
                                          fit: BoxFit.scaleDown,
                                          uniqueKey:
                                              "/${widget.book.id}/${_pageTexts[_currentIndex].title}/img/$_currentIndex",
                                          errorWidget: const Text('Error'),
                                          placeholder:
                                              const CircularProgressIndicator(),
                                          bytes: Uint8List.fromList(
                                              _pageTexts[_currentIndex].image!),
                                        ),
                                      ),
                                    ),
                                    Text(_pageTexts[_currentIndex].content),
                                  ],
                                ),
                              )
                            : SelectableText(_pageTexts[_currentIndex].content,
                                style: widget.style),
                      )
                    : SizedBox(),
              ),
            ),
            Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.first_page),
                    onPressed: () {
                      setState(() {
                        _currentIndex = 0;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.navigate_before),
                    onPressed: () {
                      setState(() {
                        if (_currentIndex > 0) _currentIndex--;
                        if (widget.onPageChange != null)
                          widget.onPageChange!(_currentIndex);
                      });
                    },
                  ),
                  Text(
                    _isPaging
                        ? ''
                        : '${_currentIndex + 1}/${_pageTexts.length}',
                  ),
                  IconButton(
                    icon: Icon(Icons.navigate_next),
                    onPressed: () {
                      setState(() {
                        if (_currentIndex < _pageTexts.length - 1)
                          _currentIndex++;
                        if (widget.onPageChange != null)
                          widget.onPageChange!(_currentIndex);
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.last_page),
                    onPressed: () {
                      setState(() {
                        _currentIndex = _pageTexts.length - 1;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_isPaging)
          Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:cached_memory_image/cached_memory_image.dart';
import 'package:Literatur/models/Book.dart';
import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter/scheduler.dart';
import 'package:logger/logger.dart';
import "package:universal_html/parsing.dart" as parsing;
import 'package:path/path.dart' as p;
import 'package:html/parser.dart';
import 'package:image/image.dart' as images;
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_html/flutter_html.dart' as fhtml;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as htmlParser;

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

  //get chapter from book
  void getChapter() async {
    var targetFile = File(widget.book.filePath!);
    var bytes = await targetFile.readAsBytes();
    EpubBook epubBook = await EpubReader.readBook(bytes);

    EpubContent bookContent = epubBook.Content!;

    setState(() {
      images = bookContent.Images!;
      chapters = epubBook.Chapters!;
      htmlFiles = bookContent.Html!;
    });

    // setState(() {
    //   fullText = fullText;
    // });
    // Logger().d(fullText);

    // EpubChapter chapter = epubBook.Chapters!.first;

    // // Logger().d(chapter.HtmlContent);
    // final htmlDocument = parsing.parseHtmlDocument(chapter.HtmlContent!);
    // final allImages = htmlDocument.querySelectorAll("img");
    // allImages.forEach((element) {
    //   images.forEach((key, value) {
    //     if (element.attributes["src"]!.contains(key)) {
    //       // Logger().d(element.attributes["src"]);
    //       //parse image to base64 ang set to src
    //       String base64Image = base64Encode(value.Content!);
    //       final extension = p.extension(key);

    //       element.setAttribute(
    //           "src", "data:image/${extension};base64,${base64Image}");
    //     }
    //     // Logger().d(key);
    //   });
    // });
    // EpubChapter debugChapter = epubBook.Chapters![1];
    // // Logger().d(htmlDocument.body!.innerHtml);
    // Logger().d(debugChapter.HtmlContent);
    // Logger().d(images);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      getChapter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.book.title}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PagingText(widget.book.id, chapters,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
            images: images,
            htmlFiles: htmlFiles),
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
  final int id;
  final List<EpubChapter> chapters;
  final TextStyle style;
  Map<String, EpubByteContentFile>? images;

  Map<String, EpubTextContentFile>? htmlFiles;

  PagingText(this.id, this.chapters,
      {this.style = const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
      this.images,
      this.htmlFiles});

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

    if (widget.chapters != oldWidget.chapters &&
        widget.images != oldWidget.images &&
        widget.htmlFiles != oldWidget.htmlFiles) {
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
        if (chapter.SubChapters != null) {
          for (EpubChapter subChapter in chapter.SubChapters!) {
            if (subChapter.ContentFileName != null &&
                key.contains(subChapter.ContentFileName!)) {
              title = subChapter.Title!;
            }

            if (subChapter.SubChapters != null) {
              for (EpubChapter subSubChapter in subChapter.SubChapters!) {
                if (subSubChapter.ContentFileName != null &&
                    key.contains(subSubChapter.ContentFileName!)) {
                  title = subSubChapter.Title!;
                }
              }
            }
          }
        }
      }
      if (title == "") {
        title = key;
      }

      final document = parse(value.Content!);
      final String parsedString =
          parse(document.body!.text).documentElement!.text;

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
    // for (EpubChapter chapter in chapters) {
    //   final document = parse(chapter.HtmlContent!);
    //   final String parsedString =
    //       parse(document.body!.text).documentElement!.text;

    //   var haveImage = null;
    //   final htmlDocument = parsing.parseHtmlDocument(chapter.HtmlContent!);
    //   final allImages = htmlDocument.querySelectorAll("img");
    //   allImages.forEach((element) {
    //     widget.images!.forEach((key, value) {
    //       if (element.attributes["src"]!.contains(key)) {
    //         haveImage = value.Content!;
    //         used[key] = value;
    //       }
    //     });
    //   });

    //   final pageSize =
    //       (_pageKey.currentContext!.findRenderObject() as RenderBox).size;
    //   final textSpan = TextSpan(
    //     text: parsedString,
    //     style: widget.style,
    //   );
    //   final textPainter = TextPainter(
    //     text: textSpan,
    //     textDirection: TextDirection.ltr,
    //   );
    //   textPainter.layout(
    //     minWidth: 0,
    //     maxWidth: pageSize.width - 16,
    //   );

    //   final heightOffset = 150;

    //   // https://medium.com/swlh/flutter-line-metrics-fd98ab180a64
    //   List<LineMetrics> lines = textPainter.computeLineMetrics();
    //   double currentPageBottom = pageSize.height - heightOffset;
    //   int currentPageStartIndex = 0;
    //   int currentPageEndIndex = 0;

    //   for (int i = 0; i < lines.length; i++) {
    //     final line = lines[i];

    //     final left = line.left;
    //     final top = line.baseline - line.ascent;
    //     final bottom = line.baseline + line.descent;

    //     // Current line overflow page
    //     if (currentPageBottom < bottom) {
    //       // https://stackoverflow.com/questions/56943994/how-to-get-the-raw-text-from-a-flutter-textbox/56943995#56943995
    //       currentPageEndIndex =
    //           textPainter.getPositionForOffset(Offset(left, top)).offset;
    //       final pageText = parsedString.substring(
    //           currentPageStartIndex, currentPageEndIndex);
    //       responseData.add(PagingChapter(
    //           title: chapter.Title!, content: pageText, image: haveImage));

    //       currentPageStartIndex = currentPageEndIndex;
    //       currentPageBottom = top + (pageSize.height - heightOffset);
    //     }
    //   }

    //   final lastPageText = PagingChapter(
    //       title: chapter.Title!,
    //       content: parsedString.substring(currentPageStartIndex),
    //       image: haveImage);
    //   responseData.add(lastPageText);
    //   index++;
    // }

    // widget.images!.forEach((key, value) {
    //   if (used[key] == null) {
    //     responseData.add(
    //       PagingChapter(title: "Image", content: "", image: value.Content!),
    //     );
    //   }
    // });

    return Future.value(responseData);
  }

  void _paginate() async {
    if (_pageKey.currentContext == null) return;
    _pageTexts.clear();

    await Future.delayed(Duration(seconds: 1));
    //await paginateHtmlContent(widget.chapters);
    _pageTexts = await generatePaginateTexts(widget.chapters);
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _currentIndex = 0;
      _needPaging = false;
      _isPaging = false;
    });
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
                    ? (_pageTexts[_currentIndex].image != null)
                        ? Wrap(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height -
                                            186,
                                    //maximum height set to 100% of vertical height

                                    maxWidth:
                                        MediaQuery.of(context).size.width - 16,
                                    //maximum width set to 100% of width
                                  ),
                                  child: CachedMemoryImage(
                                    fit: BoxFit.scaleDown,
                                    uniqueKey:
                                        "/${widget.id}/${_pageTexts[_currentIndex].title}/img/$_currentIndex",
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
                          )
                        : Text(_pageTexts[_currentIndex].content,
                            style: TextStyle(fontSize: 16))
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

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

class ViewBookPage extends StatefulWidget {
  final Book book;
  const ViewBookPage({super.key, required this.book});

  @override
  State<ViewBookPage> createState() => _ViewBookPageState();
}

class _ViewBookPageState extends State<ViewBookPage> {
  List<EpubChapter> chapters = [];
  Map<String, EpubByteContentFile> images = {};

  //get chapter from book
  void getChapter() async {
    var targetFile = File(widget.book.filePath!);
    var bytes = await targetFile.readAsBytes();
    EpubBook epubBook = await EpubReader.readBook(bytes);

    EpubContent bookContent = epubBook.Content!;

    setState(() {
      chapters = epubBook.Chapters!;
      //images = bookContent.Images!;
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
    getChapter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.book.title}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PagingText(
          chapters,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          images: images,
        ),
      ),
    );
  }
}

class PagingChapter {
  final String title;
  final String content;
  final CachedMemoryImage? image;

  PagingChapter(this.title, this.content, this.image);
}

//https://gist.github.com/ltvu93/36b249d1b5b5861a5ef58d958a50ad98
class PagingText extends StatefulWidget {
  final List<EpubChapter> chapters;
  final TextStyle style;
  Map<String, EpubByteContentFile>? images;

  PagingText(
    this.chapters, {
    this.style = const TextStyle(
      color: Colors.black,
      fontSize: 16,
    ),
    this.images,
  });

  @override
  _PagingTextState createState() => _PagingTextState();
}

class _PagingTextState extends State<PagingText> {
  final List<PagingChapter> _pageTexts = [];
  int _currentIndex = 0;
  bool _needPaging = true;
  bool _isPaging = false;
  final _pageKey = GlobalKey();

  @override
  void didUpdateWidget(PagingText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.chapters != oldWidget.chapters ||
        widget.images != oldWidget.images) {
      setState(() {
        _pageTexts.clear();
        _currentIndex = 0;
        _needPaging = true;
        _isPaging = false;
      });
    }
  }

  void _paginate() {
    _pageTexts.clear();

    int index = 0;
    widget.chapters.forEach((EpubChapter chapter) {
      if (index == 0) {
        widget.images!.forEach((key, value) {
          var imgData = images.decodeImage(value.Content!);
          if(imgData != null){
            var imgWidget = CachedMemoryImage(
  uniqueKey: value.FileName!,
  bytes: Uint8List.fromList(images.encodePng(imgData)),
  errorWidget: const Text('Error'),
                placeholder: const CircularProgressIndicator(),
);
            _pageTexts.add(
              
              PagingChapter("Image", "", imgWidget));
          }
        });
      }
        
      splitChapter(chapter);
      index++;
    });

    setState(() {
      _currentIndex = 0;
      _needPaging = false;
      _isPaging = false;
    });
  }

  void splitChapter(EpubChapter chapter) {
    if (_pageKey.currentContext == null) return;
    // final document = parse(chapter.HtmlContent!);
    // final String parsedString =
    //     parse(document.body!.text).documentElement!.text;
    
    final String parsedString = chapter.HtmlContent!.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');

    CachedMemoryImage? haveImage = null;
    // if (widget.images != null) {
    //   final htmlDocument = parsing.parseHtmlDocument(chapter.HtmlContent!);
    //   final allImages = htmlDocument.querySelectorAll("img");
    //   allImages.forEach((element) {
    //     widget.images!.forEach((key, value) {
    //       if (element.attributes["src"]!.contains(key)) {
    //         //print("Found : ${element.attributes["src"]} = ${key}");
    //         haveImage = images.decodeImage(value.Content!);
    //       } else {
    //         //print("Not Found : ${element.attributes["src"]}");
    //       }
    //     });
    //   });
    // }

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
        final pageText =
            parsedString.substring(currentPageStartIndex, currentPageEndIndex);
        _pageTexts.add(PagingChapter(chapter.Title!, pageText, haveImage));

        currentPageStartIndex = currentPageEndIndex;
        currentPageBottom = top + (pageSize.height - heightOffset);
      }
    }

    final lastPageText = PagingChapter(chapter.Title!,
        parsedString.substring(currentPageStartIndex), haveImage);
    _pageTexts.add(lastPageText);
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
                    ? Column(
                        children: [
                          if (_pageTexts[_currentIndex].image != null)
                            _pageTexts[_currentIndex].image!,
                          Text(
                            _isPaging ? ' ' : _pageTexts[_currentIndex].content,
                            style: widget.style,
                          )
                        ],
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ),
            Row(
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
                  _isPaging ? '' : '${_currentIndex + 1}/${_pageTexts.length}',
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

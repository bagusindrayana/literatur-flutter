import 'dart:typed_data';

import 'package:Literatur/helpers/UIHelper.dart';
import 'package:Literatur/repositories/TranslateRepository.dart';
import 'package:flutter/material.dart';
import 'package:Literatur/models/Book.dart';
import 'package:Literatur/repositories/BookRepository.dart';
import 'package:Literatur/widgets/BookCard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as images;
import 'package:flutter/widgets.dart' as widgets;
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  BookRepository _bookRepository = BookRepository();
  StatusProcessBook loadDataStatus = StatusProcessBook.loading;
  TranslateRepository _translateRepository = TranslateRepository();

  List<Book> books = [];
  List<Book> multiSelectBooks = [];
  bool multiSelectMode = false;
  bool showLoading = false;

  void selectBook(Book book) {
    if (multiSelectBooks.contains(book)) {
      multiSelectBooks.remove(book);
    } else {
      multiSelectBooks.add(book);
    }
    setState(() {});
  }

  void _multiDeleteBooks() async {
    multiSelectBooks.forEach((element) {
      _translateRepository.deleteTranslates(element.id);
      //delete file
      File file = File(element.filePath!);
      if (file.existsSync()) {
        file.deleteSync();
      }

      //delete cover image
      if (element.coverImage != null) {
        File coverImage = File(element.coverImage!);
        if (coverImage.existsSync()) {
          coverImage.deleteSync();
        }
      }
    });
    await _bookRepository
        .deleteBooks(multiSelectBooks.map((e) => e.id).toList());
    multiSelectBooks.clear();
    multiSelectMode = false;
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      loadDataStatus = StatusProcessBook.loading;
    });
    books = await _bookRepository.getBooks(_searchController.text);
    setState(() {
      loadDataStatus = StatusProcessBook.success;
    });
  }

  void _pickEpub() {
    FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'],
    ).then((result) {
      if (result != null) {
        PlatformFile file = result.files.first;
        _parseEpub(file);
      }
    });
  }

  void _insertBook(Book book) {
    _bookRepository.addBook(book, book.originalFilePath!).then((v) {
      setState(() {
        showLoading = false;
      });
      _loadData();
    });
  }

  void _copyEpuub(Book book) {
    File originalFile = File(book.originalFilePath!);
    File targetFile = File(book.filePath!);

    if (targetFile.existsSync()) {
      targetFile.deleteSync();
    }

    targetFile.create(recursive: true).then((_) {
      targetFile.writeAsBytes(originalFile.readAsBytesSync()).then((_) {
        _insertBook(book);
      });
    });
  }

  void _copyCoverImage(
    Book book,
    images.Image coverImage,
  ) {
    //save image
    if (book.coverImage != null) {
      File coverImageFile = File(book.coverImage!);
      if (coverImageFile.existsSync()) {
        coverImageFile.deleteSync();
      }

      coverImageFile.create(recursive: true).then((_) {
        coverImageFile.writeAsBytes(images.encodeJpg(coverImage)).then((_) {
          _copyEpuub(book);
        });
      });
    }
  }

  void _parseEpub(PlatformFile file) {
    List<int>? bytes = file.bytes;
    if (bytes == null) {
      {
        String fullPath = file.path!;
        var targetFile = File(fullPath);
        targetFile.readAsBytes().then((bytes) {
          EpubReader.readBook(bytes).then((EpubBook epubBook) {
            images.Image? coverImage = epubBook.CoverImage;
            if (coverImage == null) {
              EpubContent bookContent = epubBook.Content!;
              Map<String, EpubByteContentFile> _images = bookContent.Images!;
              if (_images.isNotEmpty) {
                EpubByteContentFile image = _images.values.first;
                coverImage =
                    images.decodeImage(Uint8List.fromList(image.Content!));
              }
            }
            final timeString = DateTime.now().millisecondsSinceEpoch.toString();
            getApplicationDocumentsDirectory().then((directory) {
              //copy file to storage
              String saveDir = directory.path + '/books';
              String savePath = '$saveDir/${timeString}_${file.name}';

              Book newBook = Book();
              newBook.title =
                  file.name.replaceAll(file.extension.toString(), "");
              newBook.filePath = savePath;
              newBook.originalFilePath = file.path;
              newBook.chapters = [];
              if (coverImage != null) {
                newBook.coverImage = '$saveDir/${timeString}_${file.name}.jpg';
                _copyCoverImage(newBook, coverImage);
              } else {
                _copyEpuub(newBook);
              }
            });
          });
        });
      }
    }
  }

  void _addBook() {
    setState(() {
      showLoading = true;
    });

    try {
      _pickEpub();
    } catch (e) {
      Logger().e(e);
      setState(() {
        showLoading = false;
      });
      UIHelper.showSnackBar(context, "Failed to open file");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // final gemini = Gemini.instance;
    // gemini.text("what you can do?").then((value) {
    //   print(value?.output);
    // }).catchError((e) {
    //   Logger().e(e);
    // });
    Future.delayed(Duration.zero, () {
      WakelockPlus.disable();
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (!multiSelectMode)
          ? AppBar(
              title: Text("Literatur"),
              actions: [
                IconButton(
                    onPressed: () {
                      AdaptiveTheme.of(context).toggleThemeMode();
                    },
                    icon: AdaptiveTheme.of(context).mode.isDark
                        ? Icon(Icons.light_mode)
                        : Icon(Icons.dark_mode)),
              ],
            )
          : AppBar(
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    multiSelectMode = false;
                    multiSelectBooks.clear();
                    setState(() {});
                  }),
              title: Text("${multiSelectBooks.length} selected"),
            ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) {
                _loadData();
              },
              onChanged: (value) {
                if (value.isEmpty) {
                  _loadData();
                }
              },
            ),
          ),
          if (loadDataStatus == StatusProcessBook.loading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (books.length == 0)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _addBook();
                },
                child: Text('Add Book'),
              ),
            )
          else
            Expanded(
              child: Stack(
                children: [
                  if (showLoading)
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                  RefreshIndicator(
                      onRefresh: () async {
                        return _loadData();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, left: 8.0, right: 8.0, bottom: 0),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: books.length,
                          itemBuilder: (context, index) {
                            return BookCard(
                              title: "${books[index].title}",
                              thumbnail: books[index].coverImage != null
                                  ? widgets.Image.file(
                                      File("${books[index].coverImage}"),
                                      fit: BoxFit.fitHeight)
                                  : null,
                              selectMode: multiSelectMode,
                              isSelected:
                                  multiSelectBooks.contains(books[index]),
                              onSelect: (isSelected) {
                                if (isSelected) {
                                  multiSelectBooks.add(books[index]);
                                } else {
                                  multiSelectBooks.remove(books[index]);
                                }
                                setState(() {});
                              },
                              onLongPress: () {
                                if (!multiSelectMode) {
                                  multiSelectMode = true;
                                  multiSelectBooks.add(books[index]);
                                  setState(() {});
                                }
                              },
                              onTap: () {
                                if (!multiSelectMode) {
                                  Navigator.pushNamed(context, '/view',
                                          arguments: books[index])
                                      .then((v) {
                                    _loadData();
                                  });
                                }
                              },
                            );
                          },
                        ),
                      ))
                ],
              ),
            ),
        ],
      ),
      //show floating button if book > 0
      floatingActionButton: books.length > 0
          ? (!multiSelectMode)
              ? FloatingActionButton(
                  onPressed: () {
                    _addBook();
                  },
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                )
              : FloatingActionButton(
                  onPressed: () {
                    _multiDeleteBooks();
                  },
                  child: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                )
          : null,
    );
  }
}

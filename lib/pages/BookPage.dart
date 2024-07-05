import 'package:flutter/material.dart';
import 'package:Literatur/models/Book.dart';
import 'package:Literatur/repositories/BookRepository.dart';
import 'package:Literatur/widgets/BookCard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:epubx/epubx.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as images;
import 'package:flutter/widgets.dart' as widgets;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  BookRepository _bookRepository = BookRepository();
  StatusProcessBook loadDataStatus = StatusProcessBook.loading;

  List<Book> books = [];
  List<Book> multiSelectBooks = [];
  bool multiSelectMode = false;

  void selectBook(Book book) {
    if (multiSelectBooks.contains(book)) {
      multiSelectBooks.remove(book);
    } else {
      multiSelectBooks.add(book);
    }
    setState(() {});
  }

  void _multiDeleteBooks() async {
    await _bookRepository
        .deleteBooks(multiSelectBooks.map((e) => e.id).toList());
    multiSelectBooks.clear();
    multiSelectMode = false;
    _loadData();
  }

  void _loadData() async {
    setState(() {
      loadDataStatus = StatusProcessBook.loading;
    });
    books = await _bookRepository.getBooks(_searchController.text);
    setState(() {
      loadDataStatus = StatusProcessBook.success;
    });
  }

  void _addBook() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      List<int>? bytes;
      if (file.bytes != null) {
        bytes = file.bytes!;
      } else {
        String fullPath = file.path!;
        var targetFile = File(fullPath);
        bytes = await targetFile.readAsBytes();
      }

      if (bytes != null) {
        EpubBook epubBook = await EpubReader.readBook(bytes);

        images.Image? coverImage = epubBook.CoverImage;
        if (coverImage == null) {
          EpubContent bookContent = epubBook.Content!;
          Map<String, EpubByteContentFile> _images = bookContent.Images!;
          if (_images.isNotEmpty) {
            EpubByteContentFile image = _images.values.first;
            coverImage = images.decodeImage(image.Content!);
          }
        }
        final timeString = DateTime.now().millisecondsSinceEpoch.toString();
        final directory = await getApplicationDocumentsDirectory();
        //copy file to storage
        String saveDir = directory.path + '/books';
        String savePath = '$saveDir/${timeString}_${file.name}';
        File targetFile = File(savePath);
        if (targetFile.existsSync()) {
          targetFile.deleteSync();
        }

        targetFile.createSync(recursive: true);
        targetFile.writeAsBytesSync(bytes);

        //save image
        if (coverImage != null) {
          String coverImagePath = '$saveDir/${timeString}_${file.name}.jpg';
          File coverImageFile = File(coverImagePath);
          if (coverImageFile.existsSync()) {
            coverImageFile.deleteSync();
          }

          coverImageFile.createSync(recursive: true);
          coverImageFile.writeAsBytesSync(images.encodeJpg(coverImage));
        }

        Book newBook = Book();
        newBook.title = file.name.replaceAll(file.extension.toString(), "");
        newBook.filePath = savePath;
        newBook.originalFilePath = file.path;
        if (coverImage != null) {
          newBook.coverImage = '$saveDir/${timeString}_${file.name}.jpg';
        }

        await _bookRepository.addBook(newBook, file.path);
        _loadData();
      }
    } else {
      // User canceled the picker
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (!multiSelectMode)
          ? AppBar(
              title: Text("Literatur"),
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
              child: RefreshIndicator(
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
                                  fit: BoxFit.fitWidth)
                              : null,
                          selectMode: multiSelectMode,
                          isSelected: multiSelectBooks.contains(books[index]),
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
                        );
                      },
                    ),
                  )),
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
                  child: Icon(Icons.add),
                )
              : FloatingActionButton(
                  onPressed: () {
                    _multiDeleteBooks();
                  },
                  child: Icon(Icons.delete),
                )
          : null,
    );
  }
}

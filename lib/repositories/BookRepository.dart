import 'package:Literatur/models/Book.dart';
import 'package:Literatur/models/Translate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';

enum StatusProcessBook { loading, success, error }

class BookRepository {
  Future<Isar?> initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    var isar = Isar.getInstance();
    //if isar already exists, open it
    if (isar != null) {
      return isar;
    } else {
      //if isar does not exist, create it
      isar = await Isar.open(
        [BookSchema, TranslateSchema],
        directory: dir.path,
      );
      return isar;
    }
  }

  //get list book with search by title
  Future<List<Book>> getBooks(String title) async {
    final isar = await initDB();
    if (isar != null) {
      return isar.books.where().filter().titleContains(title).findAll();
    } else {
      return [];
    }
  }

  //add book
  Future<void> addBook(Book book, String? originalPath) async {
    final isar = await initDB();
    if (isar != null) {
      if (originalPath == null) {
        await isar.writeTxn<void>(() async => await isar.books.put(book));
      } else {
        //find by original path
        final bookExist = await isar.books
            .where()
            .filter()
            .originalFilePathEqualTo(originalPath)
            .findFirst();
        if (bookExist == null) {
          await isar.writeTxn<void>(() async => await isar.books.put(book));
        }
      }
    }
  }

  //get by id
  Future<Book?> getBookById(int id) async {
    final isar = await initDB();
    if (isar != null) {
      return isar.books.get(id);
    } else {
      return null;
    }
  }

  //multi delete by id
  Future<void> deleteBooks(List<int> ids) async {
    final isar = await initDB();
    if (isar != null) {
      await isar.writeTxn<void>(() async {
        for (var id in ids) {
          await isar.books.delete(id);
        }
      });
    }
  }

  //update lastReadPosition
  Future<void> updateLastReadPosition(int id, String lastReadPosition) async {
    final isar = await initDB();
    if (isar != null) {
      await isar.writeTxn<void>(() async {
        final book = await isar.books.get(id);
        if (book != null) {
          book.lastReadPosition = lastReadPosition;
          await isar.books.put(book);
        }
      });
    }
  }

  //update lastTranslateId
  Future<void> updateLastTranslateId(int id, int lastTranslateId) async {
    final isar = await initDB();
    if (isar != null) {
      await isar.writeTxn<void>(() async {
        final book = await isar.books.get(id);
        if (book != null) {
          book.lastTranslateId = lastTranslateId;
          await isar.books.put(book);
        }
      });
    }
  }

  //update book
  Future<void> updateBook(int id, Book book) async {
    final isar = await initDB();
    if (isar != null) {
      await isar.writeTxn<void>(() async {
        final bookExist = await isar.books.get(id);
        if (bookExist != null) {
          book.id = bookExist.id;
          await isar.books.put(book);
        }
      });
    }
  }

  //add chapter
  Future<void> addChapter(int id, Chapter chapter) async {
    final isar = await initDB();
    if (isar != null) {
      await isar.writeTxn<void>(() async {
        final book = await isar.books.get(id);
        if (book != null) {
          book.chapters = [...book.chapters, chapter];
          await isar.books.put(book);
        }
      });
    }
  }

  //update chapter
  Future<void> updateChapter(int bookId, Chapter chapter) async {
    final isar = await initDB();
    if (isar != null) {
      await isar.writeTxn<void>(() async {
        final book = await isar.books.get(bookId);

        if (book != null) {
          if (book.chapters.isNotEmpty) {
            final index = book.chapters.indexWhere((element) =>
                element.translateId == chapter.translateId &&
                element.title!.trim() == chapter.title!.trim() &&
                element.key!.trim() == chapter.key!.trim());
            if (index != -1) {
              var tmp = book.chapters;
              tmp[index] = chapter;
              book.chapters = tmp;
              await isar.books.put(book);
            }
          } else {
            book.chapters = [chapter];
            await isar.books.put(book);
          }
        }
      });
    }
  }

  //delete book
  Future<void> deleteBook(int id) async {
    final isar = await initDB();
    if (isar != null) {
      await isar.writeTxn<void>(() async {
        await isar.books.delete(id);
      });
    }
  }
}

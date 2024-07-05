import 'package:Literatur/models/Book.dart';
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
        [BookSchema],
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
}

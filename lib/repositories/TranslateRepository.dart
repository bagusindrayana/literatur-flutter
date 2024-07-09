import 'package:Literatur/models/Book.dart';
import 'package:Literatur/models/Translate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';

class TranslateRepository {
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

  //get translate by bookId
  Future<List<Translate>> getTranslates(int bookId) async {
    final isar = await initDB();
    if (isar != null) {
      return isar.translates.where().filter().bookIdEqualTo(bookId).findAll();
    } else {
      return [];
    }
  }

  //add translate
  Future<void> addTranslate(Translate translate) async {
    final isar = await initDB();
    if (isar != null) {
      await isar
          .writeTxn<void>(() async => await isar.translates.put(translate));
    }
  }

  //delete translate by bookId
  Future<void> deleteTranslates(int bookId) async {
    final isar = await initDB();
    if (isar != null) {
      await isar.writeTxn<void>(() async {
        await isar.translates
            .where()
            .filter()
            .bookIdEqualTo(bookId)
            .deleteAll();
      });
    }
  }

  //delete translate by id
  Future<void> deleteTranslate(int id) async {
    final isar = await initDB();
    if (isar != null) {
      await isar.writeTxn<void>(() async {
        await isar.translates.where().filter().idEqualTo(id).deleteAll();
      });
    }
  }
}

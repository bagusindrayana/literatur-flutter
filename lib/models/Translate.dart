import 'package:isar/isar.dart';

part 'Translate.g.dart';

@collection
class Translate {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment
  int bookId = 0;
  String? prePrompt;
  String? fromLanguage;
  String? toLanguage;
  String? lastReadPosition;
}

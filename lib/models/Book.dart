import 'package:isar/isar.dart';

part 'Book.g.dart';

@collection
class Book {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  String? title;
  String? filePath;
  String? originalFilePath;
  String? coverImage;
  List<Chapter> chapters = [];
  String? prePrompt;
  String? lastReadPosition;
  int? lastTranslateId;
}

@embedded
class Chapter {
  int order = 0;
  int translateId = 0;
  String? key;
  String? title;
  String? originalContent;
  String? translatedTitle;
  String? translatedContent;
  String? prePrompt;
  String? fromLanguage;
  String? toLanguage;
  int? statusTranslation;
}

import 'package:isar/isar.dart';

part 'Book.g.dart';

@collection
class Book {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  String? title;
  String? filePath;
  String? originalFilePath;
  String? coverImage;
  List<Chapter>? chapters;
  String? prePrompt;
}

@embedded
class Chapter {
  String? title;
  String? originalContent;
  String? translatedContent;
  String? prePrompt;
  int? statusTranslation;
}

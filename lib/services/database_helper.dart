import 'dart:io';

import 'package:flutter/services.dart';
import 'package:myanmar_dictionary_mobile/models/word_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static final previewColumns = ["id", "word", "part_of_speech", "phonetics"];

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, "mm_mm.db");

    if (!await File(path).exists()) {
      ByteData data = await rootBundle.load("assets/databases/mm_mm.db");
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes);
    }

    return await openDatabase(path, readOnly: true);
  }

  static Future<PaginatedResult<WordPreviewModel>> searchWord(
    String keyword, {
    int page = 1,
    int limit = 20,
  }) async {
    final db = await database;

    // Get total count for hasMore calculation
    final countResult = await db.rawQuery(
      'SELECT COUNT(DISTINCT word) as total FROM dictionary_words WHERE word LIKE ?',
      ['$keyword%'],
    );
    final total = countResult.first['total'] as int;

    final data = await db.query(
      "dictionary_words",
      where: "word LIKE ?",
      distinct: true,
      whereArgs: ['$keyword%'],
      columns: previewColumns,
      groupBy: "word",
      limit: limit,
      offset: (page - 1) * limit,
    );

    final words = data.map((word) => WordPreviewModel.fromJson(word)).toList();

    return PaginatedResult(
      total: total,
      items: words,
      currentPage: page,
      limit: limit,
      hasMore: (page * limit) < total,
    );
  }

  // Example: get all words
  static Future<List<WordPreviewModel>> getAllWords() async {
    final db = await database;
    final data = await db.query(
      'dictionary_words',
      distinct: true,
      columns: previewColumns,
      groupBy: "word",
    );
    final words = data.map((word) => WordPreviewModel.fromJson(word)).toList();

    return words;
  }

  static Future<List<WordModel>> getWordsWithWordName(String wordName) async {
    final db = await database;
    final data = await db.query(
      'dictionary_words',
      where: "word = ?",
      whereArgs: [wordName],
    );
    final words = data.map((word) => WordModel.fromJson(word)).toList();

    return words;
  }
}

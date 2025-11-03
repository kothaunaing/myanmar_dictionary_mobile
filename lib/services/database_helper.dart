import 'dart:io';

import 'package:flutter/services.dart';
import 'package:myanmar_dictionary_mobile/models/word_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static Database? _userDatabase;
  static final previewColumns = ["id", "word", "part_of_speech", "phonetics"];

  // Database names
  static const String _mainDbName = "mm_mm.db";
  static const String _userDbName = "user_data.db";

  // Table names for user data
  static const String tableFavorites = "favorites";
  static const String tableRecents = "recents";

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initMainDB();
    return _database!;
  }

  static Future<Database> get userDatabase async {
    if (_userDatabase != null) return _userDatabase!;
    _userDatabase = await _initUserDB();
    return _userDatabase!;
  }

  static Future<Database> _initMainDB() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, _mainDbName);

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

  static Future<Database> _initUserDB() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, _userDbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create favorites table
        await db.execute('''
          CREATE TABLE $tableFavorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word_id INTEGER NOT NULL,
            word TEXT NOT NULL,
            part_of_speech TEXT,
            phonetics TEXT,
            created_at INTEGER NOT NULL
          )
        ''');

        // Create recents table
        await db.execute('''
          CREATE TABLE $tableRecents (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word_id INTEGER NOT NULL,
            word TEXT NOT NULL,
            part_of_speech TEXT,
            phonetics TEXT,
            accessed_at INTEGER NOT NULL
          )
        ''');

        // Create indexes for better performance
        await db.execute('''
          CREATE UNIQUE INDEX idx_favorites_word_id 
          ON $tableFavorites (word_id)
        ''');

        await db.execute('''
          CREATE INDEX idx_recents_accessed_at 
          ON $tableRecents (accessed_at)
        ''');

        await db.execute('''
          CREATE UNIQUE INDEX idx_recents_word_id 
          ON $tableRecents (word_id)
        ''');
      },
    );
  }

  // Favorite words methods
  static Future<void> addToFavorites(WordPreviewModel word) async {
    final db = await userDatabase;

    // Check if already in favorites
    final existing = await db.query(
      tableFavorites,
      where: 'word_id = ?',
      whereArgs: [word.id],
    );

    if (existing.isEmpty) {
      await db.insert(tableFavorites, {
        'word_id': word.id,
        'word': word.word,
        'part_of_speech': word.partOfSpeech,
        'phonetics': word.phonetics,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  static Future<void> removeFromFavorites(String wordName) async {
    final db = await userDatabase;
    await db.delete(tableFavorites, where: 'word = ?', whereArgs: [wordName]);
  }

  static Future<bool> isFavorite(String wordName) async {
    final db = await userDatabase;
    final result = await db.query(
      tableFavorites,
      where: 'word = ?',
      whereArgs: [wordName],
    );
    return result.isNotEmpty;
  }

  // Updated favorites method with pagination
  static Future<PaginatedResult<WordPreviewModel>> getFavoritesPaginated({
    int page = 1,
    int limit = 20,
  }) async {
    final db = await userDatabase;

    // Get total count
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM $tableFavorites',
    );
    final total = countResult.first['total'] as int;

    // Get paginated data
    final data = await db.query(
      tableFavorites,
      orderBy: 'created_at DESC',
      limit: limit,
      offset: (page - 1) * limit,
    );

    final words =
        data
            .map(
              (word) => WordPreviewModel.fromJson({
                'id': word['word_id'],
                'word': word['word'],
                'part_of_speech': word['part_of_speech'],
                'phonetics': word['phonetics'],
              }),
            )
            .toList();

    return PaginatedResult(
      total: total,
      items: words,
      currentPage: page,
      limit: limit,
      hasMore: (page * limit) < total,
    );
  }

  // Keep the original method for backward compatibility
  static Future<List<WordPreviewModel>> getFavorites() async {
    final db = await userDatabase;
    final data = await db.query(tableFavorites, orderBy: 'created_at DESC');

    return data
        .map(
          (word) => WordPreviewModel.fromJson({
            'id': word['word_id'],
            'word': word['word'],
            'part_of_speech': word['part_of_speech'],
            'phonetics': word['phonetics'],
          }),
        )
        .toList();
  }

  // Recent words methods
  static Future<void> addToRecents(WordPreviewModel word) async {
    final db = await userDatabase;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Check if already in recents
    final existing = await db.query(
      tableRecents,
      where: 'word_id = ?',
      whereArgs: [word.id],
    );

    if (existing.isNotEmpty) {
      // Update access time if exists
      await db.update(
        tableRecents,
        {'accessed_at': now},
        where: 'word_id = ?',
        whereArgs: [word.id],
      );
    } else {
      // Insert new recent word
      await db.insert(tableRecents, {
        'word_id': word.id,
        'word': word.word,
        'part_of_speech': word.partOfSpeech,
        'phonetics': word.phonetics,
        'accessed_at': now,
      });
    }

    // Limit recents to last 50 items to prevent database from growing too large
    await _cleanupRecents();
  }

  static Future<void> _cleanupRecents() async {
    final db = await userDatabase;

    // Delete all but the 50 most recent items
    await db.execute('''
      DELETE FROM $tableRecents 
      WHERE id NOT IN (
        SELECT id FROM $tableRecents 
        ORDER BY accessed_at DESC 
        LIMIT 50
      )
    ''');
  }

  // Updated recents method with pagination
  static Future<PaginatedResult<WordPreviewModel>> getRecentsPaginated({
    int page = 1,
    int limit = 20,
  }) async {
    final db = await userDatabase;

    // Get total count (max 50 due to cleanup)
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM $tableRecents',
    );
    final total = countResult.first['total'] as int;

    // Get paginated data
    final data = await db.query(
      tableRecents,
      orderBy: 'accessed_at DESC',
      limit: limit,
      offset: (page - 1) * limit,
    );

    final words =
        data
            .map(
              (word) => WordPreviewModel.fromJson({
                'id': word['word_id'],
                'word': word['word'],
                'part_of_speech': word['part_of_speech'],
                'phonetics': word['phonetics'],
              }),
            )
            .toList();

    return PaginatedResult(
      total: total,
      items: words,
      currentPage: page,
      limit: limit,
      hasMore: (page * limit) < total,
    );
  }

  // Keep the original method for backward compatibility
  static Future<List<WordPreviewModel>> getRecents() async {
    final db = await userDatabase;
    final data = await db.query(tableRecents, orderBy: 'accessed_at DESC');

    return data
        .map(
          (word) => WordPreviewModel.fromJson({
            'id': word['word_id'],
            'word': word['word'],
            'part_of_speech': word['part_of_speech'],
            'phonetics': word['phonetics'],
          }),
        )
        .toList();
  }

  static Future<void> clearRecents() async {
    final db = await userDatabase;
    await db.delete(tableRecents);
  }

  static Future<void> removeRecent(int wordId) async {
    final db = await userDatabase;
    await db.delete(tableRecents, where: 'word_id = ?', whereArgs: [wordId]);
  }

  // Original methods remain unchanged
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

  static Future<List<WordPreviewModel?>> getPrevAndNextWords(
    String currentWord,
  ) async {
    final db = await database;

    final prevWordResult = await db.rawQuery(
      ''' 
    SELECT DISTINCT * FROM dictionary_words
    WHERE LOWER(word) < LOWER(?)
    ORDER BY LOWER(word) DESC LIMIT 1
    ''',
      [currentWord],
    );

    final nextWordResult = await db.rawQuery(
      ''' 
    SELECT DISTINCT * FROM dictionary_words
    WHERE LOWER(word) > LOWER(?)
    ORDER BY LOWER(word) ASC LIMIT 1
    ''',
      [currentWord],
    );

    final prevWord =
        prevWordResult.isEmpty
            ? null
            : WordPreviewModel.fromJson(prevWordResult.first);
    final nextWord =
        nextWordResult.isEmpty
            ? null
            : WordPreviewModel.fromJson(nextWordResult.first);

    return [prevWord, nextWord];
  }
}

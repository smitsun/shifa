import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shifa_cache.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE subjects (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        thumbnailUrl TEXT,
        chaptersCount INTEGER,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE chapters (
        id TEXT PRIMARY KEY,
        subjectId TEXT,
        title TEXT,
        description TEXT,
        videosCount INTEGER,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE videos (
        id TEXT PRIMARY KEY,
        subjectId TEXT,
        chapterId TEXT,
        title TEXT,
        description TEXT,
        youtubeUrl TEXT,
        thumbnailUrl TEXT,
        duration TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE progress (
        id TEXT PRIMARY KEY, -- userId_videoId
        userId TEXT,
        videoId TEXT,
        subjectId TEXT,
        chapterId TEXT,
        watchTime INTEGER,
        isCompleted INTEGER,
        lastWatchedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE bookmarks (
        id TEXT PRIMARY KEY, -- userId_itemId
        userId TEXT,
        itemId TEXT,
        itemType TEXT,
        bookmarkedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        userId TEXT,
        videoId TEXT,
        noteText TEXT,
        timestampInSeconds INTEGER,
        createdAt TEXT
      )
    ''');
  }

  // --- Caching Subjects ---
  Future<void> cacheSubjects(List<SubjectModel> subjects) async {
    final db = await database;
    final batch = db.batch();
    for (var sub in subjects) {
      batch.insert('subjects', sub.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<SubjectModel>> getCachedSubjects() async {
    final db = await database;
    final maps = await db.query('subjects');
    return maps.map((m) => SubjectModel.fromMap(m)).toList();
  }

  // --- Caching Chapters ---
  Future<void> cacheChapters(List<ChapterModel> chapters) async {
    final db = await database;
    final batch = db.batch();
    for (var ch in chapters) {
      batch.insert('chapters', ch.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<ChapterModel>> getCachedChapters(String subjectId) async {
    final db = await database;
    final maps = await db.query('chapters', where: 'subjectId = ?', whereArgs: [subjectId]);
    return maps.map((m) => ChapterModel.fromMap(m)).toList();
  }

  // --- Caching Videos ---
  Future<void> cacheVideos(List<VideoModel> videos) async {
    final db = await database;
    final batch = db.batch();
    for (var v in videos) {
      batch.insert('videos', v.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<VideoModel>> getCachedVideos(String chapterId) async {
    final db = await database;
    final maps = await db.query('videos', where: 'chapterId = ?', whereArgs: [chapterId]);
    return maps.map((m) => VideoModel.fromMap(m)).toList();
  }

  Future<VideoModel?> getCachedVideoById(String videoId) async {
    final db = await database;
    final maps = await db.query('videos', where: 'id = ?', whereArgs: [videoId]);
    if (maps.isEmpty) return null;
    return VideoModel.fromMap(maps.first);
  }

  Future<List<VideoModel>> searchCachedVideos(String query) async {
    final db = await database;
    final maps = await db.query(
      'videos',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((m) => VideoModel.fromMap(m)).toList();
  }

  // --- Caching Progress ---
  Future<void> saveProgress(VideoProgressModel progress) async {
    final db = await database;
    final key = '${progress.userId}_${progress.videoId}';
    final map = progress.toMap();
    map['id'] = key;
    await db.insert('progress', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<VideoProgressModel?> getProgress(String userId, String videoId) async {
    final db = await database;
    final key = '${userId}_${videoId}';
    final maps = await db.query('progress', where: 'id = ?', whereArgs: [key]);
    if (maps.isEmpty) return null;
    return VideoProgressModel.fromMap(maps.first);
  }

  Future<List<VideoProgressModel>> getAllUserProgress(String userId) async {
    final db = await database;
    final maps = await db.query('progress', where: 'userId = ?', whereArgs: [userId]);
    return maps.map((m) => VideoProgressModel.fromMap(m)).toList();
  }

  // --- Bookmarks ---
  Future<void> saveBookmark(BookmarkModel bookmark) async {
    final db = await database;
    final key = '${bookmark.userId}_${bookmark.itemId}';
    final map = bookmark.toMap();
    map['id'] = key;
    await db.insert('bookmarks', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteBookmark(String userId, String itemId) async {
    final db = await database;
    final key = '${userId}_${itemId}';
    await db.delete('bookmarks', where: 'id = ?', whereArgs: [key]);
  }

  Future<bool> isBookmarked(String userId, String itemId) async {
    final db = await database;
    final key = '${userId}_${itemId}';
    final maps = await db.query('bookmarks', where: 'id = ?', whereArgs: [key]);
    return maps.isNotEmpty;
  }

  Future<List<BookmarkModel>> getBookmarks(String userId) async {
    final db = await database;
    final maps = await db.query('bookmarks', where: 'userId = ?', whereArgs: [userId]);
    return maps.map((m) => BookmarkModel.fromMap(m)).toList();
  }

  // --- Notes ---
  Future<void> saveNote(VideoNoteModel note) async {
    final db = await database;
    await db.insert('notes', note.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<VideoNoteModel>> getVideoNotes(String userId, String videoId) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'userId = ? AND videoId = ?',
      whereArgs: [userId, videoId],
      orderBy: 'timestampInSeconds ASC',
    );
    return maps.map((m) => VideoNoteModel.fromMap(m)).toList();
  }
}

import '../../core/services/database_helper.dart';
import '../../core/services/network_info.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/interfaces.dart';
import '../datasources/remote_datasource.dart';
import '../models/models.dart';

class LearningRepositoryImpl implements LearningRepository {
  final RemoteDataSource remoteDataSource;
  final DatabaseHelper dbHelper;
  final NetworkInfo networkInfo;
  final String currentUserId; // Required to scope progress, notes and bookmarks

  LearningRepositoryImpl({
    required this.remoteDataSource,
    required this.dbHelper,
    required this.networkInfo,
    required this.currentUserId,
  });

  @override
  Future<List<Subject>> getSubjects({bool forceRefresh = false}) async {
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteDataSource.getSubjects();
        await dbHelper.cacheSubjects(remote);
        return remote;
      } catch (_) {
        // Fallback to cache if remote call errors out
        return await dbHelper.getCachedSubjects();
      }
    } else {
      return await dbHelper.getCachedSubjects();
    }
  }

  @override
  Future<List<Chapter>> getChapters(String subjectId, {bool forceRefresh = false}) async {
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteDataSource.getChapters(subjectId);
        await dbHelper.cacheChapters(remote);
        return remote;
      } catch (_) {
        return await dbHelper.getCachedChapters(subjectId);
      }
    } else {
      return await dbHelper.getCachedChapters(subjectId);
    }
  }

  @override
  Future<List<Video>> getVideos(String subjectId, String chapterId, {bool forceRefresh = false}) async {
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteDataSource.getVideos(subjectId, chapterId);
        await dbHelper.cacheVideos(remote);
        return remote;
      } catch (_) {
        return await dbHelper.getCachedVideos(chapterId);
      }
    } else {
      return await dbHelper.getCachedVideos(chapterId);
    }
  }

  @override
  Future<List<Video>> searchVideos(String query) async {
    // Queries local SQLite index for super fast and offline global search
    return await dbHelper.searchCachedVideos(query);
  }

  // --- Progress Tracking ---
  @override
  Future<VideoProgress?> getProgress(String videoId) async {
    return await dbHelper.getProgress(currentUserId, videoId);
  }

  @override
  Future<void> saveProgress(
    String videoId,
    String subjectId,
    String chapterId,
    int watchTime,
    bool isCompleted,
  ) async {
    final progress = VideoProgressModel(
      userId: currentUserId,
      videoId: videoId,
      subjectId: subjectId,
      chapterId: chapterId,
      watchTime: watchTime,
      isCompleted: isCompleted,
      lastWatchedAt: DateTime.now(),
    );
    await dbHelper.saveProgress(progress);
    
    // Increment watched lectures count in user streak tracker if finished
    if (isCompleted) {
      // Typically fires a Firestore sync in production
    }
  }

  @override
  Future<List<VideoProgress>> getAllUserProgress() async {
    return await dbHelper.getAllUserProgress(currentUserId);
  }

  // --- Bookmarks ---
  @override
  Future<List<Bookmark>> getBookmarks() async {
    return await dbHelper.getBookmarks(currentUserId);
  }

  @override
  Future<void> addBookmark(String itemId, String itemType) async {
    final b = BookmarkModel(
      userId: currentUserId,
      itemId: itemId,
      itemType: itemType,
      bookmarkedAt: DateTime.now(),
    );
    await dbHelper.saveBookmark(b);
  }

  @override
  Future<void> removeBookmark(String itemId) async {
    await dbHelper.deleteBookmark(currentUserId, itemId);
  }

  @override
  Future<bool> isBookmarked(String itemId) async {
    return await dbHelper.isBookmarked(currentUserId, itemId);
  }

  // --- Personal Video Notes ---
  @override
  Future<List<VideoNote>> getVideoNotes(String videoId) async {
    return await dbHelper.getVideoNotes(currentUserId, videoId);
  }

  @override
  Future<VideoNote> addNote(String videoId, String noteText, int timestampInSeconds) async {
    final note = VideoNoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUserId,
      videoId: videoId,
      noteText: noteText,
      timestampInSeconds: timestampInSeconds,
      createdAt: DateTime.now(),
    );
    await dbHelper.saveNote(note);
    return note;
  }

  @override
  Future<void> deleteNote(String noteId) async {
    await dbHelper.deleteNote(noteId);
  }
}

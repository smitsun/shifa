import '../entities/entities.dart';

abstract class AuthRepository {
  Future<AppUser?> get currentUser;
  Future<AppUser> login(String email, String password);
  Future<AppUser> signup(String email, String password, String name);
  Future<AppUser> loginWithGoogle();
  Future<AppUser> loginAsGuest();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> logout();
}

abstract class LearningRepository {
  Future<List<Subject>> getSubjects({bool forceRefresh = false});
  Future<List<Chapter>> getChapters(String subjectId, {bool forceRefresh = false});
  Future<List<Video>> getVideos(String subjectId, String chapterId, {bool forceRefresh = false});
  Future<List<Video>> searchVideos(String query);
  Future<Video?> getVideoById(String videoId);
  
  // Progress
  Future<VideoProgress?> getProgress(String videoId);
  Future<void> saveProgress(String videoId, String subjectId, String chapterId, int watchTime, bool isCompleted);
  Future<List<VideoProgress>> getAllUserProgress();

  // Bookmarks
  Future<List<Bookmark>> getBookmarks();
  Future<void> addBookmark(String itemId, String itemType);
  Future<void> removeBookmark(String itemId);
  Future<bool> isBookmarked(String itemId);

  // Notes
  Future<List<VideoNote>> getVideoNotes(String videoId);
  Future<VideoNote> addNote(String videoId, String noteText, int timestampInSeconds);
  Future<void> deleteNote(String noteId);
}

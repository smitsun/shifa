class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String role;
  final DateTime createdAt;
  final DateTime lastActiveDate;
  final int streak;
  final int totalVideosWatched;
  final List<String> completedChapters;
  final List<String> completedSubjects;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.role,
    required this.createdAt,
    required this.lastActiveDate,
    required this.streak,
    required this.totalVideosWatched,
    required this.completedChapters,
    required this.completedSubjects,
  });

  bool get isAdmin => role == 'admin';
}

class Subject {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int chaptersCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subject({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.chaptersCount,
    required this.createdAt,
    required this.updatedAt,
  });
}

class Chapter {
  final String id;
  final String subjectId;
  final String title;
  final String description;
  final int videosCount;
  final DateTime createdAt;

  Chapter({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.videosCount,
    required this.createdAt,
  });
}

class Video {
  final String id;
  final String subjectId;
  final String chapterId;
  final String title;
  final String description;
  final String youtubeUrl;
  final String thumbnailUrl;
  final String duration;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<VideoJumpPoint> jumpPoints;

  Video({
    required this.id,
    required this.subjectId,
    required this.chapterId,
    required this.title,
    required this.description,
    required this.youtubeUrl,
    required this.thumbnailUrl,
    required this.duration,
    required this.createdAt,
    required this.updatedAt,
    this.jumpPoints = const [],
  });

  String get youtubeId {
    final regex = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
    );
    final match = regex.firstMatch(youtubeUrl);
    return (match != null && match.groupCount >= 1) ? match.group(1)! : '';
  }
}

class VideoProgress {
  final String userId;
  final String videoId;
  final String subjectId;
  final String chapterId;
  final int watchTime; // in seconds
  final bool isCompleted;
  final DateTime lastWatchedAt;

  VideoProgress({
    required this.userId,
    required this.videoId,
    required this.subjectId,
    required this.chapterId,
    required this.watchTime,
    required this.isCompleted,
    required this.lastWatchedAt,
  });
}

class VideoNote {
  final String id;
  final String userId;
  final String videoId;
  final String noteText;
  final int timestampInSeconds;
  final DateTime createdAt;

  VideoNote({
    required this.id,
    required this.userId,
    required this.videoId,
    required this.noteText,
    required this.timestampInSeconds,
    required this.createdAt,
  });
}

class Bookmark {
  final String userId;
  final String itemId;
  final String itemType; // 'subject' | 'chapter' | 'video'
  final DateTime bookmarkedAt;

  Bookmark({
    required this.userId,
    required this.itemId,
    required this.itemType,
    required this.bookmarkedAt,
  });
}

class VideoJumpPoint {
  final String label;
  final int timestamp; // in seconds

  VideoJumpPoint({
    required this.label,
    required this.timestamp,
  });
}

class LectureDeck {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final List<String> videoIds;
  final DateTime createdAt;

  LectureDeck({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.videoIds,
    required this.createdAt,
  });
}

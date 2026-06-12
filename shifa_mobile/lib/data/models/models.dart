import '../../domain/entities/entities.dart';

class UserModel extends AppUser {
  UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    required super.photoUrl,
    required super.role,
    required super.createdAt,
    required super.lastActiveDate,
    required super.streak,
    required super.totalVideosWatched,
    required super.completedChapters,
    required super.completedSubjects,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      role: map['role'] ?? 'student',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      lastActiveDate: map['lastActiveDate'] != null 
          ? DateTime.parse(map['lastActiveDate']) 
          : DateTime.now(),
      streak: map['streak'] ?? 0,
      totalVideosWatched: map['totalVideosWatched'] ?? 0,
      completedChapters: List<String>.from(map['completedChapters'] ?? []),
      completedSubjects: List<String>.from(map['completedSubjects'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveDate': lastActiveDate.toIso8601String(),
      'streak': streak,
      'totalVideosWatched': totalVideosWatched,
      'completedChapters': completedChapters,
      'completedSubjects': completedSubjects,
    };
  }
}

class SubjectModel extends Subject {
  SubjectModel({
    required super.id,
    required super.title,
    required super.description,
    required super.thumbnailUrl,
    required super.chaptersCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      chaptersCount: map['chaptersCount'] ?? 0,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'chaptersCount': chaptersCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ChapterModel extends Chapter {
  ChapterModel({
    required super.id,
    required super.subjectId,
    required super.title,
    required super.description,
    required super.videosCount,
    required super.createdAt,
  });

  factory ChapterModel.fromMap(Map<String, dynamic> map) {
    return ChapterModel(
      id: map['id'] ?? '',
      subjectId: map['subjectId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      videosCount: map['videosCount'] ?? 0,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'title': title,
      'description': description,
      'videosCount': videosCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class VideoModel extends Video {
  VideoModel({
    required super.id,
    required super.subjectId,
    required super.chapterId,
    required super.title,
    required super.description,
    required super.youtubeUrl,
    required super.thumbnailUrl,
    required super.duration,
    required super.createdAt,
    required super.updatedAt,
  });

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'] ?? '',
      subjectId: map['subjectId'] ?? '',
      chapterId: map['chapterId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      youtubeUrl: map['youtubeUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      duration: map['duration'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'chapterId': chapterId,
      'title': title,
      'description': description,
      'youtubeUrl': youtubeUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class VideoProgressModel extends VideoProgress {
  VideoProgressModel({
    required super.userId,
    required super.videoId,
    required super.subjectId,
    required super.chapterId,
    required super.watchTime,
    required super.isCompleted,
    required super.lastWatchedAt,
  });

  factory VideoProgressModel.fromMap(Map<String, dynamic> map) {
    return VideoProgressModel(
      userId: map['userId'] ?? '',
      videoId: map['videoId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      chapterId: map['chapterId'] ?? '',
      watchTime: map['watchTime'] ?? 0,
      isCompleted: map['isCompleted'] is bool 
          ? map['isCompleted'] 
          : (map['isCompleted'] == 1),
      lastWatchedAt: map['lastWatchedAt'] != null 
          ? DateTime.parse(map['lastWatchedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'videoId': videoId,
      'subjectId': subjectId,
      'chapterId': chapterId,
      'watchTime': watchTime,
      'isCompleted': isCompleted ? 1 : 0, // 1/0 is safe for SQLite, and Firestore works too
      'lastWatchedAt': lastWatchedAt.toIso8601String(),
    };
  }
}

class VideoNoteModel extends VideoNote {
  VideoNoteModel({
    required super.id,
    required super.userId,
    required super.videoId,
    required super.noteText,
    required super.timestampInSeconds,
    required super.createdAt,
  });

  factory VideoNoteModel.fromMap(Map<String, dynamic> map) {
    return VideoNoteModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      videoId: map['videoId'] ?? '',
      noteText: map['noteText'] ?? '',
      timestampInSeconds: map['timestampInSeconds'] ?? 0,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'videoId': videoId,
      'noteText': noteText,
      'timestampInSeconds': timestampInSeconds,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class BookmarkModel extends Bookmark {
  BookmarkModel({
    required super.userId,
    required super.itemId,
    required super.itemType,
    required super.bookmarkedAt,
  });

  factory BookmarkModel.fromMap(Map<String, dynamic> map) {
    return BookmarkModel(
      userId: map['userId'] ?? '',
      itemId: map['itemId'] ?? '',
      itemType: map['itemType'] ?? 'video',
      bookmarkedAt: map['bookmarkedAt'] != null 
          ? DateTime.parse(map['bookmarkedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'itemId': itemId,
      'itemType': itemType,
      'bookmarkedAt': bookmarkedAt.toIso8601String(),
    };
  }
}

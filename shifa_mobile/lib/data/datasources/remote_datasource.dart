import '../models/models.dart';

abstract class RemoteDataSource {
  Future<List<SubjectModel>> getSubjects();
  Future<List<ChapterModel>> getChapters(String subjectId);
  Future<List<VideoModel>> getVideos(String subjectId, String chapterId);
  Future<List<LectureDeckModel>> getLectureDecks();
  Future<UserModel> login(String email, String password);
  Future<UserModel> signup(String email, String password, String name);
  Future<UserModel> loginWithGoogle();
  Future<UserModel> loginAsGuest();
}

class RemoteDataSourceImpl implements RemoteDataSource {
  // Pre-populated medical courses data matching the Admin Panel
  final List<SubjectModel> _mockSubjects = [
    SubjectModel(
      id: 'anatomy',
      title: 'Anatomy',
      description: 'Study of the human body structure, including gross anatomy, osteology, and neuroanatomy.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1576086213369-97a306d36557?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
      chaptersCount: 5,
      createdAt: DateTime.parse('2026-06-01T08:00:00.000Z'),
      updatedAt: DateTime.parse('2026-06-01T08:00:00.000Z'),
    ),
    SubjectModel(
      id: 'physiology',
      title: 'Physiology',
      description: 'Understanding the mechanical, physical, and biochemical functions of humans in good health.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1530026405186-ed1ea0ac7a63?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
      chaptersCount: 3,
      createdAt: DateTime.parse('2026-06-02T08:00:00.000Z'),
      updatedAt: DateTime.parse('2026-06-02T08:00:00.000Z'),
    ),
    SubjectModel(
      id: 'biochemistry',
      title: 'Biochemistry',
      description: 'Exploration of chemical processes within and relating to living organisms.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1532187863486-abf9d39d66e8?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
      chaptersCount: 2,
      createdAt: DateTime.parse('2026-06-03T08:00:00.000Z'),
      updatedAt: DateTime.parse('2026-06-03T08:00:00.000Z'),
    ),
    SubjectModel(
      id: 'pathology',
      title: 'Pathology',
      description: 'The study of the causes and effects of diseases or injuries to guide clinical treatment.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1581093588401-fbb62a02f120?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
      chaptersCount: 4,
      createdAt: DateTime.parse('2026-06-04T08:00:00.000Z'),
      updatedAt: DateTime.parse('2026-06-04T08:00:00.000Z'),
    ),
    SubjectModel(
      id: 'pharmacology',
      title: 'Pharmacology',
      description: 'The branch of medicine concerned with the uses, effects, and modes of action of drugs.',
      thumbnailUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
      chaptersCount: 3,
      createdAt: DateTime.parse('2026-06-05T08:00:00.000Z'),
      updatedAt: DateTime.parse('2026-06-05T08:00:00.000Z'),
    ),
  ];

  final List<ChapterModel> _mockChapters = [
    ChapterModel(id: 'anatomy_upper_limb', subjectId: 'anatomy', title: 'Upper Limb', description: 'Detailed anatomy of shoulder, arm, forearm, and hand.', videosCount: 5, createdAt: DateTime.parse('2026-06-01T08:30:00.000Z')),
    ChapterModel(id: 'anatomy_lower_limb', subjectId: 'anatomy', title: 'Lower Limb', description: 'Detailed anatomy of gluteal region, thigh, leg, and foot.', videosCount: 0, createdAt: DateTime.parse('2026-06-01T08:45:00.000Z')),
    ChapterModel(id: 'anatomy_thorax', subjectId: 'anatomy', title: 'Thorax', description: 'Anatomy of the chest wall, lungs, and heart structures.', videosCount: 0, createdAt: DateTime.parse('2026-06-01T09:00:00.000Z')),
    ChapterModel(id: 'anatomy_abdomen', subjectId: 'anatomy', title: 'Abdomen', description: 'Abdominal wall anatomy, digestive organs, and vasculature.', videosCount: 0, createdAt: DateTime.parse('2026-06-01T09:15:00.000Z')),
    ChapterModel(id: 'anatomy_head_neck', subjectId: 'anatomy', title: 'Head and Neck', description: 'Brain anatomy, cranial nerves, skull osteology, and neck triangles.', videosCount: 0, createdAt: DateTime.parse('2026-06-01T09:30:00.000Z')),
    
    ChapterModel(id: 'phys_cardio', subjectId: 'physiology', title: 'Cardiovascular System', description: 'Heart cycle, cardiac output, blood pressure regulation, and ECG interpretation.', videosCount: 2, createdAt: DateTime.parse('2026-06-02T08:30:00.000Z')),
    ChapterModel(id: 'phys_renal', subjectId: 'physiology', title: 'Renal Physiology', description: 'Glomerular filtration, tubular reabsorption, and acid-base balance.', videosCount: 1, createdAt: DateTime.parse('2026-06-02T09:00:00.000Z')),
    ChapterModel(id: 'phys_resp', subjectId: 'physiology', title: 'Respiratory System', description: 'Pulmonary ventilation, gas transport, and compliance.', videosCount: 0, createdAt: DateTime.parse('2026-06-02T09:30:00.000Z')),
  ];

    VideoModel(
      id: 'anatomy_ul_intro',
      subjectId: 'anatomy',
      chapterId: 'anatomy_upper_limb',
      title: 'Introduction to Upper Limb Anatomy',
      description: 'An introductory video on the skeletal layout and fascial compartments of the upper limb.',
      youtubeUrl: 'https://www.youtube.com/watch?v=kYOpVj2Zoxw',
      thumbnailUrl: 'https://img.youtube.com/vi/kYOpVj2Zoxw/maxresdefault.jpg',
      duration: '08:45',
      createdAt: DateTime.parse('2026-06-01T10:00:00.000Z'),
      updatedAt: DateTime.parse('2026-06-01T10:00:00.000Z'),
      jumpPoints: [
        VideoJumpPointModel(label: 'Introduction', timestamp: 0),
        VideoJumpPointModel(label: 'Skeletal Layout', timestamp: 80),
        VideoJumpPointModel(label: 'Fascial Compartments', timestamp: 225),
        VideoJumpPointModel(label: 'Nerve Outlines', timestamp: 370),
      ],
    ),
    VideoModel(
      id: 'anatomy_ul_bones',
      subjectId: 'anatomy',
      chapterId: 'anatomy_upper_limb',
      title: 'Bones of the Upper Limb',
      description: 'Detailed walk-through of the Clavicle, Scapula, Humerus, Radius, Ulna, and Carpals.',
      youtubeUrl: 'https://www.youtube.com/watch?v=wQ1wH1xL4jM',
      thumbnailUrl: 'https://img.youtube.com/vi/wQ1wH1xL4jM/maxresdefault.jpg',
      duration: '14:20',
      createdAt: DateTime.parse('2026-06-01T10:15:00.000Z'),
      updatedAt: DateTime.parse('2026-06-01T10:15:00.000Z'),
      jumpPoints: [
        VideoJumpPointModel(label: 'Introduction', timestamp: 0),
        VideoJumpPointModel(label: 'Humerus Bone', timestamp: 135),
        VideoJumpPointModel(label: 'Radius & Ulna', timestamp: 340),
        VideoJumpPointModel(label: 'Wrist & Carpals', timestamp: 550),
      ],
    ),
    VideoModel(
      id: 'anatomy_ul_muscles',
      subjectId: 'anatomy',
      chapterId: 'anatomy_upper_limb',
      title: 'Muscles of the Shoulder and Arm',
      description: 'Study of the Rotator Cuff muscles, Deltoid, Biceps brachii, Brachialis, and Triceps.',
      youtubeUrl: 'https://www.youtube.com/watch?v=I80LX7fXqLw',
      thumbnailUrl: 'https://img.youtube.com/vi/I80LX7fXqLw/maxresdefault.jpg',
      duration: '18:10',
      createdAt: DateTime.parse('2026-06-01T10:30:00.000Z'),
      updatedAt: DateTime.parse('2026-06-01T10:30:00.000Z'),
    ),
    VideoModel(
      id: 'anatomy_ul_nerves',
      subjectId: 'anatomy',
      chapterId: 'anatomy_upper_limb',
      title: 'The Brachial Plexus and Nerves',
      description: 'Step-by-step drawing and clinical breakdown of the Brachial Plexus roots, trunks, divisions, cords, and branches.',
      youtubeUrl: 'https://www.youtube.com/watch?v=aGgB_nO_rJg',
      thumbnailUrl: 'https://img.youtube.com/vi/aGgB_nO_rJg/maxresdefault.jpg',
      duration: '22:15',
      createdAt: DateTime.parse('2026-06-01T10:45:00.000Z'),
      updatedAt: DateTime.parse('2026-06-01T10:45:00.000Z'),
    ),
    VideoModel(
      id: 'anatomy_ul_blood',
      subjectId: 'anatomy',
      chapterId: 'anatomy_upper_limb',
      title: 'Blood Supply of the Upper Extremity',
      description: 'Follow the Axillary artery, Brachial artery, Radial and Ulnar arteries, and the palmar arches.',
      youtubeUrl: 'https://www.youtube.com/watch?v=FqSg43S5-7k',
      thumbnailUrl: 'https://img.youtube.com/vi/FqSg43S5-7k/maxresdefault.jpg',
      duration: '11:40',
      createdAt: DateTime.parse('2026-06-01T11:00:00.000Z'),
      updatedAt: DateTime.parse('2026-06-01T11:00:00.000Z'),
    ),
    
    // Physiology -> Cardiovascular
    VideoModel(
      id: 'phys_cv_cycle',
      subjectId: 'physiology',
      chapterId: 'phys_cardio',
      title: 'The Cardiac Cycle Explained',
      description: 'Interactive explanation of systole, diastole, pressure volume loops, and heart sounds.',
      youtubeUrl: 'https://www.youtube.com/watch?v=5tUWOF6wZyM',
      thumbnailUrl: 'https://img.youtube.com/vi/5tUWOF6wZyM/maxresdefault.jpg',
      duration: '15:55',
      createdAt: DateTime.parse('2026-06-02T10:00:00.000Z'),
      updatedAt: DateTime.parse('2026-06-02T10:00:00.000Z'),
      jumpPoints: [
        VideoJumpPointModel(label: 'Introduction', timestamp: 0),
        VideoJumpPointModel(label: 'Atrial Systole', timestamp: 190),
        VideoJumpPointModel(label: 'Isovolumetric Contraction', timestamp: 465),
        VideoJumpPointModel(label: 'Ventricular Ejection', timestamp: 680),
      ],
    ),
    VideoModel(
      id: 'phys_cv_ecg',
      subjectId: 'physiology',
      chapterId: 'phys_cardio',
      title: 'ECG Basics: Waves, Segments and Intervals',
      description: 'Learn how to read an electrocardiogram, understanding the P wave, QRS complex, and T wave.',
      youtubeUrl: 'https://www.youtube.com/watch?v=xIZQRjkwV9Q',
      thumbnailUrl: 'https://img.youtube.com/vi/xIZQRjkwV9Q/maxresdefault.jpg',
      duration: '19:30',
      createdAt: DateTime.parse('2026-06-02T10:30:00.000Z'),
      updatedAt: DateTime.parse('2026-06-02T10:30:00.000Z'),
    )
  ];

  final List<LectureDeckModel> _mockDecks = [
    LectureDeckModel(
      id: 'deck_anatomy_overview',
      title: 'Upper Limb Anatomy Overview',
      description: 'A comprehensive study of the upper limb skeleton, compartments, and major muscles.',
      subjectId: 'anatomy',
      videoIds: ['anatomy_ul_intro', 'anatomy_ul_bones', 'anatomy_ul_muscles'],
      createdAt: DateTime.parse('2026-06-10T08:00:00.000Z'),
    ),
    LectureDeckModel(
      id: 'deck_brachial_plexus',
      title: 'Brachial Plexus Deep Dive',
      description: 'Mastering the nerves and blood supply of the upper extremity.',
      subjectId: 'anatomy',
      videoIds: ['anatomy_ul_nerves', 'anatomy_ul_blood'],
      createdAt: DateTime.parse('2026-06-11T08:00:00.000Z'),
    ),
    LectureDeckModel(
      id: 'deck_cardio_fundamentals',
      title: 'Cardiovascular Fundamentals',
      description: 'Crucial physiology concepts: cardiac cycles, volume loops, and reading ECG basics.',
      subjectId: 'physiology',
      videoIds: ['phys_cv_cycle', 'phys_cv_ecg'],
      createdAt: DateTime.parse('2026-06-12T08:00:00.000Z'),
    ),
  ];

  @override
  Future<List<SubjectModel>> getSubjects() async {
    await Future.delayed(const Duration(milliseconds: 600)); // Network delay simulation
    return _mockSubjects;
  }

  @override
  Future<List<ChapterModel>> getChapters(String subjectId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockChapters.where((ch) => ch.subjectId == subjectId).toList();
  }

  @override
  Future<List<VideoModel>> getVideos(String subjectId, String chapterId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockVideos.where((v) => v.subjectId == subjectId && v.chapterId == chapterId).toList();
  }

  @override
  Future<List<LectureDeckModel>> getLectureDecks() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockDecks;
  }

  @override
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (email.contains('error')) {
      throw Exception('Authentication failed. User not found.');
    }
    final isAdminUser = email.toLowerCase().contains('admin');
    return UserModel(
      uid: 'user_mock_123',
      email: email,
      displayName: email.split('@').first,
      photoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      role: isAdminUser ? 'admin' : 'student',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      lastActiveDate: DateTime.now(),
      streak: 5,
      totalVideosWatched: 4,
      completedChapters: ['anatomy_upper_limb'],
      completedSubjects: [],
    );
  }

  @override
  Future<UserModel> signup(String email, String password, String name) async {
    await Future.delayed(const Duration(seconds: 1));
    final isAdminUser = email.toLowerCase().contains('admin');
    return UserModel(
      uid: 'user_mock_456',
      email: email,
      displayName: name,
      photoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      role: isAdminUser ? 'admin' : 'student',
      createdAt: DateTime.now(),
      lastActiveDate: DateTime.now(),
      streak: 1,
      totalVideosWatched: 0,
      completedChapters: [],
      completedSubjects: [],
    );
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    return login('google.student@medical.edu', 'secret');
  }

  @override
  Future<UserModel> loginAsGuest() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return UserModel(
      uid: 'guest_user',
      email: 'guest@shifa.org',
      displayName: 'Guest Student',
      photoUrl: '',
      role: 'student',
      createdAt: DateTime.now(),
      lastActiveDate: DateTime.now(),
      streak: 0,
      totalVideosWatched: 0,
      completedChapters: [],
      completedSubjects: [],
    );
  }
}

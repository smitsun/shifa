export interface Subject {
  id: string;
  title: string;
  description: string;
  thumbnailUrl: string;
  chaptersCount: number;
  createdAt: string;
  updatedAt: string;
}

export interface Chapter {
  id: string;
  subjectId: string;
  title: string;
  description: string;
  videosCount: number;
  createdAt: string;
}

export interface Video {
  id: string;
  subjectId: string;
  chapterId: string;
  title: string;
  description: string;
  youtubeUrl: string;
  thumbnailUrl: string;
  duration: string;
  createdAt: string;
  updatedAt: string;
}

export interface UserProfile {
  uid: string;
  email: string;
  displayName: string;
  photoUrl: string;
  role: 'student' | 'admin';
  createdAt: string;
  lastActiveDate: string;
  streak: number;
  totalVideosWatched: number;
  completedChapters: string[];
  completedSubjects: string[];
}

export interface LearningProgress {
  userId: string;
  videoId: string;
  subjectId: string;
  chapterId: string;
  watchTime: number; // in seconds
  isCompleted: boolean;
  lastWatchedAt: string;
}

// Pre-populated initial mock data
const INITIAL_SUBJECTS: Subject[] = [
  {
    id: 'anatomy',
    title: 'Anatomy',
    description: 'Study of the human body structure, including gross anatomy, osteology, and neuroanatomy.',
    thumbnailUrl: 'https://images.unsplash.com/photo-1576086213369-97a306d36557?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
    chaptersCount: 5,
    createdAt: '2026-06-01T08:00:00.000Z',
    updatedAt: '2026-06-01T08:00:00.000Z'
  },
  {
    id: 'physiology',
    title: 'Physiology',
    description: 'Understanding the mechanical, physical, and biochemical functions of humans in good health.',
    thumbnailUrl: 'https://images.unsplash.com/photo-1530026405186-ed1ea0ac7a63?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
    chaptersCount: 3,
    createdAt: '2026-06-02T08:00:00.000Z',
    updatedAt: '2026-06-02T08:00:00.000Z'
  },
  {
    id: 'biochemistry',
    title: 'Biochemistry',
    description: 'Exploration of chemical processes within and relating to living organisms.',
    thumbnailUrl: 'https://images.unsplash.com/photo-1532187863486-abf9d39d66e8?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
    chaptersCount: 2,
    createdAt: '2026-06-03T08:00:00.000Z',
    updatedAt: '2026-06-03T08:00:00.000Z'
  },
  {
    id: 'pathology',
    title: 'Pathology',
    description: 'The study of the causes and effects of diseases or injuries to guide clinical treatment.',
    thumbnailUrl: 'https://images.unsplash.com/photo-1581093588401-fbb62a02f120?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
    chaptersCount: 4,
    createdAt: '2026-06-04T08:00:00.000Z',
    updatedAt: '2026-06-04T08:00:00.000Z'
  },
  {
    id: 'pharmacology',
    title: 'Pharmacology',
    description: 'The branch of medicine concerned with the uses, effects, and modes of action of drugs.',
    thumbnailUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3',
    chaptersCount: 3,
    createdAt: '2026-06-05T08:00:00.000Z',
    updatedAt: '2026-06-05T08:00:00.000Z'
  }
];

const INITIAL_CHAPTERS: Chapter[] = [
  // Anatomy chapters
  { id: 'anatomy_upper_limb', subjectId: 'anatomy', title: 'Upper Limb', description: 'Detailed anatomy of shoulder, arm, forearm, and hand.', videosCount: 5, createdAt: '2026-06-01T08:30:00.000Z' },
  { id: 'anatomy_lower_limb', subjectId: 'anatomy', title: 'Lower Limb', description: 'Detailed anatomy of gluteal region, thigh, leg, and foot.', videosCount: 0, createdAt: '2026-06-01T08:45:00.000Z' },
  { id: 'anatomy_thorax', subjectId: 'anatomy', title: 'Thorax', description: 'Anatomy of the chest wall, lungs, and heart structures.', videosCount: 0, createdAt: '2026-06-01T09:00:00.000Z' },
  { id: 'anatomy_abdomen', subjectId: 'anatomy', title: 'Abdomen', description: 'Abdominal wall anatomy, digestive organs, and vasculature.', videosCount: 0, createdAt: '2026-06-01T09:15:00.000Z' },
  { id: 'anatomy_head_neck', subjectId: 'anatomy', title: 'Head and Neck', description: 'Brain anatomy, cranial nerves, skull osteology, and neck triangles.', videosCount: 0, createdAt: '2026-06-01T09:30:00.000Z' },
  
  // Physiology chapters
  { id: 'phys_cardio', subjectId: 'physiology', title: 'Cardiovascular System', description: 'Heart cycle, cardiac output, blood pressure regulation, and ECG interpretation.', videosCount: 2, createdAt: '2026-06-02T08:30:00.000Z' },
  { id: 'phys_renal', subjectId: 'physiology', title: 'Renal Physiology', description: 'Glomerular filtration, tubular reabsorption, and acid-base balance.', videosCount: 1, createdAt: '2026-06-02T09:00:00.000Z' },
  { id: 'phys_resp', subjectId: 'physiology', title: 'Respiratory System', description: 'Pulmonary ventilation, gas transport, and compliance.', videosCount: 0, createdAt: '2026-06-02T09:30:00.000Z' }
];

const INITIAL_VIDEOS: Video[] = [
  // Anatomy -> Upper Limb
  {
    id: 'anatomy_ul_intro',
    subjectId: 'anatomy',
    chapterId: 'anatomy_upper_limb',
    title: 'Introduction to Upper Limb Anatomy',
    description: 'An introductory video on the skeletal layout and fascial compartments of the upper limb.',
    youtubeUrl: 'https://www.youtube.com/watch?v=kYOpVj2Zoxw',
    thumbnailUrl: 'https://img.youtube.com/vi/kYOpVj2Zoxw/maxresdefault.jpg',
    duration: '08:45',
    createdAt: '2026-06-01T10:00:00.000Z',
    updatedAt: '2026-06-01T10:00:00.000Z'
  },
  {
    id: 'anatomy_ul_bones',
    subjectId: 'anatomy',
    chapterId: 'anatomy_upper_limb',
    title: 'Bones of the Upper Limb',
    description: 'Detailed walk-through of the Clavicle, Scapula, Humerus, Radius, Ulna, and Carpals.',
    youtubeUrl: 'https://www.youtube.com/watch?v=wQ1wH1xL4jM',
    thumbnailUrl: 'https://img.youtube.com/vi/wQ1wH1xL4jM/maxresdefault.jpg',
    duration: '14:20',
    createdAt: '2026-06-01T10:15:00.000Z',
    updatedAt: '2026-06-01T10:15:00.000Z'
  },
  {
    id: 'anatomy_ul_muscles',
    subjectId: 'anatomy',
    chapterId: 'anatomy_upper_limb',
    title: 'Muscles of the Shoulder and Arm',
    description: 'Study of the Rotator Cuff muscles, Deltoid, Biceps brachii, Brachialis, and Triceps.',
    youtubeUrl: 'https://www.youtube.com/watch?v=I80LX7fXqLw',
    thumbnailUrl: 'https://img.youtube.com/vi/I80LX7fXqLw/maxresdefault.jpg',
    duration: '18:10',
    createdAt: '2026-06-01T10:30:00.000Z',
    updatedAt: '2026-06-01T10:30:00.000Z'
  },
  {
    id: 'anatomy_ul_nerves',
    subjectId: 'anatomy',
    chapterId: 'anatomy_upper_limb',
    title: 'The Brachial Plexus and Nerves',
    description: 'Step-by-step drawing and clinical breakdown of the Brachial Plexus roots, trunks, divisions, cords, and branches.',
    youtubeUrl: 'https://www.youtube.com/watch?v=aGgB_nO_rJg',
    thumbnailUrl: 'https://img.youtube.com/vi/aGgB_nO_rJg/maxresdefault.jpg',
    duration: '22:15',
    createdAt: '2026-06-01T10:45:00.000Z',
    updatedAt: '2026-06-01T10:45:00.000Z'
  },
  {
    id: 'anatomy_ul_blood',
    subjectId: 'anatomy',
    chapterId: 'anatomy_upper_limb',
    title: 'Blood Supply of the Upper Extremity',
    description: 'Follow the Axillary artery, Brachial artery, Radial and Ulnar arteries, and the palmar arches.',
    youtubeUrl: 'https://www.youtube.com/watch?v=FqSg43S5-7k',
    thumbnailUrl: 'https://img.youtube.com/vi/FqSg43S5-7k/maxresdefault.jpg',
    duration: '11:40',
    createdAt: '2026-06-01T11:00:00.000Z',
    updatedAt: '2026-06-01T11:00:00.000Z'
  },
  
  // Physiology -> Cardiovascular
  {
    id: 'phys_cv_cycle',
    subjectId: 'physiology',
    chapterId: 'phys_cardio',
    title: 'The Cardiac Cycle Explained',
    description: 'Interactive explanation of systole, diastole, pressure volume loops, and heart sounds.',
    youtubeUrl: 'https://www.youtube.com/watch?v=5tUWOF6wZyM',
    thumbnailUrl: 'https://img.youtube.com/vi/5tUWOF6wZyM/maxresdefault.jpg',
    duration: '15:55',
    createdAt: '2026-06-02T10:00:00.000Z',
    updatedAt: '2026-06-02T10:00:00.000Z'
  },
  {
    id: 'phys_cv_ecg',
    subjectId: 'physiology',
    chapterId: 'phys_cardio',
    title: 'ECG Basics: Waves, Segments and Intervals',
    description: 'Learn how to read an electrocardiogram, understanding the P wave, QRS complex, and T wave.',
    youtubeUrl: 'https://www.youtube.com/watch?v=xIZQRjkwV9Q',
    thumbnailUrl: 'https://img.youtube.com/vi/xIZQRjkwV9Q/maxresdefault.jpg',
    duration: '19:30',
    createdAt: '2026-06-02T10:30:00.000Z',
    updatedAt: '2026-06-02T10:30:00.000Z'
  }
];

const INITIAL_USERS: UserProfile[] = [
  {
    uid: 'admin_user',
    email: 'admin@shifa.org',
    displayName: 'Dr. Sarah Rahman',
    photoUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150&auto=format&fit=crop&q=80',
    role: 'admin',
    createdAt: '2026-05-01T00:00:00.000Z',
    lastActiveDate: '2026-06-12T11:00:00.000Z',
    streak: 15,
    totalVideosWatched: 0,
    completedChapters: [],
    completedSubjects: []
  },
  {
    uid: 'student_1',
    email: 'khalid@shifa.org',
    displayName: 'Khalid Al-Mansoor',
    photoUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&auto=format&fit=crop&q=80',
    role: 'student',
    createdAt: '2026-06-01T12:00:00.000Z',
    lastActiveDate: '2026-06-12T09:00:00.000Z',
    streak: 8,
    totalVideosWatched: 5,
    completedChapters: ['anatomy_upper_limb'],
    completedSubjects: []
  },
  {
    uid: 'student_2',
    email: 'aisha@shifa.org',
    displayName: 'Aisha Siddiqui',
    photoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
    role: 'student',
    createdAt: '2026-06-05T09:30:00.000Z',
    lastActiveDate: '2026-06-12T10:45:00.000Z',
    streak: 4,
    totalVideosWatched: 2,
    completedChapters: [],
    completedSubjects: []
  }
];

// Helper database manager with localStorage backing
class MockDBManager {
  private getStorageItem<T>(key: string, defaultVal: T): T {
    try {
      const data = localStorage.getItem(key);
      return data ? JSON.parse(data) : defaultVal;
    } catch {
      return defaultVal;
    }
  }

  private setStorageItem<T>(key: string, data: T): void {
    localStorage.setItem(key, JSON.stringify(data));
  }

  getSubjects(): Subject[] {
    return this.getStorageItem<Subject[]>('shifa_subjects', INITIAL_SUBJECTS);
  }

  saveSubjects(subjects: Subject[]): void {
    this.setStorageItem('shifa_subjects', subjects);
  }

  getChapters(): Chapter[] {
    return this.getStorageItem<Chapter[]>('shifa_chapters', INITIAL_CHAPTERS);
  }

  saveChapters(chapters: Chapter[]): void {
    this.setStorageItem('shifa_chapters', chapters);
  }

  getVideos(): Video[] {
    return this.getStorageItem<Video[]>('shifa_videos', INITIAL_VIDEOS);
  }

  saveVideos(videos: Video[]): void {
    this.setStorageItem('shifa_videos', videos);
  }

  getUsers(): UserProfile[] {
    return this.getStorageItem<UserProfile[]>('shifa_users', INITIAL_USERS);
  }

  saveUsers(users: UserProfile[]): void {
    this.setStorageItem('shifa_users', users);
  }
}

export const mockDB = new MockDBManager();

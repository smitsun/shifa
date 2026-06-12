import { mockDB } from './mockData';
import type { Subject, Chapter, Video, UserProfile, LectureDeck } from './mockData';

// Toggle this to false to link directly with Firebase
export const USE_MOCK = true;

// Mock implementations
const getSubjects = async (): Promise<Subject[]> => {
  return mockDB.getSubjects();
};

const saveSubject = async (subject: Omit<Subject, 'createdAt' | 'updatedAt' | 'chaptersCount'>): Promise<Subject> => {
  const subjects = mockDB.getSubjects();
  const index = subjects.findIndex((s) => s.id === subject.id);
  const now = new Date().toISOString();

  if (index >= 0) {
    const updated: Subject = {
      ...subjects[index],
      title: subject.title,
      description: subject.description,
      thumbnailUrl: subject.thumbnailUrl,
      updatedAt: now,
    };
    subjects[index] = updated;
    mockDB.saveSubjects(subjects);
    return updated;
  } else {
    const created: Subject = {
      ...subject,
      chaptersCount: 0,
      createdAt: now,
      updatedAt: now,
    };
    subjects.push(created);
    mockDB.saveSubjects(subjects);
    return created;
  }
};

const deleteSubject = async (id: string): Promise<void> => {
  const subjects = mockDB.getSubjects().filter((s) => s.id !== id);
  mockDB.saveSubjects(subjects);

  // Also clean up chapters and videos
  const chapters = mockDB.getChapters().filter((c) => c.subjectId !== id);
  mockDB.saveChapters(chapters);

  const videos = mockDB.getVideos().filter((v) => v.subjectId !== id);
  mockDB.saveVideos(videos);
};

const getChapters = async (): Promise<Chapter[]> => {
  return mockDB.getChapters();
};

const saveChapter = async (chapter: Omit<Chapter, 'id' | 'createdAt' | 'videosCount'> & { id?: string }): Promise<Chapter> => {
  const chapters = mockDB.getChapters();
  const id = chapter.id || `${chapter.subjectId}_${chapter.title.toLowerCase().replace(/\s+/g, '_')}`;
  const index = chapters.findIndex((c) => c.id === id);
  const now = new Date().toISOString();

  if (index >= 0) {
    const updated: Chapter = {
      ...chapters[index],
      title: chapter.title,
      description: chapter.description,
    };
    chapters[index] = updated;
    mockDB.saveChapters(chapters);
    return updated;
  } else {
    const created: Chapter = {
      id,
      subjectId: chapter.subjectId,
      title: chapter.title,
      description: chapter.description,
      videosCount: 0,
      createdAt: now,
    };
    chapters.push(created);
    mockDB.saveChapters(chapters);

    // Increment chaptersCount in subject
    const subjects = mockDB.getSubjects();
    const sIndex = subjects.findIndex((s) => s.id === chapter.subjectId);
    if (sIndex >= 0) {
      subjects[sIndex].chaptersCount += 1;
      mockDB.saveSubjects(subjects);
    }

    return created;
  }
};

const deleteChapter = async (id: string): Promise<void> => {
  const chapters = mockDB.getChapters();
  const chapter = chapters.find((c) => c.id === id);
  if (!chapter) return;

  const filteredChapters = chapters.filter((c) => c.id !== id);
  mockDB.saveChapters(filteredChapters);

  // Clean up videos
  const videos = mockDB.getVideos().filter((v) => v.chapterId !== id);
  mockDB.saveVideos(videos);

  // Decrement chaptersCount in subject
  const subjects = mockDB.getSubjects();
  const sIndex = subjects.findIndex((s) => s.id === chapter.subjectId);
  if (sIndex >= 0) {
    subjects[sIndex].chaptersCount = Math.max(0, subjects[sIndex].chaptersCount - 1);
    mockDB.saveSubjects(subjects);
  }
};

const getVideos = async (): Promise<Video[]> => {
  return mockDB.getVideos();
};

const saveVideo = async (video: Omit<Video, 'id' | 'createdAt' | 'updatedAt' | 'thumbnailUrl'> & { id?: string }): Promise<Video> => {
  const videos = mockDB.getVideos();
  const id = video.id || `${video.chapterId}_${video.title.toLowerCase().replace(/\s+/g, '_')}`;
  const index = videos.findIndex((v) => v.id === id);
  const now = new Date().toISOString();

  let ytId = '';
  const regex = new RegExp('(?:youtube\\.com/(?:[^/]+/.+/(?:v|e(?:mbed)?)/|.*[?&]v=)|youtu\\.be/)([^"&?/\\s]{11})', 'i');
  const match = video.youtubeUrl.match(regex);
  if (match && match[1]) {
    ytId = match[1];
  }
  const thumbnailUrl = ytId ? `https://img.youtube.com/vi/${ytId}/maxresdefault.jpg` : 'https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=500&auto=format&fit=crop&q=60';

  if (index >= 0) {
    const updated: Video = {
      ...videos[index],
      title: video.title,
      description: video.description,
      youtubeUrl: video.youtubeUrl,
      duration: video.duration,
      thumbnailUrl,
      updatedAt: now,
      jumpPoints: video.jumpPoints || [],
    };
    videos[index] = updated;
    mockDB.saveVideos(videos);
    return updated;
  } else {
    const created: Video = {
      id,
      subjectId: video.subjectId,
      chapterId: video.chapterId,
      title: video.title,
      description: video.description,
      youtubeUrl: video.youtubeUrl,
      duration: video.duration,
      thumbnailUrl,
      createdAt: now,
      updatedAt: now,
      jumpPoints: video.jumpPoints || [],
    };
    videos.push(created);
    mockDB.saveVideos(videos);

    // Increment videosCount in chapter
    const chapters = mockDB.getChapters();
    const cIndex = chapters.findIndex((c) => c.id === video.chapterId);
    if (cIndex >= 0) {
      chapters[cIndex].videosCount += 1;
      mockDB.saveChapters(chapters);
    }

    return created;
  }
};

const deleteVideo = async (id: string): Promise<void> => {
  const videos = mockDB.getVideos();
  const video = videos.find((v) => v.id === id);
  if (!video) return;

  const filteredVideos = videos.filter((v) => v.id !== id);
  mockDB.saveVideos(filteredVideos);

  // Decrement videosCount in chapter
  const chapters = mockDB.getChapters();
  const cIndex = chapters.findIndex((c) => c.id === video.chapterId);
  if (cIndex >= 0) {
    chapters[cIndex].videosCount = Math.max(0, chapters[cIndex].videosCount - 1);
    mockDB.saveChapters(chapters);
  }
};

const getUsers = async (): Promise<UserProfile[]> => {
  return mockDB.getUsers();
};

const updateUserRole = async (uid: string, role: 'student' | 'admin'): Promise<void> => {
  const users = mockDB.getUsers();
  const index = users.findIndex((u) => u.uid === uid);
  if (index >= 0) {
    users[index].role = role;
    mockDB.saveUsers(users);
  }
};

const getLectureDecks = async (): Promise<LectureDeck[]> => {
  return mockDB.getLectureDecks();
};

const saveLectureDeck = async (deck: Omit<LectureDeck, 'id' | 'createdAt' | 'updatedAt'> & { id?: string }): Promise<LectureDeck> => {
  const decks = mockDB.getLectureDecks();
  const id = deck.id || `deck_${deck.title.toLowerCase().replace(/\s+/g, '_')}_${Date.now()}`;
  const index = decks.findIndex((d) => d.id === id);
  const now = new Date().toISOString();

  if (index >= 0) {
    const updated: LectureDeck = {
      ...decks[index],
      title: deck.title,
      description: deck.description,
      subjectId: deck.subjectId,
      videoIds: deck.videoIds,
      updatedAt: now,
    };
    decks[index] = updated;
    mockDB.saveLectureDecks(decks);
    return updated;
  } else {
    const created: LectureDeck = {
      id,
      title: deck.title,
      description: deck.description,
      subjectId: deck.subjectId,
      videoIds: deck.videoIds,
      createdAt: now,
      updatedAt: now,
    };
    decks.push(created);
    mockDB.saveLectureDecks(decks);
    return created;
  }
};

const deleteLectureDeck = async (id: string): Promise<void> => {
  const decks = mockDB.getLectureDecks().filter((d) => d.id !== id);
  mockDB.saveLectureDecks(decks);
};

// Export database client API (Decoupled, easy to integrate Firebase in future)
export const dbAPI = {
  getSubjects,
  saveSubject,
  deleteSubject,
  getChapters,
  saveChapter,
  deleteChapter,
  getVideos,
  saveVideo,
  deleteVideo,
  getUsers,
  updateUserRole,
  getLectureDecks,
  saveLectureDeck,
  deleteLectureDeck,
};

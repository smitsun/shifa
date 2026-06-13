import React, { useState, useEffect, useCallback } from 'react';
import { 
  BookOpen, 
  Layers, 
  Film, 
  Users, 
  Sun, 
  Moon, 
  LogOut, 
  Plus, 
  Search, 
  Edit3, 
  Trash2, 
  X, 
  Play,
  TrendingUp,
  Clock,
  Sparkles,
  List
} from 'lucide-react';
import { dbAPI } from './services/db';
import type { Subject, Chapter, Video, UserProfile, LectureDeck } from './services/mockData';

// Helper functions defined outside the component to prevent recreation on every render
const getYoutubeId = (url: string) => {
  const regex = new RegExp('(?:youtube\\.com/(?:[^/]+/.+/(?:v|e(?:mbed)?)/|.*[?&]v=)|youtu\\.be/)([^"&?/\\s]{11})', 'i');
  const match = url.match(regex);
  return (match && match[1]) ? match[1] : '';
};

const timeToSeconds = (timeStr: string): number => {
  const parts = timeStr.split(':').map(Number);
  if (parts.length === 2 && !isNaN(parts[0]) && !isNaN(parts[1])) {
    return parts[0] * 60 + parts[1];
  }
  return Number(timeStr) || 0;
};

const secondsToTime = (secs: number): string => {
  const m = Math.floor(secs / 60);
  const s = secs % 60;
  return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
};

export default function App() {
  const [theme, setTheme] = useState<'light' | 'dark'>(() => {
    return (localStorage.getItem('shifa_admin_theme') as 'light' | 'dark') || 'dark';
  });
  const [activeTab, setActiveTab] = useState<'dashboard' | 'subjects' | 'chapters' | 'videos' | 'users' | 'lectureDecks'>('dashboard');
  const [previewVideoId, setPreviewVideoId] = useState<string | null>(null);
  const [isLoggedIn, setIsLoggedIn] = useState(true);

  // Controlled login form state
  const [loginEmail, setLoginEmail] = useState('admin@shifa.org');
  const [loginPassword, setLoginPassword] = useState('password');

  // Loading state
  const [isLoading, setIsLoading] = useState(false);

  // Custom alert / error modal state
  const [errorState, setErrorState] = useState<{
    isOpen: boolean;
    message: string;
  }>({ isOpen: false, message: '' });

  // Delete confirmation modal state
  const [deleteConfirm, setDeleteConfirm] = useState<{
    isOpen: boolean;
    type: 'subject' | 'chapter' | 'video' | 'lectureDeck' | null;
    id: string | null;
  }>({ isOpen: false, type: null, id: null });
  
  // Data State
  const [subjects, setSubjects] = useState<Subject[]>([]);
  const [chapters, setChapters] = useState<Chapter[]>([]);
  const [videos, setVideos] = useState<Video[]>([]);
  const [lectureDecks, setLectureDecks] = useState<LectureDeck[]>([]);
  const [users, setUsers] = useState<UserProfile[]>([]);
  
  // Filtering & Dropdown State
  const [selectedSubjectId, setSelectedSubjectId] = useState<string>('');
  const [selectedChapterId, setSelectedChapterId] = useState<string>('');
  const [searchQuery, setSearchQuery] = useState<string>('');
  
  // Modals state
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalType, setModalType] = useState<'subject' | 'chapter' | 'video' | 'lectureDeck' | null>(null);
  const [modalAction, setModalAction] = useState<'add' | 'edit'>('add');
  
  // Form State
  const [editId, setEditId] = useState<string>('');
  const [subjectForm, setSubjectForm] = useState({ id: '', title: '', description: '', thumbnailUrl: '' });
  const [chapterForm, setChapterForm] = useState({ title: '', description: '', subjectId: '' });
  const [videoForm, setVideoForm] = useState<{
    title: string;
    description: string;
    youtubeUrl: string;
    duration: string;
    subjectId: string;
    chapterId: string;
    jumpPoints: { label: string; timestamp: number }[];
  }>({ title: '', description: '', youtubeUrl: '', duration: '', subjectId: '', chapterId: '', jumpPoints: [] });
  const [lectureDeckForm, setLectureDeckForm] = useState({ title: '', description: '', subjectId: '', videoIds: [] as string[] });

  // Flag to guarantee loadAllData initial selection logic runs exactly once on mount
  const isInitializedRef = React.useRef(false);

  // Load data helper - memoized with useCallback
  const loadAllData = useCallback(async () => {
    setIsLoading(true);
    try {
      const s = await dbAPI.getSubjects();
      const c = await dbAPI.getChapters();
      const v = await dbAPI.getVideos();
      const u = await dbAPI.getUsers();
      const ld = await dbAPI.getLectureDecks();
      
      setSubjects(s);
      setChapters(c);
      setVideos(v);
      setLectureDecks(ld);
      setUsers(u);
    } catch (err) {
      console.error("Failed to load data: ", err);
      setErrorState({ isOpen: true, message: "Failed to synchronize data with local database storage." });
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Separate initialization logic from loadAllData, running exactly once
  useEffect(() => {
    if (!isInitializedRef.current && subjects.length > 0) {
      isInitializedRef.current = true;
      const initialSubId = subjects[0].id;
      setSelectedSubjectId(initialSubId);
      
      const filtered = chapters.filter(chap => chap.subjectId === initialSubId);
      if (filtered.length > 0) {
        setSelectedChapterId(filtered[0].id);
      }
    }
  }, [subjects, chapters]);

  // Keep selectedChapterId synchronized with selectedSubjectId
  useEffect(() => {
    if (selectedSubjectId) {
      const filtered = chapters.filter(c => c.subjectId === selectedSubjectId);
      if (filtered.length > 0) {
        const exists = filtered.some(c => c.id === selectedChapterId);
        if (!exists) {
          setSelectedChapterId(filtered[0].id);
        }
      } else {
        setSelectedChapterId('');
      }
    } else {
      setSelectedChapterId('');
    }
  }, [selectedSubjectId, chapters, selectedChapterId]);

  // Init Data
  useEffect(() => {
    loadAllData();
  }, [loadAllData]);

  // Sync Theme
  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('shifa_admin_theme', theme);
  }, [theme]);

  const toggleTheme = () => {
    setTheme(prev => prev === 'light' ? 'dark' : 'light');
  };

  // Open Add Modals
  const openAddModal = (type: 'subject' | 'chapter' | 'video' | 'lectureDeck') => {
    setModalType(type);
    setModalAction('add');
    setEditId('');
    
    if (type === 'subject') {
      setSubjectForm({ id: '', title: '', description: '', thumbnailUrl: '' });
    } else if (type === 'chapter') {
      setChapterForm({ title: '', description: '', subjectId: selectedSubjectId || (subjects[0]?.id || '') });
    } else if (type === 'video') {
      setVideoForm({ title: '', description: '', youtubeUrl: '', duration: '', subjectId: selectedSubjectId || (subjects[0]?.id || ''), chapterId: selectedChapterId || '', jumpPoints: [] });
    } else if (type === 'lectureDeck') {
      setLectureDeckForm({ title: '', description: '', subjectId: selectedSubjectId || (subjects[0]?.id || ''), videoIds: [] });
    }
    setIsModalOpen(true);
  };

  // Open Edit Modals
  const openEditModal = (type: 'subject' | 'chapter' | 'video' | 'lectureDeck', item: Subject | Chapter | Video | LectureDeck) => {
    setModalType(type);
    setModalAction('edit');
    setEditId(item.id);
    
    if (type === 'subject') {
      const s = item as Subject;
      setSubjectForm({ id: s.id, title: s.title, description: s.description, thumbnailUrl: s.thumbnailUrl });
    } else if (type === 'chapter') {
      const c = item as Chapter;
      setChapterForm({ title: c.title, description: c.description, subjectId: c.subjectId });
    } else if (type === 'video') {
      const v = item as Video;
      setVideoForm({ 
        title: v.title, 
        description: v.description, 
        youtubeUrl: v.youtubeUrl, 
        duration: v.duration, 
        subjectId: v.subjectId, 
        chapterId: v.chapterId,
        jumpPoints: v.jumpPoints || []
      });
    } else if (type === 'lectureDeck') {
      const ld = item as LectureDeck;
      setLectureDeckForm({
        title: ld.title,
        description: ld.description,
        subjectId: ld.subjectId,
        videoIds: ld.videoIds
      });
    }
    setIsModalOpen(true);
  };

  // Handle Form Submission
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    try {
      if (modalType === 'subject') {
        await dbAPI.saveSubject({
          ...subjectForm,
          id: modalAction === 'edit' ? editId : subjectForm.id
        });
      } else if (modalType === 'chapter') {
        await dbAPI.saveChapter({
          ...(modalAction === 'edit' ? { id: editId } : {}),
          subjectId: chapterForm.subjectId,
          title: chapterForm.title,
          description: chapterForm.description
        });
      } else if (modalType === 'video') {
        await dbAPI.saveVideo({
          ...(modalAction === 'edit' ? { id: editId } : {}),
          subjectId: videoForm.subjectId,
          chapterId: videoForm.chapterId,
          title: videoForm.title,
          description: videoForm.description,
          youtubeUrl: videoForm.youtubeUrl,
          duration: videoForm.duration,
          jumpPoints: videoForm.jumpPoints
        });
      } else if (modalType === 'lectureDeck') {
        await dbAPI.saveLectureDeck({
          ...(modalAction === 'edit' ? { id: editId } : {}),
          subjectId: lectureDeckForm.subjectId,
          title: lectureDeckForm.title,
          description: lectureDeckForm.description,
          videoIds: lectureDeckForm.videoIds
        });
      }
      setIsModalOpen(false);
      await loadAllData();
    } catch (err) {
      console.error("Error saving content: ", err);
      setErrorState({ isOpen: true, message: `Failed to save changes to the database. Please try again.` });
    } finally {
      setIsLoading(false);
    }
  };

  // Handle Deletion Trigger
  const handleDelete = (type: 'subject' | 'chapter' | 'video' | 'lectureDeck', id: string) => {
    setDeleteConfirm({
      isOpen: true,
      type,
      id
    });
  };

  // Handle Deletion Confirmation
  const handleConfirmDelete = async () => {
    const { type, id } = deleteConfirm;
    if (!type || !id) return;
    
    setIsLoading(true);
    try {
      if (type === 'subject') {
        await dbAPI.deleteSubject(id);
      } else if (type === 'chapter') {
        await dbAPI.deleteChapter(id);
      } else if (type === 'video') {
        await dbAPI.deleteVideo(id);
      } else if (type === 'lectureDeck') {
        await dbAPI.deleteLectureDeck(id);
      }
      await loadAllData();
      setDeleteConfirm({ isOpen: false, type: null, id: null });
    } catch (err) {
      console.error("Failed to delete item: ", err);
      setErrorState({ isOpen: true, message: `Failed to delete ${type}. Please try again.` });
    } finally {
      setIsLoading(false);
    }
  };

  // Toggle User Role
  const toggleUserRole = async (uid: string, currentRole: 'student' | 'admin') => {
    const targetRole = currentRole === 'admin' ? 'student' : 'admin';
    setIsLoading(true);
    try {
      await dbAPI.updateUserRole(uid, targetRole);
      await loadAllData();
    } catch (err) {
      console.error("Failed to update user role: ", err);
      setErrorState({ isOpen: true, message: "Failed to update user role. Please try again." });
    } finally {
      setIsLoading(false);
    }
  };

  // Helper stats
  const totalSubjects = subjects.length;
  const totalChapters = chapters.length;
  const totalVideos = videos.length;
  const totalStudents = users.filter(u => u.role === 'student').length;

  if (!isLoggedIn) {
    return (
      <div style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        height: '100vh',
        width: '100vw',
        background: 'var(--bg-primary)',
        fontFamily: 'var(--font-body)'
      }}>
        <div className="modal-content" style={{ width: '400px', padding: '40px', display: 'flex', flexDirection: 'column', gap: '24px' }}>
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '12px' }}>
            <img src="./logo.png" alt="Shifa Care Logo" style={{ height: '70px', width: 'auto', marginBottom: '8px', borderRadius: '12px', background: 'white', padding: '6px' }} />
            <h2 style={{ fontSize: '24px', fontWeight: 800, color: 'var(--text-primary)' }}>Shifa Care Admin Console</h2>
            <p style={{ fontSize: '13px', color: 'var(--text-secondary)', textAlign: 'center' }}>Please authenticate to access the course catalog dashboard.</p>
          </div>
          
          <form onSubmit={(e) => { e.preventDefault(); setIsLoggedIn(true); }} style={{ display: 'flex', flexDirection: 'column', gap: '18px' }}>
            <div className="form-group" style={{ marginBottom: 0 }}>
              <label>Administrator Email</label>
              <input 
                type="email" 
                required 
                className="form-control" 
                value={loginEmail} 
                onChange={(e) => setLoginEmail(e.target.value)} 
              />
            </div>
            <div className="form-group" style={{ marginBottom: 0 }}>
              <label>Password</label>
              <input 
                type="password" 
                required 
                className="form-control" 
                value={loginPassword} 
                onChange={(e) => setLoginPassword(e.target.value)} 
              />
            </div>
            <button type="submit" className="primary-btn" style={{ justifyContent: 'center', width: '100%', marginTop: '10px', padding: '12px' }}>
              Sign In to System
            </button>
          </form>
        </div>
      </div>
    );
  }

  return (
    <div className="admin-layout">
      {/* Sidebar */}
      <aside className="sidebar">
        <div className="sidebar-header">
          <img src="./logo.png" alt="Logo" style={{ height: '34px', width: 'auto', borderRadius: '6px', background: 'white', padding: '3px' }} />
          <span className="logo-text">Shifa Care</span>
        </div>
        
        <ul className="sidebar-menu">
          <li>
            <div 
              className={`menu-item ${activeTab === 'dashboard' ? 'active' : ''}`}
              onClick={() => { setActiveTab('dashboard'); setSearchQuery(''); }}
            >
              <TrendingUp size={20} />
              Dashboard
            </div>
          </li>
          <li>
            <div 
              className={`menu-item ${activeTab === 'subjects' ? 'active' : ''}`}
              onClick={() => { setActiveTab('subjects'); setSearchQuery(''); }}
            >
              <BookOpen size={20} />
              Subjects
            </div>
          </li>
          <li>
            <div 
              className={`menu-item ${activeTab === 'chapters' ? 'active' : ''}`}
              onClick={() => { setActiveTab('chapters'); setSearchQuery(''); }}
            >
              <Layers size={20} />
              Chapters
            </div>
          </li>
          <li>
            <div 
              className={`menu-item ${activeTab === 'videos' ? 'active' : ''}`}
              onClick={() => { setActiveTab('videos'); setSearchQuery(''); }}
            >
              <Film size={20} />
              Video Lectures
            </div>
          </li>
          <li>
            <div 
              className={`menu-item ${activeTab === 'lectureDecks' ? 'active' : ''}`}
              onClick={() => { setActiveTab('lectureDecks'); setSearchQuery(''); }}
            >
              <List size={20} />
              Lecture Decks
            </div>
          </li>
          <li>
            <div 
              className={`menu-item ${activeTab === 'users' ? 'active' : ''}`}
              onClick={() => { setActiveTab('users'); setSearchQuery(''); }}
            >
              <Users size={20} />
              User Directory
            </div>
          </li>
        </ul>

        <div className="sidebar-footer">
          <div className="user-info">
            <img 
              src="https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150&auto=format&fit=crop&q=80" 
              alt="Admin Profile" 
              className="user-avatar"
            />
            <div className="user-details">
              <h4>Dr. Sarah Rahman</h4>
              <span>System Administrator</span>
            </div>
          </div>
        </div>
      </aside>

      {/* Main Panel */}
      <main className="main-content">
        {/* Header */}
        <header className="topbar">
          <h2 className="page-title">
            {activeTab === 'dashboard' && 'Analytics Overview'}
            {activeTab === 'subjects' && 'Course Subjects'}
            {activeTab === 'chapters' && 'Chapters Management'}
            {activeTab === 'videos' && 'Video Library'}
            {activeTab === 'lectureDecks' && 'Lecture Presentation Decks'}
            {activeTab === 'users' && 'Active User Profiles'}
          </h2>

          <div className="topbar-actions">
            <button className="theme-toggle-btn" onClick={toggleTheme} title="Toggle Dark/Light Mode">
              {theme === 'light' ? <Moon size={18} /> : <Sun size={18} />}
            </button>
            <button className="logout-btn" title="Sign Out" onClick={() => setIsLoggedIn(false)}>
              <LogOut size={18} />
            </button>
          </div>
        </header>

        {/* Scrollable Container */}
        <div className="page-container">
          
          {/* ============ DASHBOARD VIEW ============ */}
          {activeTab === 'dashboard' && (
            <div>
              {/* Analytics Metric Cards */}
              <div className="analytics-grid">
                <div 
                  className="analytics-card" 
                  style={{ '--accent-color': '#4f46e5', cursor: 'pointer' } as React.CSSProperties}
                  onClick={() => setActiveTab('subjects')}
                >
                  <div className="card-icon-wrapper">
                    <BookOpen size={24} />
                  </div>
                  <div className="card-info">
                    <span className="card-value">{totalSubjects}</span>
                    <span className="card-label">Active Subjects</span>
                  </div>
                </div>

                <div 
                  className="analytics-card" 
                  style={{ '--accent-color': '#06b6d4', cursor: 'pointer' } as React.CSSProperties}
                  onClick={() => setActiveTab('chapters')}
                >
                  <div className="card-icon-wrapper">
                    <Layers size={24} />
                  </div>
                  <div className="card-info">
                    <span className="card-value">{totalChapters}</span>
                    <span className="card-label">Total Chapters</span>
                  </div>
                </div>

                <div 
                  className="analytics-card" 
                  style={{ '--accent-color': '#10b981', cursor: 'pointer' } as React.CSSProperties}
                  onClick={() => setActiveTab('videos')}
                >
                  <div className="card-icon-wrapper">
                    <Film size={24} />
                  </div>
                  <div className="card-info">
                    <span className="card-value">{totalVideos}</span>
                    <span className="card-label">Video Lectures</span>
                  </div>
                </div>

                <div 
                  className="analytics-card" 
                  style={{ '--accent-color': '#f59e0b', cursor: 'pointer' } as React.CSSProperties}
                  onClick={() => setActiveTab('users')}
                >
                  <div className="card-icon-wrapper">
                    <Users size={24} />
                  </div>
                  <div className="card-info">
                    <span className="card-value">{totalStudents}</span>
                    <span className="card-label">Active Students</span>
                  </div>
                </div>
              </div>

              {/* Chart Grid */}
              <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '32px', marginBottom: '40px' }}>
                
                {/* Visual Chart Card */}
                <div className="content-section" style={{ marginBottom: 0 }}>
                  <div className="section-header">
                    <h3>Curriculum Depth (Videos per Subject)</h3>
                    <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Distribution analysis</span>
                  </div>
                  
                  <div className="chart-container">
                    {subjects.map((sub) => {
                      const videoCount = videos.filter(v => v.subjectId === sub.id).length;
                      const maxVideos = Math.max(...subjects.map(s => videos.filter(v => v.subjectId === s.id).length), 1);
                      const heightPct = `${(videoCount / maxVideos) * 75 + 10}%`;

                      return (
                        <div key={sub.id} className="chart-bar-wrapper">
                          <div className="chart-bar" style={{ height: heightPct }}>
                            <div className="chart-bar-tooltip">{videoCount} Videos</div>
                          </div>
                          <span className="chart-label">{sub.title}</span>
                        </div>
                      );
                    })}
                  </div>
                </div>

                {/* Performance Streak Card */}
                <div className="content-section" style={{ marginBottom: 0, padding: '24px' }}>
                  <h3 style={{ fontSize: '18px', fontWeight: 700, marginBottom: '20px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <Sparkles color="var(--accent-warning)" size={20} />
                    Top Active Streaks
                  </h3>
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                    {users
                      .filter(u => u.role === 'student')
                      .sort((a, b) => b.streak - a.streak)
                      .slice(0, 3)
                      .map((user) => (
                        <div key={user.uid} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px', backgroundColor: 'var(--bg-tertiary)', borderRadius: '12px' }}>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                            <img src={user.photoUrl} alt={user.displayName} style={{ width: '36px', height: '36px', borderRadius: '50%' }} />
                            <div>
                              <h5 style={{ fontSize: '13px', fontWeight: 600 }}>{user.displayName}</h5>
                              <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{user.email}</span>
                            </div>
                          </div>
                          <span style={{ fontSize: '14px', fontWeight: 700, color: 'var(--accent-warning)' }}>🔥 {user.streak} days</span>
                        </div>
                      ))}
                  </div>
                </div>

              </div>

              {/* Recent Active User Activity */}
              <div className="content-section">
                <div className="section-header">
                  <h3>Recent User Engagement</h3>
                </div>
                <div className="table-container">
                  <table className="custom-table">
                    <thead>
                      <tr>
                        <th>User</th>
                        <th>Email</th>
                        <th>Status</th>
                        <th>Last Active Date</th>
                        <th>Videos Watched</th>
                      </tr>
                    </thead>
                    <tbody>
                      {users.map((user) => (
                        <tr key={user.uid}>
                          <td>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                              <img src={user.photoUrl} alt={user.displayName} style={{ width: '34px', height: '34px', borderRadius: '50%' }} />
                              <span style={{ fontWeight: 600 }}>{user.displayName}</span>
                            </div>
                          </td>
                          <td>{user.email}</td>
                          <td>
                            <span className={`badge ${user.role === 'admin' ? 'badge-success' : 'badge-primary'}`}>
                              {user.role}
                            </span>
                          </td>
                          <td>{new Date(user.lastActiveDate).toLocaleDateString(undefined, { dateStyle: 'medium' })}</td>
                          <td>{user.totalVideosWatched} video(s)</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}

          {/* ============ SUBJECTS VIEW ============ */}
          {activeTab === 'subjects' && (
            <div className="content-section">
              <div className="section-header">
                <div className="search-input-wrapper">
                  <Search size={18} className="search-icon-pos" />
                  <input 
                    type="text" 
                    placeholder="Search subjects..." 
                    className="search-input" 
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                  />
                </div>
                <button className="primary-btn" onClick={() => openAddModal('subject')}>
                  <Plus size={16} />
                  Add Subject
                </button>
              </div>

              <div className="table-container">
                <table className="custom-table">
                  <thead>
                    <tr>
                      <th>Thumbnail</th>
                      <th>Subject ID</th>
                      <th>Title</th>
                      <th>Description</th>
                      <th>Chapters</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {subjects
                      .filter(s => s.title.toLowerCase().includes(searchQuery.toLowerCase()) || s.description.toLowerCase().includes(searchQuery.toLowerCase()))
                      .map((sub) => (
                        <tr key={sub.id}>
                          <td>
                            <img src={sub.thumbnailUrl} alt={sub.title} className="item-thumbnail" />
                          </td>
                          <td><code style={{ fontSize: '13px', color: 'var(--accent-primary)', fontWeight: 600 }}>{sub.id}</code></td>
                          <td><span style={{ fontWeight: 600 }}>{sub.title}</span></td>
                          <td style={{ maxWidth: '300px', color: 'var(--text-secondary)', fontSize: '13px' }}>{sub.description}</td>
                          <td>{chapters.filter(c => c.subjectId === sub.id).length} chapters</td>
                          <td>
                            <div className="action-buttons-group">
                              <button 
                                className="icon-action-btn edit" 
                                onClick={() => openEditModal('subject', sub)}
                                title="Edit Subject"
                              >
                                <Edit3 size={14} />
                              </button>
                              <button 
                                className="icon-action-btn delete" 
                                onClick={() => handleDelete('subject', sub.id)}
                                title="Delete Subject"
                              >
                                <Trash2 size={14} />
                              </button>
                            </div>
                          </td>
                        </tr>
                      ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* ============ CHAPTERS VIEW ============ */}
          {activeTab === 'chapters' && (
            <div>
              {/* Dropdown Filters */}
              <div style={{ display: 'flex', gap: '16px', marginBottom: '24px', alignItems: 'center' }}>
                <div className="form-group" style={{ marginBottom: 0 }}>
                  <label htmlFor="subjectFilter" style={{ fontSize: '12px', fontWeight: 700 }}>Filter by Subject</label>
                  <select 
                    id="subjectFilter"
                    className="form-control" 
                    style={{ width: '240px', padding: '10px 14px' }}
                    value={selectedSubjectId}
                    onChange={(e) => {
                      const subId = e.target.value;
                      setSelectedSubjectId(subId);
                      const filtered = chapters.filter(c => c.subjectId === subId);
                      if (filtered.length > 0) {
                        setSelectedChapterId(filtered[0].id);
                      } else {
                        setSelectedChapterId('');
                      }
                    }}
                  >
                    {subjects.map(s => (
                      <option key={s.id} value={s.id}>{s.title}</option>
                    ))}
                  </select>
                </div>
              </div>

              <div className="content-section">
                <div className="section-header">
                  <div className="search-input-wrapper">
                    <Search size={18} className="search-icon-pos" />
                    <input 
                      type="text" 
                      placeholder="Search chapters..." 
                      className="search-input" 
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                    />
                  </div>
                  <button className="primary-btn" onClick={() => openAddModal('chapter')}>
                    <Plus size={16} />
                    Add Chapter
                  </button>
                </div>

                <div className="table-container">
                  <table className="custom-table">
                    <thead>
                      <tr>
                        <th>Chapter ID</th>
                        <th>Chapter Title</th>
                        <th>Description</th>
                        <th>Videos</th>
                        <th>Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {chapters
                        .filter(c => c.subjectId === selectedSubjectId)
                        .filter(c => c.title.toLowerCase().includes(searchQuery.toLowerCase()) || c.description.toLowerCase().includes(searchQuery.toLowerCase()))
                        .map((chap) => (
                          <tr key={chap.id}>
                            <td><code style={{ fontSize: '13px', color: 'var(--accent-primary)', fontWeight: 600 }}>{chap.id}</code></td>
                            <td><span style={{ fontWeight: 600 }}>{chap.title}</span></td>
                            <td style={{ maxWidth: '350px', color: 'var(--text-secondary)', fontSize: '13px' }}>{chap.description}</td>
                            <td>{videos.filter(v => v.chapterId === chap.id).length} video lectures</td>
                            <td>
                              <div className="action-buttons-group">
                                <button 
                                  className="icon-action-btn edit" 
                                  onClick={() => openEditModal('chapter', chap)}
                                  title="Edit Chapter"
                                >
                                  <Edit3 size={14} />
                                </button>
                                <button 
                                  className="icon-action-btn delete" 
                                  onClick={() => handleDelete('chapter', chap.id)}
                                  title="Delete Chapter"
                                >
                                  <Trash2 size={14} />
                                </button>
                              </div>
                            </td>
                          </tr>
                        ))}
                      {chapters.filter(c => c.subjectId === selectedSubjectId).length === 0 && (
                        <tr>
                          <td colSpan={5} style={{ textAlign: 'center', color: 'var(--text-muted)', padding: '40px' }}>
                            No chapters found for this subject. Click "Add Chapter" to create one.
                          </td>
                        </tr>
                      )}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}

          {/* ============ VIDEOS VIEW ============ */}
          {activeTab === 'videos' && (
            <div>
              {/* Dropdowns Filters */}
              <div style={{ display: 'flex', gap: '20px', marginBottom: '24px' }}>
                <div className="form-group" style={{ marginBottom: 0 }}>
                  <label htmlFor="videoSubjectFilter" style={{ fontSize: '12px', fontWeight: 700 }}>Select Subject</label>
                  <select 
                    id="videoSubjectFilter"
                    className="form-control" 
                    style={{ width: '220px', padding: '10px 14px' }}
                    value={selectedSubjectId}
                    onChange={(e) => {
                      const subId = e.target.value;
                      setSelectedSubjectId(subId);
                      const filtered = chapters.filter(c => c.subjectId === subId);
                      if (filtered.length > 0) {
                        setSelectedChapterId(filtered[0].id);
                      } else {
                        setSelectedChapterId('');
                      }
                    }}
                  >
                    {subjects.map(s => (
                      <option key={s.id} value={s.id}>{s.title}</option>
                    ))}
                  </select>
                </div>

                <div className="form-group" style={{ marginBottom: 0 }}>
                  <label htmlFor="videoChapterFilter" style={{ fontSize: '12px', fontWeight: 700 }}>Select Chapter</label>
                  <select 
                    id="videoChapterFilter"
                    className="form-control" 
                    style={{ width: '240px', padding: '10px 14px' }}
                    value={selectedChapterId}
                    onChange={(e) => setSelectedChapterId(e.target.value)}
                    disabled={!selectedSubjectId}
                  >
                    {chapters.filter(c => c.subjectId === selectedSubjectId).map(c => (
                      <option key={c.id} value={c.id}>{c.title}</option>
                    ))}
                    {chapters.filter(c => c.subjectId === selectedSubjectId).length === 0 && (
                      <option value="">No chapters available</option>
                    )}
                  </select>
                </div>
              </div>

              <div className="content-section">
                <div className="section-header">
                  <div className="search-input-wrapper">
                    <Search size={18} className="search-icon-pos" />
                    <input 
                      type="text" 
                      placeholder="Search videos..." 
                      className="search-input" 
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                    />
                  </div>
                  <button 
                    className="primary-btn" 
                    onClick={() => openAddModal('video')}
                    disabled={!selectedChapterId}
                  >
                    <Plus size={16} />
                    Add Video
                  </button>
                </div>

                <div className="table-container">
                  <table className="custom-table">
                    <thead>
                      <tr>
                        <th>Thumbnail</th>
                        <th>Video Title</th>
                        <th>Duration</th>
                        <th>YouTube Link</th>
                        <th>Created At</th>
                        <th>Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {videos
                        .filter(v => v.subjectId === selectedSubjectId && v.chapterId === selectedChapterId)
                        .filter(v => v.title.toLowerCase().includes(searchQuery.toLowerCase()) || v.description.toLowerCase().includes(searchQuery.toLowerCase()))
                        .map((vid) => (
                          <tr key={vid.id}>
                            <td>
                              <img src={vid.thumbnailUrl} alt={vid.title} className="item-thumbnail" />
                            </td>
                            <td>
                              <div style={{ display: 'flex', flexDirection: 'column' }}>
                                <span style={{ fontWeight: 600 }}>{vid.title}</span>
                                <span style={{ fontSize: '12px', color: 'var(--text-secondary)', marginTop: '4px', maxWidth: '300px', display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                                  {vid.description}
                                </span>
                              </div>
                            </td>
                            <td>
                              <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-secondary)' }}>
                                <Clock size={14} />
                                {vid.duration}
                              </div>
                            </td>
                            <td>
                              <div style={{ display: 'flex', flexDirection: 'column', gap: '6px', alignItems: 'flex-start' }}>
                                <button 
                                  onClick={() => {
                                    const ytId = getYoutubeId(vid.youtubeUrl);
                                    if (ytId) setPreviewVideoId(ytId);
                                  }}
                                  style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--accent-primary)', background: 'none', border: 'none', cursor: 'pointer', fontWeight: 600, padding: 0 }}
                                >
                                  <Play size={14} fill="var(--accent-primary)" />
                                  Play Inline
                                </button>
                                <a 
                                  href={vid.youtubeUrl} 
                                  target="_blank" 
                                  rel="noopener noreferrer" 
                                  style={{ fontSize: '11px', color: 'var(--text-secondary)', display: 'inline-flex', alignItems: 'center', gap: '4px', textDecoration: 'none', fontWeight: 500 }}
                                  onMouseOver={(e) => e.currentTarget.style.color = 'var(--accent-primary)'}
                                  onMouseOut={(e) => e.currentTarget.style.color = 'var(--text-secondary)'}
                                >
                                  Open on YouTube ↗
                                </a>
                              </div>
                            </td>
                            <td>{new Date(vid.createdAt).toLocaleDateString(undefined, { dateStyle: 'short' })}</td>
                            <td>
                              <div className="action-buttons-group">
                                <button 
                                  className="icon-action-btn edit" 
                                  onClick={() => openEditModal('video', vid)}
                                  title="Edit Video"
                                >
                                  <Edit3 size={14} />
                                </button>
                                <button 
                                  className="icon-action-btn delete" 
                                  onClick={() => handleDelete('video', vid.id)}
                                  title="Delete Video"
                                >
                                  <Trash2 size={14} />
                                </button>
                              </div>
                            </td>
                          </tr>
                        ))}
                      {videos.filter(v => v.subjectId === selectedSubjectId && v.chapterId === selectedChapterId).length === 0 && (
                        <tr>
                          <td colSpan={6} style={{ textAlign: 'center', color: 'var(--text-muted)', padding: '40px' }}>
                            No video lectures found for this chapter. Click "Add Video" to upload a new one.
                          </td>
                        </tr>
                      )}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}

          {/* ============ LECTURE DECKS VIEW ============ */}
          {activeTab === 'lectureDecks' && (
            <div className="content-section">
              <div className="section-header">
                <div className="search-input-wrapper">
                  <Search size={18} className="search-icon-pos" />
                  <input 
                    type="text" 
                    placeholder="Search lecture decks..." 
                    className="search-input" 
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                  />
                </div>
                <button className="primary-btn" onClick={() => openAddModal('lectureDeck')}>
                  <Plus size={16} />
                  Create Lecture Deck
                </button>
              </div>

              <div className="table-container">
                <table className="custom-table">
                  <thead>
                    <tr>
                      <th>Deck Title</th>
                      <th>Parent Subject</th>
                      <th>Lectures Count</th>
                      <th>Created At</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {lectureDecks
                      .filter(d => d.title.toLowerCase().includes(searchQuery.toLowerCase()) || d.description.toLowerCase().includes(searchQuery.toLowerCase()))
                      .map((deck) => (
                        <tr key={deck.id}>
                          <td>
                            <div style={{ display: 'flex', flexDirection: 'column' }}>
                              <span style={{ fontWeight: 600 }}>{deck.title}</span>
                              <span style={{ fontSize: '12px', color: 'var(--text-secondary)', marginTop: '4px', maxWidth: '400px' }}>
                                {deck.description}
                              </span>
                            </div>
                          </td>
                          <td>
                            <span className="badge badge-primary" style={{ textTransform: 'uppercase' }}>
                              {deck.subjectId}
                            </span>
                          </td>
                          <td>
                            <span style={{ fontWeight: 600 }}>
                              {deck.videoIds.length} lectures
                            </span>
                          </td>
                          <td>{new Date(deck.createdAt).toLocaleDateString(undefined, { dateStyle: 'short' })}</td>
                          <td>
                            <div className="action-buttons-group">
                              <button 
                                className="icon-action-btn edit" 
                                onClick={() => openEditModal('lectureDeck', deck)}
                                title="Edit Lecture Deck"
                              >
                                <Edit3 size={14} />
                              </button>
                              <button 
                                className="icon-action-btn delete" 
                                onClick={() => handleDelete('lectureDeck', deck.id)}
                                title="Delete Lecture Deck"
                              >
                                <Trash2 size={14} />
                              </button>
                            </div>
                          </td>
                        </tr>
                      ))}
                    {lectureDecks.length === 0 && (
                      <tr>
                        <td colSpan={5} style={{ textAlign: 'center', color: 'var(--text-muted)', padding: '40px' }}>
                          No lecture presentation decks created yet. Click "Create Lecture Deck" to build one.
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* ============ USER DIRECTORY VIEW ============ */}
          {activeTab === 'users' && (
            <div className="content-section">
              <div className="section-header">
                <div className="search-input-wrapper">
                  <Search size={18} className="search-icon-pos" />
                  <input 
                    type="text" 
                    placeholder="Search users..." 
                    className="search-input" 
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                  />
                </div>
              </div>

              <div className="table-container">
                <table className="custom-table">
                  <thead>
                    <tr>
                      <th>User Profile</th>
                      <th>Email ID</th>
                      <th>Current System Role</th>
                      <th>Streak Status</th>
                      <th>Lectures Completed</th>
                      <th>Modify Role</th>
                    </tr>
                  </thead>
                  <tbody>
                    {users
                      .filter(u => u.displayName.toLowerCase().includes(searchQuery.toLowerCase()) || u.email.toLowerCase().includes(searchQuery.toLowerCase()))
                      .map((user) => (
                        <tr key={user.uid}>
                          <td>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
                              <img src={user.photoUrl} alt={user.displayName} style={{ width: '38px', height: '38px', borderRadius: '50%', border: '2px solid var(--border-color)' }} />
                              <span style={{ fontWeight: 600 }}>{user.displayName}</span>
                            </div>
                          </td>
                          <td>{user.email}</td>
                          <td>
                            <span className={`badge ${user.role === 'admin' ? 'badge-success' : 'badge-primary'}`}>
                              {user.role}
                            </span>
                          </td>
                          <td>
                            <span style={{ fontWeight: 700, color: 'var(--accent-warning)', display: 'flex', alignItems: 'center', gap: '4px' }}>
                              🔥 {user.streak} days
                            </span>
                          </td>
                          <td>
                            <span style={{ fontWeight: 600, color: 'var(--accent-success)' }}>
                              ✓ {user.totalVideosWatched} lectures
                            </span>
                          </td>
                          <td>
                            <button 
                              className="secondary-btn" 
                              style={{ padding: '6px 12px', fontSize: '12px' }}
                              onClick={() => toggleUserRole(user.uid, user.role)}
                            >
                              Make {user.role === 'admin' ? 'Student' : 'Admin'}
                            </button>
                          </td>
                        </tr>
                      ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

        </div>
      </main>

      {/* ============ MODAL WINDOW ============ */}
      {isModalOpen && (
        <div className="modal-overlay">
          <div className="modal-content">
            <div className="modal-header">
              <h3>
                {modalAction === 'add' ? 'Add New' : 'Edit'}{' '}
                {modalType === 'subject' && 'Subject'}
                {modalType === 'chapter' && 'Chapter'}
                {modalType === 'video' && 'Video Lecture'}
              </h3>
              <button className="close-btn" onClick={() => setIsModalOpen(false)}>
                <X size={20} />
              </button>
            </div>
            
            <form onSubmit={handleSubmit}>
              <div className="modal-body">
                
                {/* 1. SUBJECT FORM */}
                {modalType === 'subject' && (
                  <div>
                    <div className="form-group">
                      <label htmlFor="subIdInput">Subject ID (Immutable, lowercase, e.g. "pathology")</label>
                      <input 
                        id="subIdInput"
                        type="text" 
                        className="form-control" 
                        required 
                        disabled={modalAction === 'edit'}
                        value={subjectForm.id}
                        onChange={(e) => setSubjectForm({ ...subjectForm, id: e.target.value.toLowerCase().replace(/\s+/g, '') })}
                      />
                    </div>
                    <div className="form-group">
                      <label htmlFor="subTitleInput">Subject Title</label>
                      <input 
                        id="subTitleInput"
                        type="text" 
                        className="form-control" 
                        required
                        value={subjectForm.title}
                        onChange={(e) => setSubjectForm({ ...subjectForm, title: e.target.value })}
                      />
                    </div>
                    <div className="form-group">
                      <label htmlFor="subDescInput">Detailed Description (Optional)</label>
                      <textarea 
                        id="subDescInput"
                        className="form-control" 
                        value={subjectForm.description}
                        onChange={(e) => setSubjectForm({ ...subjectForm, description: e.target.value })}
                      />
                    </div>
                    <div className="form-group">
                      <label htmlFor="subThumbnailInput">Thumbnail Image URL (Optional)</label>
                      <input 
                        id="subThumbnailInput"
                        type="url" 
                        className="form-control" 
                        value={subjectForm.thumbnailUrl}
                        onChange={(e) => setSubjectForm({ ...subjectForm, thumbnailUrl: e.target.value })}
                      />
                    </div>
                  </div>
                )}

                {/* 2. CHAPTER FORM */}
                {modalType === 'chapter' && (
                  <div>
                    <div className="form-group">
                      <label htmlFor="chapSubjectSelect">Parent Subject</label>
                      <select 
                        id="chapSubjectSelect"
                        className="form-control" 
                        required
                        disabled={modalAction === 'edit'}
                        value={chapterForm.subjectId}
                        onChange={(e) => setChapterForm({ ...chapterForm, subjectId: e.target.value })}
                      >
                        {subjects.map(s => (
                          <option key={s.id} value={s.id}>{s.title}</option>
                        ))}
                      </select>
                    </div>
                    <div className="form-group">
                      <label htmlFor="chapTitleInput">Chapter Title</label>
                      <input 
                        id="chapTitleInput"
                        type="text" 
                        className="form-control" 
                        required
                        value={chapterForm.title}
                        onChange={(e) => setChapterForm({ ...chapterForm, title: e.target.value })}
                      />
                    </div>
                    <div className="form-group">
                      <label htmlFor="chapDescInput">Description / Learning Objectives (Optional)</label>
                      <textarea 
                        id="chapDescInput"
                        className="form-control" 
                        value={chapterForm.description}
                        onChange={(e) => setChapterForm({ ...chapterForm, description: e.target.value })}
                      />
                    </div>
                  </div>
                )}

                {/* 3. VIDEO FORM */}
                {modalType === 'video' && (
                  <div>
                    <div className="form-group">
                      <label htmlFor="vidSubjectSelect">Parent Subject</label>
                      <select 
                        id="vidSubjectSelect"
                        className="form-control" 
                        required
                        disabled={modalAction === 'edit'}
                        value={videoForm.subjectId}
                        onChange={(e) => {
                          const subId = e.target.value;
                          const filteredChaps = chapters.filter(c => c.subjectId === subId);
                          setVideoForm({
                            ...videoForm,
                            subjectId: subId,
                            chapterId: filteredChaps.length > 0 ? filteredChaps[0].id : ''
                          });
                        }}
                      >
                        {subjects.map(s => (
                          <option key={s.id} value={s.id}>{s.title}</option>
                        ))}
                      </select>
                    </div>
                    <div className="form-group">
                      <label htmlFor="vidChapterSelect">Parent Chapter</label>
                      <select 
                        id="vidChapterSelect"
                        className="form-control" 
                        required
                        disabled={modalAction === 'edit'}
                        value={videoForm.chapterId}
                        onChange={(e) => setVideoForm({ ...videoForm, chapterId: e.target.value })}
                      >
                        {chapters.filter(c => c.subjectId === videoForm.subjectId).map(c => (
                          <option key={c.id} value={c.id}>{c.title}</option>
                        ))}
                        {chapters.filter(c => c.subjectId === videoForm.subjectId).length === 0 && (
                          <option value="">No chapters available</option>
                        )}
                      </select>
                    </div>
                    <div className="form-group">
                      <label htmlFor="vidTitleInput">Video Title</label>
                      <input 
                        id="vidTitleInput"
                        type="text" 
                        className="form-control" 
                        required
                        value={videoForm.title}
                        onChange={(e) => setVideoForm({ ...videoForm, title: e.target.value })}
                      />
                    </div>
                    <div className="form-group">
                      <label htmlFor="vidDescInput">Video Description (Optional)</label>
                      <textarea 
                        id="vidDescInput"
                        className="form-control" 
                        value={videoForm.description}
                        onChange={(e) => setVideoForm({ ...videoForm, description: e.target.value })}
                      />
                    </div>
                    <div className="form-group">
                      <label htmlFor="vidDurationInput">Duration (Optional, MM:SS, e.g. "12:35")</label>
                      <input 
                        id="vidDurationInput"
                        type="text" 
                        className="form-control" 
                        placeholder="e.g. 15:45"
                        value={videoForm.duration}
                        onChange={(e) => setVideoForm({ ...videoForm, duration: e.target.value })}
                      />
                    </div>
                    <div className="form-group">
                      <label htmlFor="vidUrlInput">YouTube URL</label>
                      <input 
                        id="vidUrlInput"
                        type="url" 
                        className="form-control" 
                        required
                        placeholder="https://www.youtube.com/watch?v=..."
                        value={videoForm.youtubeUrl}
                        onChange={(e) => setVideoForm({ ...videoForm, youtubeUrl: e.target.value })}
                      />
                    </div>

                    {/* Video Jump Points Widget */}
                    <div className="form-group">
                      <label style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '13px', fontWeight: 700, marginBottom: '8px' }}>
                        Video Jump-Points (Timestamps)
                        <button 
                          type="button" 
                          className="secondary-btn" 
                          style={{ padding: '4px 8px', fontSize: '11px' }}
                          onClick={() => {
                            setVideoForm({
                              ...videoForm,
                              jumpPoints: [...(videoForm.jumpPoints || []), { label: '', timestamp: 0 }]
                            });
                          }}
                        >
                          + Add Jump Point
                        </button>
                      </label>
                      <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', marginTop: '8px' }}>
                        {(videoForm.jumpPoints || []).map((jp, jpIdx) => (
                          <div key={jpIdx} style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                            <input 
                              type="text" 
                              placeholder="Label (e.g. Incision)" 
                              className="form-control" 
                              style={{ flex: 2, marginBottom: 0 }}
                              value={jp.label}
                              onChange={(e) => {
                                const updatedJps = [...videoForm.jumpPoints];
                                updatedJps[jpIdx].label = e.target.value;
                                setVideoForm({ ...videoForm, jumpPoints: updatedJps });
                              }}
                            />
                            <input 
                              type="text" 
                              placeholder="Time (MM:SS)" 
                              className="form-control" 
                              style={{ flex: 1, marginBottom: 0 }}
                              value={secondsToTime(jp.timestamp)}
                              onChange={(e) => {
                                const updatedJps = [...videoForm.jumpPoints];
                                updatedJps[jpIdx].timestamp = timeToSeconds(e.target.value);
                                setVideoForm({ ...videoForm, jumpPoints: updatedJps });
                              }}
                            />
                            <button 
                              type="button" 
                              className="icon-action-btn delete"
                              style={{ padding: '8px' }}
                              onClick={() => {
                                const updatedJps = videoForm.jumpPoints.filter((_, idx) => idx !== jpIdx);
                                setVideoForm({ ...videoForm, jumpPoints: updatedJps });
                              }}
                            >
                              <X size={14} />
                            </button>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                )}

                {/* 4. LECTURE DECK FORM */}
                {modalType === 'lectureDeck' && (
                  <div>
                    <div className="form-group">
                      <label htmlFor="deckTitleInput">Deck Title</label>
                      <input 
                        id="deckTitleInput"
                        type="text" 
                        className="form-control" 
                        required
                        placeholder="e.g. Thoracic Surgery Basics"
                        value={lectureDeckForm.title}
                        onChange={(e) => setLectureDeckForm({ ...lectureDeckForm, title: e.target.value })}
                      />
                    </div>
                    <div className="form-group">
                      <label htmlFor="deckDescInput">Description / Presenter Notes (Optional)</label>
                      <textarea 
                        id="deckDescInput"
                        className="form-control" 
                        placeholder="Provide details about the presentation topics..."
                        value={lectureDeckForm.description}
                        onChange={(e) => setLectureDeckForm({ ...lectureDeckForm, description: e.target.value })}
                      />
                    </div>
                    <div className="form-group">
                      <label htmlFor="deckSubjectSelect">Parent Subject</label>
                      <select 
                        id="deckSubjectSelect"
                        className="form-control" 
                        required
                        value={lectureDeckForm.subjectId}
                        onChange={(e) => {
                          setLectureDeckForm({ 
                            ...lectureDeckForm, 
                            subjectId: e.target.value,
                            videoIds: [] // Reset selected videos if subject changes
                          });
                        }}
                      >
                        {subjects.map(s => (
                          <option key={s.id} value={s.id}>{s.title}</option>
                        ))}
                      </select>
                    </div>

                    {/* Playlist builder grid */}
                    <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 1fr', gap: '20px', marginTop: '16px' }}>
                      {/* Left: Available videos */}
                      <div>
                        <label style={{ fontWeight: 700, fontSize: '13px', marginBottom: '8px', display: 'block' }}>Available Lectures</label>
                        <div style={{ maxHeight: '250px', overflowY: 'auto', border: '1px solid var(--border-color)', borderRadius: '8px', padding: '8px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
                          {videos
                            .filter(v => v.subjectId === lectureDeckForm.subjectId)
                            .map(vid => {
                              const isAdded = lectureDeckForm.videoIds.includes(vid.id);
                              return (
                                <div key={vid.id} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '6px 10px', backgroundColor: 'var(--bg-tertiary)', borderRadius: '6px', fontSize: '12px' }}>
                                  <span style={{ fontWeight: 600, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', maxWidth: '140px' }}>{vid.title}</span>
                                  <button
                                    type="button"
                                    className={isAdded ? "secondary-btn" : "primary-btn"}
                                    style={{ padding: '3px 8px', fontSize: '11px' }}
                                    disabled={isAdded}
                                    onClick={() => {
                                      setLectureDeckForm({
                                        ...lectureDeckForm,
                                        videoIds: [...lectureDeckForm.videoIds, vid.id]
                                      });
                                    }}
                                  >
                                    {isAdded ? 'Added' : 'Add'}
                                  </button>
                                </div>
                              );
                            })}
                          {videos.filter(v => v.subjectId === lectureDeckForm.subjectId).length === 0 && (
                            <div style={{ padding: '20px', textAlign: 'center', color: 'var(--text-muted)', fontSize: '12px' }}>
                              No lectures available under this subject.
                            </div>
                          )}
                        </div>
                      </div>

                      {/* Right: Ordered playlist */}
                      <div>
                        <label style={{ fontWeight: 700, fontSize: '13px', marginBottom: '8px', display: 'block' }}>Ordered Playlist ({lectureDeckForm.videoIds.length})</label>
                        <div style={{ maxHeight: '250px', overflowY: 'auto', border: '1px solid var(--border-color)', borderRadius: '8px', padding: '8px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
                          {lectureDeckForm.videoIds.map((vidId, idx) => {
                            const vid = videos.find(v => v.id === vidId);
                            if (!vid) return null;
                            return (
                              <div key={vidId} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '6px', backgroundColor: 'var(--bg-primary)', borderRadius: '6px', border: '1px solid var(--border-color)', fontSize: '11px' }}>
                                <span style={{ fontWeight: 600, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', maxWidth: '100px' }}>{idx + 1}. {vid.title}</span>
                                <div style={{ display: 'flex', gap: '4px' }}>
                                  <button
                                    type="button"
                                    style={{ padding: '2px 4px', fontSize: '10px', cursor: 'pointer' }}
                                    disabled={idx === 0}
                                    onClick={() => {
                                      const updated = [...lectureDeckForm.videoIds];
                                      const temp = updated[idx];
                                      updated[idx] = updated[idx - 1];
                                      updated[idx - 1] = temp;
                                      setLectureDeckForm({ ...lectureDeckForm, videoIds: updated });
                                    }}
                                  >
                                    ↑
                                  </button>
                                  <button
                                    type="button"
                                    style={{ padding: '2px 4px', fontSize: '10px', cursor: 'pointer' }}
                                    disabled={idx === lectureDeckForm.videoIds.length - 1}
                                    onClick={() => {
                                      const updated = [...lectureDeckForm.videoIds];
                                      const temp = updated[idx];
                                      updated[idx] = updated[idx + 1];
                                      updated[idx + 1] = temp;
                                      setLectureDeckForm({ ...lectureDeckForm, videoIds: updated });
                                    }}
                                  >
                                    ↓
                                  </button>
                                  <button
                                    type="button"
                                    style={{ padding: '2px 4px', fontSize: '10px', color: 'red', cursor: 'pointer' }}
                                    onClick={() => {
                                      const updated = lectureDeckForm.videoIds.filter(id => id !== vidId);
                                      setLectureDeckForm({ ...lectureDeckForm, videoIds: updated });
                                    }}
                                  >
                                    ✕
                                  </button>
                                </div>
                              </div>
                            );
                          })}
                          {lectureDeckForm.videoIds.length === 0 && (
                            <div style={{ padding: '20px', textAlign: 'center', color: 'var(--text-muted)', fontSize: '12px' }}>
                              Playlist is empty. Add lectures from the left panel.
                            </div>
                          )}
                        </div>
                      </div>
                    </div>
                  </div>
                )}

              </div>
              <div className="modal-footer">
                <button type="button" className="secondary-btn" onClick={() => setIsModalOpen(false)}>
                  Cancel
                </button>
                <button type="submit" className="primary-btn">
                  Save Changes
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Inline Video Preview Modal */}
      {previewVideoId && (
        <div className="modal-overlay" onClick={(e) => { if (e.target === e.currentTarget) setPreviewVideoId(null); }}>
          <div className="modal-content" style={{ width: '640px', maxWidth: '95%' }}>
            <div className="modal-header">
              <h3>Lecture Video Inline Player</h3>
              <button className="close-btn" onClick={() => setPreviewVideoId(null)}>
                <X size={20} />
              </button>
            </div>
            <div className="modal-body" style={{ padding: 0, backgroundColor: '#000' }}>
              <div style={{ position: 'relative', paddingBottom: '56.25%', height: 0, overflow: 'hidden' }}>
                <iframe
                  src={`https://www.youtube.com/embed/${previewVideoId}?autoplay=1`}
                  title="YouTube video player"
                  frameBorder="0"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                  allowFullScreen
                  style={{ position: 'absolute', top: 0, left: 0, width: '100%', height: '100%' }}
                ></iframe>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Custom Delete Confirmation Modal */}
      {deleteConfirm.isOpen && (
        <div className="modal-overlay" onClick={(e) => { if (e.target === e.currentTarget) setDeleteConfirm({ isOpen: false, type: null, id: null }); }}>
          <div className="modal-content" style={{ width: '400px', textAlign: 'center', padding: '32px' }}>
            <div className="danger-modal-icon">
              <Trash2 size={28} />
            </div>
            <h3 style={{ fontSize: '20px', fontWeight: 700, color: 'var(--text-primary)', marginBottom: '8px' }}>Confirm Delete</h3>
            <p style={{ fontSize: '14px', color: 'var(--text-secondary)', marginBottom: '24px', lineHeight: 1.5 }}>
              Are you sure you want to delete this {deleteConfirm.type}? This action is permanent and cannot be undone.
            </p>
            <div style={{ display: 'flex', gap: '12px', justifyContent: 'center' }}>
              <button 
                className="secondary-btn" 
                style={{ padding: '10px 20px', minWidth: '100px' }}
                onClick={() => setDeleteConfirm({ isOpen: false, type: null, id: null })}
              >
                Cancel
              </button>
              <button 
                className="primary-btn" 
                style={{ backgroundColor: 'var(--accent-danger)', padding: '10px 20px', minWidth: '100px', display: 'inline-flex', justifyContent: 'center' }}
                onClick={handleConfirmDelete}
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Custom Error Modal */}
      {errorState.isOpen && (
        <div className="modal-overlay" onClick={(e) => { if (e.target === e.currentTarget) setErrorState({ isOpen: false, message: '' }); }}>
          <div className="modal-content" style={{ width: '400px', textAlign: 'center', padding: '32px' }}>
            <div className="danger-modal-icon" style={{ background: 'rgba(239, 68, 68, 0.1)', color: 'var(--accent-danger)' }}>
              <X size={28} />
            </div>
            <h3 style={{ fontSize: '20px', fontWeight: 700, color: 'var(--text-primary)', marginBottom: '8px' }}>System Alert</h3>
            <p style={{ fontSize: '14px', color: 'var(--text-secondary)', marginBottom: '24px', lineHeight: 1.5 }}>
              {errorState.message}
            </p>
            <div style={{ display: 'flex', justifyContent: 'center' }}>
              <button 
                className="primary-btn" 
                style={{ padding: '10px 24px' }}
                onClick={() => setErrorState({ isOpen: false, message: '' })}
              >
                Acknowledge
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Glassmorphic Loading Spinner Overlay */}
      {isLoading && (
        <div className="loading-overlay">
          <div className="spinner"></div>
          <span className="loading-text">Processing Request...</span>
        </div>
      )}
    </div>
  );
}

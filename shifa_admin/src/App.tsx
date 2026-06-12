import React, { useState, useEffect } from 'react';
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
  Sparkles
} from 'lucide-react';
import { dbAPI } from './services/db';
import type { Subject, Chapter, Video, UserProfile } from './services/mockData';

export default function App() {
  const [theme, setTheme] = useState<'light' | 'dark'>(() => {
    return (localStorage.getItem('shifa_admin_theme') as 'light' | 'dark') || 'dark';
  });
  const [activeTab, setActiveTab] = useState<'dashboard' | 'subjects' | 'chapters' | 'videos' | 'users'>('dashboard');
  const [previewVideoId, setPreviewVideoId] = useState<string | null>(null);
  const [isLoggedIn, setIsLoggedIn] = useState(true);
  
  const getYoutubeId = (url: string) => {
    const regex = new RegExp('(?:youtube\\.com/(?:[^/]+/.+/(?:v|e(?:mbed)?)/|.*[?&]v=)|youtu\\.be/)([^"&?/\\s]{11})', 'i');
    const match = url.match(regex);
    return (match && match[1]) ? match[1] : '';
  };
  
  // Data State
  const [subjects, setSubjects] = useState<Subject[]>([]);
  const [chapters, setChapters] = useState<Chapter[]>([]);
  const [videos, setVideos] = useState<Video[]>([]);
  const [users, setUsers] = useState<UserProfile[]>([]);
  
  // Filtering & Dropdown State
  const [selectedSubjectId, setSelectedSubjectId] = useState<string>('');
  const [selectedChapterId, setSelectedChapterId] = useState<string>('');
  const [searchQuery, setSearchQuery] = useState<string>('');
  
  // Modals state
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalType, setModalType] = useState<'subject' | 'chapter' | 'video' | null>(null);
  const [modalAction, setModalAction] = useState<'add' | 'edit'>('add');
  
  // Form State
  const [editId, setEditId] = useState<string>('');
  const [subjectForm, setSubjectForm] = useState({ id: '', title: '', description: '', thumbnailUrl: '' });
  const [chapterForm, setChapterForm] = useState({ title: '', description: '', subjectId: '' });
  const [videoForm, setVideoForm] = useState({ title: '', description: '', youtubeUrl: '', duration: '', subjectId: '', chapterId: '' });

  // Load data helper
  const loadAllData = async () => {
    const s = await dbAPI.getSubjects();
    const c = await dbAPI.getChapters();
    const v = await dbAPI.getVideos();
    const u = await dbAPI.getUsers();
    
    setSubjects(s);
    setChapters(c);
    setVideos(v);
    setUsers(u);

    if (s.length > 0) {
      const initialSubId = selectedSubjectId || s[0].id;
      if (!selectedSubjectId) {
        setSelectedSubjectId(initialSubId);
      }
      const filtered = c.filter(chap => chap.subjectId === initialSubId);
      if (filtered.length > 0 && !selectedChapterId) {
        setSelectedChapterId(filtered[0].id);
      }
    }
  };

  // Init Data
  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    loadAllData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Sync Theme
  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('shifa_admin_theme', theme);
  }, [theme]);

  const toggleTheme = () => {
    setTheme(prev => prev === 'light' ? 'dark' : 'light');
  };

  // Open Add Modals
  const openAddModal = (type: 'subject' | 'chapter' | 'video') => {
    setModalType(type);
    setModalAction('add');
    setEditId('');
    
    if (type === 'subject') {
      setSubjectForm({ id: '', title: '', description: '', thumbnailUrl: '' });
    } else if (type === 'chapter') {
      setChapterForm({ title: '', description: '', subjectId: selectedSubjectId });
    } else if (type === 'video') {
      setVideoForm({ title: '', description: '', youtubeUrl: '', duration: '', subjectId: selectedSubjectId, chapterId: selectedChapterId });
    }
    setIsModalOpen(true);
  };

  // Open Edit Modals
  const openEditModal = (type: 'subject' | 'chapter' | 'video', item: Subject | Chapter | Video) => {
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
        chapterId: v.chapterId 
      });
    }
    setIsModalOpen(true);
  };

  // Handle Form Submission
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (modalType === 'subject') {
        await dbAPI.saveSubject(subjectForm);
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
          duration: videoForm.duration
        });
      }
      setIsModalOpen(false);
      await loadAllData();
    } catch (err) {
      console.error("Error saving content: ", err);
    }
  };

  // Handle Deletion
  const handleDelete = async (type: 'subject' | 'chapter' | 'video', id: string) => {
    if (window.confirm(`Are you sure you want to delete this ${type}? This action cannot be undone.`)) {
      if (type === 'subject') {
        await dbAPI.deleteSubject(id);
      } else if (type === 'chapter') {
        await dbAPI.deleteChapter(id);
      } else if (type === 'video') {
        await dbAPI.deleteVideo(id);
      }
      await loadAllData();
    }
  };

  // Toggle User Role
  const toggleUserRole = async (uid: string, currentRole: 'student' | 'admin') => {
    const targetRole = currentRole === 'admin' ? 'student' : 'admin';
    await dbAPI.updateUserRole(uid, targetRole);
    await loadAllData();
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
            <img src="/logo.png" alt="Shifa Care Logo" style={{ height: '70px', width: 'auto', marginBottom: '8px', borderRadius: '12px', background: 'white', padding: '6px' }} />
            <h2 style={{ fontSize: '24px', fontWeight: 800, color: 'var(--text-primary)' }}>Shifa Care Admin Console</h2>
            <p style={{ fontSize: '13px', color: 'var(--text-secondary)', textAlign: 'center' }}>Please authenticate to access the course catalog dashboard.</p>
          </div>
          
          <form onSubmit={(e) => { e.preventDefault(); setIsLoggedIn(true); }} style={{ display: 'flex', flexDirection: 'column', gap: '18px' }}>
            <div className="form-group" style={{ marginBottom: 0 }}>
              <label>Administrator Email</label>
              <input type="email" required className="form-control" defaultValue="admin@shifa.org" />
            </div>
            <div className="form-group" style={{ marginBottom: 0 }}>
              <label>Password</label>
              <input type="password" required className="form-control" defaultValue="password" />
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
          <img src="/logo.png" alt="Logo" style={{ height: '34px', width: 'auto', borderRadius: '6px', background: 'white', padding: '3px' }} />
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
                          <td>{sub.chaptersCount} chapters</td>
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
                            <td>{chap.videosCount} video lectures</td>
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
                      <label htmlFor="subDescInput">Detailed Description</label>
                      <textarea 
                        id="subDescInput"
                        className="form-control" 
                        required
                        value={subjectForm.description}
                        onChange={(e) => setSubjectForm({ ...subjectForm, description: e.target.value })}
                      />
                    </div>
                    <div className="form-group">
                      <label htmlFor="subThumbnailInput">Thumbnail Image URL</label>
                      <input 
                        id="subThumbnailInput"
                        type="url" 
                        className="form-control" 
                        required
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
                      <label htmlFor="chapDescInput">Description / Learning Objectives</label>
                      <textarea 
                        id="chapDescInput"
                        className="form-control" 
                        required
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
                      <label htmlFor="vidDescInput">Video Description</label>
                      <textarea 
                        id="vidDescInput"
                        className="form-control" 
                        required
                        value={videoForm.description}
                        onChange={(e) => setVideoForm({ ...videoForm, description: e.target.value })}
                      />
                    </div>
                    <div className="form-group">
                      <label htmlFor="vidDurationInput">Duration (MM:SS, e.g. "12:35")</label>
                      <input 
                        id="vidDurationInput"
                        type="text" 
                        className="form-control" 
                        required
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
        <div className="modal-overlay" onClick={() => setPreviewVideoId(null)}>
          <div className="modal-content" style={{ width: '640px', maxWidth: '95%' }} onClick={(e) => e.stopPropagation()}>
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
    </div>
  );
}

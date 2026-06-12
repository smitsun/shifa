import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/entities.dart';
import '../providers/providers.dart';
import '../widgets/glass_card.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final Video video;
  final List<Video> playlist;

  const VideoPlayerScreen({
    super.key,
    required this.video,
    required this.playlist,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  late TextEditingController _noteController;
  
  bool _isBookmarked = false;
  List<VideoNote> _notes = [];
  bool _isPlayerReady = false;

  bool _isCasting = false;
  String? _selectedCastDisplay;
  bool _presenterViewEnabled = false;
  Duration _elapsedPresentationTime = Duration.zero;
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    _elapsedPresentationTime = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedPresentationTime += const Duration(seconds: 1);
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    
    // 1. Initialize Youtube controller with Video ID
    _controller = YoutubePlayerController(
      initialVideoId: widget.video.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        forceHD: false,
      ),
    )..addListener(_listener);

    _loadInitialState();
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      // Periodic progress saving (e.g., save current elapsed time)
      final duration = _controller.value.position.inSeconds;
      final totalDuration = _controller.value.metaData.duration.inSeconds;
      
      if (duration > 0 && totalDuration > 0) {
        final isCompleted = duration >= (totalDuration - 5); // completed if within 5s of end
        
        ref.read(learningRepositoryProvider).saveProgress(
          widget.video.id,
          widget.video.subjectId,
          widget.video.chapterId,
          duration,
          isCompleted,
        );
      }
    }
  }

  void _loadInitialState() async {
    final repo = ref.read(learningRepositoryProvider);
    
    // Get saved progress to resume playback
    final progress = await repo.getProgress(widget.video.id);
    if (progress != null && progress.watchTime > 0) {
      _controller.seekTo(Duration(seconds: progress.watchTime));
    }

    // Check bookmark status
    final bookmarked = await repo.isBookmarked(widget.video.id);
    
    // Load notes
    final notes = await repo.getVideoNotes(widget.video.id);

    if (mounted) {
      setState(() {
        _isBookmarked = bookmarked;
        _notes = notes;
      });
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    _noteController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // --- Cast Simulation Helper Methods ---
  void _showCastSelectorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Connect to Classroom Display'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.tv_rounded),
                title: const Text('Main Lecture Room Projector'),
                onTap: () => _connectToCast('Main Projector'),
              ),
              ListTile(
                leading: const Icon(Icons.tv_rounded),
                title: const Text('Anatomy Lab Side Screen'),
                onTap: () => _connectToCast('Lab Side Screen'),
              ),
              ListTile(
                leading: const Icon(Icons.tv_rounded),
                title: const Text('Seminar Hall Display B'),
                onTap: () => _connectToCast('Seminar Display B'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            )
          ],
        );
      },
    );
  }

  void _connectToCast(String displayName) {
    Navigator.pop(context); // Dismiss dialog
    setState(() {
      _isCasting = true;
      _selectedCastDisplay = displayName;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Casting to $displayName successfully!')),
    );
  }

  void _disconnectCast() {
    _stopTimer();
    setState(() {
      _isCasting = false;
      _selectedCastDisplay = null;
      _presenterViewEnabled = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Disconnected from classroom display.')),
    );
  }

  Widget _buildPresenterDashboard(ThemeData theme, Widget player) {
    final isPlaying = _controller.value.isPlaying;
    final currentPosition = _controller.value.position;
    final totalDuration = _controller.value.metaData.duration;

    return Container(
      color: const Color(0xFF0F0F1A), // midnight blue
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () {
              setState(() {
                _presenterViewEnabled = false;
              });
              _stopTimer();
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Smart Remote Console',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Casting to $_selectedCastDisplay',
                style: TextStyle(color: Colors.blueAccent, fontSize: 11),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: _disconnectCast,
              icon: const Icon(Icons.cast_connected, color: Colors.redAccent, size: 16),
              label: const Text('Disconnect', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Presentation Timer & Status
              GlassCard(
                color: Colors.white.withOpacity(0.04),
                borderColor: Colors.white.withOpacity(0.1),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.green, blurRadius: 8, spreadRadius: 2),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'PRESENTATION ACTIVE',
                          style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _formatDuration(_elapsedPresentationTime.inSeconds),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'Courier',
                        letterSpacing: 2,
                      ),
                    ),
                    const Text(
                      'Elapsed Lecture Time',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Confidence Monitor (Direct Cast Preview)
              const Text(
                'CONFIDENCE MONITOR (CAST PREVIEW)',
                style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 180,
                  child: player,
                ),
              ),
              const SizedBox(height: 20),

              // Remote Control Actions
              GlassCard(
                color: Colors.white.withOpacity(0.04),
                borderColor: Colors.white.withOpacity(0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT LECTURE VIDEO',
                      style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.video.title,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    // Progress Slider
                    Row(
                      children: [
                        Text(
                          _formatDuration(currentPosition.inSeconds),
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        Expanded(
                          child: Slider(
                            value: currentPosition.inSeconds.toDouble(),
                            min: 0.0,
                            max: totalDuration.inSeconds.toDouble() > 0.0 
                                ? totalDuration.inSeconds.toDouble() 
                                : 100.0,
                            activeColor: theme.colorScheme.primary,
                            inactiveColor: Colors.white10,
                            onChanged: (value) {
                              _controller.seekTo(Duration(seconds: value.toInt()));
                            },
                          ),
                        ),
                        Text(
                          _formatDuration(totalDuration.inSeconds),
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                    // Playback Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 28),
                          onPressed: () {
                            final newPos = currentPosition - const Duration(seconds: 10);
                            _controller.seekTo(newPos < Duration.zero ? Duration.zero : newPos);
                          },
                        ),
                        const SizedBox(width: 24),
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: theme.colorScheme.primary,
                          child: IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              if (isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 28),
                          onPressed: () {
                            final newPos = currentPosition + const Duration(seconds: 10);
                            _controller.seekTo(newPos);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Jump Points inside dashboard
              if (widget.video.jumpPoints.isNotEmpty) ...[
                const Text(
                  'INDEXED JUMP POINTS',
                  style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.video.jumpPoints.length,
                    itemBuilder: (context, index) {
                      final jp = widget.video.jumpPoints[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.08),
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(0.15)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          onPressed: () {
                            _controller.seekTo(Duration(seconds: jp.timestamp));
                          },
                          icon: const Icon(Icons.label_important_outline_rounded, size: 14, color: Colors.blueAccent),
                          label: Text(
                            '${_formatDuration(jp.timestamp)} - ${jp.label}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Speaker Notes notepad
              const Text(
                'PRIVATE SPEAKER NOTES',
                style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 10),
              GlassCard(
                color: Colors.white.withOpacity(0.02),
                borderColor: Colors.white.withOpacity(0.08),
                padding: const EdgeInsets.all(12),
                child: const TextField(
                  maxLines: 5,
                  style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                  decoration: InputDecoration(
                    hintText: 'Type reminders, bullet points, and clinical notes here. Visible to you only, not classroom screens...',
                    hintStyle: TextStyle(color: Colors.white24, fontSize: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // --- Bookmark Toggle ---
  void _toggleBookmark() async {
    final repo = ref.read(learningRepositoryProvider);
    if (_isBookmarked) {
      await repo.removeBookmark(widget.video.id);
    } else {
      await repo.addBookmark(widget.video.id, 'video');
    }
    
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    final _ = ref.refresh(bookmarksProvider);
  }

  // --- Add Timestamped Note ---
  void _addNote() async {
    if (_noteController.text.trim().isEmpty) return;

    final repo = ref.read(learningRepositoryProvider);
    final timestamp = _controller.value.position.inSeconds;
    
    final note = await repo.addNote(
      widget.video.id,
      _noteController.text.trim(),
      timestamp,
    );

    setState(() {
      _notes.add(note);
      _notes.sort((a, b) => a.timestampInSeconds.compareTo(b.timestampInSeconds));
      _noteController.clear();
    });

    if (mounted) {
      FocusScope.of(context).unfocus();
    }
  }

  // --- Delete Note ---
  void _deleteNote(String id) async {
    final repo = ref.read(learningRepositoryProvider);
    await repo.deleteNote(id);
    setState(() {
      _notes.removeWhere((n) => n.id == id);
    });
  }

  // --- Play Next Video ---
  void _playNextVideo() {
    final index = widget.playlist.indexWhere((v) => v.id == widget.video.id);
    if (index >= 0 && index < widget.playlist.length - 1) {
      final nextVid = widget.playlist[index + 1];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            video: nextVid,
            playlist: widget.playlist,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have reached the end of this chapter!')),
      );
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildDescriptionText(String text, ThemeData theme) {
    final urlRegex = RegExp(
      r'(https?:\/\/[^\s]+)',
      caseSensitive: false,
    );

    final matches = urlRegex.allMatches(text);
    if (matches.isEmpty) {
      return Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, height: 1.4),
      );
    }

    final List<InlineSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, height: 1.4),
        ));
      }

      final url = match.group(0)!;
      spans.add(TextSpan(
        text: url,
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.primary,
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.w600,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            Clipboard.setData(ClipboardData(text: url));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Copied link: $url'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
      ));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, height: 1.4),
      ));
    }

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: theme.colorScheme.primary,
        progressColors: ProgressBarColors(
          playedColor: theme.colorScheme.primary,
          handleColor: theme.colorScheme.primary,
        ),
        onReady: () {
          setState(() {
            _isPlayerReady = true;
          });
        },
        onEnded: (data) {
          _playNextVideo();
        },
      ),
      builder: (context, player) {
        if (_presenterViewEnabled) {
          return _buildPresenterDashboard(theme, player);
        }
        return Container(
          decoration: isDark 
              ? AppTheme.darkPageBackgroundDecoration 
              : AppTheme.pageBackgroundDecoration,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: const Text('Lecture Video Player'),
              actions: [
                IconButton(
                  icon: Icon(
                    _isCasting ? Icons.cast_connected : Icons.cast_rounded,
                    color: _isCasting ? theme.colorScheme.primary : null,
                  ),
                  onPressed: _showCastSelectorDialog,
                  tooltip: 'Connect to classroom cast screen',
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Interactive Video Player widget
                player,

                // Video Metadata & Controls (GlassCard)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.video.title,
                          style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        _buildDescriptionText(widget.video.description, theme),
                        const SizedBox(height: 12),

                        // Jump points chips below description
                        if (widget.video.jumpPoints.isNotEmpty) ...[
                          SizedBox(
                            height: 38,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.video.jumpPoints.length,
                              itemBuilder: (context, index) {
                                final jp = widget.video.jumpPoints[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ActionChip(
                                    avatar: Icon(
                                      Icons.fast_forward_rounded,
                                      size: 14,
                                      color: theme.colorScheme.primary,
                                    ),
                                    label: Text(
                                      '${_formatDuration(jp.timestamp)} ${jp.label}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                                    side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
                                    onPressed: () {
                                      _controller.seekTo(Duration(seconds: jp.timestamp));
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Casting banner
                        if (_isCasting) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.cast_connected, color: theme.colorScheme.primary, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Casting to $_selectedCastDisplay',
                                    style: TextStyle(
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold, 
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _presenterViewEnabled = true;
                                    });
                                    _startTimer();
                                  },
                                  child: const Text('Open Presenter View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Actions bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Bookmark button
                            TextButton.icon(
                              onPressed: _toggleBookmark,
                              icon: Icon(
                                _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                                size: 18,
                              ),
                              label: Text(_isBookmarked ? 'Bookmarked' : 'Bookmark', style: const TextStyle(fontSize: 13)),
                            ),

                            // Share button
                            TextButton.icon(
                              onPressed: () {
                                Share.share(
                                  'Watch this medical lecture: ${widget.video.title}\nLink: ${widget.video.youtubeUrl}',
                                );
                              },
                              icon: const Icon(Icons.share_rounded, size: 18),
                              label: const Text('Share Link', style: TextStyle(fontSize: 13)),
                            ),

                            // Play Next Trigger
                            IconButton(
                              onPressed: _playNextVideo,
                              icon: const Icon(Icons.skip_next_rounded),
                              tooltip: 'Play Next Video',
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Interactive Notes & Playlist section (Tabs inside a GlassCard)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      child: DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            TabBar(
                              labelColor: theme.colorScheme.primary,
                              unselectedLabelColor: theme.colorScheme.onBackground.withOpacity(0.6),
                              indicatorColor: theme.colorScheme.primary,
                              tabs: const [
                                Tab(icon: Icon(Icons.note_alt_outlined), text: 'Personal Notes'),
                                Tab(icon: Icon(Icons.playlist_play_rounded), text: 'Chapter Lectures'),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  // 1. NOTES TAB
                                  _buildNotesTab(theme),

                                  // 2. PLAYLIST TAB
                                  _buildPlaylistTab(theme),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesTab(ThemeData theme) {
    return Column(
      children: [
        // Note Input
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Add note at ${_formatDuration(_controller.value.position.inSeconds)}...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: _addNote,
                icon: const Icon(Icons.check_rounded),
              )
            ],
          ),
        ),

        // Notes List
        Expanded(
          child: _notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notes_rounded, color: theme.colorScheme.onBackground.withOpacity(0.3), size: 40),
                      const SizedBox(height: 8),
                      const Text('No notes created for this lecture yet.', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _notes.length,
                  separatorBuilder: (c, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(note.noteText, style: const TextStyle(fontSize: 13)),
                      subtitle: Text(
                        'Timestamp: ${_formatDuration(note.timestampInSeconds)}',
                        style: TextStyle(color: theme.colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      leading: IconButton(
                        icon: const Icon(Icons.play_circle_fill_rounded, size: 28),
                        color: theme.colorScheme.secondary,
                        onPressed: () {
                          _controller.seekTo(Duration(seconds: note.timestampInSeconds));
                        },
                        tooltip: 'Seek to timestamp',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
                        onPressed: () => _deleteNote(note.id),
                      ),
                    );
                  },
                ),
        )
      ],
    );
  }

  Widget _buildPlaylistTab(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.playlist.length,
      itemBuilder: (context, index) {
        final vid = widget.playlist[index];
        final isCurrent = vid.id == widget.video.id;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCurrent 
                  ? theme.colorScheme.primary.withOpacity(0.15) 
                  : theme.colorScheme.onSurface.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCurrent ? Icons.play_circle_outline_rounded : Icons.play_arrow_rounded, 
              color: isCurrent ? theme.colorScheme.primary : Colors.grey,
            ),
          ),
          title: Text(
            vid.title, 
            style: TextStyle(
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
              color: isCurrent ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
            ),
          ),
          subtitle: Text('Duration: ${vid.duration}', style: const TextStyle(fontSize: 11)),
          trailing: const Icon(Icons.chevron_right_rounded, size: 16),
          onTap: isCurrent 
              ? null 
              : () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(
                        video: vid,
                        playlist: widget.playlist,
                      ),
                    ),
                  );
                },
        );
      },
    );
  }
}

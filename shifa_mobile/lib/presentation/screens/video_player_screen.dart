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
    super.dispose();
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

    ref.refresh(bookmarksProvider);
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

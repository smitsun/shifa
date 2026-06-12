import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/entities.dart';
import '../providers/providers.dart';
import 'video_player_screen.dart';

class SubjectDetailScreen extends ConsumerWidget {
  final Subject subject;

  const SubjectDetailScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersProvider(subject.id));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.title),
      ),
      body: CustomScrollView(
        slivers: [
          // Subject Thumbnail banner
          SliverToBoxAdapter(
            child: AspectRatio(
              aspectRatio: 1.8,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: subject.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorWidget: (c, u, e) => Container(color: theme.colorScheme.primaryContainer),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subject.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          // Chapters Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 28.0, bottom: 12.0),
              child: Text(
                'Course Chapters',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),

          // Chapters List
          chaptersAsync.when(
            data: (chapters) {
              if (chapters.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No chapters uploaded yet for this subject.')),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final chap = chapters[index];
                    return _ChapterExpansionTile(subject: subject, chapter: chap);
                  },
                  childCount: chapters.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Error loading chapters: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Expansion Tile to load lectures dynamically under chapter
class _ChapterExpansionTile extends ConsumerWidget {
  final Subject subject;
  final Chapter chapter;

  const _ChapterExpansionTile({required this.subject, required this.chapter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final videosAsync = ref.watch(videosProvider(StringListParam(subject.id, chapter.id)));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ExpansionTile(
        title: Text(
          chapter.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          chapter.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        expandedAlignment: Alignment.topLeft,
        children: [
          videosAsync.when(
            data: (videos) {
              if (videos.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: Text('No lectures available in this chapter yet.', style: TextStyle(fontSize: 13))),
                );
              }

              return Column(
                children: videos.map((vid) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.play_arrow_rounded, color: theme.colorScheme.primary, size: 28),
                    ),
                    title: Text(vid.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(
                      'Duration: ${vid.duration}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(
                            video: vid,
                            playlist: videos,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (err, stack) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: Text('Error: $err')),
            ),
          )
        ],
      ),
    );
  }
}

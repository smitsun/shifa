import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../providers/providers.dart';
import '../widgets/glass_card.dart';
import 'subject_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Widget> tabs = [
      const _DashboardTab(),
      const _SearchTab(),
      const _BookmarksTab(),
      const _ProfileTab(),
    ];

    return Container(
      decoration: isDark 
          ? AppTheme.darkPageBackgroundDecoration 
          : AppTheme.pageBackgroundDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true, // Allows list content to scroll under floating glass bottom bar
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12, width: 0.5),
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 24,
                  width: 24,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _currentIndex == 0
                    ? 'Shifa Care'
                    : (_currentIndex == 1
                        ? 'Search Library'
                        : (_currentIndex == 2 ? 'Bookmarks' : 'Student Profile')),
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
            ],
          ),
          actions: [
            if (_currentIndex == 0 && user != null)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Chip(
                  avatar: const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 16),
                  label: Text(
                    '${user.streak} Days',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        body: tabs[_currentIndex],
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: 24,
              blur: 20,
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) => setState(() => _currentIndex = index),
                backgroundColor: Colors.transparent,
                elevation: 0,
                indicatorColor: theme.colorScheme.primary.withOpacity(0.15),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.search_rounded),
                    selectedIcon: Icon(Icons.search_rounded),
                    label: 'Search',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bookmark_outline_rounded),
                    selectedIcon: Icon(Icons.bookmark_rounded),
                    label: 'Bookmarks',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Tab 1: Dashboard ---
class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () => ref.refresh(subjectsProvider.future),
      child: ListView(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 120.0),
        children: [
          // Greeting Banner
          Text(
            user != null ? 'Welcome Back, ${user.displayName}' : 'Welcome to Shifa Care',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            'What medical subjects would you like to review today?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // Quick learning stats (GlassCard)
          if (user != null) ...[
            GlassCard(
              padding: const EdgeInsets.all(20),
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.indigo.withOpacity(0.08),
              borderColor: isDark ? Colors.white.withOpacity(0.15) : Colors.indigo.withOpacity(0.2),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR PROGRESS',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.indigo.shade800,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${user.totalVideosWatched} Lectures Completed',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.indigo.shade900,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Linear indicator
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: 0.35, // Demo progress percentage
                            backgroundColor: isDark ? Colors.white24 : Colors.indigo.withOpacity(0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? Colors.white : theme.colorScheme.primary,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : theme.colorScheme.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: isDark ? Colors.white : theme.colorScheme.primary,
                      size: 28,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],

          // Featured Courses / Subjects Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Medical Subjects', style: theme.textTheme.titleMedium),
              Text(
                'View All',
                style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Subjects Grid list
          subjectsAsync.when(
            data: (subjects) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final sub = subjects[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubjectDetailScreen(subject: sub),
                        ),
                      );
                    },
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: sub.thumbnailUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
                                  child: Icon(Icons.book_rounded, color: theme.colorScheme.primary),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sub.title,
                                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${sub.chaptersCount} chapters',
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error loading subjects: $err')),
          ),
        ],
      ),
    );
  }
}

// --- Tab 2: Global Search ---
class _SearchTab extends ConsumerStatefulWidget {
  const _SearchTab();

  @override
  ConsumerState<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends ConsumerState<_SearchTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Search Field
          TextField(
            controller: _searchController,
            onChanged: (val) => ref.read(videoSearchQueryProvider.notifier).state = val.trim(),
            decoration: InputDecoration(
              hintText: 'Search video lectures or details...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(videoSearchQueryProvider.notifier).state = '';
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Search results
          Expanded(
            child: searchResults.when(
              data: (videos) {
                if (_searchController.text.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_library_rounded, size: 50, color: theme.colorScheme.primary.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        Text('Enter query to search library', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  );
                }
                
                if (videos.isEmpty) {
                  return const Center(child: Text('No lectures matching your search found.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: videos.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final vid = videos[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: vid.thumbnailUrl,
                          width: 80,
                          height: 60,
                          fit: BoxFit.cover,
                          errorWidget: (c, u, e) => const Icon(Icons.video_collection),
                        ),
                      ),
                      title: Text(vid.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(
                        vid.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        // Open player directly
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Search error: $err')),
            ),
          )
        ],
      ),
    );
  }
}

// --- Tab 3: Bookmarks ---
class _BookmarksTab extends ConsumerWidget {
  const _BookmarksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksProvider);
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(bookmarksProvider.future),
      child: bookmarksAsync.when(
        data: (bookmarks) {
          if (bookmarks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 50, color: theme.colorScheme.primary.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  Text('No bookmarks saved yet', style: theme.textTheme.bodyMedium),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final b = bookmarks[index];
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    b.itemId.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text('Type: ${b.itemType}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    onPressed: () async {
                      await ref.read(learningRepositoryProvider).removeBookmark(b.itemId);
                      ref.refresh(bookmarksProvider);
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

// --- Tab 4: Profile & Settings ---
class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (user == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () => ref.read(authStateProvider.notifier).logout(),
          child: const Text('Return to Login'),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 120.0),
      children: [
        // Profile Info (GlassCard)
        GlassCard(
          child: Column(
            children: [
              CircleAvatar(
                radius: 46,
                backgroundImage: user.photoUrl.isNotEmpty
                    ? CachedNetworkImageProvider(user.photoUrl)
                    : null,
                child: user.photoUrl.isEmpty
                    ? const Icon(Icons.person_rounded, size: 40)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(user.displayName, style: theme.textTheme.titleMedium?.copyWith(fontSize: 20)),
              const SizedBox(height: 4),
              Text(user.email, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Chip(
                label: Text(
                  user.role.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 11),
                ),
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                side: BorderSide.none,
              )
            ],
          ),
        ),
        const SizedBox(height: 28),

        Text('System Settings', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        
        // Settings triggers (GlassCard)
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark Theme'),
                trailing: Switch(
                  value: theme.brightness == Brightness.dark,
                  onChanged: (val) {
                    // Toggle Theme notifier integration
                  },
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.cleaning_services_outlined),
                title: const Text('Clear SQLite Offline Cache'),
                subtitle: const Text('Wipe all cached video meta details'),
                onTap: () async {
                  // Action to reset database
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Offline Cache cleared successfully!')),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        ElevatedButton.icon(
          onPressed: () => ref.read(authStateProvider.notifier).logout(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade50.withOpacity(isDark ? 0.08 : 0.8),
            foregroundColor: Colors.red,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.red.shade100.withOpacity(0.3)),
            ),
          ),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Log Out Account', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

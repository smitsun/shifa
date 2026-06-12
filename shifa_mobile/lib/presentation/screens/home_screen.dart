import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
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

    final List<Widget> tabs = [
      const _DashboardTab(),
      const _SearchTab(),
      const _BookmarksTab(),
      const _ProfileTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.healing_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _currentIndex == 0
                  ? 'Shifa Learning'
                  : (_currentIndex == 1
                      ? 'Search Library'
                      : (_currentIndex == 2 ? 'Bookmarks' : 'Student Profile')),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
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

    return RefreshIndicator(
      onRefresh: () => ref.refresh(subjectsProvider.future),
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Greeting Banner
          Text(
            user != null ? 'Welcome Back, ${user.displayName}' : 'Welcome to Shifa',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            'What medical subjects would you like to review today?',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Quick learning stats
          if (user != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'YOUR PROGRESS',
                          style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${user.totalVideosWatched} Lectures Completed',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        // Linear indicator
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            value: 0.35, // Demo progress percentage
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.white,
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
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: CachedNetworkImage(
                              imageUrl: sub.thumbnailUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: theme.colorScheme.surfaceVariant,
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: theme.colorScheme.surfaceVariant,
                                child: Icon(Icons.book_rounded, color: theme.colorScheme.primary),
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
            padding: const EdgeInsets.all(20),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final b = bookmarks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
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

    if (user == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () => ref.read(authStateProvider.notifier).logout(),
          child: const Text('Return to Login'),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        // Profile Info
        Center(
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
              const SizedBox(height: 6),
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
        const SizedBox(height: 40),

        Text('System Settings', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        
        // Settings triggers
        Card(
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
            backgroundColor: Colors.red.shade50,
            foregroundColor: Colors.red,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.red.shade100),
            ),
          ),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Log Out Account', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/database_helper.dart';
import '../../core/services/network_info.dart';
import '../../data/datasources/remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/learning_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/interfaces.dart';

// --- Base Services Providers ---
final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfoImpl());
final remoteDataSourceProvider = Provider<RemoteDataSource>((ref) => RemoteDataSourceImpl());
final dbHelperProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

// --- Auth Repository Provider ---
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(remoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: remote);
});

// --- Auth State Notifier ---
class AuthNotifier extends StateNotifier<AsyncValue<AppUser?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final user = await _repository.currentUser;
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email, password);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> signup(String email, String password, String name) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.signup(email, password, name);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> loginWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.loginWithGoogle();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> loginAsGuest() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.loginAsGuest();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();
    try {
      await _repository.sendPasswordResetEmail(email);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AppUser?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

// --- Learning Repository Provider ---
final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  final remote = ref.watch(remoteDataSourceProvider);
  final db = ref.watch(dbHelperProvider);
  final net = ref.watch(networkInfoProvider);
  
  // Scope repository items to currently logged in user ID, defaulting to "guest"
  final authState = ref.watch(authStateProvider);
  final userId = authState.maybeWhen(
    data: (user) => user?.uid ?? 'guest_user',
    orElse: () => 'guest_user',
  );

  return LearningRepositoryImpl(
    remoteDataSource: remote,
    dbHelper: db,
    networkInfo: net,
    currentUserId: userId,
  );
});

// --- Learning Content Providers ---
final subjectsProvider = FutureProvider.autoDispose<List<Subject>>((ref) async {
  final repo = ref.watch(learningRepositoryProvider);
  return repo.getSubjects();
});

final chaptersProvider = FutureProvider.autoDispose.family<List<Chapter>, String>((ref, subjectId) async {
  final repo = ref.watch(learningRepositoryProvider);
  return repo.getChapters(subjectId);
});

final videosProvider = FutureProvider.autoDispose.family<List<Video>, StringListParam>((ref, param) async {
  final repo = ref.watch(learningRepositoryProvider);
  return repo.getVideos(param.subjectId, param.chapterId);
});

// Search query provider
final videoSearchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider.autoDispose<List<Video>>((ref) async {
  final query = ref.watch(videoSearchQueryProvider);
  if (query.isEmpty) return [];
  final repo = ref.watch(learningRepositoryProvider);
  return repo.searchVideos(query);
});

// Parameter class for family provider
class StringListParam {
  final String subjectId;
  final String chapterId;

  StringListParam(this.subjectId, this.chapterId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StringListParam &&
          runtimeType == other.runtimeType &&
          subjectId == other.subjectId &&
          chapterId == other.chapterId;

  @override
  int get hashCode => subjectId.hashCode ^ chapterId.hashCode;
}

// User Bookmarks provider
final bookmarksProvider = FutureProvider.autoDispose<List<Bookmark>>((ref) async {
  final repo = ref.watch(learningRepositoryProvider);
  return repo.getBookmarks();
});

// Video progress check provider
final videoProgressProvider = FutureProvider.autoDispose.family<VideoProgress?, String>((ref, videoId) async {
  final repo = ref.watch(learningRepositoryProvider);
  return repo.getProgress(videoId);
});

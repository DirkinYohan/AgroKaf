import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agrokaf/core/providers/service_providers.dart';
import 'package:agrokaf/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:agrokaf/features/profile/domain/entities/user_profile.dart';
import 'package:agrokaf/features/profile/domain/repositories/profile_repository.dart';

final Provider<ProfileRepository> profileRepositoryProvider =
    Provider<ProfileRepository>(
      (Ref ref) => ProfileRepositoryImpl(
        ref.watch(databaseServiceProvider),
        ref.watch(imageServiceProvider),
      ),
    );

/// The saved user profile, or `null` if none exists yet.
final FutureProvider<UserProfile?> profileProvider =
    FutureProvider<UserProfile?>(
      (Ref ref) => ref.watch(profileRepositoryProvider).getProfile(),
    );

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/database_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/profile_photo_service.dart';
import '../data/user_profile.dart';
import '../data/user_profile_repository.dart';

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository(ref.watch(databaseProvider));
});

final profilePhotoServiceProvider = Provider<ProfilePhotoService>((ref) {
  return ProfilePhotoService(ref.watch(firebaseStorageProvider));
});

final userProfileProvider = StreamProvider<UserProfile>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(const UserProfile());
  return ref.watch(userProfileRepositoryProvider).watch(user.uid);
});

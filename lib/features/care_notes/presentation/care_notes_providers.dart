import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/database_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/care_note.dart';
import '../data/care_notes_repository.dart';

final careNotesRepositoryProvider = Provider<CareNotesRepository>((ref) {
  return CareNotesRepository(ref.watch(databaseProvider));
});

final careNotesProvider = StreamProvider<List<CareNote>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(careNotesRepositoryProvider).watch(user.uid);
});

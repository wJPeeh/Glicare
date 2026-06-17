import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/database_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/care_team.dart';
import '../data/care_team_repository.dart';

final careTeamRepositoryProvider = Provider<CareTeamRepository>((ref) {
  return CareTeamRepository(ref.watch(databaseProvider));
});

final careTeamProvider = StreamProvider<CareTeam>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(careTeamRepositoryProvider).watch(user.uid);
});

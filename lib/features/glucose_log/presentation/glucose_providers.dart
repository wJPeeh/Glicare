import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/database_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/glucose_reading.dart';
import '../data/glucose_repository.dart';

final glucoseRepositoryProvider = Provider<GlucoseRepository>((ref) {
  return GlucoseRepository(ref.watch(databaseProvider));
});

final recentGlucoseReadingsProvider = StreamProvider<List<GlucoseReading>>(
  (ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const Stream.empty();
    return ref.watch(glucoseRepositoryProvider).watchRecent(user.uid);
  },
);

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/database_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/meal_log.dart';
import '../data/meal_log_repository.dart';

final mealLogRepositoryProvider = Provider<MealLogRepository>((ref) {
  return MealLogRepository(ref.watch(databaseProvider));
});

final recentMealLogsProvider = StreamProvider<List<MealLog>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(mealLogRepositoryProvider).watchRecent(user.uid);
});

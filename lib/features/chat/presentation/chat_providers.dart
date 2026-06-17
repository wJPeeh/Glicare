import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/database_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/chat_message.dart';
import '../data/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(databaseProvider));
});

final chatMessagesProvider = StreamProvider<List<ChatMessage>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(chatRepositoryProvider).watch(user.uid);
});

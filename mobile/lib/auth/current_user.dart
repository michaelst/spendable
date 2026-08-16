import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_client.dart';
import '../api/api_error.dart';

part 'current_user.g.dart';

/// The account behind the stored token. Invalidate after anything that changes it.
@riverpod
Future<User> currentUser(Ref ref) async {
  final response = await ref.watch(apiProvider).getSessionApi().getCurrentUser().orApiError();

  return response.data!;
}

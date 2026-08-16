import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_client.dart';
import '../api/api_error.dart';

part 'splits_providers.g.dart';

@riverpod
Future<List<Split>> splits(Ref ref) async {
  final response = await ref.watch(apiProvider).getSplitsApi().listSplits().orApiError();

  return response.data!.toList();
}

@riverpod
class SplitSelection extends _$SplitSelection {
  @override
  Set<String> build() => const {};

  void toggle(String id) => state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};

  void clear() => state = const {};
}

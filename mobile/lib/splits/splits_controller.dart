import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_client.dart';
import '../api/api_error.dart';
import 'splits_providers.dart';

part 'splits_controller.g.dart';

/// Writing splits. Archiving several is N requests rather than a bulk endpoint, because a user
/// has a handful of splits, not a page of them.
@riverpod
class SplitsController extends _$SplitsController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> save({String? id, required SplitRequest request}) => _write(() async {
    final splits = ref.read(apiProvider).getSplitsApi();

    if (id == null) {
      await splits.createSplit(splitRequest: request).orApiError();
    } else {
      await splits.updateSplit(id: id, splitRequest: request).orApiError();
    }
  });

  Future<bool> archive(Iterable<String> ids) => _write(() async {
    for (final id in ids) {
      await ref.read(apiProvider).getSplitsApi().archiveSplit(id: id).orApiError();
    }

    ref.read(splitSelectionProvider.notifier).clear();
  });

  Future<bool> _write(Future<void> Function() write) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(write);

    if (state.hasError) return false;

    ref.invalidate(splitsProvider);

    return true;
  }
}

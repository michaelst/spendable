import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_tab.g.dart';

enum AppTab { budgets, transactions, splits, banks }

/// Which tab the shell is showing. A provider rather than the shell's own state because a tapped
/// notification has to be able to move it.
@Riverpod(keepAlive: true)
class SelectedTab extends _$SelectedTab {
  @override
  AppTab build() => AppTab.budgets;

  void select(AppTab tab) => state = tab;
}

import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_client.dart';
import '../api/api_error.dart';

part 'banks_providers.g.dart';

@riverpod
Future<List<BankMember>> bankMembers(Ref ref) async {
  final response = await ref.watch(apiProvider).getBanksApi().listBanks().orApiError();

  return response.data!.toList();
}

/// Logos come down the authenticated API rather than a public URL, so they are fetched through
/// the same client and held per member instead of by an image cache.
@Riverpod(keepAlive: true)
Future<Uint8List> bankLogo(Ref ref, String memberId) async {
  final response = await ref.watch(apiProvider).getBanksApi().getBankLogo(id: memberId).orApiError();

  return response.data!;
}

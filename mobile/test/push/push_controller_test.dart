import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendable/api/api_client.dart';
import 'package:spendable/auth/auth_controller.dart';
import 'package:spendable/auth/token_storage.dart';
import 'package:spendable/push/push_channel.dart';
import 'package:spendable/push/push_controller.dart';
import 'package:spendable/selected_tab.dart';
import 'package:spendable/transactions/transactions_providers.dart';

import '../support/fakes.dart';

const _transaction = {
  'id': 'trn_1',
  'name': 'Coffee',
  'amount': '-4.50',
  'date': '2026-08-16',
  'reviewed': false,
  'excluded': false,
  'budget_allocations': <Object>[],
};

ProviderContainer _container({
  required FakePushChannel push,
  required FakeApi api,
  String? token = 'apt_stored',
}) {
  final container = ProviderContainer(
    overrides: [
      pushChannelProvider.overrideWithValue(push),
      tokenStorageProvider.overrideWithValue(FakeTokenStorage(token)),
      apiProvider.overrideWithValue(api.build()),
    ],
  );

  addTearDown(container.dispose);

  return container;
}

void main() {
  test('a signed-in launch asks for permission', () async {
    final push = FakePushChannel();
    final container = _container(push: push, api: FakeApi({}));

    container.listen(pushControllerProvider, (previous, next) {});

    // The session is read from the Keychain, so the ask cannot happen on the first frame.
    await container.read(authStateProvider.future);
    await pumpEventQueue();

    expect(push.registered, 1);
  });

  test('a signed-out launch asks for nothing', () async {
    final push = FakePushChannel();
    final container = _container(push: push, api: FakeApi({}), token: null);

    container.listen(pushControllerProvider, (previous, next) {});

    await container.read(authStateProvider.future);
    await pumpEventQueue();

    expect(push.registered, 0);
  });

  test('a device token is registered against the session', () async {
    final push = FakePushChannel();
    final api = FakeApi({'PATCH /api/session': (status: 204, body: null)});
    final container = _container(push: push, api: api);

    container.listen(pushControllerProvider, (previous, next) {});

    await container.read(authStateProvider.future);

    push.send(const PushToken('abcdef'));

    await pumpEventQueue();

    expect(api.requests.single.method, 'PATCH');
    expect(api.requests.single.data, containsPair('apns_token', 'abcdef'));
  });

  // The API token the device token would hang off does not exist yet.
  test('a device token that arrives signed out is not sent', () async {
    final push = FakePushChannel();
    final api = FakeApi({});
    final container = _container(push: push, api: api, token: null);

    container.listen(pushControllerProvider, (previous, next) {});

    await container.read(authStateProvider.future);

    push.send(const PushToken('abcdef'));

    await pumpEventQueue();

    expect(api.requests, isEmpty);
  });

  // A silent push says a sync finished, which is the only signal the app gets that what it is
  // showing is behind.
  test('a silent push refetches the lists', () async {
    final push = FakePushChannel();
    final api = FakeApi({
      'GET /api/transactions': (status: 200, body: [_transaction]),
    });
    final container = _container(push: push, api: api);

    container.listen(pushControllerProvider, (previous, next) {});
    container.listen(transactionsProvider, (previous, next) {});

    await container.read(transactionsProvider.future);

    push.send(const PushRefresh());

    await pumpEventQueue();
    await container.read(transactionsProvider.future);

    expect(api.requests.where((request) => request.path == '/api/transactions'), hasLength(2));
  });

  test('a tapped notification opens the transactions tab', () async {
    final push = FakePushChannel();
    final api = FakeApi({
      'GET /api/transactions': (status: 200, body: [_transaction]),
    });
    final container = _container(push: push, api: api);

    container.listen(pushControllerProvider, (previous, next) {});

    expect(container.read(selectedTabProvider), AppTab.budgets);

    push.send(const PushOpened());

    await pumpEventQueue();

    expect(container.read(selectedTabProvider), AppTab.transactions);
  });
}

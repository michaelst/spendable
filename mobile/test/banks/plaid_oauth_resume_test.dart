import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendable/api/api_client.dart';
import 'package:spendable/banks/banks_controller.dart';
import 'package:spendable/banks/pending_plaid_session.dart';
import 'package:spendable/banks/plaid_link_flow.dart';

import '../support/fakes.dart';
import 'banks_screen_test.dart' show FakePendingPlaidSession, FakePlaidLinkFlow;

const _member = {
  'id': 'bkm_1',
  'name': 'Chase',
  'provider': 'Plaid',
  'status': 'CONNECTED',
  'has_logo': false,
  'bank_accounts': <Object>[],
};

ProviderContainer _container({
  required FakeApi api,
  required FakePlaidLinkFlow link,
  required FakePendingPlaidSession session,
}) {
  final container = ProviderContainer(
    overrides: [
      apiProvider.overrideWithValue(api.build()),
      plaidLinkFlowProvider.overrideWithValue(link),
      pendingPlaidSessionProvider.overrideWithValue(session),
    ],
  );

  addTearDown(container.dispose);

  return container;
}

void main() {
  // iOS killed the app on the bank's OAuth page. The redirect brings it back with no memory of
  // the flow beyond what was written down before Link opened.
  test('a resumed connect exchanges the public token', () async {
    final api = FakeApi({
      'POST /api/banks': (status: 201, body: _member),
      'GET /api/banks': (status: 200, body: [_member]),
    });
    final link = FakePlaidLinkFlow('public-resumed');
    final session = FakePendingPlaidSession(PlaidSessionKind.connect);

    final container = _container(api: api, link: link, session: session);

    await container
        .read(banksControllerProvider.notifier)
        .resumeOAuth('https://spendable.money/plaid-oauth?oauth_state_id=abc');

    expect(link.resumed, ['https://spendable.money/plaid-oauth?oauth_state_id=abc']);
    expect(api.requests.map((request) => '${request.method} ${request.path}'), contains('POST /api/banks'));
    expect(session.kind, isNull);
  });

  // Repairing an item hands back nothing worth exchanging, so posting it would create a duplicate
  // connection for a bank the user already has.
  test('a resumed reconnect exchanges nothing', () async {
    final api = FakeApi({
      'GET /api/banks': (status: 200, body: [_member]),
    });
    final link = FakePlaidLinkFlow('public-resumed');
    final session = FakePendingPlaidSession(PlaidSessionKind.reconnect);

    final container = _container(api: api, link: link, session: session);

    await container.read(banksControllerProvider.notifier).resumeOAuth('https://spendable.money/plaid-oauth');

    expect(link.resumed, hasLength(1));
    expect(
      api.requests.map((request) => '${request.method} ${request.path}'),
      isNot(contains('POST /api/banks')),
    );
    expect(session.kind, isNull);
  });

  // A stray visit to the redirect with nothing in flight must not open Link at all.
  test('a redirect with no session in flight does nothing', () async {
    final api = FakeApi({
      'GET /api/banks': (status: 200, body: [_member]),
    });
    final link = FakePlaidLinkFlow('public-resumed');

    final container = _container(api: api, link: link, session: FakePendingPlaidSession());

    await container.read(banksControllerProvider.notifier).resumeOAuth('https://spendable.money/plaid-oauth');

    expect(link.resumed, isEmpty);
    expect(
      api.requests.map((request) => '${request.method} ${request.path}'),
      isNot(contains('POST /api/banks')),
    );
  });

  // Otherwise a failed exchange leaves a session pending that the next launch tries again.
  test('a connect that Link abandons clears the session', () async {
    final api = FakeApi({
      'POST /api/banks/link_token': (status: 200, body: {'link_token': 'link-new'}),
      'GET /api/banks': (status: 200, body: [_member]),
    });
    final session = FakePendingPlaidSession();

    final container = _container(api: api, link: FakePlaidLinkFlow(), session: session);

    await container.read(banksControllerProvider.notifier).connect();

    expect(session.kind, isNull);
    expect(
      api.requests.map((request) => '${request.method} ${request.path}'),
      isNot(contains('POST /api/banks')),
    );
  });
}

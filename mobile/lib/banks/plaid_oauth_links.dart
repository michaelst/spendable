import 'package:app_links/app_links.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'banks_controller.dart';

part 'plaid_oauth_links.g.dart';

/// Universal links the app is opened with. The first one is included, which is the case that
/// matters here - the app was not running when the bank redirected.
@Riverpod(keepAlive: true)
Stream<Uri> incomingLinks(Ref ref) => AppLinks().uriLinkStream;

/// Finishes a bank connection the user started before iOS terminated the app on them. Watched
/// from the root so it is listening whichever screen they land on.
@Riverpod(keepAlive: true)
void plaidOAuthResume(Ref ref) {
  ref.listen(incomingLinksProvider, (_, next) {
    if (next case AsyncData(value: final uri) when uri.path == '/plaid-oauth') {
      ref.read(banksControllerProvider.notifier).resumeOAuth(uri.toString());
    }
  });
}

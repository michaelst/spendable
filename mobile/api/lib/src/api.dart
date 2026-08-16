//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:dio/dio.dart';
import 'package:built_value/serializer.dart';
import 'package:spendable_api/src/serializers.dart';
import 'package:spendable_api/src/auth/api_key_auth.dart';
import 'package:spendable_api/src/auth/basic_auth.dart';
import 'package:spendable_api/src/auth/bearer_auth.dart';
import 'package:spendable_api/src/auth/oauth.dart';
import 'package:spendable_api/src/api/banks_api.dart';
import 'package:spendable_api/src/api/budgets_api.dart';
import 'package:spendable_api/src/api/session_api.dart';
import 'package:spendable_api/src/api/splits_api.dart';
import 'package:spendable_api/src/api/transactions_api.dart';

class SpendableApi {
  static const String basePath = r'https://spendable.money';

  final Dio dio;
  final Serializers serializers;

  SpendableApi({
    Dio? dio,
    Serializers? serializers,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  })  : this.serializers = serializers ?? standardSerializers,
        this.dio = dio ??
            Dio(BaseOptions(
              baseUrl: basePathOverride ?? basePath,
              connectTimeout: const Duration(milliseconds: 5000),
              receiveTimeout: const Duration(milliseconds: 3000),
            )) {
    if (interceptors == null) {
      this.dio.interceptors.addAll([
        OAuthInterceptor(),
        BasicAuthInterceptor(),
        BearerAuthInterceptor(),
        ApiKeyAuthInterceptor(),
      ]);
    } else {
      this.dio.interceptors.addAll(interceptors);
    }
  }

  void setOAuthToken(String name, String token) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens[name] = token;
    }
  }

  void setBearerAuth(String name, String token) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens[name] = token;
    }
  }

  void setBasicAuth(String name, String username, String password) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo[name] = BasicAuthInfo(username, password);
    }
  }

  void setApiKey(String name, String apiKey) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys[name] = apiKey;
    }
  }

  /// Get BanksApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  BanksApi getBanksApi() {
    return BanksApi(dio, serializers);
  }

  /// Get BudgetsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  BudgetsApi getBudgetsApi() {
    return BudgetsApi(dio, serializers);
  }

  /// Get SessionApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SessionApi getSessionApi() {
    return SessionApi(dio, serializers);
  }

  /// Get SplitsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SplitsApi getSplitsApi() {
    return SplitsApi(dio, serializers);
  }

  /// Get TransactionsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  TransactionsApi getTransactionsApi() {
    return TransactionsApi(dio, serializers);
  }
}

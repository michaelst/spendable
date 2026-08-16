import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendable/api/api_error.dart';

DioException _failure({int? status, Object? body}) {
  final options = RequestOptions(path: '/api/budgets');

  return DioException(
    requestOptions: options,
    type: status == null ? DioExceptionType.connectionError : DioExceptionType.badResponse,
    message: 'Connection refused',
    response: status == null ? null : Response(requestOptions: options, statusCode: status, data: body),
  );
}

void main() {
  test('carries the code the server sent', () {
    final error = ApiError.from(
      _failure(
        status: 409,
        body: {
          'errors': [
            {'code': 'last_identity', 'detail': 'is the only way to sign in'},
          ],
        },
      ),
    );

    expect(error.code, 'last_identity');
    expect(error.detail, 'is the only way to sign in');
    expect(error.statusCode, 409);
  });

  test('keys validation errors by their pointer', () {
    final error = ApiError.from(
      _failure(
        status: 422,
        body: {
          'errors': [
            {
              'code': 'invalid',
              'detail': "can't be blank",
              'source': {'pointer': '/name'},
            },
            {
              'code': 'invalid',
              'detail': 'is invalid',
              'source': {'pointer': '/budget_allocations/0/amount'},
            },
          ],
        },
      ),
    );

    expect(error.fieldErrors, {'/name': "can't be blank", '/budget_allocations/0/amount': 'is invalid'});
  });

  test('a request that never got an answer is marked unreachable', () {
    final error = ApiError.from(_failure());

    expect(error.isUnreachable, isTrue);
    expect(error.code, 'unreachable');
  });

  test('a body that is not the error envelope does not crash the parse', () {
    final error = ApiError.from(_failure(status: 502, body: '<html>bad gateway</html>'));

    expect(error.code, 'unreachable');
    expect(error.statusCode, 502);
    expect(error.fieldErrors, isEmpty);
  });
}

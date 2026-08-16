import 'package:dio/dio.dart';

/// A failed call, in the shape the server actually returns:
/// `{"errors": [{"code", "detail", "source": {"pointer"}}]}`.
class ApiError implements Exception {
  const ApiError({
    required this.statusCode,
    required this.code,
    required this.detail,
    this.fieldErrors = const {},
  });

  /// Anything dio throws, including a request that never reached the server.
  factory ApiError.from(Object error) {
    if (error is! DioException) return ApiError(statusCode: null, code: 'unknown', detail: '$error');

    final entries = _entries(error.response?.data);

    if (entries.isEmpty) {
      return ApiError(
        statusCode: error.response?.statusCode,
        code: 'unreachable',
        detail: error.message ?? 'Could not reach Spendable.',
      );
    }

    return ApiError(
      statusCode: error.response?.statusCode,
      code: entries.first['code'] as String? ?? 'unknown',
      detail: entries.first['detail'] as String? ?? '',
      fieldErrors: _fieldErrors(entries),
    );
  }

  final int? statusCode;
  final String code;
  final String detail;

  /// Keyed by JSON pointer, so `/name` or `/budget_allocations/0/amount`. Allocation pointers
  /// index the list the server settled on rather than the one sent, because it prepends the
  /// Spendable line - match on budget id, never position.
  final Map<String, String> fieldErrors;

  /// The request never got an answer, so retrying it is worth offering.
  bool get isUnreachable => statusCode == null;

  @override
  String toString() => detail.isEmpty ? code : detail;

  static List<Map<String, dynamic>> _entries(Object? body) {
    if (body is! Map) return const [];

    final errors = body['errors'];

    if (errors is! List) return const [];

    return errors.whereType<Map<String, dynamic>>().toList();
  }

  static Map<String, String> _fieldErrors(List<Map<String, dynamic>> entries) {
    final pointers = <String, String>{};

    for (final entry in entries) {
      final pointer = (entry['source'] as Map?)?['pointer'];

      if (pointer is String) pointers[pointer] = entry['detail'] as String? ?? '';
    }

    return pointers;
  }
}

/// Every call the app makes goes through this, so a failure surfaces as an [ApiError] carrying
/// the server's own code rather than as a dio internal.
extension ApiCall<T> on Future<T> {
  Future<T> orApiError() async {
    try {
      return await this;
    } on DioException catch (error) {
      throw ApiError.from(error);
    }
  }
}

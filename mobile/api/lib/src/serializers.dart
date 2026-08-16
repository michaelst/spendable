//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:spendable_api/src/date_serializer.dart';
import 'package:spendable_api/src/model/date.dart';

import 'package:spendable_api/src/model/bank_account.dart';
import 'package:spendable_api/src/model/bank_account_request.dart';
import 'package:spendable_api/src/model/bank_member.dart';
import 'package:spendable_api/src/model/budget.dart';
import 'package:spendable_api/src/model/budget_allocation.dart';
import 'package:spendable_api/src/model/budget_allocation_request.dart';
import 'package:spendable_api/src/model/budget_request.dart';
import 'package:spendable_api/src/model/budget_summary.dart';
import 'package:spendable_api/src/model/bulk_failure.dart';
import 'package:spendable_api/src/model/bulk_request.dart';
import 'package:spendable_api/src/model/bulk_result.dart';
import 'package:spendable_api/src/model/connect_request.dart';
import 'package:spendable_api/src/model/errors.dart';
import 'package:spendable_api/src/model/errors_errors_inner.dart';
import 'package:spendable_api/src/model/errors_errors_inner_source.dart';
import 'package:spendable_api/src/model/identity.dart';
import 'package:spendable_api/src/model/link_token.dart';
import 'package:spendable_api/src/model/month_spend.dart';
import 'package:spendable_api/src/model/session.dart';
import 'package:spendable_api/src/model/session_request.dart';
import 'package:spendable_api/src/model/session_update_request.dart';
import 'package:spendable_api/src/model/split.dart';
import 'package:spendable_api/src/model/split_line.dart';
import 'package:spendable_api/src/model/split_line_request.dart';
import 'package:spendable_api/src/model/split_request.dart';
import 'package:spendable_api/src/model/transaction.dart';
import 'package:spendable_api/src/model/transaction_request.dart';
import 'package:spendable_api/src/model/transaction_source.dart';
import 'package:spendable_api/src/model/transfer_request.dart';
import 'package:spendable_api/src/model/user.dart';

part 'serializers.g.dart';

@SerializersFor([
  BankAccount,
  BankAccountRequest,
  BankMember,
  Budget,
  BudgetAllocation,
  BudgetAllocationRequest,
  BudgetRequest,
  BudgetSummary,
  BulkFailure,
  BulkRequest,
  BulkResult,
  ConnectRequest,
  Errors,
  ErrorsErrorsInner,
  ErrorsErrorsInnerSource,
  Identity,
  LinkToken,
  MonthSpend,
  Session,
  SessionRequest,
  SessionUpdateRequest,
  Split,
  SplitLine,
  SplitLineRequest,
  SplitRequest,
  Transaction,
  TransactionRequest,
  TransactionSource,
  TransferRequest,
  User,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Split)]),
        () => ListBuilder<Split>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Transaction)]),
        () => ListBuilder<Transaction>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(BankMember)]),
        () => ListBuilder<BankMember>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Budget)]),
        () => ListBuilder<Budget>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();

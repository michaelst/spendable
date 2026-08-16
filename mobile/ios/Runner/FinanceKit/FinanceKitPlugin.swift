import Flutter
import Foundation

#if canImport(FinanceKit)
  import FinanceKit
#endif

/// Transport only. Amounts stay unsigned and undecided here - the sign, the dedup and every
/// ledger rule live on the server.
final class FinanceKitPlugin: NSObject, WalletApi {
  static func register(with messenger: FlutterBinaryMessenger) {
    WalletApiSetup.setUp(binaryMessenger: messenger, api: FinanceKitPlugin())
  }

  func isAvailable() throws -> Bool {
    #if canImport(FinanceKit)
      guard #available(iOS 17.4, *) else { return false }

      return FinanceStore.isDataAvailable(.financialData)
    #else
      return false
    #endif
  }

  func authorizationStatus(completion: @escaping (Result<WalletAuthorization, Error>) -> Void) {
    #if canImport(FinanceKit)
      guard #available(iOS 17.4, *), FinanceStore.isDataAvailable(.financialData) else {
        return completion(.success(.denied))
      }

      Task {
        do {
          completion(.success(Self.authorization(try await FinanceStore.shared.authorizationStatus())))
        } catch {
          completion(.failure(error))
        }
      }
    #else
      completion(.success(.denied))
    #endif
  }

  func requestAuthorization(completion: @escaping (Result<WalletAuthorization, Error>) -> Void) {
    #if canImport(FinanceKit)
      guard #available(iOS 17.4, *), FinanceStore.isDataAvailable(.financialData) else {
        return completion(.success(.denied))
      }

      Task {
        do {
          completion(.success(Self.authorization(try await FinanceStore.shared.requestAuthorization())))
        } catch {
          completion(.failure(error))
        }
      }
    #else
      completion(.success(.denied))
    #endif
  }

  func read(historyToken: String?, completion: @escaping (Result<WalletChanges, Error>) -> Void) {
    #if canImport(FinanceKit)
      guard #available(iOS 17.4, *) else { return completion(.failure(WalletUnavailable())) }

      Task {
        do {
          completion(.success(try await Self.read(historyToken)))
        } catch {
          completion(.failure(error))
        }
      }
    #else
      completion(.failure(WalletUnavailable()))
    #endif
  }
}

struct WalletUnavailable: Error {}

#if canImport(FinanceKit)
  @available(iOS 17.4, *)
  extension FinanceKitPlugin {
    /// History is per account and so is its token, but the server holds one token per connection,
    /// which it only ever compares for equality. So the tokens travel together under the account
    /// they belong to, and an account with no entry - a card added since the last read - is read
    /// from the beginning while the others resume.
    static func read(_ historyToken: String?) async throws -> WalletChanges {
      let store = FinanceStore.shared
      let accounts = try await store.accounts(query: AccountQuery())
      let balances = try await latestBalances()
      let tokens = decode(historyToken)

      var wallet: [WalletAccount] = []
      var inserted: [WalletCharge] = []
      var updated: [WalletCharge] = []
      var deleted: [String] = []
      var next: [String: HistoryToken] = [:]

      for account in accounts {
        let externalId = account.id.uuidString
        let balance = balances[account.id].map(self.balance) ?? (value: "0", creditDebit: .debit)

        wallet.append(
          WalletAccount(
            externalId: externalId,
            name: account.displayName,
            kind: kind(account),
            balance: balance.value,
            creditDebit: balance.creditDebit
          ))

        // isMonitoring off, or the sequence stays open waiting for the next purchase.
        let history = store.transactionHistory(
          forAccountID: account.id, since: tokens[externalId], isMonitoring: false)

        for try await batch in history {
          inserted.append(contentsOf: batch.inserted.map { charge($0, accountExternalId: externalId) })
          updated.append(contentsOf: batch.updated.map { charge($0, accountExternalId: externalId) })
          deleted.append(contentsOf: batch.deleted.map(\.uuidString))

          next[externalId] = batch.newToken
        }
      }

      return WalletChanges(
        accounts: wallet,
        inserted: inserted,
        updated: updated,
        deleted: deleted,
        historyToken: encode(next)
      )
    }

    /// FinanceKit keeps older balances alongside the current one, so the newest per account wins.
    static func latestBalances() async throws -> [UUID: Balance] {
      var latest: [UUID: Balance] = [:]

      for account in try await FinanceStore.shared.accountBalances(query: AccountBalanceQuery()) {
        guard let balance = current(account.currentBalance) else { continue }

        if let held = latest[account.accountID], held.asOfDate >= balance.asOfDate { continue }

        latest[account.accountID] = balance
      }

      return latest
    }

    static func current(_ balance: CurrentBalance) -> Balance? {
      switch balance {
      case .available(let available): return available
      case .booked(let booked): return booked
      case .availableAndBooked(let available, _): return available
      @unknown default: return nil
      }
    }

    /// Apple Card is the only liability Wallet exposes, and it is the one thing that has to read
    /// as a card - that is what puts it into the credit card balance rather than into Spendable.
    static func kind(_ account: Account) -> WalletAccountKind {
      switch account {
      case .liability: return .creditCard
      case .asset: return .cash
      @unknown default: return .cash
      }
    }

    static func balance(_ balance: Balance) -> (value: String, creditDebit: WalletCreditDebit) {
      (decimal(balance.amount.amount), indicator(balance.creditDebitIndicator))
    }

    static func charge(_ transaction: FinanceKit.Transaction, accountExternalId: String) -> WalletCharge {
      WalletCharge(
        accountExternalId: accountExternalId,
        externalId: transaction.id.uuidString,
        amount: decimal(transaction.transactionAmount.amount),
        creditDebit: indicator(transaction.creditDebitIndicator),
        date: dateFormatter.string(from: transaction.transactionDate),
        name: transaction.merchantName ?? transaction.transactionDescription,
        pending: transaction.status != .booked
      )
    }

    static func authorization(_ status: AuthorizationStatus) -> WalletAuthorization {
      switch status {
      case .authorized: return .authorized
      case .denied: return .denied
      case .notDetermined: return .notDetermined
      @unknown default: return .denied
      }
    }

    static func indicator(_ value: CreditDebitIndicator) -> WalletCreditDebit {
      value == .credit ? .credit : .debit
    }

    /// Unsigned and at full precision. A Double would round money, and the sign is the server's.
    static func decimal(_ value: Decimal) -> String {
      "\(abs(value))"
    }

    static func encode(_ tokens: [String: HistoryToken]) -> String {
      guard let data = try? JSONEncoder().encode(tokens) else { return "" }

      return data.base64EncodedString()
    }

    /// A token FinanceKit will not take is no worse than no token: everything is read again, and
    /// the server drops what it already holds.
    static func decode(_ token: String?) -> [String: HistoryToken] {
      guard
        let token, let data = Data(base64Encoded: token),
        let tokens = try? JSONDecoder().decode([String: HistoryToken].self, from: data)
      else {
        return [:]
      }

      return tokens
    }

    static let dateFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.calendar = Calendar(identifier: .iso8601)
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = TimeZone(identifier: "UTC")
      formatter.dateFormat = "yyyy-MM-dd"
      return formatter
    }()
  }

  @available(iOS 17.4, *)
  typealias HistoryToken = FinanceStore.HistoryToken
#endif

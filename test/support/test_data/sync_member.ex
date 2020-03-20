defmodule Spendable.Broadway.SyncMemberTest.TestData do
  def item do
    %{
      item: %{
        available_products: [
          "assets",
          "auth",
          "balance",
          "credit_details",
          "identity",
          "income",
          "investments",
          "liabilities"
        ],
        billed_products: [
          "transactions"
        ],
        error: nil,
        institution_id: "ins_109511",
        item_id: "jQ3ZbE3BWqUMeqNBgDK6fjdyErroNwu1EPKnL",
        webhook: ""
      },
      request_id: "fkUsuVz2DGXZ75e",
      status: %{
        last_webhook: nil,
        transactions: %{
          last_failed_update: nil,
          last_successful_update: "2019-10-10T04:55:55.554Z"
        }
      }
    }
  end

  def institution do
    %{
      institution: %{
        country_codes: [
          "US"
        ],
        credentials: [
          %{
            label: "Username",
            name: "username",
            type: "text"
          },
          %{
            label: "Password",
            name: "password",
            type: "password"
          }
        ],
        has_mfa: true,
        input_spec: "fixed",
        institution_id: "ins_109511",
        logo:
          "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",
        mfa: [
          "code",
          "list",
          "questions",
          "selections"
        ],
        mfa_code_type: "numeric",
        name: "Tartan Bank",
        primary_color: "#174e7c",
        products: [
          "assets",
          "auth",
          "balance",
          "transactions",
          "credit_details",
          "income",
          "identity",
          "investments",
          "liabilities"
        ],
        routing_numbers: [],
        url: "https://www.plaid.com/"
      },
      request_id: "njyA6jBhKz4a4Lf"
    }
  end

  def accounts do
    %{
      accounts: [
        %{
          account_id: "zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP",
          balances: %{
            available: 100,
            current: 110,
            iso_currency_code: "USD",
            limit: nil,
            unofficial_currency_code: nil
          },
          mask: "0000",
          name: "Plaid Checking",
          official_name: "Plaid Gold Standard 0% Interest Checking",
          subtype: "checking",
          type: "depository"
        },
        %{
          account_id: "BeNlRPNEjncZMa1BGy3RtgzBPEznjqfwjeoW3",
          balances: %{
            available: 200,
            current: 210,
            iso_currency_code: "USD",
            limit: nil,
            unofficial_currency_code: nil
          },
          mask: "1111",
          name: "Plaid Saving",
          official_name: "Plaid Silver Standard 0.1% Interest Saving",
          subtype: "savings",
          type: "depository"
        },
        %{
          account_id: "RmJV83JvKNhVNJeq7AgDcPe5NReLqJfR4dVlD",
          balances: %{
            available: nil,
            current: 1000,
            iso_currency_code: "USD",
            limit: nil,
            unofficial_currency_code: nil
          },
          mask: "2222",
          name: "Plaid CD",
          official_name: "Plaid Bronze Standard 0.2% Interest CD",
          subtype: "cd",
          type: "depository"
        },
        %{
          account_id: "6rJmglJjqZiJ65RDpQN4SK9bWg9rR8Hg3w794",
          balances: %{
            available: nil,
            current: 410,
            iso_currency_code: "USD",
            limit: 2000,
            unofficial_currency_code: nil
          },
          mask: "3333",
          name: "Plaid Credit Card",
          official_name: "Plaid Diamond 12.5% APR Interest Credit Card",
          subtype: "credit card",
          type: "credit"
        },
        %{
          account_id: "XXp18PpvdZfQZBPxLMywt1G68ZG7XBcdEBA63",
          balances: %{
            available: 43200,
            current: 43200,
            iso_currency_code: "USD",
            limit: nil,
            unofficial_currency_code: nil
          },
          mask: "4444",
          name: "Plaid Money Market",
          official_name: "Plaid Platinum Standard 1.85% Interest Money Market",
          subtype: "money market",
          type: "depository"
        },
        %{
          account_id: "DZKR87KAemCdeN7JlKy1Uo5vgG5qPNFvQyqwB",
          balances: %{
            available: nil,
            current: 320.76,
            iso_currency_code: "USD",
            limit: nil,
            unofficial_currency_code: nil
          },
          mask: "5555",
          name: "Plaid IRA",
          official_name: nil,
          subtype: "ira",
          type: "investment"
        },
        %{
          account_id: "VRo1W4ov3euaeX68MDEBtqDXQlDyVBtWd7Mme",
          balances: %{
            available: nil,
            current: 23631.9805,
            iso_currency_code: "USD",
            limit: nil,
            unofficial_currency_code: nil
          },
          mask: "6666",
          name: "Plaid 401k",
          official_name: nil,
          subtype: "401k",
          type: "investment"
        },
        %{
          account_id: "wnDAKEDMP7FR17bAl5NzUawK4gwRJjirVeXNo",
          balances: %{
            available: nil,
            current: 65262,
            iso_currency_code: "USD",
            limit: nil,
            unofficial_currency_code: nil
          },
          mask: "7777",
          name: "Plaid Student Loan",
          official_name: nil,
          subtype: "student",
          type: "loan"
        }
      ],
      item: %{
        available_products: [
          "assets",
          "auth",
          "balance",
          "credit_details",
          "identity",
          "income",
          "investments",
          "liabilities"
        ],
        billed_products: [
          "transactions"
        ],
        error: nil,
        institution_id: "ins_109511",
        item_id: "jQ3ZbE3BWqUMeqNBgDK6fjdyErroNwu1EPKnL",
        webhook: ""
      },
      request_id: "YRZvS0XA4qOSjCC"
    }
  end

  def account_transactions("zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP") do
    %{
      accounts: [
        %{
          account_id: "zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP",
          balances: %{
            available: 100,
            current: 110,
            iso_currency_code: "USD",
            limit: nil,
            unofficial_currency_code: nil
          },
          mask: "0000",
          name: "Plaid Checking",
          official_name: "Plaid Gold Standard 0% Interest Checking",
          subtype: "checking",
          type: "depository"
        }
      ],
      item: %{
        available_products: [
          "assets",
          "auth",
          "balance",
          "credit_details",
          "identity",
          "income",
          "investments",
          "liabilities"
        ],
        billed_products: [
          "transactions"
        ],
        error: nil,
        institution_id: "ins_109511",
        item_id: "jQ3ZbE3BWqUMeqNBgDK6fjdyErroNwu1EPKnL",
        webhook: ""
      },
      request_id: "g46u5D13O5yCPJ3",
      total_transactions: 7,
      transactions: [
        %{
          account_id: "zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP",
          account_owner: nil,
          amount: 6.33,
          category: [
            "Travel",
            "Car Service",
            "Ride Share"
          ],
          category_id: "22006001",
          date: "#{Date.utc_today()}",
          iso_currency_code: "USD",
          name: "Uber 072515 SF**POOL**",
          payment_meta: %{
            by_order_of: nil,
            payee: nil,
            payer: nil,
            payment_method: nil,
            payment_processor: nil,
            ppd_id: nil,
            reason: nil,
            reference_number: nil
          },
          pending: false,
          pending_transaction_id: nil,
          transaction_id: "gjwAb9wKgytqA9dKR4Xmc3rwN8WN5nigoEkrB",
          transaction_type: "special",
          unofficial_currency_code: nil
        },
        %{
          account_id: "zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP",
          account_owner: nil,
          amount: 5.4,
          category: [
            "Travel",
            "Car Service",
            "Ride Share"
          ],
          category_id: "22006001",
          date: "2019-09-18",
          iso_currency_code: "USD",
          name: "Uber 063015 SF**POOL**",
          payment_meta: %{
            by_order_of: nil,
            payee: nil,
            payer: nil,
            payment_method: nil,
            payment_processor: nil,
            ppd_id: nil,
            reason: nil,
            reference_number: nil
          },
          pending: true,
          pending_transaction_id: nil,
          transaction_id: "8B4wpK4er1FV9XMAWGxEc81aP5MPzncwnWEzA",
          transaction_type: "special",
          unofficial_currency_code: nil
        },
        %{
          account_id: "zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP",
          account_owner: nil,
          amount: 5.4,
          category: [
            "Travel",
            "Car Service",
            "Ride Share"
          ],
          category_id: "22006001",
          date: "2019-09-18",
          iso_currency_code: "USD",
          name: "Uber 063015 SF**POOL**",
          payment_meta: %{
            by_order_of: nil,
            payee: nil,
            payer: nil,
            payment_method: nil,
            payment_processor: nil,
            ppd_id: nil,
            reason: nil,
            reference_number: nil
          },
          pending: false,
          pending_transaction_id: "8B4wpK4er1FV9XMAWGxEc81aP5MPzncwnWEzA",
          transaction_id: "8B4wpK4er1FV9XMAWGxEc81aP5MPzncwnWEzB",
          transaction_type: "special",
          unofficial_currency_code: nil
        },
        %{
          account_id: "zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP",
          account_owner: nil,
          amount: -500,
          category: [
            "Travel",
            "Airlines and Aviation Services"
          ],
          category_id: "22001000",
          date: "2019-09-16",
          iso_currency_code: "USD",
          name: "United Airlines",
          payment_meta: %{
            by_order_of: nil,
            payee: nil,
            payer: nil,
            payment_method: nil,
            payment_processor: nil,
            ppd_id: nil,
            reason: nil,
            reference_number: nil
          },
          pending: false,
          pending_transaction_id: nil,
          transaction_id: "EMRN9eRGQySgAPL8qNWvClGXDvkDoWuXy4dVM",
          transaction_type: "special",
          unofficial_currency_code: nil
        },
        %{
          account_id: "zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP",
          account_owner: nil,
          amount: 12,
          category: [
            "Food and Drink",
            "Restaurants"
          ],
          category_id: "13005000",
          date: "2019-09-15",
          iso_currency_code: "USD",
          location: %{
            address: nil,
            city: nil,
            country: nil,
            lat: nil,
            lon: nil,
            postal_code: nil,
            region: nil,
            store_number: "3322"
          },
          name: "McDonald's",
          payment_meta: %{
            by_order_of: nil,
            payee: nil,
            payer: nil,
            payment_method: nil,
            payment_processor: nil,
            ppd_id: nil,
            reason: nil,
            reference_number: nil
          },
          pending: false,
          pending_transaction_id: nil,
          transaction_id: "W6w8RNwvxQfzQLbW1Aj7fPoRvznv8GulR6avN",
          transaction_type: "place",
          unofficial_currency_code: nil
        },
        %{
          account_id: "zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP",
          account_owner: nil,
          amount: 4.33,
          category: [
            "Food and Drink",
            "Restaurants",
            "Coffee Shop"
          ],
          category_id: "13005043",
          date: "2019-09-15",
          iso_currency_code: "USD",
          name: "Starbucks",
          payment_meta: %{
            by_order_of: nil,
            payee: nil,
            payer: nil,
            payment_method: nil,
            payment_processor: nil,
            ppd_id: nil,
            reason: nil,
            reference_number: nil
          },
          pending: false,
          pending_transaction_id: nil,
          transaction_id: "A75QnN58PGFwJdmez7obtXjM3br3DWC189eyR",
          transaction_type: "place",
          unofficial_currency_code: nil
        },
        %{
          account_id: "zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP",
          account_owner: nil,
          amount: 89.4,
          category: [
            "Food and Drink",
            "Restaurants"
          ],
          category_id: "13005000",
          date: "2019-09-14",
          iso_currency_code: "USD",
          name: "SparkFun",
          payment_meta: %{
            by_order_of: nil,
            payee: nil,
            payer: nil,
            payment_method: nil,
            payment_processor: nil,
            ppd_id: nil,
            reason: nil,
            reference_number: nil
          },
          pending: false,
          pending_transaction_id: nil,
          transaction_id: "GLb3QZbvMli6l78ErQDwFGe9JW7J4AI1a6j8W",
          transaction_type: "place",
          unofficial_currency_code: nil
        },
        %{
          account_id: "zyBMmKBpeZcDVZgqEx3ACKveJjvwmBHomPbyP",
          account_owner: nil,
          amount: 6.33,
          category: [
            "Travel",
            "Car Service",
            "Ride Share"
          ],
          category_id: "22006001",
          date: "2019-09-01",
          iso_currency_code: "USD",
          name: "Uber 072515 SF**POOL**",
          payment_meta: %{
            by_order_of: nil,
            payee: nil,
            payer: nil,
            payment_method: nil,
            payment_processor: nil,
            ppd_id: nil,
            reason: nil,
            reference_number: nil
          },
          pending: false,
          pending_transaction_id: nil,
          transaction_id: "1XrylZrdRkfgLDvwaXbVC6KpA9WEWaF5oWdme",
          transaction_type: "special",
          unofficial_currency_code: nil
        }
      ]
    }
  end
end

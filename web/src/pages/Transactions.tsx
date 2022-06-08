import React, { useState } from 'react'
import { useQuery } from '@apollo/client'
import TransactionRow, { TransactionRowItem } from '../components/TransactionRow'
import { LIST_TRANSACTIONS } from '../queries'
import { ListTransactions } from '../graphql/ListTransactions'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faArrowsRotate, faMagnifyingGlass, faPlus } from '@fortawesome/free-solid-svg-icons'
import TransactionForm from '../components/TransactionForm'

const Transactions = () => {
  const [showAddTransaction, setShowAddTransaction] = useState(false)

  const { data, fetchMore, refetch } = useQuery<ListTransactions>(LIST_TRANSACTIONS, {
    variables: {
      offset: 0
    }
  })


  const transactions: TransactionRowItem[] =
    [...data?.transactions?.results ?? []]
      .sort((a, b) => b.date.getTime() - a.date.getTime())
      .map(transaction => ({
        id: transaction.id,
        name: transaction.name,
        amount: transaction.amount,
        date: transaction.date,
        reviewed: transaction.reviewed,
      }))


  return (
    <>
    <div className="flex flex-col items-center py-16">
      <div className="flex flex-col w-1/2">
        <div className="mb-2 bg-white ml-auto rounded-full p-2 px-3">
          <button className="mr-3" onClick={() => setShowAddTransaction(true)}>
            <FontAwesomeIcon icon={faPlus} />
          </button>
          <button className="mr-3" onClick={() => refetch()}>
            <FontAwesomeIcon icon={faMagnifyingGlass} />
          </button>
          <button onClick={() => refetch()}>
            <FontAwesomeIcon icon={faArrowsRotate} />
          </button>
        </div>
        {transactions.map(transaction => <TransactionRow key={transaction.id} {...transaction} />)}
        <button onClick={() => fetchMore({ variables: { offset: data?.transactions?.results?.length } })}>Load More</button>
      </div>
    </div>

    <TransactionForm show={showAddTransaction} setShow={setShowAddTransaction} />
    </>
  )
}

export default Transactions
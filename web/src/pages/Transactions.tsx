import React from 'react'
import { useQuery } from '@apollo/client'
import TransactionRow, { TransactionRowItem } from '../components/TransactionRow'
import { LIST_TRANSACTIONS } from '../queries'
import { ListTransactions } from '../graphql/ListTransactions'

const Transactions = () => {

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
    <div className="flex flex-col items-center py-16">
      <button onClick={() => refetch()}>Refresh</button>
      {transactions.map(transaction => <TransactionRow key={transaction.id} {...transaction} />)}
      <button onClick={() => fetchMore({variables: {offset: data?.transactions?.results?.length}})}>Load More</button>
    </div>
  )
}

export default Transactions
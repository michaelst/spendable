import React from 'react'
import { useQuery } from '@apollo/client'
import TransactionRow, { TransactionRowItem } from '../components/TransactionRow'
import { LIST_TRANSACTIONS } from '../queries'
import { ListTransactions } from '../graphql/ListTransactions'
import { useNavigate } from 'react-router-dom'

const Transactions = () => {
  const navigate = useNavigate()

  const { data, fetchMore } = useQuery<ListTransactions>(LIST_TRANSACTIONS, {
    variables: {
      offset: 0
    }
  })
  

  const transactions: TransactionRowItem[] =
    [...data?.transactions?.results ?? []]
      .sort((a, b) => b.date.getTime() - a.date.getTime())
      .map(transaction => ({
        key: transaction.id,
        id: transaction.id,
        title: transaction.name,
        amount: transaction.amount,
        transactionDate: transaction.date,
        transactionReviewed: transaction.reviewed,
        onClick: () => navigate(`/transactions/${transaction.id}`)
      }))


  return (
    <div className="flex flex-col items-center py-16">
      {transactions.map(transaction => <TransactionRow {...transaction} />)}
      <button onClick={() => fetchMore({variables: {offset: data?.transactions?.results?.length}})}>Load More</button>
    </div>
  )
}

export default Transactions
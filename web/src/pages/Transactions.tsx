import React, { useEffect, useState } from 'react'
import { useQuery } from '@apollo/client'
import TransactionRow, { TransactionRowItem } from '../components/TransactionRow'
import { LIST_TRANSACTIONS } from '../queries'
import { ListTransactions } from '../graphql/ListTransactions'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faArrowsRotate, faMagnifyingGlass, faPlus } from '@fortawesome/free-solid-svg-icons'
import TransactionForm from '../components/TransactionForm'

const Transactions = () => {
  const [showAddTransaction, setShowAddTransaction] = useState(false)
  const [loadMore, setLoadMore] = useState(false)

  const { data, fetchMore, refetch, loading } = useQuery<ListTransactions>(LIST_TRANSACTIONS, {
    variables: {
      offset: 0
    }
  })

  useEffect(() => {
    const handleScroll = () => {
      const scrollPosition = window.pageYOffset
      const documentHeight = document.body.scrollHeight - window.innerHeight
      if (scrollPosition > documentHeight - 500 && !loading && !loadMore) {
        setLoadMore(true)
      }
    }

    window.removeEventListener('scroll', handleScroll)
    window.addEventListener('scroll', handleScroll, { passive: true })
    return () => window.removeEventListener('scroll', handleScroll)
  }, [loadMore, setLoadMore, loading])

  useEffect(() => {
    if (loadMore) {
      fetchMore({ variables: { offset: data!.transactions!.results!.length } })
        .then(() => setLoadMore(false))
    }
  }, [loadMore, data, fetchMore])

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
        </div>
      </div>

      <TransactionForm show={showAddTransaction} setShow={setShowAddTransaction} />
    </>
  )
}

export default Transactions
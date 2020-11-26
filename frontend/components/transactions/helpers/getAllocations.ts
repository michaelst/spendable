import Decimal from "decimal.js-light";
import { GetTransaction_transaction, GetTransaction_transaction_allocations } from "../graphql/GetTransaction";

const getAllocations = (transaction: GetTransaction_transaction) => {
  const sortedAllocations = [...transaction.allocations].sort((a, b) => b.amount.comparedTo(a.amount))
  const allocated = transaction.allocations.reduce((acc, allocation) => acc.add(allocation.amount), new Decimal('0'))

  const spendable: GetTransaction_transaction_allocations = {
    __typename: 'Allocation',
    id: 'spendable',
    amount: transaction.amount.sub(allocated),
    budget: {
      __typename: 'Budget',
      id: 'spendable',
      name: 'Spendable'
    }
  }

  if (spendable.amount.eq(new Decimal('0'))) {
    return sortedAllocations
  } else {
    return [spendable].concat(sortedAllocations)
  }
}

export default getAllocations
import Decimal from "decimal.js-light"

export default function formatCurrency(decimal: Decimal) {
  const formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 2,
  })

  return formatter.format(decimal.toNumber())
}
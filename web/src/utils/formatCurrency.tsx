import Decimal from "decimal.js-light"

export default function formatCurrency(decimal: Decimal, digits: number = 2) {
  const formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: digits,
  })

  return formatter.format(decimal.toNumber())
}
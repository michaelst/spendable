import Decimal from "decimal.js-light"

export default function formatCurrency(decimal: Decimal) {
  const roundedDecimal = decimal.absoluteValue().toDecimalPlaces(2).toFixed(2)
  const formatted = new Intl.NumberFormat().format(roundedDecimal)
  return decimal.isNegative() ? `($${formatted})` : `$${formatted}`
}
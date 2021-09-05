import React, { useState } from 'react'
import { View, Text, StyleSheet, TouchableWithoutFeedback, StatusBar } from 'react-native'
import { NativeModules } from 'react-native'
import { useQuery } from '@apollo/client'
import { FlatList } from 'react-native-gesture-handler'
import { DateTime } from 'luxon'
import { MAIN_SCREEN_QUERY } from 'src/queries'
import { MainScreen } from 'src/graphql/MainScreen'
import formatCurrency from 'src/utils/formatCurrency'
import useAppStyles from 'src/utils/useAppStyles'
import { SafeAreaView } from 'react-native-safe-area-context'
import BudgetRow, { BudgetRowItem } from 'src/components/BudgetRow'

type monthListDataItem = {
  month: string
  spent: string
}

const Main = () => {
  const { isDarkMode, styles } = useStyles()

  const { data } = useQuery<MainScreen>(MAIN_SCREEN_QUERY, {
    onCompleted: (data) => {
      NativeModules.RNUserDefaults.setSpendable(formatCurrency(data.currentUser.spendable))
    }
  })

  if (!data) return null

  const monthListData: monthListDataItem[] = [
    {
      month: 'Sep 2021',
      spent: formatCurrency(data.currentUser.spendable)
    },
    {
      month: 'Aug 2021',
      spent: formatCurrency(data.currentUser.spendable)
    },
    {
      month: 'Jul 2021',
      spent: formatCurrency(data.currentUser.spendable)
    },
    {
      month: 'Jun 2021',
      spent: formatCurrency(data.currentUser.spendable)
    },
    {
      month: 'May 2021',
      spent: formatCurrency(data.currentUser.spendable)
    },
    // add an empty space at the end
    {
      month: '',
      spent: ''
    }
  ]

  const budgetListData: BudgetRowItem[] = [
    {
      id: 'spendable',
      title: "Spendable",
      amount: data.currentUser.spendable,
      subText: "AVAILABLE"
    },
    ...data.budgets.map(budget => ({
      id: budget.id,
      title: budget.name,
      amount: budget.balance,
      subText: "REMAINING"
    }))
  ]

  return (
    <SafeAreaView>
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
      <FlatList
        style={styles.budgetsList}
        data={budgetListData}
        keyExtractor={item => item.id}
        renderItem={({ item }) => <BudgetRow item={item} />}
        ListHeaderComponent={<MonthsFlatList data={monthListData} />}
      />
    </SafeAreaView>
  )
}

type MonthsFlatListProps = {
  data: monthListDataItem[]
}

const MonthsFlatList = ({ data }: MonthsFlatListProps) => {
  const { styles } = useStyles()
  const [activeMonth, setActiveMonth] = useState(DateTime.now().toFormat('MMM yyyy'))

  return <FlatList
    style={styles.monthsList}
    data={data}
    horizontal={true}
    keyExtractor={item => item.month}
    renderItem={({ item }) => <MonthItem
      item={item}
      active={item.month === activeMonth}
      onPress={() => setActiveMonth(item.month)}
    />}
  />
}

type MonthItemProps = {
  item: monthListDataItem
  active: boolean
  onPress: () => void
}

const MonthItem = ({ item: { month, spent }, active, onPress }: MonthItemProps) => {
  const { styles } = useStyles()

  return (
    <View style={styles.monthView}>
      <TouchableWithoutFeedback onPress={onPress}>
        <View style={active ? styles.activeMonthDetails : styles.monthDetails}>
          <Text style={styles.monthDetailText}>{month}</Text>
          <Text style={styles.monthDetailSecondaryText}>{spent}</Text>
        </View>
      </TouchableWithoutFeedback>
    </View>
  )
}

const useStyles = () => {
  const { isDarkMode, styles, colors, baseUnit } = useAppStyles()

  const screenStyles = StyleSheet.create({
    ...styles,
    monthsList: {
      backgroundColor: colors.card,
      margin: baseUnit * 2,
      paddingVertical: baseUnit * 3,
      paddingHorizontal: baseUnit * 2,
      borderRadius: baseUnit
    },
    budgetsList: {
    },
    monthView: {
      paddingHorizontal: baseUnit,
      justifyContent: 'center'
    },
    activeMonthDetails: {
      backgroundColor: colors.primary,
      padding: baseUnit * 2,
      borderRadius: baseUnit
    },
    monthDetails: {
      padding: baseUnit * 2
    },
    monthDetailText: {
      ...styles.text,
      marginBottom: baseUnit / 4
    },
    monthDetailSecondaryText: {
      ...styles.secondaryText
    },
    budgetView: {
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'space-between',
      borderBottomColor: colors.border,
      borderBottomWidth: StyleSheet.hairlineWidth,
      paddingVertical: baseUnit * 3,
      marginHorizontal: baseUnit * 2
    },
    budgetNameView: {

    },
    budgetDetailView: {
    },
    budgetDetailText: {
      ...styles.text,
      textAlign: 'right',
      marginBottom: baseUnit / 4
    },
    budgetDetailSubText: {
      ...styles.subText,
      textAlign: 'right'
    }
  })

  return {
    isDarkMode: isDarkMode,
    baseUnit: baseUnit,
    styles: screenStyles
  }
}

export default Main

import React, { Dispatch, SetStateAction, useContext, useState } from 'react'
import { View, Text, StyleSheet, TouchableWithoutFeedback, StatusBar, SafeAreaView, TouchableHighlight, RefreshControl } from 'react-native'
import { NativeModules } from 'react-native'
import { ApolloQueryResult, OperationVariables, useQuery } from '@apollo/client'
import { FlatList } from 'react-native-gesture-handler'
import { DateTime } from 'luxon'
import { MAIN_QUERY } from 'src/queries'
import { Main as Data } from 'src/graphql/Main'
import formatCurrency from 'src/utils/formatCurrency'
import useAppStyles from 'src/hooks/useAppStyles'
import BudgetRow, { BudgetRowItem } from 'src/components/BudgetRow'
import { useNavigation } from '@react-navigation/native'
import { FontAwesomeIcon } from '@fortawesome/react-native-fontawesome'
import { faChevronRight } from '@fortawesome/free-solid-svg-icons'
import Decimal from 'decimal.js-light'
import SettingsContext from 'src/context/Settings'

type monthListDataItem = {
  month: DateTime | null
  spent: Decimal | null
}

const Main = () => {
  const { isDarkMode } = useStyles()

  return (
    <SafeAreaView>
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
      <Budgets />
    </SafeAreaView>
  )
}
//.toFormat('MMM yyyy')
const Budgets = () => {
  const { activeMonth } = useContext(SettingsContext)
  const currentMonth = DateTime.now().startOf('month')
  const navigation = useNavigation<NavigationProp>()
  const { styles, colors } = useAppStyles()

  const { data, loading, refetch } = useQuery<Data>(MAIN_QUERY, {
    variables: { month: activeMonth.toFormat('yyyy-MM-dd') },
    onCompleted: (data) => {
      NativeModules.RNUserDefaults.setSpendable(formatCurrency(data.currentUser.spendable))
    }
  })

  const spentByMonth = data?.currentUser.spentByMonth.map(s => {
    return { ...s, month: DateTime.fromJSDate(s.month).startOf('month') }
  }) || []

  const spentThisMonth = spentByMonth.find(s => s.month === activeMonth)?.spent || new Decimal(0)
  const spentFromBudgetsThisMonth = [...data?.budgets || []].reduce((total, budget) => total.add(budget.spent), new Decimal(0))
  const spentFromSpendableThisMonth = spentThisMonth.minus(spentFromBudgetsThisMonth)

  const budgetListData: BudgetRowItem[] = [
    {
      id: 'spendable',
      title: "Spendable",
      amount: (currentMonth === activeMonth ? data?.currentUser.spendable : spentFromSpendableThisMonth) || new Decimal(0),
      subText: currentMonth === activeMonth ? "AVAILABLE" : "SPENT",
      hideDelete: true,
      onPress: () => navigation.navigate('Budget', { budgetId: 'spendabe' })
    },
    ...(data?.budgets || []).map(budget => ({
      id: budget.id,
      title: budget.name,
      amount: currentMonth === activeMonth && !budget.trackSpendingOnly ? budget.balance : budget.spent,
      subText: currentMonth === activeMonth && !budget.trackSpendingOnly ? "REMAINING" : "SPENT",
      onPress: () => navigation.navigate('Budget', { budgetId: budget.id })
    }))
  ]

  return (
    <FlatList
      data={budgetListData}
      keyExtractor={item => item.id}
      renderItem={({ item }) => <BudgetRow item={item} />}
      ListHeaderComponent={(
        <Header
          spentByMonth={spentByMonth}
          refetch={refetch}
        />
      )}
      ListFooterComponent={() => (
        <TouchableHighlight onPress={() => navigation.navigate('Create Budget')}>
          <View style={styles.footer}>
            <Text style={{ color: colors.primary }}>Add Expense</Text>
          </View>
        </TouchableHighlight>
      )}
      showsVerticalScrollIndicator={false}
      refreshControl={<RefreshControl refreshing={loading} onRefresh={refetch} />}
    />
  )
}

type HeaderProps = {
  spentByMonth: monthListDataItem[]
  refetch: (variables?: Partial<OperationVariables> | undefined) => Promise<ApolloQueryResult<Data>>
}

const Header = ({ spentByMonth, refetch }: HeaderProps) => {
  const { activeMonth, setActiveMonth } = useContext(SettingsContext)
  const navigation = useNavigation<NavigationProp>()
  const { styles, colors, fontSize } = useStyles()

  const monthListData: monthListDataItem[] = [
    ...spentByMonth,
    // add an empty space at the end
    {
      month: null,
      spent: null
    }
  ]

  return (
    <>
      <FlatList
        style={styles.monthsList}
        data={monthListData}
        horizontal={true}
        keyExtractor={item => item.month}
        showsHorizontalScrollIndicator={false}
        renderItem={({ item }: {item: monthListDataItem}) => <MonthItem
          item={item}
          active={item.month?.equals(activeMonth) || false}
          onPress={() => {
            if (!item.month) return
            setActiveMonth(item.month)
            refetch({ month: item.month })
          }}
        />}
      />
      <View>
        <View style={styles.linkCardRow}>
          <TouchableHighlight
            onPress={() => navigation.navigate('Banks')}
            style={{ ...styles.linkCard, ...styles.linkCardLeft }}
          >
            <>
              <Text style={styles.text}>Banks</Text>
              <FontAwesomeIcon icon={faChevronRight} color={colors.text} size={fontSize} />
            </>
          </TouchableHighlight>
          <TouchableHighlight
            onPress={() => navigation.navigate('Settings')}
            style={styles.linkCard}
          >
            <>
              <Text style={styles.text}>Settings</Text>
              <FontAwesomeIcon icon={faChevronRight} color={colors.text} size={fontSize} />
            </>
          </TouchableHighlight>
        </View>
        <View style={styles.linkCardRow}>
          <TouchableHighlight
            onPress={() => navigation.navigate('Transactions')}
            style={styles.linkCard}
          >
            <>
              <Text style={styles.text}>View All Transactions</Text>
              <FontAwesomeIcon icon={faChevronRight} color={colors.text} size={fontSize} />
            </>
          </TouchableHighlight>
        </View>
      </View>
    </>
  )
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
          <Text style={styles.monthDetailText}>{month?.toFormat('MMM yyyy')}</Text>
          <Text style={styles.secondaryText}>{spent && formatCurrency(spent)}</Text>
        </View>
      </TouchableWithoutFeedback>
    </View>
  )
}

const useStyles = () => {
  const { isDarkMode, styles, colors, baseUnit, fontSize } = useAppStyles()

  const screenStyles = StyleSheet.create({
    ...styles,
    monthsList: {
      backgroundColor: colors.card,
      margin: baseUnit * 2,
      padding: baseUnit * 2,
      borderRadius: baseUnit
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
    linkCardRow: {
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'space-between',
      marginHorizontal: baseUnit * 2
    },
    linkCard: {
      flexGrow: 1,
      // give same width so they flexGrow the same
      width: '25%',
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'space-between',
      backgroundColor: colors.card,
      marginBottom: baseUnit * 2,
      padding: baseUnit * 2,
      borderRadius: baseUnit
    },
    linkCardLeft: {
      marginRight: baseUnit * 2
    },
  })

  return {
    colors: colors,
    isDarkMode: isDarkMode,
    baseUnit: baseUnit,
    fontSize: fontSize,
    styles: screenStyles
  }
}

export default Main

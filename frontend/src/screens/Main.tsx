import React, { useState } from 'react'
import { View, Text, StyleSheet, TouchableWithoutFeedback, StatusBar, SafeAreaView, TouchableHighlight } from 'react-native'
import { NativeModules } from 'react-native'
import { useQuery } from '@apollo/client'
import { FlatList } from 'react-native-gesture-handler'
import { DateTime } from 'luxon'
import { MAIN_QUERY } from 'src/queries'
import { Main as Data } from 'src/graphql/Main'
import formatCurrency from 'src/utils/formatCurrency'
import useAppStyles from 'src/utils/useAppStyles'
import BudgetRow, { BudgetRowItem } from 'src/components/BudgetRow'
import { useNavigation } from '@react-navigation/native'
import { FontAwesomeIcon } from '@fortawesome/react-native-fontawesome'
import { faChevronRight } from '@fortawesome/free-solid-svg-icons'

type monthListDataItem = {
  month: string
  spent: string
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

const Budgets = () => {
  const navigation = useNavigation<NavigationProp>()
  const { styles, colors } = useAppStyles()

  const { data } = useQuery<Data>(MAIN_QUERY, {
    onCompleted: (data) => {
      NativeModules.RNUserDefaults.setSpendable(formatCurrency(data.currentUser.spendable))
    }
  })

  if (!data) return null

  const budgetListData: BudgetRowItem[] = [
    {
      id: 'spendable',
      title: "Spendable",
      amount: data.currentUser.spendable,
      subText: "AVAILABLE",
      hideDelete: true,
      onPress: () => navigation.navigate('Budget', { budgetId: 'spendabe' })
    },
    ...data.budgets.map(budget => ({
      id: budget.id,
      title: budget.name,
      amount: budget.balance,
      subText: "REMAINING",
      onPress: () => navigation.navigate('Budget', { budgetId: budget.id })
    }))
  ]

  return (
    <FlatList
      data={budgetListData}
      keyExtractor={item => item.id}
      renderItem={({ item }) => <BudgetRow item={item} />}
      ListHeaderComponent={< Header />}
      ListFooterComponent={() => (
        <TouchableHighlight onPress={() => navigation.navigate('Create Budget')}>
          <View style={styles.footer}>
            <Text style={{ color: colors.primary }}>Add Expense</Text>
          </View>
        </TouchableHighlight>
      )}
      showsVerticalScrollIndicator={false}
    />
  )
}

const Header = () => {
  const navigation = useNavigation<NavigationProp>()
  const { styles, colors, fontSize } = useStyles()
  const [activeMonth, setActiveMonth] = useState(DateTime.now().toFormat('MMM yyyy'))

  const monthListData: monthListDataItem[] = [
    {
      month: 'Sep 2021',
      spent: '$10,550.74'
    },
    {
      month: 'Aug 2021',
      spent: '$10,550.74'
    },
    {
      month: 'Jul 2021',
      spent: '$10,550.74'
    },
    {
      month: 'Jun 2021',
      spent: '$10,550.74'
    },
    {
      month: 'May 2021',
      spent: '$10,550.74'
    },
    // add an empty space at the end
    {
      month: '',
      spent: ''
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
        renderItem={({ item }) => <MonthItem
          item={item}
          active={item.month === activeMonth}
          onPress={() => setActiveMonth(item.month)}
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
          <Text style={styles.monthDetailText}>{month}</Text>
          <Text style={styles.secondaryText}>{spent}</Text>
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

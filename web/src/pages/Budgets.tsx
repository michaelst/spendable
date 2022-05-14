import React from 'react';

function Home() {
  const { activeMonth } = useContext(SettingsContext)
  const navigation = useNavigation<NavigationProp>()
  const { styles, colors } = useAppStyles()

  const activeMonthIsCurrentMonth = DateTime.now().startOf('month').equals(activeMonth)

  const { data, loading, refetch } = useQuery<Data>(MAIN_QUERY, {
    variables: { month: activeMonth.toFormat('yyyy-MM-dd') }
  })

  const spentByMonth = data?.currentUser.spentByMonth.map(s => {
    return { ...s, month: DateTime.fromJSDate(s.month).startOf('month') }
  }) || []

  const budgetListData: BudgetRowItem[] = (data?.budgets || []).map(budget => {
    return {
      id: budget.id,
      title: budget.name,
      amount: amount(activeMonthIsCurrentMonth, budget, data?.currentUser.spendable || new Decimal(0)),
      subText: subText(activeMonthIsCurrentMonth, budget),
      hideDelete: budget.name === "Spendable",
      onPress: () => navigation.navigate('Budget', { budgetId: budget.id })
    }
  })

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

export default Home;

import { StyleSheet } from 'react-native'
import { useTheme } from '@react-navigation/native'

export default function AppStyles() {
  const { colors }: any = useTheme()

  return StyleSheet.create({
    activityIndicator: {
      flex: 1,
      alignItems: 'center',
      justifyContent: 'center',
    },
    headerButton: {
      color: colors.primary, 
      fontSize: 18, 
      paddingRight: 18
    },
    headerText: {
      backgroundColor: colors.background,
      color: colors.secondary,
      padding: 20,
      paddingBottom: 5
    },
    deleteButtonText: {
      color: 'white',
      fontSize: 16,
      padding: 10,
      fontWeight: 'bold'
    },
    deleteButton: {
      alignItems: 'center',
      flex: 1,
      flexDirection: 'row',
      backgroundColor: '#dd2c00',
      justifyContent: 'flex-end'
    },
    row: {
      flexDirection: 'row',
      padding: 20,
      alignItems: 'center',
      backgroundColor: colors.card,
      borderBottomColor: colors.border,
      borderBottomWidth: StyleSheet.hairlineWidth
    }
  })
} 
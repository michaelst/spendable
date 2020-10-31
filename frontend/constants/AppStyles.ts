import { StyleSheet } from 'react-native'
import { useTheme } from '@react-navigation/native'

export default function AppStyles() {
  const { colors }: any = useTheme()
  const fontSize = 18
  const padding = 20
  
  const styles = StyleSheet.create({
    activityIndicator: {
      flex: 1,
      alignItems: 'center',
      justifyContent: 'center',
    },
    text: {
      color: colors.text,
      fontSize: fontSize
    },
    rightText: {
      color: colors.secondary,
      fontSize: fontSize,
      paddingRight: 8
    },
    headerTitleText: {
      color: colors.text, 
      fontWeight: 'bold', 
      fontSize: fontSize
    },
    headerButtonText: {
      color: colors.primary, 
      fontSize: fontSize, 
      paddingLeft: padding,
      paddingRight: padding
    },
    sectionHeaderText: {
      backgroundColor: colors.background,
      color: colors.secondary,
      padding: padding,
      paddingBottom: 5
    },
    sectionFooterText: {
      backgroundColor: colors.background,
      color: colors.secondary,
      padding: padding,
      paddingTop: 5
    },
    deleteButtonText: {
      color: 'white',
      fontSize: fontSize,
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
      padding: padding,
      alignItems: 'center',
      backgroundColor: colors.card,
      borderBottomColor: colors.border,
      borderBottomWidth: StyleSheet.hairlineWidth
    },
    formInputText: {
      textAlign: 'right',
      width: '100%',
      fontSize: fontSize,
      color: colors.secondary
    },
    contentContainerStyle: {
      paddingBottom: 36
    }
  })

  return {
    styles: styles,
    fontSize: fontSize
  }
} 
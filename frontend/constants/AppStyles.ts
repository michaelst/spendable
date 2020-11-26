import { StyleSheet } from 'react-native'
import { useTheme } from '@react-navigation/native'

export default function AppStyles() {
  const { colors }: any = useTheme()

  const fontSize = 18
  const secondaryFontSize = 14
  const padding = 8
  
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
    secondaryText: {
      color: colors.secondary,
      fontSize: secondaryFontSize
    },
    rightText: {
      color: colors.secondary,
      fontSize: fontSize,
      paddingRight: padding
    },
    headerTitleText: {
      color: colors.text, 
      fontWeight: 'bold', 
      fontSize: fontSize
    },
    headerButtonText: {
      color: colors.primary, 
      fontSize: fontSize, 
      paddingLeft: padding * 2,
      paddingRight: padding * 2
    },
    smallButtonText: {
      color: colors.primary, 
      fontSize: secondaryFontSize,
      paddingTop: padding,
      paddingLeft: padding * 2,
      paddingRight: padding * 2
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
      padding: padding,
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
      padding: padding * 2,
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
    sectionlistContentContainerStyle: {
      paddingBottom: padding * 4
    },
    flatlistContentContainerStyle: {
      paddingTop: padding * 4,
      paddingBottom: padding * 4
    }
  })

  return {
    styles: styles,
    fontSize: fontSize,
    padding: padding
  }
} 
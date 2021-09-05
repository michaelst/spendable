import { Dimensions, StyleSheet } from 'react-native'
import { Theme, useTheme } from '@react-navigation/native'

export type SpendableTheme = Theme & {
  colors: {
    secondary: string
    danger: string
  }
}

const useAppStyles = () => {
  const { dark: isDarkMode, colors } = useTheme() as SpendableTheme

  const height = Dimensions.get('window').height
  const fontSize = 18
  const secondaryFontSize = 14
  const subTextFontSize = 12
  const baseUnit = 8
  
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
    dangerText: {
      color: colors.danger,
      fontSize: fontSize
    },
    secondaryText: {
      color: colors.secondary,
      fontSize: secondaryFontSize
    },
    subText: {
      color: colors.secondary,
      fontSize: subTextFontSize
    },
    rightText: {
      color: colors.secondary,
      fontSize: fontSize,
      paddingRight: baseUnit
    },
    headerTitleText: {
      color: colors.text, 
      fontWeight: 'bold', 
      fontSize: fontSize
    },
    headerButtonText: {
      color: colors.primary, 
      fontSize: fontSize, 
      paddingLeft: baseUnit * 2,
      paddingRight: baseUnit * 2
    },
    smallButtonText: {
      color: colors.primary, 
      fontSize: secondaryFontSize,
      paddingTop: baseUnit,
      paddingLeft: baseUnit * 2,
      paddingRight: baseUnit * 2
    },
    sectionHeaderText: {
      backgroundColor: colors.background,
      color: colors.secondary,
      padding: baseUnit,
      paddingBottom: 5
    },
    sectionFooterText: {
      backgroundColor: colors.background,
      color: colors.secondary,
      padding: baseUnit,
      paddingTop: 5
    },
    deleteButtonText: {
      color: 'white',
      fontSize: fontSize,
      padding: baseUnit,
      fontWeight: 'bold'
    },
    deleteButton: {
      alignItems: 'center',
      flex: 1,
      flexDirection: 'row',
      backgroundColor: '#dd2c00',
      justifyContent: 'flex-end'
    },
    inputRow: {
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: baseUnit * 2,
      backgroundColor: colors.card,
      borderBottomColor: colors.border,
      borderBottomWidth: StyleSheet.hairlineWidth
    },
    row: {
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'space-between',
      borderBottomColor: colors.border,
      borderBottomWidth: StyleSheet.hairlineWidth,
      paddingVertical: baseUnit * 3,
      marginHorizontal: baseUnit * 2
    },
    formInputText: {
      textAlign: 'right',
      width: '100%',
      fontSize: fontSize,
      color: colors.secondary
    },
    sectionListContentContainerStyle: {
      paddingBottom: baseUnit * 4
    },
    flatlistContentContainerStyle: {
      paddingTop: baseUnit * 4,
      paddingBottom: baseUnit * 4
    }
  })

  return {
    height: height,
    baseUnit: baseUnit,
    colors: colors,
    fontSize: fontSize,
    isDarkMode: isDarkMode,
    styles: styles,
  }
} 

export default useAppStyles
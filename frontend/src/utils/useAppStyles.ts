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
    detailText: {
      textAlign: 'right',
      marginBottom: baseUnit / 4
    },
    detailSubText: {
      color: colors.secondary,
      fontSize: subTextFontSize,
      textAlign: 'right'
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
      paddingRight: baseUnit
    },
    smallButtonText: {
      color: colors.primary, 
      fontSize: secondaryFontSize,
      paddingTop: baseUnit,
      paddingLeft: baseUnit * 2,
      paddingRight: baseUnit * 2
    },
    sectionHeader: {
      marginHorizontal: baseUnit * 2,
      marginTop: baseUnit * 4,
      paddingBottom: baseUnit,
      borderBottomColor: colors.border,
      borderBottomWidth: StyleSheet.hairlineWidth
    },
    footer: {
      marginHorizontal: baseUnit * 2,
      marginTop: baseUnit * 2,
    },
    sectionHeaderText: {
      color: colors.secondary
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
    flex: {
      flex: 1
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
      fontSize: fontSize,
      color: colors.secondary
    },
    sectionListContentContainerStyle: {
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
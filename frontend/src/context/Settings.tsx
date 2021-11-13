import React, { createContext, ReactElement, useState } from "react"
import { DateTime } from "luxon"

export interface SettingsContext {
  activeMonth: DateTime
  setActiveMonth: (month: DateTime) => void
  deviceToken: string | null
  setDeviceToken: React.Dispatch<React.SetStateAction<string | null>>
}

type Props = {
  children: ReactElement<any, any>
  settings: SettingsContext
}

const SettingsContext = createContext<SettingsContext>({})

export const SettingsProvider = ({ children, settings }: Props) => {

  const context = {
    ...settings,
    setActiveMonth: (month: DateTime) => settings.setActiveMonth(month.startOf('month'))
  }

  return (
    <SettingsContext.Provider value={context}>
      {children}
    </SettingsContext.Provider>
  )
}

export default SettingsContext
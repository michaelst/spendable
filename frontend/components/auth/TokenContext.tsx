import React from 'react'

export interface TokenContext {
  deviceToken: string | null,
  token: string | null,
  setToken: React.Dispatch<React.SetStateAction<string | null>>
}

export const TokenContext = React.createContext<TokenContext>({
  deviceToken: null,
  token: null,
  setToken: () => {},
});
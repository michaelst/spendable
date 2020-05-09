import React from 'react'

export interface TokenContext {
  token: string | null,
  setToken: React.Dispatch<React.SetStateAction<string | null>>
}

export const TokenContext = React.createContext<TokenContext>({
  token: null,
  setToken: () => {},
});
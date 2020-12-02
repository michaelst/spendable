import React from 'react'

export interface TokenContext {
  deviceToken: string | null,
}

export const TokenContext = React.createContext<TokenContext>({
  deviceToken: null,
});
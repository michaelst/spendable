import React from 'react'
import { Platform, StyleSheet, View, Text } from 'react-native'
import * as AppleAuthentication from 'expo-apple-authentication'
import { gql, useMutation } from '@apollo/client'
import { TokenContext } from 'components/auth/TokenContext'
import { SignInWithApple } from './graphql/SignInWithApple'

export const SIGN_IN_WITH_APPLE = gql`
  mutation SignInWithApple($token: String!) {
    signInWithApple(token: $token) {
      token
    }
  }
`

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'rgb(50, 120, 200)',
    alignItems: 'center',
    justifyContent: 'center',
    height: '100%',
    width: '100%'
  },
})

export default function AuthScreen() {
  return (
    <TokenContext.Consumer>
      {({ setToken }) => (
        <View style={styles.container}>
          <Text>Spendable</Text>
          {Platform.OS === 'ios' && <SignInWithAppleButton setToken={setToken} />}
        </View>
      )}
    </TokenContext.Consumer>
  )
}

type SignInWithAppleButtonProps = {
  setToken: React.Dispatch<React.SetStateAction<string | null>>
}

function SignInWithAppleButton({ setToken }: SignInWithAppleButtonProps) {
  const [signInWithApple] = useMutation<SignInWithApple>(SIGN_IN_WITH_APPLE, {
    onCompleted: (data: SignInWithApple) => setToken(data.signInWithApple?.token ?? null)

  })

  return (
    <AppleAuthentication.AppleAuthenticationButton
      buttonType={AppleAuthentication.AppleAuthenticationButtonType.SIGN_IN}
      buttonStyle={AppleAuthentication.AppleAuthenticationButtonStyle.BLACK}
      cornerRadius={5}
      style={{ width: '80%', height: 60 }}
      onPress={async () => {
        try {
          const credential = await AppleAuthentication.signInAsync({})
          signInWithApple({ variables: { token: credential.identityToken } })
        } catch (e) {
          if (e.code === 'ERR_CANCELED') {
            // handle that the user canceled the sign-in flow
          } else {
            // handle other errors
          }
        }
      }}
    />
  )
}
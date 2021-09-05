import React from 'react'
import { Platform, View, Text } from 'react-native'
import appleAuth, { AppleButton } from '@invertase/react-native-apple-authentication'
import auth from '@react-native-firebase/auth'
import { GoogleSignin, GoogleSigninButton } from '@react-native-community/google-signin'

export default function AuthScreen() {

  return (
    <View style={{
      flex: 1,
      backgroundColor: 'rgb(50, 120, 200)',
      alignItems: 'center',
      justifyContent: 'center',
      height: '100%',
      width: '100%'
    }}>
      <Text>Spendable</Text>
      {Platform.OS === 'ios' && (
        <AppleButton
          buttonStyle={AppleButton.Style.BLACK}
          buttonType={AppleButton.Type.SIGN_IN}
          cornerRadius={5}
          style={{
            width: '80%',
            height: 48,
            marginBottom: 8
          }}
          onPress={onAppleButtonPress}
        />
      )}
      <GoogleSigninButton
        style={{ width: '80%', height: 48 }}
        size={GoogleSigninButton.Size.Wide}
        color={GoogleSigninButton.Color.Light}
        onPress={onGoogleButtonPress}
      />
    </View>
  )
}

async function onAppleButtonPress() {
  // Start the sign-in request
  const appleAuthRequestResponse = await appleAuth.performRequest({
    requestedOperation: appleAuth.Operation.LOGIN,
    requestedScopes: [appleAuth.Scope.EMAIL, appleAuth.Scope.FULL_NAME],
  });

  // Ensure Apple returned a user identityToken
  if (!appleAuthRequestResponse.identityToken) {
    throw 'Apple Sign-In failed - no identify token returned';
  }

  // Create a Firebase credential from the response
  const { identityToken, nonce } = appleAuthRequestResponse;
  const appleCredential = auth.AppleAuthProvider.credential(identityToken, nonce);

  // Sign the user in with the credential
  return auth().signInWithCredential(appleCredential);
}

async function onGoogleButtonPress() {
  GoogleSignin.configure({
    webClientId: '973501356954-1hjtihk253ub2vou4oom4kdlokpe44t4.apps.googleusercontent.com',
  })

  // Get the users ID token
  const { idToken } = await GoogleSignin.signIn();

  // Create a Google credential with the token
  const googleCredential = auth.GoogleAuthProvider.credential(idToken);

  // Sign-in the user with the credential
  return auth().signInWithCredential(googleCredential);
}
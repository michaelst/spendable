import { initializeApp } from "firebase/app";
import { OAuthProvider, getAuth, signInWithPopup } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyAMwiKd9_-gpYAZVSbA6Dmgrqo6rjtV3kw",
  authDomain: "cloud-57.firebaseapp.com",
  databaseURL: "https://cloud-57.firebaseio.com",
  projectId: "cloud-57",
  storageBucket: "cloud-57.appspot.com",
  messagingSenderId: "973501356954",
  appId: "1:973501356954:web:c28cd9ce3736fbf7b4f823"
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

const provider = new OAuthProvider('apple.com');

const signInWithApple = async () => {
  try {
    signInWithPopup(auth, provider);
  } catch (err) {
    console.error(err);
  }
};

export {
  auth,
  signInWithApple
}
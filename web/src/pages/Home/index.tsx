import React from 'react';
import { signOut } from "firebase/auth";
import { auth } from '../../firebase';

function Home() {
  return (
    <button onClick={() => signOut(auth)}>Logout</button>
  );
}

export default Home;

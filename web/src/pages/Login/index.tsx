import React from 'react';
import { signInWithApple } from '../../firebase';

function Home() {
  return (
    <button onClick={signInWithApple}>Login</button>
  );
}

export default Home;

import React from 'react';
import { signInWithApple, signInWithGoogle } from '../firebase';

function Home() {
  return (
    <div className="w-full flex flex-wrap">
      <div className="w-full md:w-1/2 flex flex-col">
        <div className="flex justify-center md:justify-start pt-12 md:pl-12 md:-mb-24">
          <a href="/" className="bg-black text-white font-bold text-xl p-4">Logo</a>
        </div>
        <div className="flex flex-col justify-center md:justify-start my-auto pt-8 md:pt-0 px-8 md:px-24 lg:px-32">
          <p className="text-center text-3xl">Welcome.</p>

          <button className="bg-black text-white font-bold text-lg hover:bg-gray-700 p-2 mt-8" onClick={signInWithApple}>Sign In With Apple</button>
          <button className="bg-[#4285F4] text-white font-bold text-lg hover:bg-gray-700 p-2 mt-3" onClick={signInWithGoogle}>Sign In With Google</button>
        </div>
      </div>

      <div className="h-screen w-1/2 shadow-2xl bg-gradient-to-br from-sky-600 to-sky-800"> </div>
    </div>
  );
}

export default Home;

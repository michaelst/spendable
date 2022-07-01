import React from 'react';
import { signInWithApple, signInWithGoogle } from '../firebase';

function Home() {
  return (
    <div className="w-full flex flex-wrap">
      <div className="w-full md:w-1/2 flex flex-col">
        <div className="flex justify-center md:justify-start pt-12 md:pl-12 md:-mb-24">
          <a href="/" className="p-4">
            <img src="full-logo.svg" alt="Logo" className="h-12" />
          </a>
        </div>
        <div className="flex flex-col justify-center md:justify-start my-auto px-8 md:px-24 lg:px-32">
          <p className="text-center text-3xl">Welcome.</p>

          <button className="bg-black text-white font-bold text-lg hover:bg-gray-700 p-2 mt-8 rounded-md" onClick={signInWithApple}>Sign In With Apple</button>
          <button className="bg-[#4285F4] text-white font-bold text-lg hover:bg-gray-700 p-2 mt-3 rounded-md" onClick={signInWithGoogle}>Sign In With Google</button>
        </div>
      </div>

      <div className="h-screen w-1/2">
        <div className="absolute h-100 w-100 bg-gradient-to-r from-white via-transparent"></div>
        <div className="h-100 w-100 bg-repeat bg-center" style={{ backgroundImage: "url(logo-pattern.svg)" }}></div>
      </div>
    </div>
  );
}

export default Home;

import React, { useEffect } from 'react';
import { Routes, Route, useNavigate, useLocation } from "react-router-dom";
import { useAuthState } from "react-firebase-hooks/auth";

import { auth } from './firebase';
import './App.css';
import Home from './pages/Home';
import Login from './pages/Login';

function App() {
  const [user, loading] = useAuthState(auth);
  const navigate = useNavigate()
  const location = useLocation()

  const needsToLogin = location.pathname != "/login" && !user
  console.log(needsToLogin, user)

  useEffect(() => {
    if (loading) return;
    if (needsToLogin) navigate('/login')
    if (user) navigate('/')
  }, [user, loading]);

  if (needsToLogin) return

  return (
    <div className="App">
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="login" element={<Login />} />
      </Routes>
    </div>
  );
}

export default App;

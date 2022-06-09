import React, { useEffect } from 'react';
import { Routes, Route, useNavigate, useLocation } from "react-router-dom";
import { useAuthState } from "react-firebase-hooks/auth";

import { auth } from './firebase';
import './App.css';
import Budgets from './pages/Budgets';
import Login from './pages/Login';
import Sidebar from './components/Sidebar';
import Transactions from './pages/Transactions';
import Banks from './pages/Banks';
import Budget from './pages/Budget';

function App() {
  const [user, loading] = useAuthState(auth);
  const navigate = useNavigate()
  const location = useLocation()

  const needsToLogin = location.pathname !== "/login" && !user

  useEffect(() => {
    if (loading) return;
    if (needsToLogin) navigate('/login')
    if (user && location.pathname === "/login") navigate('/')
  }, [user, loading, needsToLogin, navigate, location.pathname]);

  if (location.pathname === "/login") return <Login />
  if (needsToLogin) return null

  return (
    <div className="App bg-slate-100 min-h-screen">
      <Sidebar />
      <div className="ml-20">
        <Routes>
          <Route path="/" element={<Budgets />} />
          <Route path="/budgets/:id" element={<Budget />} />
          <Route path="/transactions" element={<Transactions />} />
          <Route path="/banks" element={<Banks />} />
        </Routes>
      </div>
    </div>
  );
}

export default App;

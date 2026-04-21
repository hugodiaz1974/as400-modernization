import React, { useState } from 'react';
import { Landmark, Users, Lock, X } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

export default function LoginForm() {
    const { login } = useAuth();
    const [loginForm, setLoginForm] = useState({ usuario: '', password: '' });
    const [loginError, setLoginError] = useState('');
    const [isLoggingIn, setIsLoggingIn] = useState(false);

    const submitLogin = async (e) => {
        e.preventDefault();
        setLoginError('');
        setIsLoggingIn(true);
        try {
            await login(loginForm.usuario, loginForm.password);
        } catch (err) {
            setLoginError(err.message || 'Error de conexión con el servidor de autenticación');
        }
        setIsLoggingIn(false);
    };

    return (
        <div className="min-h-screen bg-slate-900 flex items-center justify-center p-4">
            <div className="absolute inset-0 overflow-hidden pointer-events-none">
                <div className="absolute -top-1/2 -left-1/2 w-full h-full bg-blue-900/20 blur-3xl rounded-full"></div>
                <div className="absolute top-1/2 left-1/2 w-full h-full bg-indigo-900/20 blur-3xl rounded-full"></div>
            </div>
            
            <div className="bg-white/5 backdrop-blur-xl border border-white/10 p-10 rounded-2xl shadow-2xl w-full max-w-[420px] relative z-10">
                <div className="flex flex-col items-center mb-8">
                    <div className="h-16 w-16 bg-blue-600 rounded-2xl flex items-center justify-center mb-4 shadow-lg shadow-blue-500/30">
                        <Landmark className="text-white h-8 w-8" />
                    </div>
                    <h1 className="text-2xl font-bold text-white">Core Bancario AWS</h1>
                    <p className="text-slate-400 mt-2 text-sm text-center">Ingrese sus credenciales de administrador para acceder a los módulos parametrizables.</p>
                </div>
                
                <form onSubmit={submitLogin} className="space-y-5">
                    {loginError && (
                        <div className="p-3 bg-red-500/10 border border-red-500/50 rounded-lg text-red-400 text-sm flex items-center gap-2">
                            <X size={16} /> {loginError}
                        </div>
                    )}
                    <div>
                        <label className="block text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2">Usuario (Identificación IBM i)</label>
                        <div className="relative">
                            <Users className="absolute left-3 top-2.5 h-5 w-5 text-slate-500" />
                            <input 
                                type="text" 
                                value={loginForm.usuario}
                                onChange={e => setLoginForm({...loginForm, usuario: e.target.value})}
                                className="w-full bg-black/20 border border-white/10 text-white pl-10 pr-4 py-2.5 rounded-xl outline-none focus:ring-2 focus:ring-blue-500/50 transition-all font-medium"
                                placeholder="admin"
                            />
                        </div>
                    </div>
                    <div>
                        <label className="block text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2">Contraseña Segura</label>
                        <div className="relative">
                            <Lock className="absolute left-3 top-2.5 h-5 w-5 text-slate-500" />
                            <input 
                                type="password" 
                                value={loginForm.password}
                                onChange={e => setLoginForm({...loginForm, password: e.target.value})}
                                className="w-full bg-black/20 border border-white/10 text-white pl-10 pr-4 py-2.5 rounded-xl outline-none focus:ring-2 focus:ring-blue-500/50 transition-all font-medium"
                                placeholder="••••••••"
                            />
                        </div>
                    </div>
                    <button 
                        type="submit" 
                        disabled={isLoggingIn}
                        className="w-full bg-blue-600 hover:bg-blue-500 text-white font-bold py-3 rounded-xl transition-all shadow-lg shadow-blue-600/30 disabled:opacity-50"
                    >
                        {isLoggingIn ? "Autenticando..." : "Ingresar Placa de Seguridad"}
                    </button>
                </form>
            </div>
        </div>
    );
}

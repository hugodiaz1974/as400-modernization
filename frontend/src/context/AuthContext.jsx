import React, { createContext, useState, useContext } from 'react';

const AuthContext = createContext();

export function AuthProvider({ children }) {
    const [token, setToken] = useState(localStorage.getItem('jwt_token') || null);
    const [authUser, setAuthUser] = useState(JSON.parse(localStorage.getItem('auth_user')) || null);

    const login = async (usuario, password) => {
        const res = await fetch('/api/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ usuario, password })
        });
        const data = await res.json();
        
        if (!res.ok) {
            throw new Error(data.error || 'Credenciales inválidas');
        }

        // Guardar en localStorage
        localStorage.setItem('jwt_token', data.token);
        localStorage.setItem('auth_user', JSON.stringify(data.user));
        
        setToken(data.token);
        setAuthUser(data.user);
    };

    const logout = () => {
        localStorage.removeItem('jwt_token');
        localStorage.removeItem('auth_user');
        setToken(null);
        setAuthUser(null);
    };

    // Utilidad para inyectar token en peticiones API del Dashboard
    const authHeaders = { 
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}` 
    };

    return (
        <AuthContext.Provider value={{ token, authUser, login, logout, authHeaders }}>
            {children}
        </AuthContext.Provider>
    );
}

export function useAuth() {
    return useContext(AuthContext);
}

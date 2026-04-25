import React from 'react';
import { Landmark, ShieldCheck, CreditCard, Users, Settings, LogOut, RefreshCw } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

export default function Sidebar({ activeView, setActiveView }) {
  const { logout } = useAuth();

  return (
    <div className="w-64 bg-[#0B132B] text-slate-300 flex flex-col shadow-2xl z-20 shrink-0 h-screen">
      <div className="h-16 flex items-center px-6 bg-[#070D1F] border-b border-slate-800">
        <Landmark className="text-blue-500 h-6 w-6 mr-3" />
        <h1 className="text-lg font-bold text-white tracking-wide">Core Bank AWS</h1>
      </div>
      
      <div className="flex-1 overflow-y-auto py-6">
        <p className="px-6 text-xs font-semibold text-slate-500 uppercase tracking-wider mb-3">Módulos</p>
        <nav className="space-y-1">
          <button 
            onClick={() => setActiveView('exonerations')}
            className={`flex items-center w-full px-6 py-3 transition-colors ${activeView === 'exonerations' ? 'bg-[#1A2542] text-white border-r-4 border-blue-500' : 'hover:bg-[#111A33] hover:text-white group'}`}
          >
            <ShieldCheck className={`h-5 w-5 mr-3 ${activeView === 'exonerations' ? 'text-blue-400' : 'text-slate-500 group-hover:text-blue-400'}`} />
            <span className="font-medium">Exoneraciones</span>
          </button>
          
          <button 
            onClick={() => setActiveView('batch')}
            className={`flex items-center w-full px-6 py-3 transition-colors ${activeView === 'batch' ? 'bg-[#1A2542] text-white border-r-4 border-blue-500' : 'hover:bg-[#111A33] hover:text-white group'}`}
          >
            <RefreshCw className={`h-5 w-5 mr-3 ${activeView === 'batch' ? 'text-blue-400' : 'text-slate-500 group-hover:text-blue-400'}`} />
            <span className="font-medium">Monitor Batch</span>
          </button>

          <a href="#" className="flex items-center px-6 py-3 hover:bg-[#111A33] hover:text-white transition-colors group">
            <CreditCard className="h-5 w-5 mr-3 text-slate-500 group-hover:text-blue-400 transition-colors" />
            Emisión Tarjetas
          </a>
          <a href="#" className="flex items-center px-6 py-3 hover:bg-[#111A33] hover:text-white transition-colors group">
            <Users className="h-5 w-5 mr-3 text-slate-500 group-hover:text-blue-400 transition-colors" />
            Maestro Clientes
          </a>
        </nav>
      </div>

      <div className="p-4 bg-[#070D1F]">
        <button onClick={logout} className="flex items-center w-full px-4 py-2 text-sm text-slate-400 hover:text-white hover:bg-red-900/30 hover:border-red-500/50 border border-transparent rounded-md transition-all">
          <LogOut className="h-4 w-4 mr-2" />
          Cerrar Sesión Activa
        </button>
      </div>
    </div>
  );
}

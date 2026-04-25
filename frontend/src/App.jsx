import React, { useState, useEffect } from 'react';
import { Search, PlusCircle } from 'lucide-react';
import { useAuth } from './context/AuthContext';
import LoginForm from './components/LoginForm';
import Sidebar from './components/Sidebar';
import ExonerationTable from './components/ExonerationTable';
import ExonerationModal from './components/ExonerationModal';
import BatchDashboard from './components/BatchDashboard';

export default function App() {
  const { token, authUser, logout, authHeaders } = useAuth();
  
  // Navigation State
  const [activeView, setActiveView] = useState('exonerations');
  
  // Dashboard State
  const [showModal, setShowModal] = useState(false);
  const [exonerations, setExonerations] = useState([]);
  const [params, setParams] = useState({});
  const [searchTerm, setSearchTerm] = useState('');
  
  const [modalMode, setModalMode] = useState('create');
  const [selectedData, setSelectedData] = useState(null);

  const fetchExonerations = async () => {
    if (!token) return;
    try {
      const res = await fetch('/api/exonerations', { headers: authHeaders });
      if (res.status === 401 || res.status === 403) return logout();
      const data = await res.json();
      setExonerations(data);
    } catch (error) { console.error("Error cargando los datos", error); }
  };

  const fetchParameters = async () => {
    if (!token) return;
    try {
      const res = await fetch('/api/parameters', { headers: authHeaders });
      if (res.status === 401 || res.status === 403) return;
      const data = await res.json();
      setParams(data);
    } catch (error) { console.error("Error cargando parámetros", error); }
  };

  useEffect(() => {
    if (token) {
        fetchExonerations();
        fetchParameters();
    }
  }, [token]);

  const openModal = (mode, data = null) => {
    setModalMode(mode);
    setSelectedData(data);
    setShowModal(true);
  };

  const handleSave = async (formData) => {
    const method = modalMode === 'edit' ? 'PUT' : 'POST';
    const url = modalMode === 'edit' ? `/api/exonerations/${selectedData.id}` : '/api/exonerations';
    const res = await fetch(url, {
      method, 
      headers: authHeaders,
      body: JSON.stringify(formData)
    });
    const data = await res.json();
    
    if (res.status === 401 || res.status === 403) { logout(); throw new Error('Sesión Expirada'); }
    if (!res.ok) { throw new Error(data.error); }
    
    fetchExonerations();
  };

  const handleDelete = async (id) => {
    if(window.confirm('¿Desea suprimir este registro? (Opción 4)')) {
      try {
        const res = await fetch(`/api/exonerations/${id}`, { method: 'DELETE', headers: authHeaders });
        if (res.status === 401 || res.status === 403) return logout();
        fetchExonerations();
      } catch (error) { console.error("Error al borrar", error); }
    }
  };

  if (!token) {
    return <LoginForm />;
  }

  return (
    <div className="flex h-screen bg-[#f3f4f6] font-sans overflow-hidden">
      <Sidebar activeView={activeView} setActiveView={setActiveView} />

      {/* MAIN CONTENT AREA */}
      <div className="flex-1 flex flex-col h-full overflow-hidden">
        
        {activeView === 'exonerations' ? (
          <>
            <header className="h-16 bg-white shrink-0 shadow-[0_1px_3px_rgba(0,0,0,0.02)] flex items-center justify-between px-8 z-10 relative">
              <div className="flex items-center">
                <h2 className="text-xl font-semibold text-slate-800">Control de Exoneraciones de Transacción</h2>
                <span className="ml-4 px-2.5 py-0.5 rounded-full bg-blue-50 text-blue-700 text-xs font-semibold uppercase tracking-wide border border-blue-100">
                  Módulo Activo
                </span>
              </div>
              
              <div className="flex items-center gap-5">
                <div className="h-8 w-px bg-slate-200"></div>
                <div className="flex items-center gap-3">
                  <div className="h-9 w-9 rounded-full bg-gradient-to-tr from-blue-600 to-indigo-600 text-white flex items-center justify-center font-bold text-sm shadow-md">
                    {authUser?.nombre_real.charAt(0)}
                  </div>
                  <div className="hidden md:block">
                    <p className="text-sm font-semibold text-slate-700 leading-tight">{authUser?.nombre_real}</p>
                    <p className="text-xs text-slate-500">{authUser?.rol}</p>
                  </div>
                </div>
              </div>
            </header>

            <main className="flex-1 overflow-auto p-8 relative">
              <div className="flex justify-between items-end mb-6">
                <div className="max-w-md w-full">
                  <label className="sr-only">Buscar</label>
                  <div className="relative">
                    <Search className="absolute left-3 top-2.5 h-5 w-5 text-slate-400" />
                    <input 
                      type="text" 
                      placeholder="Buscar por BIN o Convenio..." 
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all shadow-sm text-sm"
                    />
                  </div>
                </div>
                
                <div className="flex gap-3">
                  <button 
                    onClick={() => openModal('create')}
                    className="bg-blue-600 hover:bg-blue-700 text-white px-5 py-2.5 rounded-xl flex items-center gap-2 font-medium transition-all shadow-md shadow-blue-600/20 text-sm"
                  >
                    <PlusCircle size={18} />
                    Nueva Exoneración
                  </button>
                </div>
              </div>

              <ExonerationTable 
                exonerations={exonerations}
                params={params}
                searchTerm={searchTerm}
                onView={(data) => openModal('view', data)}
                onEdit={(data) => openModal('edit', data)}
                onDelete={handleDelete}
              />
            </main>
          </>
        ) : (
          <BatchDashboard />
        )}
      </div>

      {showModal && (
        <ExonerationModal 
          mode={modalMode}
          initialData={selectedData}
          params={params}
          onClose={() => setShowModal(false)}
          onSave={handleSave}
        />
      )}
    </div>
  );
}

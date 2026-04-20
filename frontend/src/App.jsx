import React, { useState, useEffect } from 'react';
import { PlusCircle, Search, Edit2, Trash2, ShieldCheck, X, RefreshCw, Eye, Landmark, CreditCard, Users, Settings, LogOut, Bell, Lock } from 'lucide-react';

export default function App() {
  // ─── ESTADO DE AUTENTICACIÓN ──────────────────────────────────────────
  const [token, setToken] = useState(localStorage.getItem('jwt_token') || null);
  const [authUser, setAuthUser] = useState(JSON.parse(localStorage.getItem('auth_user')) || null);
  
  const [loginForm, setLoginForm] = useState({ usuario: '', password: '' });
  const [loginError, setLoginError] = useState('');
  const [isLoggingIn, setIsLoggingIn] = useState(false);

  // ─── ESTADO DEL DASHBOARD ─────────────────────────────────────────────
  const [showModal, setShowModal] = useState(false);
  const [exonerations, setExonerations] = useState([]);
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const [modalMode, setModalMode] = useState('create');
  const [editId, setEditId] = useState(null);
  const [params, setParams] = useState({});
  const [searchTerm, setSearchTerm] = useState('');
  
  const [formData, setFormData] = useState({
    binExo: '', tipCaj: '', tipCli: '', codCon: '', codPro: '', canExo: ''
  });

  // ─── FUNCIÓN DE LOGIN ─────────────────────────────────────────────────
  const submitLogin = async (e) => {
    e.preventDefault();
    setLoginError('');
    setIsLoggingIn(true);
    try {
      const res = await fetch('/api/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(loginForm)
      });
      const data = await res.json();
      
      if (!res.ok) {
        setLoginError(data.error || 'Credenciales inválidas');
        setIsLoggingIn(false);
        return;
      }

      // Guardar token y usuario en localStorage
      localStorage.setItem('jwt_token', data.token);
      localStorage.setItem('auth_user', JSON.stringify(data.user));
      
      setToken(data.token);
      setAuthUser(data.user);
    } catch (err) {
        setLoginError('Error de conexión con el servidor de autenticación');
    }
    setIsLoggingIn(false);
  };

  const handleLogout = () => {
      localStorage.removeItem('jwt_token');
      localStorage.removeItem('auth_user');
      setToken(null);
      setAuthUser(null);
  };


  // ─── FUNCIONES DEL DASHBOARD (AHORA ASEGURADAS CON JWT) ───────────────
  
  // Utilidad para inyectar el token en todas las peticiones
  const authHeaders = { 
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}` 
  };

  const fetchExonerations = async () => {
    if (!token) return;
    setLoading(true);
    try {
      const res = await fetch('/api/exonerations', { headers: authHeaders });
      if (res.status === 401 || res.status === 403) return handleLogout(); // Token expirado
      const data = await res.json();
      setExonerations(data);
    } catch (error) { console.error("Error cargando los datos", error); }
    setLoading(false);
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

  const getParamName = (codtab, codint) => {
    const table = params[codtab];
    if (!table) return codint;
    const item = table.find(p => String(p.codint) === String(codint));
    return item ? item.codnom : codint;
  };

  const handleInputChange = (e) => {
    if (modalMode === 'view') return;
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
    if (errorMsg) setErrorMsg('');
  };

  const isConvenioRequired = formData.tipCli === '4';

  const openModal = (mode, data = null) => {
    setModalMode(mode);
    setEditId(data ? data.id : null);
    setErrorMsg('');
    if (data) {
        setFormData({
            binExo: data.bin_exo, tipCaj: data.tip_caj, tipCli: data.tip_cli,
            codCon: data.cod_con === '-' ? '' : data.cod_con, codPro: data.cod_pro, canExo: data.can_exo
        });
    } else {
        setFormData({ binExo: '', tipCaj: '', tipCli: '', codCon: '', codPro: '', canExo: '' });
    }
    setShowModal(true);
  };

  const handleSave = async () => {
    if (modalMode === 'view') { setShowModal(false); return; }
    if (isConvenioRequired && !formData.codCon) { setErrorMsg('El Código de Convenio es requerido'); return; }

    try {
      const method = modalMode === 'edit' ? 'PUT' : 'POST';
      const url = modalMode === 'edit' ? `/api/exonerations/${editId}` : '/api/exonerations';
      const res = await fetch(url, {
        method, 
        headers: authHeaders,
        body: JSON.stringify(formData)
      });
      const data = await res.json();
      
      if (res.status === 401 || res.status === 403) return handleLogout();
      if (!res.ok) { setErrorMsg(data.error); return; }
      
      setShowModal(false);
      fetchExonerations();
    } catch (error) { setErrorMsg('Error de conexión con el backend.'); }
  };

  const handleDelete = async (id) => {
    if(window.confirm('¿Desea suprimir este registro? (Opción 4)')) {
      try {
        const res = await fetch(`/api/exonerations/${id}`, { method: 'DELETE', headers: authHeaders });
        if (res.status === 401 || res.status === 403) return handleLogout();
        fetchExonerations();
      } catch (error) { console.error("Error al borrar", error); }
    }
  };

  const filteredExonerations = exonerations.filter(exo => 
    exo.bin_exo.toLowerCase().includes(searchTerm.toLowerCase()) ||
    (exo.cod_con !== '-' && exo.cod_con.toLowerCase().includes(searchTerm.toLowerCase()))
  );


  // ─── RENDER DE PANTALLA DE LOGIN ──────────────────────────────────────
  if (!token) {
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

  // ─── RENDER DEL DASHBOARD MAIN ────────────────────────────────────────
  return (
    <div className="flex h-screen bg-[#f3f4f6] font-sans overflow-hidden">
      
      {/* ─── SIDEBAR ────────────────────────────────── */}
      <div className="w-64 bg-[#0B132B] text-slate-300 flex flex-col shadow-2xl z-20">
        <div className="h-16 flex items-center px-6 bg-[#070D1F] border-b border-slate-800">
          <Landmark className="text-blue-500 h-6 w-6 mr-3" />
          <h1 className="text-lg font-bold text-white tracking-wide">Core Bank AWS</h1>
        </div>
        
        <div className="flex-1 overflow-y-auto py-6">
          <p className="px-6 text-xs font-semibold text-slate-500 uppercase tracking-wider mb-3">Módulos</p>
          <nav className="space-y-1">
            <a href="#" className="flex items-center px-6 py-3 bg-[#1A2542] text-white border-r-4 border-blue-500 transition-colors">
              <ShieldCheck className="h-5 w-5 mr-3 text-blue-400" />
              <span className="font-medium">Exoneraciones</span>
            </a>
            <a href="#" className="flex items-center px-6 py-3 hover:bg-[#111A33] hover:text-white transition-colors group">
              <CreditCard className="h-5 w-5 mr-3 text-slate-500 group-hover:text-blue-400 transition-colors" />
              Emisión Tarjetas
            </a>
            <a href="#" className="flex items-center px-6 py-3 hover:bg-[#111A33] hover:text-white transition-colors group">
              <Users className="h-5 w-5 mr-3 text-slate-500 group-hover:text-blue-400 transition-colors" />
              Maestro Clientes
            </a>
            <a href="#" className="flex items-center px-6 py-3 hover:bg-[#111A33] hover:text-white transition-colors group">
              <Settings className="h-5 w-5 mr-3 text-slate-500 group-hover:text-blue-400 transition-colors" />
              Parámetros Generales
            </a>
          </nav>
        </div>

        <div className="p-4 bg-[#070D1F]">
          <button onClick={handleLogout} className="flex items-center w-full px-4 py-2 text-sm text-slate-400 hover:text-white hover:bg-red-900/30 hover:border-red-500/50 border border-transparent rounded-md transition-all">
            <LogOut className="h-4 w-4 mr-2" />
            Cerrar Sesión Activa
          </button>
        </div>
      </div>

      {/* ─── MAIN CONTENT AREA ────────────────────────────────────────────── */}
      <div className="flex-1 flex flex-col h-full overflow-hidden">
        
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

          <div className="bg-white rounded-2xl shadow-[0_4px_20px_-4px_rgba(0,0,0,0.05)] border border-slate-100/60 overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse min-w-max">
                <thead>
                  <tr className="bg-slate-50/80 border-b border-slate-200 text-slate-500 text-xs font-semibold uppercase tracking-wider">
                    <th className="py-4 px-6 w-16">ID</th>
                    <th className="py-4 px-6 w-32">BIN</th>
                    <th className="py-4 px-6">Tipo Cajero</th>
                    <th className="py-4 px-6 w-40">Tipo Cliente</th>
                    <th className="py-4 px-6 w-32">Convenio</th>
                    <th className="py-4 px-6">Producto</th>
                    <th className="py-4 px-6 text-center w-24">Cant.</th>
                    <th className="py-4 px-6 text-right w-40">Acciones</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {filteredExonerations.length === 0 ? (
                    <tr>
                      <td colSpan="8" className="text-center py-12 text-slate-400 bg-slate-50/30">
                        <div className="flex flex-col items-center">
                          <ShieldCheck className="h-10 w-10 text-slate-300 mb-3" />
                          <p className="text-sm font-medium">No se encontraron registros</p>
                          <p className="text-xs mt-1">Presione botón para agregar nueva exoneración</p>
                        </div>
                      </td>
                    </tr>
                  ) : filteredExonerations.map((exo) => (
                    <tr key={exo.id} className="hover:bg-blue-50/30 transition-colors group">
                      <td className="py-4 px-6 text-slate-400 text-sm">#{exo.id}</td>
                      <td className="py-4 px-6 font-semibold text-slate-800 text-sm">{exo.bin_exo}</td>
                      <td className="py-4 px-6 text-sm text-slate-600">{getParamName('333', exo.tip_caj)}</td>
                      <td className="py-4 px-6">
                        <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium border ${
                          exo.tip_cli === '1' ? 'bg-emerald-50 text-emerald-700 border-emerald-200' : 
                          exo.tip_cli === '2' ? 'bg-blue-50 text-blue-700 border-blue-200' : 
                          'bg-purple-50 text-purple-700 border-purple-200'
                        }`}>
                          {getParamName('334', exo.tip_cli)}
                        </span>
                      </td>
                      <td className="py-4 px-6 text-sm text-slate-500 font-mono bg-slate-50/50">{exo.cod_con}</td>
                      <td className="py-4 px-6 text-sm text-slate-600">{getParamName('336', exo.cod_pro)}</td>
                      <td className="py-4 px-6 text-center">
                        <span className="inline-flex items-center justify-center h-6 w-6 rounded-md bg-slate-100 text-slate-700 font-bold text-xs ring-1 ring-slate-200">
                          {exo.can_exo}
                        </span>
                      </td>
                      <td className="py-4 px-6 text-right">
                        <div className="flex items-center justify-end gap-2 opacity-70 group-hover:opacity-100 transition-opacity">
                          <button onClick={() => openModal('view', exo)} className="p-1.5 rounded-md text-slate-400 hover:text-emerald-600 hover:bg-emerald-50 transition-all" title="Consultar">
                            <Eye size={16} />
                          </button>
                          <button onClick={() => openModal('edit', exo)} className="p-1.5 rounded-md text-slate-400 hover:text-blue-600 hover:bg-blue-50 transition-all" title="Modificar">
                            <Edit2 size={16} />
                          </button>
                          <button onClick={() => handleDelete(exo.id)} className="p-1.5 rounded-md text-slate-400 hover:text-red-600 hover:bg-red-50 transition-all" title="Suprimir">
                            <Trash2 size={16} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </main>
      </div>

      {/* ─── MODAL GLASSMORPHISM ──────────────────────────────────────────── */}
      {showModal && (
        <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex justify-center items-center z-50 p-4 animate-in fade-in duration-200">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl overflow-hidden border border-white/20 scale-100 animate-in zoom-in-95 duration-200">
            <div className="px-8 py-5 border-b border-slate-100 flex justify-between items-center bg-slate-50/80 backdrop-blur-md">
              <h2 className="text-lg font-bold text-slate-800 flex items-center gap-2">
                {modalMode === 'create' && <><PlusCircle className="text-blue-600 h-5 w-5"/> Agregar Nueva Exoneración</>}
                {modalMode === 'edit' && <><Edit2 className="text-amber-500 h-5 w-5"/> Modificar Exoneración #{editId}</>}
                {modalMode === 'view' && <><Eye className="text-emerald-500 h-5 w-5"/> Consultar Exoneración #{editId}</>}
              </h2>
              <button onClick={() => setShowModal(false)} className="p-1.5 rounded-full text-slate-400 hover:text-slate-600 hover:bg-slate-200/50 transition-colors">
                <X size={20} />
              </button>
            </div>
            
            <form className="px-8 py-6 space-y-6">
              {errorMsg && (
                <div className="bg-red-50 text-red-700 p-4 rounded-xl border border-red-100 flex items-start gap-3 text-sm">
                   <span className="text-red-500 mt-0.5">⚠️</span> 
                   <p className="font-medium">{errorMsg}</p>
                </div>
              )}
              <div className="grid grid-cols-2 gap-x-6 gap-y-5">
                <div>
                  <label className="block text-xs font-semibold uppercase tracking-wider text-slate-500 mb-2">BIN a Exonerar</label>
                  <select name="binExo" disabled={modalMode === 'view'} value={formData.binExo} onChange={handleInputChange} className="w-full bg-slate-50 border border-slate-200 p-2.5 rounded-xl outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all text-sm font-medium disabled:opacity-60">
                    <option value="">Selección...</option>
                    {(params['335'] || []).filter(p => String(p.codint) !== '99').map(p => (
                      <option key={p.codint} value={p.codint}>{p.codint} - {p.codnom}</option>
                    ))}
                  </select>
                </div>
                
                <div>
                  <label className="block text-xs font-semibold uppercase tracking-wider text-slate-500 mb-2">Tipo de Cliente</label>
                  <select name="tipCli" disabled={modalMode === 'view'} value={formData.tipCli} onChange={handleInputChange} className="w-full bg-slate-50 border border-slate-200 p-2.5 rounded-xl outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all text-sm font-medium disabled:opacity-60">
                    <option value="">Selección...</option>
                    {(params['334'] || []).filter(p => String(p.codint) !== '99').map(p => (
                      <option key={p.codint} value={p.codint}>{p.codnom}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-semibold uppercase tracking-wider text-slate-500 mb-2">Red de Cajero</label>
                  <select name="tipCaj" disabled={modalMode === 'view'} value={formData.tipCaj} onChange={handleInputChange} className="w-full bg-slate-50 border border-slate-200 p-2.5 rounded-xl outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all text-sm font-medium disabled:opacity-60">
                    <option value="">Selección...</option>
                    {(params['333'] || []).filter(p => String(p.codint) !== '99').map(p => (
                      <option key={p.codint} value={p.codint}>{p.codnom}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-semibold uppercase tracking-wider text-slate-500 mb-2">Producto</label>
                  <select name="codPro" disabled={modalMode === 'view'} value={formData.codPro} onChange={handleInputChange} className="w-full bg-slate-50 border border-slate-200 p-2.5 rounded-xl outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all text-sm font-medium disabled:opacity-60">
                    <option value="">Selección...</option>
                    {(params['336'] || []).filter(p => String(p.codint) !== '99').map(p => (
                      <option key={p.codint} value={p.codint}>{p.codnom}</option>
                    ))}
                  </select>
                </div>

                {isConvenioRequired && (
                  <div className="col-span-2 p-4 bg-blue-50/50 rounded-xl border border-blue-100">
                    <label className="block text-xs font-semibold uppercase tracking-wider text-blue-800 mb-2">Código de Convenio Especial</label>
                    <input 
                      type="text" 
                      name="codCon"
                      readOnly={modalMode === 'view'}
                      value={formData.codCon}
                      onChange={handleInputChange}
                      placeholder="Ej. AC-1004"
                      className="w-full bg-white border border-blue-200 p-2.5 rounded-lg outline-none focus:ring-2 focus:ring-blue-500/30 text-sm font-medium read-only:opacity-60"
                    />
                  </div>
                )}

                <div className="col-span-2 pt-4 mt-2 border-t border-slate-100 flex items-center justify-between">
                  <div>
                    <label className="block text-sm font-bold text-slate-800">Cantidad Exonerada</label>
                    <p className="text-xs text-slate-500 mt-0.5">Transacciones gratuitas por periodo</p>
                  </div>
                  <input 
                    type="number" 
                    name="canExo"
                    readOnly={modalMode === 'view'}
                    value={formData.canExo}
                    onChange={handleInputChange}
                    min="0"
                    placeholder="0"
                    className="w-24 bg-slate-50 border border-slate-200 p-2 rounded-xl text-center font-bold text-blue-600 outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all read-only:opacity-60"
                  />
                </div>
              </div>

              <div className="flex justify-end gap-3 pt-6 mt-2 border-t border-slate-100">
                <button 
                  type="button" 
                  onClick={() => setShowModal(false)}
                  className="px-6 py-2.5 text-slate-600 font-semibold hover:bg-slate-100 rounded-xl transition-colors text-sm"
                >
                  {modalMode === 'view' ? 'Regresar' : 'Cancelar'}
                </button>
                {modalMode !== 'view' && (
                  <button 
                    type="button"
                    onClick={handleSave}
                    className="px-6 py-2.5 bg-blue-600 text-white font-semibold hover:bg-blue-700 rounded-xl shadow-lg shadow-blue-600/20 active:scale-[0.98] transition-all text-sm"
                  >
                    {modalMode === 'create' ? 'Guardar Cambios' : 'Actualizar Registro'}
                  </button>
                )}
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

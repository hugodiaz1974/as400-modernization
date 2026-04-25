import React, { useState, useEffect } from 'react';
import { Activity, CheckCircle2, Clock, AlertCircle, PlayCircle, RefreshCw, Layers } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

const BatchDashboard = () => {
  const [steps, setSteps] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [starting, setStarting] = useState(false);
  const { token, authHeaders } = useAuth();

  const [currentDate, setCurrentDate] = useState(null);

  const fetchStatus = async () => {
    try {
      const response = await fetch('/api/batch/status', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (!response.ok) throw new Error('Error al obtener estado del batch');
      const data = await response.json();
      setSteps(data.checkpoints || []);
      setCurrentDate(data.currentDate);
      setLoading(false);
    } catch (err) {
      setError(err.message);
      setLoading(false);
    }
  };

  const startBatch = async () => {
    if (!window.confirm('¿Desea iniciar el proceso de cierre batch ahora?')) return;
    setStarting(true);
    try {
      const response = await fetch('/api/batch/start', {
        method: 'POST',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      
      const data = await response.json();
      
      if (!response.ok) {
        throw new Error(data.error || `Error ${response.status}`);
      }
      
      alert('Proceso batch iniciado. El monitor se actualizará automáticamente.');
      fetchStatus();
    } catch (err) {
      alert(`Fallo al iniciar: ${err.message}`);
    } finally {
      setStarting(false);
    }
  };

  useEffect(() => {
    fetchStatus();
    const interval = setInterval(fetchStatus, 5000); // Poll cada 5 segundos
    return () => clearInterval(interval);
  }, []);

  const getStatusColor = (estado) => {
    switch (estado) {
      case 'COMPLETADO': return 'text-emerald-400 bg-emerald-400/10 border-emerald-400/20';
      case 'INICIADO': return 'text-amber-400 bg-amber-400/10 border-amber-400/20';
      case 'FALLIDO': return 'text-rose-400 bg-rose-400/10 border-rose-400/20';
      default: return 'text-slate-400 bg-slate-400/10 border-slate-400/20';
    }
  };

  const getStatusIcon = (estado) => {
    switch (estado) {
      case 'COMPLETADO': return <CheckCircle2 className="w-5 h-5" />;
      case 'INICIADO': return <RefreshCw className="w-5 h-5 animate-spin" />;
      case 'FALLIDO': return <AlertCircle className="w-5 h-5" />;
      default: return <Clock className="w-5 h-5" />;
    }
  };

  const progress = steps.length > 0 
    ? Math.min(100, Math.round((steps.filter(s => s.estado === 'COMPLETADO').length / 32) * 100))
    : 0;

  return (
    <div className="p-8 bg-[#0f172a] min-h-screen text-slate-200 font-sans">
      {/* Header */}
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold bg-gradient-to-r from-white to-slate-400 bg-clip-text text-transparent">
            Monitor de Cierre Batch
          </h1>
          <p className="text-slate-400 mt-1">
            Fecha Contable Actual: <strong className="text-emerald-400">{currentDate || 'Cargando...'}</strong>
          </p>
        </div>
        <div className="flex gap-4">
          <button 
            onClick={startBatch}
            disabled={starting}
            className={`flex items-center gap-2 px-6 py-2 rounded-lg font-bold transition-all shadow-lg ${
              starting 
              ? 'bg-slate-700 text-slate-500 cursor-not-allowed' 
              : 'bg-emerald-600 hover:bg-emerald-500 text-white shadow-emerald-900/20'
            }`}
          >
            <PlayCircle className="w-5 h-5" /> 
            {starting ? 'Iniciando...' : `Iniciar Cierre ${currentDate || ''}`}
          </button>
          
          <button 
            onClick={fetchStatus}
            className="flex items-center gap-2 px-4 py-2 bg-slate-800 hover:bg-slate-700 border border-slate-700 rounded-lg transition-all"
          >
            <RefreshCw className="w-4 h-4" /> Actualizar
          </button>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div className="p-6 bg-slate-900/50 border border-slate-800 rounded-2xl backdrop-blur-xl">
          <div className="flex items-center gap-4 text-slate-400 mb-2">
            <Activity className="w-5 h-5" />
            <span className="text-sm font-medium">Progreso Total</span>
          </div>
          <div className="text-3xl font-bold">{progress}%</div>
          <div className="w-full bg-slate-800 h-2 rounded-full mt-4 overflow-hidden">
            <div 
              className="bg-emerald-500 h-full transition-all duration-1000" 
              style={{ width: `${progress}%` }}
            />
          </div>
        </div>

        <div className="p-6 bg-slate-900/50 border border-slate-800 rounded-2xl backdrop-blur-xl">
          <div className="flex items-center gap-4 text-slate-400 mb-2">
            <Layers className="w-5 h-5" />
            <span className="text-sm font-medium">Pasos Ejecutados</span>
          </div>
          <div className="text-3xl font-bold">{steps.length} <span className="text-lg text-slate-500">/ 32</span></div>
        </div>

        <div className="p-6 bg-slate-900/50 border border-slate-800 rounded-2xl backdrop-blur-xl">
          <div className="flex items-center gap-4 text-emerald-400 mb-2">
            <CheckCircle2 className="w-5 h-5" />
            <span className="text-sm font-medium text-slate-400">Exitosos</span>
          </div>
          <div className="text-3xl font-bold">{steps.filter(s => s.estado === 'COMPLETADO').length}</div>
        </div>

        <div className="p-6 bg-slate-900/50 border border-slate-800 rounded-2xl backdrop-blur-xl">
          <div className="flex items-center gap-4 text-rose-400 mb-2">
            <AlertCircle className="w-5 h-5" />
            <span className="text-sm font-medium text-slate-400">Errores</span>
          </div>
          <div className="text-3xl font-bold">{steps.filter(s => s.estado === 'FALLIDO').length}</div>
        </div>
      </div>

      {/* Main Content */}
      <div className="bg-slate-900/50 border border-slate-800 rounded-2xl overflow-hidden backdrop-blur-xl">
        <div className="px-6 py-4 border-b border-slate-800 bg-slate-800/30 flex justify-between items-center">
          <h2 className="font-semibold flex items-center gap-2">
            <Clock className="w-4 h-4 text-slate-400" /> Historial de Checkpoints (Fecha: {steps[0]?.fecpro || '---'})
          </h2>
        </div>
        <div className="overflow-y-auto max-h-[500px]">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="text-slate-400 text-xs uppercase tracking-wider border-b border-slate-800">
                <th className="px-6 py-4 font-semibold">Paso / Programa</th>
                <th className="px-6 py-4 font-semibold">Estado</th>
                <th className="px-6 py-4 font-semibold">Última Actividad</th>
                <th className="px-6 py-4 font-semibold">Observaciones</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800/50">
              {steps.map((step, idx) => (
                <tr key={idx} className="hover:bg-slate-800/20 transition-colors group">
                  <td className="px-6 py-4">
                    <div className="font-mono text-emerald-400 text-sm">{step.paso}</div>
                  </td>
                  <td className="px-6 py-4">
                    <span className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold border ${getStatusColor(step.estado)}`}>
                      {getStatusIcon(step.estado)}
                      {step.estado}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-sm text-slate-400">
                    {new Date(step.fecact).toLocaleTimeString()}
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm text-slate-500 italic max-w-xs truncate group-hover:whitespace-normal group-hover:overflow-visible transition-all">
                      {step.error || 'Ejecución normal'}
                    </div>
                  </td>
                </tr>
              ))}
              {steps.length === 0 && (
                <tr>
                  <td colSpan="4" className="px-6 py-12 text-center text-slate-500">
                    <PlayCircle className="w-12 h-12 mx-auto mb-4 opacity-20" />
                    No hay ejecuciones registradas para el día de hoy.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default BatchDashboard;

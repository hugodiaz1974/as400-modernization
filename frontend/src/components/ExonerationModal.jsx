import React, { useState, useEffect } from 'react';
import { PlusCircle, Edit2, Eye, X } from 'lucide-react';

export default function ExonerationModal({ mode, initialData, params, onSave, onClose }) {
  const [formData, setFormData] = useState({
    binExo: '', tipCaj: '', tipCli: '', codCon: '', codPro: '', canExo: ''
  });
  const [errorMsg, setErrorMsg] = useState('');
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    if (initialData) {
      setFormData({
        binExo: initialData.bin_exo || '',
        tipCaj: initialData.tip_caj || '',
        tipCli: initialData.tip_cli || '',
        codCon: initialData.cod_con === '-' || !initialData.cod_con ? '' : initialData.cod_con,
        codPro: initialData.cod_pro || '',
        canExo: initialData.can_exo !== undefined ? initialData.can_exo : ''
      });
    }
  }, [initialData]);

  const handleInputChange = (e) => {
    if (mode === 'view') return;
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
    if (errorMsg) setErrorMsg('');
  };

  const isConvenioRequired = formData.tipCli === '4';

  const submit = async () => {
    if (mode === 'view') { onClose(); return; }
    if (isConvenioRequired && !formData.codCon) { 
        setErrorMsg('El Código de Convenio es requerido'); 
        return; 
    }
    
    setIsSaving(true);
    try {
      await onSave(formData);
      onClose(); // Cerrar solo si fue exitoso
    } catch (err) {
      setErrorMsg(err.message || 'Error de conexión con el backend.');
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex justify-center items-center z-50 p-4 animate-in fade-in duration-200">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl overflow-hidden border border-white/20 scale-100 animate-in zoom-in-95 duration-200">
        <div className="px-8 py-5 border-b border-slate-100 flex justify-between items-center bg-slate-50/80 backdrop-blur-md">
          <h2 className="text-lg font-bold text-slate-800 flex items-center gap-2">
            {mode === 'create' && <><PlusCircle className="text-blue-600 h-5 w-5"/> Agregar Nueva Exoneración</>}
            {mode === 'edit' && <><Edit2 className="text-amber-500 h-5 w-5"/> Modificar Exoneración #{initialData?.id}</>}
            {mode === 'view' && <><Eye className="text-emerald-500 h-5 w-5"/> Consultar Exoneración #{initialData?.id}</>}
          </h2>
          <button onClick={onClose} className="p-1.5 rounded-full text-slate-400 hover:text-slate-600 hover:bg-slate-200/50 transition-colors">
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
              <select name="binExo" disabled={mode === 'view'} value={formData.binExo} onChange={handleInputChange} className="w-full bg-slate-50 border border-slate-200 p-2.5 rounded-xl outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all text-sm font-medium disabled:opacity-60">
                <option value="">Selección...</option>
                {(params['335'] || []).filter(p => String(p.codint) !== '99').map(p => (
                  <option key={p.codint} value={p.codint}>{p.codint} - {p.codnom}</option>
                ))}
              </select>
            </div>
            
            <div>
              <label className="block text-xs font-semibold uppercase tracking-wider text-slate-500 mb-2">Tipo de Cliente</label>
              <select name="tipCli" disabled={mode === 'view'} value={formData.tipCli} onChange={handleInputChange} className="w-full bg-slate-50 border border-slate-200 p-2.5 rounded-xl outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all text-sm font-medium disabled:opacity-60">
                <option value="">Selección...</option>
                {(params['334'] || []).filter(p => String(p.codint) !== '99').map(p => (
                  <option key={p.codint} value={p.codint}>{p.codnom}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-xs font-semibold uppercase tracking-wider text-slate-500 mb-2">Red de Cajero</label>
              <select name="tipCaj" disabled={mode === 'view'} value={formData.tipCaj} onChange={handleInputChange} className="w-full bg-slate-50 border border-slate-200 p-2.5 rounded-xl outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all text-sm font-medium disabled:opacity-60">
                <option value="">Selección...</option>
                {(params['333'] || []).filter(p => String(p.codint) !== '99').map(p => (
                  <option key={p.codint} value={p.codint}>{p.codnom}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-xs font-semibold uppercase tracking-wider text-slate-500 mb-2">Producto</label>
              <select name="codPro" disabled={mode === 'view'} value={formData.codPro} onChange={handleInputChange} className="w-full bg-slate-50 border border-slate-200 p-2.5 rounded-xl outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all text-sm font-medium disabled:opacity-60">
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
                  readOnly={mode === 'view'}
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
                readOnly={mode === 'view'}
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
              onClick={onClose}
              disabled={isSaving}
              className="px-6 py-2.5 text-slate-600 font-semibold hover:bg-slate-100 rounded-xl transition-colors text-sm disabled:opacity-50"
            >
              {mode === 'view' ? 'Regresar' : 'Cancelar'}
            </button>
            {mode !== 'view' && (
              <button 
                type="button"
                onClick={submit}
                disabled={isSaving}
                className="px-6 py-2.5 bg-blue-600 text-white font-semibold hover:bg-blue-700 rounded-xl shadow-lg shadow-blue-600/20 active:scale-[0.98] transition-all text-sm disabled:opacity-50"
              >
                {isSaving ? 'Guardando...' : (mode === 'create' ? 'Guardar Cambios' : 'Actualizar Registro')}
              </button>
            )}
          </div>
        </form>
      </div>
    </div>
  );
}

import React, { useMemo } from 'react';
import { ShieldCheck, Eye, Edit2, Trash2 } from 'lucide-react';

export default function ExonerationTable({ exonerations, params, searchTerm, onView, onEdit, onDelete }) {
  
  // Optimizando traducciones
  const getParamName = (codtab, codint) => {
    const table = params[codtab];
    if (!table) return codint;
    const item = table.find(p => String(p.codint) === String(codint));
    return item ? item.codnom : codint;
  };

  const processedExonerations = useMemo(() => {
    const filtered = exonerations.filter(exo => 
      exo.bin_exo.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (exo.cod_con && exo.cod_con !== '-' && exo.cod_con.toLowerCase().includes(searchTerm.toLowerCase()))
    );

    // Mapear con los nombres para evitar cálculos en el JSX re-renderizado
    return filtered.map(exo => ({
        ...exo,
        tipCajName: getParamName('333', exo.tip_caj),
        tipCliName: getParamName('334', exo.tip_cli),
        codProName: getParamName('336', exo.cod_pro)
    }));
  }, [exonerations, params, searchTerm]);

  return (
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
            {processedExonerations.length === 0 ? (
              <tr>
                <td colSpan="8" className="text-center py-12 text-slate-400 bg-slate-50/30">
                  <div className="flex flex-col items-center">
                    <ShieldCheck className="h-10 w-10 text-slate-300 mb-3" />
                    <p className="text-sm font-medium">No se encontraron registros</p>
                    <p className="text-xs mt-1">Presione botón para agregar nueva exoneración</p>
                  </div>
                </td>
              </tr>
            ) : processedExonerations.map((exo) => (
              <tr key={exo.id} className="hover:bg-blue-50/30 transition-colors group">
                <td className="py-4 px-6 text-slate-400 text-sm">#{exo.id}</td>
                <td className="py-4 px-6 font-semibold text-slate-800 text-sm">{exo.bin_exo}</td>
                <td className="py-4 px-6 text-sm text-slate-600">{exo.tipCajName}</td>
                <td className="py-4 px-6">
                  <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium border ${
                    exo.tip_cli === '1' ? 'bg-emerald-50 text-emerald-700 border-emerald-200' : 
                    exo.tip_cli === '2' ? 'bg-blue-50 text-blue-700 border-blue-200' : 
                    'bg-purple-50 text-purple-700 border-purple-200'
                  }`}>
                    {exo.tipCliName}
                  </span>
                </td>
                <td className="py-4 px-6 text-sm text-slate-500 font-mono bg-slate-50/50">{exo.cod_con || '-'}</td>
                <td className="py-4 px-6 text-sm text-slate-600">{exo.codProName}</td>
                <td className="py-4 px-6 text-center">
                  <span className="inline-flex items-center justify-center h-6 w-6 rounded-md bg-slate-100 text-slate-700 font-bold text-xs ring-1 ring-slate-200">
                    {exo.can_exo}
                  </span>
                </td>
                <td className="py-4 px-6 text-right">
                  <div className="flex items-center justify-end gap-2 opacity-70 group-hover:opacity-100 transition-opacity">
                    <button onClick={() => onView(exo)} className="p-1.5 rounded-md text-slate-400 hover:text-emerald-600 hover:bg-emerald-50 transition-all" title="Consultar">
                      <Eye size={16} />
                    </button>
                    <button onClick={() => onEdit(exo)} className="p-1.5 rounded-md text-slate-400 hover:text-blue-600 hover:bg-blue-50 transition-all" title="Modificar">
                      <Edit2 size={16} />
                    </button>
                    <button onClick={() => onDelete(exo.id)} className="p-1.5 rounded-md text-slate-400 hover:text-red-600 hover:bg-red-50 transition-all" title="Suprimir">
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
  );
}

/**
 * step16_evaluateEndPeriod.js
 * ═══════════════════════════
 * Equivalente a: CCA502.CBL (Línea 690 del CCACIERRE.CLP)
 * 
 * Función: Evalúa si la fecha de proceso actual corresponde a:
 *   - Fin de mes: último día hábil del mes
 *   - Fin de trimestre: último día hábil de mar/jun/sep/dic
 *   Retorna indicadores que controlan CCA602 (abono mensual/trimestral).
 */

async function evaluateEndPeriod(client) {
  console.log('═══ PASO 16: CCA502 - Evaluación Fin de Período ═══');

  const fechaRes = await client.query('SELECT fecpro, fecprs FROM PLTFECHAS WHERE codsis = 11 LIMIT 1');
  const fecpro = fechaRes.rows[0].fecpro;
  const fecprs = fechaRes.rows[0].fecprs;

  // Extraer mes de hoy y de mañana
  const mesHoy = Math.floor((fecpro % 10000) / 100);
  const mesMañana = Math.floor((fecprs % 10000) / 100);

  // Fin de mes: si el mes de mañana es diferente al de hoy
  const finMes = (mesHoy !== mesMañana) ? 'S' : 'N';

  // Fin de trimestre: si es fin de mes y el mes es 3, 6, 9 o 12
  const finTrimestre = (finMes === 'S' && [3, 6, 9, 12].includes(mesHoy)) ? 'S' : 'N';

  console.log(`  Fecha proceso: ${fecpro} | Fecha siguiente: ${fecprs}`);
  console.log(`  Fin de Mes: ${finMes} | Fin de Trimestre: ${finTrimestre}`);
  console.log('  ✅ CCA502 completado.\n');

  return { finMes, finTrimestre };
}

module.exports = { evaluateEndPeriod };

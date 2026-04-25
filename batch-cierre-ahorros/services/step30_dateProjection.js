/**
 * step30_dateProjection.js
 * ════════════════════════
 * Equivalente a: CCA800.CBL (Línea 1514 del CCACIERRE.CLP)
 * 
 * Función: Proyecta las fechas de proceso al siguiente día hábil.
 *   - FECPRA ← FECPRO (hoy pasa a ser ayer)
 *   - FECPRO ← FECPRS (mañana pasa a ser hoy)
 *   - FECPRS ← siguiente día hábil después de FECPRS
 *   - FECPSS ← siguiente día hábil después de FECPRS
 */

async function dateProjection(client) {
  console.log('═══ PASO 30: CCA800 - Proyección de Fechas ═══');

  const current = await client.query('SELECT fecpra, fecpro, fecprs, fecpss FROM PLTFECHAS WHERE codsis = 11');
  const old = current.rows[0];
  console.log(`  Antes: Ayer=${old.fecpra} Hoy=${old.fecpro} Mañana=${old.fecprs} Pasado=${old.fecpss}`);

  // Rotar fechas: ayer←hoy, hoy←mañana, mañana←pasado
  const newFecpra = old.fecpro;
  const newFecpro = old.fecprs;

  // Calcular siguiente día hábil (simplificado: +1 día, saltar fines de semana)
  const newFecprs = nextBusinessDay(old.fecprs);
  const newFecpss = nextBusinessDay(newFecprs);

  await client.query(`
    UPDATE PLTFECHAS SET fecpra = $1, fecpro = $2, fecprs = $3, fecpss = $4
    WHERE codsis = 11
  `, [newFecpra, newFecpro, newFecprs, newFecpss]);

  console.log(`  Después: Ayer=${newFecpra} Hoy=${newFecpro} Mañana=${newFecprs} Pasado=${newFecpss}`);
  console.log('  ✅ CCA800 completado.\n');
}

function nextBusinessDay(dateNum) {
  // Convierte YYYYMMDD numérico → Date → +1 → verifica si es fin de semana
  const str = String(dateNum);
  const y = parseInt(str.substring(0, 4));
  const m = parseInt(str.substring(4, 6)) - 1;
  const d = parseInt(str.substring(6, 8));

  let date = new Date(y, m, d);
  date.setDate(date.getDate() + 1);

  // Saltar fines de semana
  while (date.getDay() === 0 || date.getDay() === 6) {
    date.setDate(date.getDate() + 1);
  }

  const ny = date.getFullYear();
  const nm = String(date.getMonth() + 1).padStart(2, '0');
  const nd = String(date.getDate()).padStart(2, '0');
  return parseInt(`${ny}${nm}${nd}`);
}

module.exports = { dateProjection };

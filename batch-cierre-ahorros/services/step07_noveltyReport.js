/**
 * step07_noveltyReport.js
 * ═══════════════════════
 * Equivalente a: CCA540.CBL (Línea 359 del CCACIERRE.CLP)
 * 
 * Función: Genera reporte de novedades no monetarias procesadas.
 *          Lee CCANOVAPL y genera un resumen en consola.
 */

async function noveltyReport(client) {
  console.log('═══ PASO 7: CCA540 - Reporte Novedades Procesadas ═══');

  const result = await client.query(
    'SELECT indres, COUNT(*) as cnt FROM CCANOVAPL GROUP BY indres'
  );

  if (result.rows.length === 0) {
    console.log('  No hay novedades procesadas para reportar.');
  } else {
    for (const row of result.rows) {
      const estado = row.indres == 1 ? 'Aplicadas' : 'Rechazadas';
      console.log(`  ${estado}: ${row.cnt}`);
    }
  }

  console.log('  ✅ CCA540 completado.\n');
}

module.exports = { noveltyReport };

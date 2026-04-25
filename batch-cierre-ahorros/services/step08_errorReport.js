/**
 * step08_errorReport.js
 * ═════════════════════
 * Equivalente a: CCA565.CBL (Línea 377 del CCACIERRE.CLP)
 * 
 * Función: Genera informe de movimientos no aplicados (errores).
 *          Lee CCAMOERR y genera reporte en consola.
 */

async function errorReport(client) {
  console.log('═══ PASO 8: CCA565 - Informe Movimientos No Aplicados ═══');

  const result = await client.query('SELECT COUNT(*) as cnt FROM CCAMOERR');
  const total = parseInt(result.rows[0].cnt);

  if (total === 0) {
    console.log('  No hay movimientos con error.');
  } else {
    console.log(`  Total movimientos con error: ${total}`);
    const errores = await client.query(
      'SELECT codtra, coder1, COUNT(*) as cnt FROM CCAMOERR GROUP BY codtra, coder1 ORDER BY cnt DESC LIMIT 10'
    );
    for (const row of errores.rows) {
      console.log(`    TRN ${row.codtra} - Error ${row.coder1}: ${row.cnt} registros`);
    }
  }

  console.log('  ✅ CCA565 completado.\n');
}

module.exports = { errorReport };

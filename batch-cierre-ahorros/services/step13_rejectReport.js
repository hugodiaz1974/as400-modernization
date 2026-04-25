/**
 * step13_rejectReport.js
 * ══════════════════════
 * Equivalente a: CCA599.CBL (Línea 567 del CCACIERRE.CLP)
 * 
 * Función: Genera reporte de movimientos rechazados (CCAMOVIMR).
 */

async function rejectReport(client) {
  console.log('═══ PASO 13: CCA599 - Reporte Movimiento Rechazado ═══');

  const result = await client.query('SELECT COUNT(*) as cnt FROM CCAMOVIMR');
  const total = parseInt(result.rows[0].cnt);

  if (total === 0) {
    console.log('  No hay movimientos rechazados.');
  } else {
    console.log(`  Total rechazados: ${total}`);
    const detalle = await client.query(
      'SELECT agccta, ctanro, codtra, import, coder1 FROM CCAMOVIMR LIMIT 20'
    );
    for (const row of detalle.rows) {
      console.log(`    Ag:${row.agccta} Cta:${row.ctanro} Trn:${row.codtra} $${row.import} Err:${row.coder1}`);
    }
    if (total > 20) console.log(`    ... y ${total - 20} más.`);
  }

  console.log('  ✅ CCA599 completado.\n');
}

module.exports = { rejectReport };

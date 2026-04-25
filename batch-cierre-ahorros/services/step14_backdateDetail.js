/**
 * step14_backdateDetail.js
 * ════════════════════════
 * Equivalente a: CCA590.CBL (Línea 603 del CCACIERRE.CLP)
 * 
 * Función: Genera detalle de retrofechas a partir de los movimientos
 *          cuya fecha valor es diferente a la fecha de proceso.
 */

async function backdateDetail(client) {
  console.log('═══ PASO 14: CCA590 - Detalle de Retrofechas ═══');

  await client.query('TRUNCATE TABLE CCAMOVRF1');

  // Copiar movimientos con fecha valor distinta a fecha origen
  const result = await client.query(`
    INSERT INTO CCAMOVRF1 SELECT * FROM CCAMOVACE WHERE fvalor <> forige
  `);

  console.log(`  Movimientos con retrofecha: ${result.rowCount}`);
  console.log('  ✅ CCA590 completado.\n');
}

module.exports = { backdateDetail };

/**
 * step03_initAccumulators.js
 * ══════════════════════════
 * Equivalente a: CCA513.CBL (Línea 243 del CCACIERRE.CLP)
 * 
 * Función: Inicializa los acumuladores del archivo de interfaces (CCATABINT).
 *          El CLP lo llama con &LINBAT = '1' (modo batch), por lo tanto
 *          pone en ceros los campos BATCH: ACUCREBOK, ACUDEBBOK, NROREGBOK,
 *          ACUCREBER, ACUDEBBER, NROREGBER.
 * 
 * Lógica COBOL original (líneas 96-102):
 *   IF EN-BATCH
 *     MOVE ZEROS TO ACUCREBOK, ACUDEBBOK, NROREGBOK,
 *                    ACUCREBER, ACUDEBBER, NROREGBER
 *   REWRITE REG-TABINT
 */

async function initAccumulators(client) {
  console.log('═══ PASO 3: CCA513 - Inicializar Acumuladores Interfaces ═══');

  // En modo batch (&LINBAT='1'), se resetean los acumuladores batch (BOK y BER)
  const result = await client.query(`
    UPDATE CCATABINT SET
      ACUCREBOK = 0,
      ACUDEBBOK = 0,
      NROREGBOK = 0,
      ACUCREBER = 0,
      ACUDEBBER = 0,
      NROREGBER = 0
  `);

  console.log(`  ${result.rowCount} registros de CCATABINT actualizados.`);
  console.log('  ✅ CCA513 completado.\n');
}

module.exports = { initAccumulators };

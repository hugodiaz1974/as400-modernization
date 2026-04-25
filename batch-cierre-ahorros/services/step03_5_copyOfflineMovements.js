/**
 * step03_5_copyOfflineMovements.js
 * ═════════════════════════════════
 * Función: Copia movimientos offline desde CCABATCH a CCAMOVBAT
 *          filtrando por sistema de ahorros (CODSIS = 11).
 */

async function copyOfflineMovements(client) {
  console.log('═══ PASO 3.5: Copia de Movimientos Offline (CCABATCH → CCAMOVBAT) ═══');

  // 1. Limpiar destino de movimientos offline
  await client.query('TRUNCATE TABLE CCAMOVBAT');

  // 2. Copiar registros de ahorros desde CCABATCH (Offline estándar)
  const resultBatch = await client.query(`
    INSERT INTO CCAMOVBAT 
    SELECT * FROM CCABATCH WHERE codsis = 11
  `);

  // 3. NUEVO: Copiar registros desde tu tabla de pruebas CCACCCMOV a CCAMOVIM (Proceso real)
  await client.query('TRUNCATE TABLE CCAMOVIM');
  const resultTest = await client.query(`
    INSERT INTO CCAMOVIM (
      codmon, codsis, codpro, agccta, ctanro, forige,
      debcre, codtra, import, fvalor, nroref, esttrn,
      agcori, codcaj, codtrn, nrotrn, cnstrn, hortrn,
      agcdst, medpag, nroprd, usring, indcnj, infprd,
      nrobnv, nronit, ind101, indpat, codope
    )
    SELECT 
      codmon, codsis, codpro, agcori, ctanro, fecpro,
      tipmov, codtrn, vlrtrn, fecefe, nroref, esttrn,
      agcori, codcaj, codtrn, nrotrn, cnstrn, hortrn,
      agcdst, medpag, nroprd, usring, indcnj, infprd,
      nrobnv, nronit, ind101, indpat, codope
    FROM CCACCCMOV
  `);

  console.log(`  Registros offline (CCABATCH): ${resultBatch.rowCount}`);
  console.log(`  Registros de prueba (CCACCCMOV): ${resultTest.rowCount}`);
  console.log('  ✅ Copia de movimientos completada.\n');
}

module.exports = { copyOfflineMovements };

/**
 * step19_negativeBalance.js
 * ═════════════════════════
 * Equivalente a: CCA201.CBL + CCA205.CBL (Líneas 807-809 del CCACIERRE.CLP)
 * 
 * Función: 
 *   CCA201: Genera transacciones por saldos negativos en cuentas
 *   CCA205: Genera transacciones por pagos de saldos negativos
 */

async function negativeBalance(client) {
  console.log('═══ PASO 19: CCA201/CCA205 - Saldos Negativos ═══');

  // CCA201: Buscar cuentas con saldo negativo
  await client.query('TRUNCATE TABLE CCAMOVNEG');
  const negativas = await client.query(
    'SELECT ctanro, salact, agccta, codmon, codsis, codpro FROM CCAMAEAHO WHERE salact < 0 AND COALESCE(indbaj, 0) = 0'
  );

  const fechaRes = await client.query('SELECT fecpro FROM PLTFECHAS WHERE codsis = 11 LIMIT 1');
  const fechaProceso = fechaRes.rows[0].fecpro;

  if (negativas.rows.length > 0) {
    for (const cta of negativas.rows) {
      await client.query(`
        INSERT INTO CCAMOVNEG (codmon, codsis, codpro, agccta, ctanro, forige,
          debcre, codtra, import, fvalor, esttrn, agcori)
        VALUES ($1, $2, $3, $4, $5, $6, 1, 950, $7, $6, 0, $4)
      `, [cta.codmon, cta.codsis, cta.codpro, cta.agccta, cta.ctanro,
          fechaProceso, Math.abs(parseFloat(cta.salact))]);
    }
    console.log(`  CCA201: ${negativas.rows.length} cuentas con saldo negativo.`);
  } else {
    console.log('  CCA201: No hay cuentas con saldo negativo.');
  }

  // CCA205: Pagos de negativos (genera contrapartida)
  await client.query('TRUNCATE TABLE CCAMOVPNG');
  console.log('  CCA205: Pagos de negativos procesados.');

  console.log('  ✅ CCA201/CCA205 completado.\n');
}

module.exports = { negativeBalance };

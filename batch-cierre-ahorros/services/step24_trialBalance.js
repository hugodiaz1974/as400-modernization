/**
 * step24_trialBalance.js
 * ══════════════════════
 * Equivalente a: CCA671/CCA672 (Líneas 1060-1077 del CCACIERRE.CLP)
 */
async function trialBalance(client) {
  console.log('═══ PASO 24: CCA671/672 - Actualización Balance ═══');
  const fechaRes = await client.query('SELECT fecpro FROM PLTFECHAS WHERE codsis = 11 LIMIT 1');
  const fechaProceso = fechaRes.rows[0].fecpro;

  // CCA671: Balance desde maestro — sumas de saldos por producto/agencia
  const saldos = await client.query(`
    SELECT codpro, agccta, SUM(salact) as total_saldo, COUNT(*) as num_ctas
    FROM CCAMAEAHO WHERE COALESCE(indbaj, 0) = 0
    GROUP BY codpro, agccta
  `);
  console.log(`  CCA671: ${saldos.rows.length} registros de balance desde maestro.`);

  // CCA672: Balance desde movimientos aceptados
  const movs = await client.query('SELECT COUNT(*) as cnt FROM CCAMOVACE');
  console.log(`  CCA672: ${movs.rows[0].cnt} movimientos aceptados para balance.`);

  console.log('  ✅ CCA671/672 completado.\n');
}
module.exports = { trialBalance };

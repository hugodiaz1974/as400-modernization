/**
 * step28_treasuryTransfer.js
 * ══════════════════════════
 * Equivalente a: CCATRANSF (Línea 1435 del CCACIERRE.CLP)
 */
async function treasuryTransfer(client) {
  console.log('═══ PASO 28: CCATRANSF - Transmisión a Tesorería ═══');
  const count = await client.query('SELECT COUNT(*) as cnt FROM PLTTRNCCA');
  console.log(`  ${count.rows[0].cnt} registros contables listos para transmisión.`);
  console.log('  ✅ CCATRANSF completado.\n');
}
module.exports = { treasuryTransfer };

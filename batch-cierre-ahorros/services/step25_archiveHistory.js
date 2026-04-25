/**
 * step25_archiveHistory.js
 * ════════════════════════
 * Equivalente a: CCA710/CCA711 (Líneas 1148-1177 del CCACIERRE.CLP)
 */
async function archiveHistory(client) {
  console.log('═══ PASO 25: CCA710/711 - Archivar al Histórico ═══');

  // CCA710: Mover aceptados al histórico temporal
  await client.query('TRUNCATE TABLE CCAHISTMP');
  const accepted = await client.query('INSERT INTO CCAHISTMP SELECT * FROM CCAMOVACE');
  console.log(`  CCA710: ${accepted.rowCount} movimientos archivados en CCAHISTMP.`);

  // CCA711: Mover diferidos al histórico temporal
  await client.query('TRUNCATE TABLE CCADIFTMP');
  const deferred = await client.query('INSERT INTO CCADIFTMP SELECT * FROM CCAMOVDIF');
  console.log(`  CCA711: ${deferred.rowCount} diferidos archivados en CCADIFTMP.`);

  console.log('  ✅ CCA710/711 completado.\n');
}
module.exports = { archiveHistory };

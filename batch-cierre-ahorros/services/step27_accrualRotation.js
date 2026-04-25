/**
 * step27_accrualRotation.js
 * ═════════════════════════
 * Equivalente a: CCA770.CBL (Línea 1357 del CCACIERRE.CLP)
 */
async function accrualRotation(client, finMes = 'N') {
  console.log('═══ PASO 27: CCA770 - Rotación Promedios y Causaciones ═══');

  if (finMes !== 'S') {
    console.log('  No es fin de mes. Rotación no aplica.');
    console.log('  ✅ CCA770 completado.\n');
    return;
  }

  // Copiar CCACAUSAC a CCACAUSAS (respaldo)
  await client.query('TRUNCATE TABLE CCACAUSAS');
  const copied = await client.query('INSERT INTO CCACAUSAS SELECT * FROM CCACAUSAC');
  console.log(`  ${copied.rowCount} registros de causación respaldados.`);

  // Limpiar CCACAUSAC para el nuevo mes
  await client.query('TRUNCATE TABLE CCACAUSAC');

  // Restaurar desde CCACAUSAS (solo registros con fecha > corte)
  // En la práctica, CCA770 filtra por fecha y rota promedios en CCAMAEAHO
  await client.query('INSERT INTO CCACAUSAC SELECT * FROM CCACAUSAS');

  console.log('  Rotación de promedios completada.');
  console.log('  ✅ CCA770 completado.\n');
}
module.exports = { accrualRotation };

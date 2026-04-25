/**
 * step29_backups.js
 * ═════════════════
 * Equivalente a: CCACOPIAS 1-4 (Líneas 1447-1494 del CCACIERRE.CLP)
 * 
 * Función: Realiza respaldos de contabilidad, históricos y snapshot del maestro.
 *          Usa ON CONFLICT o DELETE para evitar errores de llave duplicada.
 */
async function backups(client) {
  console.log('═══ PASO 29: CCACOPIAS - Respaldos Diarios ═══');

  // CCACOPIAS1: PLTTRNCCA → PLTTRNCCAH (histórico contable)
  // Limpiar registros del día si ya existen (para permitir re-ejecución)
  const fechaRes = await client.query('SELECT fecpro FROM PLTFECHAS WHERE codsis = 11 LIMIT 1');
  const fec = fechaRes.rows[0].fecpro;

  await client.query('DELETE FROM PLTTRNCCAH WHERE fecpro = $1', [fec]);
  const cop1 = await client.query('INSERT INTO PLTTRNCCAH SELECT * FROM PLTTRNCCA');
  console.log(`  COPIAS1: ${cop1.rowCount} registros contables → PLTTRNCCAH.`);

  // CCACOPIAS2: CCAHISTMP → CCAHISTOR (histórico movimientos)
  await client.query('DELETE FROM CCAHISTOR WHERE forige = $1', [fec]);
  const cop2 = await client.query('INSERT INTO CCAHISTOR SELECT * FROM CCAHISTMP');
  console.log(`  COPIAS2: ${cop2.rowCount} movimientos → CCAHISTOR.`);

  // CCACOPIAS3: CCADIFTMP → CCAHISDIF (histórico diferidos)
  await client.query('DELETE FROM CCAHISDIF WHERE forige = $1', [fec]);
  const cop3 = await client.query('INSERT INTO CCAHISDIF SELECT * FROM CCADIFTMP');
  console.log(`  COPIAS3: ${cop3.rowCount} diferidos → CCAHISDIF.`);

  // CCACOPIAS4: Snapshot diario del maestro
  const mesdia = String(fec).slice(4); // mmdd
  const tableName = `ccamae${mesdia}`;

  try {
    // Para evitar abortar la transacción si falla CREATE TABLE, usamos un bloque anidado si fuera necesario,
    // pero aquí simplemente verificamos existencia antes o usamos IF NOT EXISTS.
    await client.query(`DROP TABLE IF EXISTS ${tableName}`);
    await client.query(`CREATE TABLE ${tableName} AS SELECT * FROM CCAMAEAHO`);
    console.log(`  COPIAS4: Snapshot ${tableName} creado.`);
  } catch (e) {
    console.log(`  COPIAS4: Error creando snapshot ${tableName}: ${e.message}`);
    // No lanzamos el error para no abortar el cierre por un backup fallido (opcional)
  }

  console.log('  ✅ CCACOPIAS completado.\n');
}
module.exports = { backups };

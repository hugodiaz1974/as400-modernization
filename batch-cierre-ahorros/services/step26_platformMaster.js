/**
 * step26_platformMaster.js
 * ════════════════════════
 * Equivalente a: CCA760/CCA765 (Líneas 1285-1320 del CCACIERRE.CLP)
 */
async function platformMaster(client) {
  console.log('═══ PASO 26: CCA760/765 - Maestro Plataforma Caja ═══');

  // CCA760: Crear maestro en línea (CCADEPMAE) desde CCAMAEAHO
  await client.query('TRUNCATE TABLE CCADEPMAE');
  const result = await client.query(`
    INSERT INTO CCADEPMAE (codmon, codsis, codpro, agccta, ctanro, nitcta,
      descri, salact, salcon, dep24, dep48, dep72, indblo, indbaj)
    SELECT codmon, codsis, codpro, agccta, ctanro, nitcta,
      descri, salact, salcon, dep24, dep48, dep72, indblo, COALESCE(indbaj, 0)
    FROM CCAMAEAHO WHERE COALESCE(indbaj, 0) = 0
  `);
  console.log(`  CCA760: ${result.rowCount} cuentas copiadas a CCADEPMAE.`);

  // CCA765: Depurar CCADEPMAE por cuentas cerradas (CCANOVCIE)
  const cerradas = await client.query('SELECT COUNT(*) as cnt FROM CCANOVCIE');
  if (parseInt(cerradas.rows[0].cnt) > 0) {
    const deleted = await client.query(`
      DELETE FROM CCADEPMAE WHERE ctanro IN (SELECT DISTINCT ctanro FROM CCANOVCIE)
    `);
    console.log(`  CCA765: ${deleted.rowCount} cuentas cerradas eliminadas de CCADEPMAE.`);
  } else {
    console.log('  CCA765: No hay cuentas cerradas para depurar.');
  }

  console.log('  ✅ CCA760/765 completado.\n');
}
module.exports = { platformMaster };

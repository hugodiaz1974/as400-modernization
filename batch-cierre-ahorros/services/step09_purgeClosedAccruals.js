/**
 * step09_purgeClosedAccruals.js
 * ═════════════════════════════
 * Equivalente a: CCA545.CBL (Línea 407 del CCACIERRE.CLP)
 * 
 * Función: Depura el archivo de causaciones (CCACAUSAC) eliminando
 *          los registros de cuentas que fueron cerradas hoy.
 *          Las cuentas cerradas vienen en CCANOVCIE (novedades con CODNOV=2).
 * 
 * Lógica CLP (líneas 393-409):
 *   1. Copia de CCANOMON a CCANOVCIE solo registros con CODNOV=2
 *   2. Si hay registros, llama CCA545 que elimina de CCACAUSAC
 */

async function purgeClosedAccruals(client) {
  console.log('═══ PASO 9: CCA545 - Depurar Causaciones Ctas Cerradas ═══');

  // Paso 1: Copiar de CCANOMON a CCANOVCIE los registros con CODNOV=2 (cierre)
  await client.query('TRUNCATE TABLE CCANOVCIE');
  const copied = await client.query(`
    INSERT INTO CCANOVCIE SELECT * FROM CCANOMON WHERE codnov = 2
  `);

  const cuentasCerradas = copied.rowCount;

  if (cuentasCerradas === 0) {
    console.log('  No hay cuentas cerradas hoy. Nada que depurar.');
    console.log('  ✅ CCA545 completado.\n');
    return;
  }

  // Paso 2: Eliminar de CCACAUSAC las cuentas que están en CCANOVCIE
  const deleted = await client.query(`
    DELETE FROM CCACAUSAC
    WHERE ctanro IN (SELECT DISTINCT ctanro FROM CCANOVCIE)
  `);

  console.log(`  Cuentas cerradas encontradas: ${cuentasCerradas}`);
  console.log(`  Causaciones eliminadas: ${deleted.rowCount}`);
  console.log('  ✅ CCA545 completado.\n');
}

module.exports = { purgeClosedAccruals };

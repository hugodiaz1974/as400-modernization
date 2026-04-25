/**
 * step21_inactivateAccounts.js
 * ════════════════════════════
 * Equivalente a: CCA660.CBL (Línea 953 del CCACIERRE.CLP)
 * 
 * Función: Inactivación automática de cuentas sin movimiento
 *          por un período prolongado. Marca indbaj en CCAMAEAHO.
 */

async function inactivateAccounts(client) {
  console.log('═══ PASO 21: CCA660 - Inactivación Automática ═══');

  const fechaRes = await client.query('SELECT fecpro FROM PLTFECHAS WHERE codsis = 11 LIMIT 1');
  const fechaProceso = fechaRes.rows[0].fecpro;

  // Inactivar cuentas con saldo 0 y sin movimiento en los últimos 180 días
  const limiteInactividad = fechaProceso - 600; // ~6 meses aprox en formato YYYYMMDD

  const result = await client.query(`
    UPDATE CCAMAEAHO SET indina = 1
    WHERE COALESCE(indbaj, 0) = 0
      AND salact = 0
      AND COALESCE(fulmov, 0) < $1
      AND COALESCE(indina, 0) = 0
  `, [limiteInactividad]);

  console.log(`  Cuentas inactivadas: ${result.rowCount}`);
  console.log('  ✅ CCA660 completado.\n');
}

module.exports = { inactivateAccounts };

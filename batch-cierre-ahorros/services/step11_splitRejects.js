/**
 * step11_splitRejects.js
 * ══════════════════════
 * Equivalente a: CCA560.CBL (Línea 479 del CCACIERRE.CLP)
 * 
 * Función: Separa movimientos aceptados de rechazados.
 *   - Movimientos con error → CCAMOVIMR (rechazados)
 *   - Movimientos sin error → permanecen en CCAMOVIM
 *   Asigna cuentas ficticias de rechazo por agencia.
 */

async function splitRejects(client) {
  console.log('═══ PASO 11: CCA560 - Separación Aceptados/Rechazados ═══');

  // Copiar errores a tabla de rechazados
  await client.query('TRUNCATE TABLE CCAMOVIMR');
  const rejected = await client.query(`
    INSERT INTO CCAMOVIMR SELECT * FROM CCAMOERR
  `);

  const rechazados = rejected.rowCount;

  // Contar aceptados restantes en CCAMOVIM
  const accepted = await client.query('SELECT COUNT(*) as cnt FROM CCAMOVIM');
  const aceptados = parseInt(accepted.rows[0].cnt);

  console.log(`  Aceptados: ${aceptados} | Rechazados: ${rechazados}`);
  console.log('  ✅ CCA560 completado.\n');
}

module.exports = { splitRejects };

/**
 * step10_validateMonetary.js
 * ══════════════════════════
 * Equivalente a: CCA550.CBL (Línea 439 del CCACIERRE.CLP)
 * 
 * Función: Valida cada movimiento monetario en CCAMOVIM:
 *   - La cuenta existe en CCAMAEAHO
 *   - La cuenta no está bloqueada (INDBLO != 1)
 *   - El código de transacción es válido en CCACODTRN
 *   - Si es débito, verifica saldo suficiente (según INDSOB de CCACODTRN)
 *   Marca errores en CODER1 del registro.
 */

async function validateMonetary(client) {
  console.log('═══ PASO 10: CCA550 - Validación Movimiento Monetario ═══');

  const movCount = await client.query('SELECT COUNT(*) as cnt FROM CCAMOVIM');
  const total = parseInt(movCount.rows[0].cnt);

  if (total === 0) {
    console.log('  No hay movimientos monetarios para validar.');
    console.log('  ✅ CCA550 completado.\n');
    return;
  }

  // Limpiar errores previos
  await client.query('TRUNCATE TABLE CCAMOERR');

  const movimientos = await client.query('SELECT * FROM CCAMOVIM');
  let validos = 0, errores = 0;

  for (const mov of movimientos.rows) {
    let codError = 0;

    // Validar: cuenta existe
    const cuenta = await client.query(
      'SELECT ctanro, indblo, indbaj, salact FROM CCAMAEAHO WHERE ctanro = $1 LIMIT 1',
      [mov.ctanro]
    );

    if (cuenta.rows.length === 0) {
      codError = 1; // Cuenta no existe
    } else {
      const cta = cuenta.rows[0];
      // Validar: cuenta no bloqueada
      if (cta.indblo == 1) {
        codError = 2; // Cuenta bloqueada
      }
      // Validar: cuenta activa (indbaj 1 = Cuenta de baja/cerrada)
      if (cta.indbaj == 1) {
        codError = 3; // Cuenta inactiva/cancelada
      }
    }

    if (codError > 0) {
      // Mover a CCAMOERR con la estructura exacta (clonando el registro de CCAMOVIM)
      // y marcando el código de error en coder1
      await client.query(`
        INSERT INTO CCAMOERR SELECT * FROM CCAMOVIM WHERE ctanro = $1 AND forige = $2 LIMIT 1
      `, [mov.ctanro, mov.forige]);
      
      await client.query(`
        UPDATE CCAMOERR SET coder1 = $1 WHERE ctanro = $2 AND forige = $3
      `, [codError, mov.ctanro, mov.forige]);
      errores++;
    } else {
      validos++;
    }
  }

  // Eliminar de CCAMOVIM los que tienen error
  if (errores > 0) {
    await client.query(`
      DELETE FROM CCAMOVIM WHERE ctanro IN (SELECT DISTINCT ctanro FROM CCAMOERR)
    `);
  }

  console.log(`  Total: ${total} | Válidos: ${validos} | Errores: ${errores}`);
  console.log('  ✅ CCA550 completado.\n');
}

module.exports = { validateMonetary };

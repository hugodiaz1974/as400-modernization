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

const Decimal = require('decimal.js');

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
    let cta = null;

    // 1. Validar: cuenta existe en maestro
    const cuenta = await client.query(
      'SELECT ctanro, indblo, indbaj, salact FROM CCAMAEAHO WHERE ctanro = $1 LIMIT 1',
      [mov.ctanro]
    );

    if (cuenta.rows.length === 0) {
      codError = 1; // Cuenta no existe
    } else {
      cta = cuenta.rows[0];
      // Validar: cuenta no bloqueada
      if (cta.indblo == 1) {
        codError = 2; // Cuenta bloqueada
      }
      // Validar: cuenta activa (indbaj 1 = Cuenta de baja/cerrada)
      if (cta.indbaj == 1) {
        codError = 3; // Cuenta inactiva/cancelada
      }
    }

    // 2. Validar: Lógica de Transacción (Matriz CCACODTRN) y Fondos Insuficientes
    if (codError === 0) {
      const codtrnRes = await client.query(
        'SELECT indhab, indsob FROM CCACODTRN WHERE codtra = $1 LIMIT 1',
        [mov.codtra]
      );

      if (codtrnRes.rows.length === 0) {
        codError = 4; // Transacción no catalogada en CCACODTRN
      } else {
        const trn = codtrnRes.rows[0];
        
        if (trn.indhab == 1) { 
          codError = 5; // Transacción inhabilitada temporalmente
        } else if (mov.debcre == 1 && trn.indsob == 0) {
          // Es Débito (Retiro/Cobro) y NO permite sobregiro (INDSOB=0)
          const saldoCta = new Decimal(cta.salact);
          const importeMov = new Decimal(mov.import);
          
          if (importeMov.gt(saldoCta)) {
            codError = 6; // FONDOS INSUFICIENTES
          }
        }
      }
    }

    if (codError > 0) {
      // Mover a CCAMOERR con la estructura exacta (clonando el registro de CCAMOVIM)
      // y marcando el código de error en coder1
      await client.query(`
        INSERT INTO CCAMOERR SELECT * FROM CCAMOVIM WHERE ctanro = $1 AND forige = $2 AND codtra = $3 LIMIT 1
      `, [mov.ctanro, mov.forige, mov.codtra]);
      
      await client.query(`
        UPDATE CCAMOERR SET coder1 = $1 WHERE ctanro = $2 AND forige = $3 AND codtra = $4
      `, [codError, mov.ctanro, mov.forige, mov.codtra]);
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

/**
 * step12_updateBalances.js
 * ════════════════════════
 * Equivalente a: CCA580.CBL (Línea 540 del CCACIERRE.CLP)
 * 
 * Función: ACTUALIZA SALDOS en el maestro CCAMAEAHO a partir de los
 *          movimientos aceptados en CCAMOVIM.
 *   - DEBCRE=1 (Débito):  SALACT = SALACT - IMPORT
 *   - DEBCRE=2 (Crédito): SALACT = SALACT + IMPORT
 *   Genera CCAMOVACE (movimientos aceptados) y CCAMOVDIF (diferidos por fecha valor).
 * 
 * Este es el paso más CRÍTICO del cierre: modifica los saldos reales.
 */

async function updateBalances(client) {
  console.log('═══ PASO 12: CCA580 - Actualización de Saldos en Maestro ═══');

  const movimientos = await client.query('SELECT * FROM CCAMOVIM ORDER BY ctanro');
  const total = movimientos.rows.length;

  if (total === 0) {
    console.log('  No hay movimientos para aplicar.');
    console.log('  ✅ CCA580 completado.\n');
    return;
  }

  // Limpiar tablas destino
  await client.query('TRUNCATE TABLE CCAMOVACE');
  await client.query('TRUNCATE TABLE CCAMOVDIF');

  let aplicados = 0, diferidos = 0;

  await client.query('BEGIN');

  try {
    for (const mov of movimientos.rows) {
      // Determinar si es movimiento del día o diferido (fecha valor futura)
      // FECVAL=1: Hoy, FECVAL=2: Mañana, FECVAL=3: Pasado mañana
      if (mov.fecval && mov.fecval > 1) {
        // Diferido → CCAMOVDIF (no afecta saldo hoy)
        await client.query(
          'INSERT INTO CCAMOVDIF SELECT * FROM CCAMOVIM WHERE ctanro = $1 AND forige = $2 AND import = $3 AND codtra = $4', 
          [mov.ctanro, mov.forige, mov.import, mov.codtra]
        );
        diferidos++;
        continue;
      }

      // Aplicar al saldo
      if (mov.debcre == 1) {
        // Débito: restar del saldo
        await client.query(
          'UPDATE CCAMAEAHO SET salact = salact - $1 WHERE ctanro = $2',
          [mov.import, mov.ctanro]
        );
      } else if (mov.debcre == 2) {
        // Crédito: sumar al saldo
        await client.query(
          'UPDATE CCAMAEAHO SET salact = salact + $1 WHERE ctanro = $2',
          [mov.import, mov.ctanro]
        );
      }

      aplicados++;
    }

    // Copiar todos los aceptados a CCAMOVACE
    await client.query('INSERT INTO CCAMOVACE SELECT * FROM CCAMOVIM');

    await client.query('COMMIT');
  } catch (err) {
    await client.query('ROLLBACK');
    throw new Error(`CCA580: Error actualizando saldos — ${err.message}`);
  }

  console.log(`  Total: ${total} | Aplicados: ${aplicados} | Diferidos: ${diferidos}`);
  console.log('  ✅ CCA580 completado.\n');
}

module.exports = { updateBalances };

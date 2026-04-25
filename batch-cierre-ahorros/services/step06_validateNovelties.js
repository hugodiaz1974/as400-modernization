/**
 * step06_validateNovelties.js
 * ═══════════════════════════
 * Equivalente a: CCA530.CBL (Línea 332 del CCACIERRE.CLP)
 * 
 * Función: Valida novedades no monetarias (CCANOMON) contra el maestro
 *          (CCAMAEAHO). Cada novedad se verifica:
 *            - La cuenta existe en el maestro
 *            - La agencia es válida
 *            - El código de novedad es válido
 *          Resultados se escriben en CCANOVAPL.
 */

async function validateNovelties(client) {
  console.log('═══ PASO 6: CCA530 - Validación Novedades No Monetarias ═══');

  const count = await client.query('SELECT COUNT(*) as cnt FROM CCANOMON');
  const total = parseInt(count.rows[0].cnt);

  if (total === 0) {
    console.log('  No hay novedades no monetarias para procesar.');
    console.log('  ✅ CCA530 completado (sin novedades).\n');
    return;
  }

  // Limpiar tabla de resultados
  await client.query('TRUNCATE TABLE CCANOVAPL');

  // Validar cada novedad contra el maestro
  const novedades = await client.query('SELECT * FROM CCANOMON');
  let aplicadas = 0, rechazadas = 0;

  for (const nov of novedades.rows) {
    const cuenta = await client.query(
      'SELECT ctanro, indest FROM CCAMAEAHO WHERE ctanro = $1 LIMIT 1',
      [nov.ctanro]
    );

    let indres = 1; // 1 = aplicada
    let rechaz = '';

    if (cuenta.rows.length === 0) {
      indres = 0;
      rechaz = 'Cuenta no existe en maestro';
      rechazadas++;
    } else {
      // Validar: código de novedad existe en catálogo
      const codnovCheck = await client.query('SELECT 1 FROM CCATABNOV WHERE codnov = $1 LIMIT 1', [nov.codnov]);
      if (codnovCheck.rows.length === 0) {
        indres = 0;
        rechaz = 'Código de novedad inválido';
        rechazadas++;
      } else {
        // Validar: agencia existe
        const agcCheck = await client.query('SELECT 1 FROM PLTAGENCI WHERE codagc = $1 LIMIT 1', [nov.agccta]);
        if (agcCheck.rows.length === 0) {
          indres = 0;
          rechaz = 'Agencia origen inválida';
          rechazadas++;
        } else {
          aplicadas++;
        }
      }
    }

    await client.query(`
      INSERT INTO CCANOVAPL (codmon, codsis, codpro, agccta, ctanro, horpro, codnov, indres, estmae, vennov, rechaz)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
    `, [nov.codmon, nov.codsis, nov.codpro, nov.agccta, nov.ctanro, nov.horpro, nov.codnov, indres, '', '', rechaz]);
  }

  console.log(`  Procesadas: ${total} | Aplicadas: ${aplicadas} | Rechazadas: ${rechazadas}`);
  console.log('  ✅ CCA530 completado.\n');
}

module.exports = { validateNovelties };

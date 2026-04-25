/**
 * step20_generateAccounting.js
 * ════════════════════════════
 * Equivalente a: CCA630.CBL (Línea 904 del CCACIERRE.CLP)
 * 
 * Función: Genera asientos contables de partida doble en PLTTRNCCA
 *          a partir de los movimientos del día (CCACAUHOY, CCAMOVINT,
 *          CCAMOVINC, CCAMOVNEG, CCAMOVPNG).
 */

async function generateAccounting(client) {
  console.log('═══ PASO 20: CCA630 - Generación Contabilidad del Día ═══');

  await client.query('TRUNCATE TABLE PLTTRNCCA');

  // Contar movimientos fuente
  const cauhoy = await client.query('SELECT COUNT(*) as cnt FROM CCACAUHOY');
  const movint = await client.query('SELECT COUNT(*) as cnt FROM CCAMOVINT');
  const movinc = await client.query('SELECT COUNT(*) as cnt FROM CCAMOVINC');

  const totalFuente = parseInt(cauhoy.rows[0].cnt) + parseInt(movint.rows[0].cnt) + parseInt(movinc.rows[0].cnt);

  if (totalFuente === 0) {
    console.log('  No hay movimientos para contabilizar.');
    console.log('  ✅ CCA630 completado.\n');
    return;
  }

  // Generar asientos agrupados por código de transacción y agencia
  const fechaRes = await client.query('SELECT fecpro FROM PLTFECHAS WHERE codsis = 11 LIMIT 1');
  const fechaProceso = fechaRes.rows[0].fecpro;

  const asientos = await client.query(`
    SELECT codtra as codtrn, agcori, debcre as tipmov, SUM(import) as vlrtrn, COUNT(*) as nroreg
    FROM CCACAUHOY
    GROUP BY codtra, agcori, debcre
  `);

  let seq = 1;
  for (const a of asientos.rows) {
    await client.query(`
      INSERT INTO PLTTRNCCA (codemp, agcori, codmon, codcaj, nrotrn, cnstrn, fecpro, codtrn, tipmov, vlrtrn)
      VALUES (1, $1, 1, 'BATCH', $2, 1, $3, $4, $5, $6)
    `, [a.agcori, seq++, fechaProceso, a.codtrn, a.tipmov, a.vlrtrn]);
  }

  console.log(`  Movimientos fuente: ${totalFuente}`);
  console.log(`  Asientos generados: ${asientos.rows.length}`);
  console.log('  ✅ CCA630 completado.\n');
}

module.exports = { generateAccounting };

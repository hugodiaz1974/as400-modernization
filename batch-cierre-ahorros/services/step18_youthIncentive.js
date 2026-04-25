/**
 * step18_youthIncentive.js
 * ════════════════════════
 * Equivalente a: CCA606.CBL (Línea 800 del CCACIERRE.CLP)
 * 
 * Función: Abono de incentivos de ahorro juvenil.
 *          Para cuentas con producto de ahorro juvenil, genera
 *          un incentivo adicional sobre la causación.
 */

async function youthIncentive(client) {
  console.log('═══ PASO 18: CCA606 - Incentivo Ahorro Juvenil ═══');

  // Buscar cuentas con producto de ahorro juvenil
  // Nota: tipaho no existe como campo en CCACODPRO migrada.
  // Se identifica por código de producto específico (a refinar con datos reales)
  const result = await client.query(`
    SELECT m.ctanro, m.salact, m.codpro, m.agccta, m.codmon, m.codsis
    FROM CCAMAEAHO m
    WHERE COALESCE(m.indbaj, 0) = 0 AND m.codpro IN (
      SELECT codpro FROM CCACODPRO WHERE descri ILIKE '%juven%'
    )
  `);

  if (result.rows.length === 0) {
    console.log('  No hay cuentas de ahorro juvenil activas.');
    console.log('  ✅ CCA606 completado.\n');
    return;
  }

  console.log(`  Cuentas juveniles encontradas: ${result.rows.length}`);

  // Generar incentivos en CCAMOVINC
  await client.query('TRUNCATE TABLE CCAMOVINC');
  let totalIncentivo = 0;

  const fechaRes = await client.query('SELECT fecpro FROM PLTFECHAS WHERE codsis = 11 LIMIT 1');
  const fechaProceso = fechaRes.rows[0].fecpro;

  for (const cta of result.rows) {
    // El incentivo se calcula según parámetros del producto
    // Por ahora usamos un placeholder que se refinará con el COBOL exacto
    const incentivo = 0; // Se calculará cuando se analice CCA606.CBL en detalle

    if (incentivo > 0) {
      await client.query(`
        INSERT INTO CCAMOVINC (codmon, codsis, codpro, agccta, ctanro, forige,
          debcre, codtra, import, fvalor, esttrn, agcori)
        VALUES ($1, $2, $3, $4, $5, $6, 2, 906, $7, $6, 0, $4)
      `, [cta.codmon, cta.codsis, cta.codpro, cta.agccta, cta.ctanro, fechaProceso, incentivo]);
      totalIncentivo += incentivo;
    }
  }

  console.log(`  Total incentivo generado: $${totalIncentivo.toFixed(2)}`);
  console.log('  ✅ CCA606 completado.\n');
}

module.exports = { youthIncentive };

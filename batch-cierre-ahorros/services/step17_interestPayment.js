/**
 * step17_interestPayment.js
 * ═════════════════════════
 * Equivalente a: CCA602.CBL (Líneas 716-752 del CCACIERRE.CLP)
 * 
 * Función: ABONO DE INTERESES según modalidad:
 *   - Diario(1):     Abona interés causado a cuentas con tipliq=1
 *   - Mensual(2):    Abona interés acumulado del mes (solo si finMes='S')
 *   - Trimestral(3): Abona interés acumulado del trimestre (solo si finTri='S')
 * 
 * Campos reales:
 *   CCACODPRO.tipliq: 1=diario, 2=mensual, 3=trimestral (numérico)
 *   CCACAUSAC.valcau: valor causación acumulada
 */

async function interestPayment(client, finMes = 'N', finTrimestre = 'N') {
  console.log('═══ PASO 17: CCA602 - Abono de Intereses ═══');

  const fechaRes = await client.query('SELECT fecpro FROM PLTFECHAS WHERE codsis = 11 LIMIT 1');
  const fechaProceso = fechaRes.rows[0].fecpro;

  // Diario (tipliq = 1)
  const abonosDiarios = await abonarIntereses(client, 1, fechaProceso);
  console.log(`  [Diario]     Cuentas abonadas: ${abonosDiarios}`);

  // Mensual (tipliq = 2)
  if (finMes === 'S') {
    const abonosMensuales = await abonarIntereses(client, 2, fechaProceso);
    console.log(`  [Mensual]    Cuentas abonadas: ${abonosMensuales}`);
  } else {
    console.log('  [Mensual]    No aplica (no es fin de mes).');
  }

  // Trimestral (tipliq = 3)
  if (finTrimestre === 'S') {
    const abonosTrimestrales = await abonarIntereses(client, 3, fechaProceso);
    console.log(`  [Trimestral] Cuentas abonadas: ${abonosTrimestrales}`);
  } else {
    console.log('  [Trimestral] No aplica (no es fin de trimestre).');
  }

  console.log('  ✅ CCA602 completado.\n');
}

async function abonarIntereses(client, tipliq, fechaProceso) {
  // 1. Abonar al saldo del maestro (Bulk UPDATE)
  const updateRes = await client.query(`
    UPDATE CCAMAEAHO m
    SET salact = m.salact + c.valcau
    FROM CCACAUSAC c
    INNER JOIN CCACODPRO p ON c.codpro = p.codpro
    WHERE m.ctanro = c.ctanro 
    AND c.valcau > 0 
    AND p.tipliq = $1
  `, [tipliq]);

  const abonados = updateRes.rowCount;

  if (abonados > 0) {
    // 2. Generar movimiento de interés en CCACAUHOY (Bulk INSERT)
    await client.query(`
      INSERT INTO CCACAUHOY (codmon, codsis, codpro, agccta, ctanro, forige,
        debcre, codtra, import, fvalor, esttrn, agcori, codcaj, usring, nrotrn, cnstrn, hortrn)
      SELECT c.codmon, c.codsis, c.codpro, c.agccta, c.ctanro, $1,
        2, 901, c.valcau, $1, 0, c.agccta, 'BATCH', 'SISBATCH', 0, 1, 235959
      FROM CCACAUSAC c
      INNER JOIN CCACODPRO p ON c.codpro = p.codpro
      WHERE c.valcau > 0 AND p.tipliq = $2
    `, [fechaProceso, tipliq]);

    // 3. Resetear causación (Bulk UPDATE)
    await client.query(`
      UPDATE CCACAUSAC c
      SET valcau = 0
      FROM CCACODPRO p
      WHERE c.codpro = p.codpro
      AND c.valcau > 0 AND p.tipliq = $1
    `, [tipliq]);
  }

  return abonados;
}

module.exports = { interestPayment };

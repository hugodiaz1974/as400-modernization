const Decimal = require('decimal.js');
const { calcularInteresDiario } = require('../utils/interestCalculator');
const { calcularTarifa } = require('../utils/feeCalculator');

async function dailyAccrual(client) {
  console.log('═══ PASO 15: CCA601 - Causación Diaria de Intereses y Tarifas ═══');

  // A. SIMULAR CLRPFM (Idempotencia): Limpiar tabla de movimientos del día
  await client.query('TRUNCATE TABLE CCACAUHOY');

  // 1. Cargar Parámetros Globales (CCAPARGEN)
  const parRes = await client.query('SELECT tracau FROM CCAPARGEN LIMIT 1');
  const tracau = parRes.rows[0]?.tracau || 1; // Código de sistema para causación

  // 2. Obtener fecha de proceso
  const fechaRes = await client.query('SELECT fecpro FROM PLTFECHAS WHERE codsis = 11 LIMIT 1');
  const fechaProceso = fechaRes.rows[0].fecpro;

  // 3. Cargar Mapeo de Transacciones y Tarifas (CCATRAPRO)
  const traproRes = await client.query('SELECT * FROM CCATRAPRO WHERE codpro = $1', [tracau]);
  const traproMap = {};
  for (const tp of traproRes.rows) {
    if (!traproMap[tp.produc]) traproMap[tp.produc] = [];
    traproMap[tp.produc].push(tp);
  }

  // 4. Cargar Planes de Interés y Tasas
  const productosRes = await client.query('SELECT codpro, plnint FROM CCACODPRO');
  const planMap = Object.fromEntries(productosRes.rows.map(p => [p.codpro, p.plnint]));

  const tasasRes = await client.query('SELECT codtas, vlrtas FROM CCACODTAS');
  const tasaMap = Object.fromEntries(tasasRes.rows.map(t => [t.codtas, t.vlrtas]));

  // 5. Procesar Cuentas Activas
  // Se lee el saldo como texto y se manejará con precisión (evitando parseFloat global)
  const cuentas = await client.query(
    'SELECT ctanro, codpro, salact, agccta, codmon, codsis FROM CCAMAEAHO WHERE COALESCE(indbaj, 0) = 0'
  );

  let totalCausado = new Decimal(0);
  let totalTarifas = new Decimal(0);
  let cuentasProcesadas = 0;

  for (const cta of cuentas.rows) {
    const planInt = planMap[cta.codpro] || 0;
    const tasa = tasaMap[planInt] || 0;
    const saldo = cta.salact || 0; 

    // El cálculo ahora es 100% decimal dentro de la utilidad
    const interes = calcularInteresDiario(saldo, tasa, 1);
    if (interes.lte(0)) continue;

    // B. Registrar Causación Acumulada (CCACAUSAC)
    await client.query(`
      INSERT INTO CCACAUSAC (codmon, codsis, codpro, agccta, ctanro, forige, salact, valcau, equefe)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      ON CONFLICT (codmon, codsis, codpro, agccta, ctanro, forige) DO UPDATE SET
        salact = $7,
        valcau = COALESCE(CCACAUSAC.valcau, 0) + $8,
        equefe = $9
    `, [cta.codmon, cta.codsis, cta.codpro, cta.agccta, cta.ctanro, fechaProceso, saldo, interes.toNumber(), tasa]);

    // C. Generar Movimientos Detallados (CCACAUHOY) basados en CCATRAPRO
    const configs = traproMap[cta.codpro] || [{ tradeb: 0, tracre: 900, tipval: 1, codtar: 0 }]; // Default fallback

    for (const conf of configs) {
      let valorFinal = interes;

      // Si tiene tarifa asociada (CCA491)
      if (conf.codtar > 0) {
        const tarifaCalculada = await calcularTarifa(client, conf.tipval, conf.codtar, interes);
        valorFinal = tarifaCalculada;
        totalTarifas = totalTarifas.add(valorFinal);
      }

      if (valorFinal.lte(0)) continue;

      // Movimiento Débito (si aplica)
      if (conf.tradeb > 0) {
        await client.query(`
          INSERT INTO CCACAUHOY (codmon, codsis, codpro, agccta, ctanro, forige, debcre, codtra, import, fvalor, esttrn, agcori)
          VALUES ($1, $2, $3, $4, $5, $6, 1, $7, $8, $6, 0, $4)
        `, [cta.codmon, cta.codsis, cta.codpro, cta.agccta, cta.ctanro, fechaProceso, conf.tradeb, valorFinal.toNumber()]);
      }

      // Movimiento Crédito (si aplica)
      if (conf.tracre > 0) {
        await client.query(`
          INSERT INTO CCACAUHOY (codmon, codsis, codpro, agccta, ctanro, forige, debcre, codtra, import, fvalor, esttrn, agcori)
          VALUES ($1, $2, $3, $4, $5, $6, 2, $7, $8, $6, 0, $4)
        `, [cta.codmon, cta.codsis, cta.codpro, cta.agccta, cta.ctanro, fechaProceso, conf.tracre, valorFinal.toNumber()]);
      }
    }

    totalCausado = totalCausado.add(interes);
    cuentasProcesadas++;
  }

  console.log(`  Cuentas procesadas: ${cuentasProcesadas}`);
  console.log(`  Total interés causado: $${totalCausado.toFixed(2)}`);
  console.log(`  Total comisiones/impuestos: $${totalTarifas.toFixed(2)}`);
  console.log('  ✅ CCA601 completado.\n');
}

module.exports = { dailyAccrual };

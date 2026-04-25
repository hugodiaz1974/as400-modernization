const pool = require('./config/database');
const checkpoint = require('./utils/checkpointManager');

// Importación de servicios (Pasos 00 a 30)
const step00 = require('./services/step00_verifyEnvironment');
const step01 = require('./services/step01_loadDates');
const step02 = require('./services/step02_clearWorkFiles');
const step03 = require('./services/step03_initAccumulators');
const step3_5 = require('./services/step03_5_copyOfflineMovements');
const step04 = require('./services/step04_consolidateInterfaces');
const step05 = require('./services/step05_interfaceReport');
const step06 = require('./services/step06_validateNovelties');
const step07 = require('./services/step07_noveltyReport');
const step08 = require('./services/step08_errorReport');
const step09 = require('./services/step09_purgeClosedAccruals');
const step10 = require('./services/step10_validateMonetary');
const step11 = require('./services/step11_splitRejects');
const step12 = require('./services/step12_updateBalances');
const step13 = require('./services/step13_rejectReport');
const step14 = require('./services/step14_backdateDetail');
const step15 = require('./services/step15_dailyAccrual');
const step16 = require('./services/step16_evaluateEndPeriod');
const step17 = require('./services/step17_interestPayment');
const step18 = require('./services/step18_youthIncentive');
const step19 = require('./services/step19_negativeBalance');
const step20 = require('./services/step20_generateAccounting');
const step21 = require('./services/step21_inactivateAccounts');
const step22 = require('./services/step22_inactiveAccounting');
const step23 = require('./services/step23_updateRemittances');
const step24 = require('./services/step24_trialBalance');
const step25 = require('./services/step25_archiveHistory');
const step26 = require('./services/step26_platformMaster');
const step27 = require('./services/step27_accrualRotation');
const step28 = require('./services/step28_treasuryTransfer');
const step29 = require('./services/step29_backups');
const step30 = require('./services/step30_dateProjection');

/**
 * Función auxiliar para ejecutar pasos con control de checkpoints
 */
async function runStep(client, codsis, fecpro, stepName, stepFunc, ...args) {
  // Obtener fecpro si no se proporciona (útil para el paso inicial)
  let targetFecpro = fecpro;
  if (!targetFecpro) {
    const res = await client.query("SELECT fecpro FROM pltfechas WHERE codsis = 11");
    targetFecpro = res.rows[0].fecpro;
  }

  if (await checkpoint.isStepCompleted(client, codsis, targetFecpro, stepName)) {
    console.log(`⏩ PASO SALTADO: ${stepName} ya fue completado previamente.`);
    return null;
  }

  try {
    await checkpoint.markStepRunning(client, codsis, targetFecpro, stepName);
    const result = await stepFunc(client, ...args);
    await checkpoint.markStepCompleted(client, codsis, targetFecpro, stepName);
    return result;
  } catch (err) {
    console.error(`  ❌ Error en paso ${stepName}:`, err.message);
    
    // Si la transacción está abortada, necesitamos una conexión limpia para grabar el error
    const loggingClient = await pool.connect();
    try {
      await checkpoint.markStepFailed(loggingClient, codsis, targetFecpro, stepName, err);
    } catch (checkpointErr) {
      console.error(`  ⚠️ No se pudo registrar el error en checkpoint: ${checkpointErr.message}`);
    } finally {
      loggingClient.release();
    }
    throw err;
  }
}

/**
 * Orquestador principal del Cierre de Ahorros con Sistema de Checkpoints.
 */
async function runBatch() {
  console.log('🚀 INICIANDO CIERRE BATCH DE AHORROS (Versión con Checkpoints)');
  const startTime = Date.now();
  const client = await pool.connect();

  try {
    // Paso 0: Verificación de Entorno y BLOQUEO EXCLUSIVO (Inicia Transacción)
    await client.query('BEGIN');
    const fecpro = await runStep(client, 11, null, 'step00_verifyEnvironment', step00.verifyEnvironment);

    // Los pasos se ejecutan secuencialmente
    await runStep(client, 11, fecpro, 'step01_loadDates', step01.loadDates);
    await runStep(client, 11, fecpro, 'step02_clearWorkFiles', step02.clearWorkFiles);
    await runStep(client, 11, fecpro, 'step03_initAccumulators', step03.initAccumulators);
    await runStep(client, 11, fecpro, 'step03_5_copyOfflineMovements', step3_5.copyOfflineMovements);
    await runStep(client, 11, fecpro, 'step04_consolidateInterfaces', step04.consolidateInterfaces);
    await runStep(client, 11, fecpro, 'step05_interfaceReport', step05.interfaceReport);
    await runStep(client, 11, fecpro, 'step06_validateNovelties', step06.validateNovelties);
    await runStep(client, 11, fecpro, 'step07_noveltyReport', step07.noveltyReport);
    await runStep(client, 11, fecpro, 'step08_errorReport', step08.errorReport);
    await runStep(client, 11, fecpro, 'step09_purgeClosedAccruals', step09.purgeClosedAccruals);
    await runStep(client, 11, fecpro, 'step10_validateMonetary', step10.validateMonetary);
    await runStep(client, 11, fecpro, 'step11_splitRejects', step11.splitRejects);
    await runStep(client, 11, fecpro, 'step12_updateBalances', step12.updateBalances);
    await runStep(client, 11, fecpro, 'step13_rejectReport', step13.rejectReport);
    await runStep(client, 11, fecpro, 'step14_backdateDetail', step14.backdateDetail);
    await runStep(client, 11, fecpro, 'step15_dailyAccrual', step15.dailyAccrual);
    
    const periodInfo = await runStep(client, 11, fecpro, 'step16_evaluateEndPeriod', step16.evaluateEndPeriod);
    const finMes = periodInfo ? periodInfo.finMes : 'N';
    const finTri = periodInfo ? periodInfo.finTrimestre : 'N';

    await runStep(client, 11, fecpro, 'step17_interestPayment', step17.interestPayment, finMes, finTri);
    await runStep(client, 11, fecpro, 'step18_youthIncentive', step18.youthIncentive);
    await runStep(client, 11, fecpro, 'step19_negativeBalance', step19.negativeBalance);
    await runStep(client, 11, fecpro, 'step20_generateAccounting', step20.generateAccounting);
    await runStep(client, 11, fecpro, 'step21_inactivateAccounts', step21.inactivateAccounts);
    await runStep(client, 11, fecpro, 'step22_inactiveAccounting', step22.inactiveAccounting);
    await runStep(client, 11, fecpro, 'step23_updateRemittances', step23.updateRemittances);
    await runStep(client, 11, fecpro, 'step24_trialBalance', step24.trialBalance);
    await runStep(client, 11, fecpro, 'step25_archiveHistory', step25.archiveHistory);
    await runStep(client, 11, fecpro, 'step26_platformMaster', step26.platformMaster);
    await runStep(client, 11, fecpro, 'step27_accrualRotation', step27.accrualRotation, finMes);
    await runStep(client, 11, fecpro, 'step28_treasuryTransfer', step28.treasuryTransfer);
    await runStep(client, 11, fecpro, 'step29_backups', step29.backups);
    await runStep(client, 11, fecpro, 'step30_dateProjection', step30.dateProjection);

    await client.query('COMMIT');
    
    const duration = ((Date.now() - startTime) / 1000).toFixed(2);
    console.log(`\n✅ CIERRE BATCH FINALIZADO EXITOSAMENTE en ${duration}s`);

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('\n❌ ERROR CRITICO DURANTE EL CIERRE:', error.message);
    process.exit(1);
  } finally {
    client.release();
  }
}

// Ejecución
if (require.main === module) {
  runBatch()
    .then(() => process.exit(0))
    .catch((err) => {
      console.error(err);
      process.exit(1);
    });
}

module.exports = { runBatch };

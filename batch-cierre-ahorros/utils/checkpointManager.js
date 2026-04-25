/**
 * checkpointManager.js
 * ═════════════════════
 * Equivalente a: CCAC085P (Control de Procesos)
 * 
 * Función: Gestiona la persistencia del estado de cada paso del cierre.
 * Permite que el proceso sea reanudable (Restartable) si falla.
 */

async function isStepCompleted(client, codsis, fecpro, paso) {
  const res = await client.query(
    'SELECT estado FROM PLTCHECKPOINT WHERE codsis = $1 AND fecpro = $2 AND paso = $3',
    [codsis, fecpro, paso]
  );
  return res.rows.length > 0 && res.rows[0].estado === 'COMPLETADO';
}

async function markStepRunning(client, codsis, fecpro, paso) {
  await client.query(`
    INSERT INTO PLTCHECKPOINT (codsis, fecpro, paso, estado)
    VALUES ($1, $2, $3, 'INICIADO')
    ON CONFLICT (codsis, fecpro, paso) DO UPDATE SET 
      estado = 'INICIADO', 
      fecact = CURRENT_TIMESTAMP
  `, [codsis, fecpro, paso]);
}

async function markStepCompleted(client, codsis, fecpro, paso) {
  await client.query(`
    UPDATE PLTCHECKPOINT SET estado = 'COMPLETADO', fecact = CURRENT_TIMESTAMP
    WHERE codsis = $1 AND fecpro = $2 AND paso = $3
  `, [codsis, fecpro, paso]);
}

async function markStepFailed(client, codsis, fecpro, paso, errorMsg) {
  await client.query(`
    UPDATE PLTCHECKPOINT SET estado = 'ERROR', fecact = CURRENT_TIMESTAMP
    WHERE codsis = $1 AND fecpro = $2 AND paso = $3
  `, [codsis, fecpro, paso]);
}

module.exports = {
  isStepCompleted,
  markStepRunning,
  markStepCompleted,
  markStepFailed
};

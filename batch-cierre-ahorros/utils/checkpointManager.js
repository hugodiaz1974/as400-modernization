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
  // Se usa INSERT ON CONFLICT porque si el orquestador hizo ROLLBACK, 
  // la fila "INICIADO" ya no existe para la conexión de logueo independiente.
  const errorText = errorMsg instanceof Error ? errorMsg.message : String(errorMsg);
  await client.query(`
    INSERT INTO PLTCHECKPOINT (codsis, fecpro, paso, estado, error)
    VALUES ($1, $2, $3, 'FALLIDO', $4)
    ON CONFLICT (codsis, fecpro, paso) DO UPDATE SET 
      estado = 'FALLIDO', 
      error = $4,
      fecact = CURRENT_TIMESTAMP
  `, [codsis, fecpro, paso, errorText.substring(0, 255)]); // Truncado por seguridad
}

module.exports = {
  isStepCompleted,
  markStepRunning,
  markStepCompleted,
  markStepFailed
};

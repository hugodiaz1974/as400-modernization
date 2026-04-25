/**
 * interestCalculator.js
 * ═════════════════════
 * Equivalente a: CCA492.CBL (Rutina interna del CCA601)
 * 
 * Función: Calcula el interés diario sobre un saldo.
 *   Fórmula: interés = saldo × (tasa_efectiva_anual / 360)
 *   
 *   En COBOL: W-TASA-DIARIA = W-TASA-ANUAL / 36000
 *             W-INTERES = W-SALDO * W-TASA-DIARIA
 */

const Decimal = require('decimal.js');

/**
 * Calcula el interés diario con precisión bancaria absoluta
 * @param {string|number} saldo - Saldo actual de la cuenta
 * @param {string|number} tasaAnual - Tasa efectiva anual (ej: 4.50 = 4.50%)
 * @param {number} dias - Número de días a causar (normalmente 1)
 * @returns {number} Interés calculado (redondeado a 2 decimales según COBOL ROUNDED)
 */
function calcularInteresDiario(saldo, tasaAnual, dias = 1) {
  const dSaldo = new Decimal(saldo);
  const dTasaAnual = new Decimal(tasaAnual);
  
  if (dSaldo.lte(0) || dTasaAnual.lte(0)) return 0;

  // Tasa diaria = tasa anual / 36000
  // Interés = saldo * tasaDiaria * dias
  const tasaDiaria = dTasaAnual.div(36000);
  const interes = dSaldo.mul(tasaDiaria).mul(dias);

  // Redondeo bancario a 2 decimales (ROUND_HALF_UP es el estándar de COBOL ROUNDED)
  return interes.toDecimalPlaces(2, Decimal.ROUND_HALF_UP);
}

module.exports = { calcularInteresDiario };

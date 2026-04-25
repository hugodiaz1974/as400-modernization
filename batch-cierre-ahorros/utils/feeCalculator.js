const Decimal = require('decimal.js');

async function calcularTarifa(client, tiptar, codtar, valorTra) {
  // Aseguramos que el valor de la transacción sea Decimal desde el inicio
  const dValorTra = new Decimal(valorTra);

  // 1. Buscar la configuración de la tarifa
  const res = await client.query(
    'SELECT * FROM CCATARIFAS WHERE tiptar = $1 AND codtar = $2',
    [tiptar, codtar]
  );

  if (res.rows.length === 0) {
    return new Decimal(0); 
  }

  const t = res.rows[0];
  let dPorcentaje = new Decimal(0);
  let dMinimo = new Decimal(0);
  let dMaximo = new Decimal(0);

  // Determinar el rango (bracket) usando comparaciones Decimal (.lte)
  if (dValorTra.lte(new Decimal(t.vlrha1 || 0))) {
    dPorcentaje = new Decimal(t.tasha1 || 0);
    dMinimo = new Decimal(t.vlmin1 || 0);
    dMaximo = new Decimal(t.vlmax1 || 0);
  } else if (dValorTra.lte(new Decimal(t.vlrha2 || 0))) {
    dPorcentaje = new Decimal(t.tasha2 || 0);
    dMinimo = new Decimal(t.vlmin2 || 0);
    dMaximo = new Decimal(t.vlmax2 || 0);
  } else if (dValorTra.lte(new Decimal(t.vlrha3 || 0))) {
    dPorcentaje = new Decimal(t.tasha3 || 0);
    dMinimo = new Decimal(t.vlmin3 || 0);
    dMaximo = new Decimal(t.vlmax3 || 0);
  } else if (dValorTra.lte(new Decimal(t.vlrha4 || 0))) {
    dPorcentaje = new Decimal(t.tasha4 || 0);
    dMinimo = new Decimal(t.vlmin4 || 0);
    dMaximo = new Decimal(t.vlmax4 || 0);
  } else {
    dPorcentaje = new Decimal(t.tasha5 || 0);
    dMinimo = new Decimal(t.vlmin5 || 0);
    dMaximo = new Decimal(t.vlmax5 || 0);
  }

  let dValorTarifa = new Decimal(0);

  // 2. Calcular según el tipo de tarifa
  if (tiptar == 1) {
    // Valor Fijo
    dValorTarifa = dPorcentaje;
  } else {
    // Valor Porcentual
    let dBase = new Decimal(1);
    switch (Number(t.expres)) {
      case 2: dBase = new Decimal(100); break;
      case 3: dBase = new Decimal(1000); break;
      default: dBase = new Decimal(1); break;
    }
    
    // Operación matemática 100% decimal
    dValorTarifa = dValorTra.mul(dPorcentaje).div(dBase);

    // Aplicar límites Min/Max si está activo
    if (t.minmax == 1) {
      if (dValorTarifa.lt(dMinimo)) dValorTarifa = dMinimo;
      if (dValorTarifa.gt(dMaximo)) dValorTarifa = dMaximo;
    }
  }

  // Retornamos el objeto Decimal redondeado a 2 decimales (Estándar Bancario)
  return dValorTarifa.toDecimalPlaces(2, Decimal.ROUND_HALF_UP);
}

module.exports = { calcularTarifa };

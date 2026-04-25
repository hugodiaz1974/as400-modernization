# Plan de Implementación — Cierre de Ahorros (CCACIERRE → Node.js)

Migración del proceso EOD desde `CCACIERRE.CLP` hacia Node.js + PostgreSQL.
El orden de ejecución respeta **exactamente** la secuencia del CLP original.

---

## 1. Estructura de Archivos

```
batch-cierre-ahorros/
├── orchestrator.js                     ← CCACIERRE.CLP
├── config/database.js
├── services/
│   ├── step01_loadDates.js             ← CCA500
│   ├── step02_clearWorkFiles.js        ← CLRPFM (CCAEXTRAC, CCACAUHOY)
│   ├── step03_initAccumulators.js      ← CCA513
│   ├── step04_consolidateInterfaces.js ← CCA510
│   ├── step05_interfaceReport.js       ← CCA520
│   ├── step06_validateNovelties.js     ← CCA530
│   ├── step07_noveltyReport.js         ← CCA540
│   ├── step08_errorReport.js           ← CCA565
│   ├── step09_purgeClosedAccruals.js   ← CCA545
│   ├── step10_validateMonetary.js      ← CCA550
│   ├── step11_splitRejects.js          ← CCA560
│   ├── step12_updateBalances.js        ← CCA580
│   ├── step13_rejectReport.js          ← CCA599
│   ├── step14_backdateDetail.js        ← CCA590
│   ├── step15_dailyAccrual.js          ← CCA601 (internamente llama CCA500,501,502,503)
│   ├── step16_evaluateEndPeriod.js     ← CCA502
│   ├── step17_interestPayment.js       ← CCA602 (diario/mensual/trimestral)
│   ├── step18_youthIncentive.js        ← CCA606
│   ├── step19_negativeBalance.js       ← CCA201, CCA205
│   ├── step20_generateAccounting.js    ← CCA630
│   ├── step21_inactivateAccounts.js    ← CCA660
│   ├── step22_inactiveAccounting.js    ← CCA661, CCA662, CCA664
│   ├── step23_updateRemittances.js     ← CCAACTREM
│   ├── step24_trialBalance.js          ← CCA671, CCA672
│   ├── step25_archiveHistory.js        ← CCA710, CCA711
│   ├── step26_platformMaster.js        ← CCA760, CCA765
│   ├── step27_accrualRotation.js       ← CCA770
│   ├── step28_treasuryTransfer.js      ← CCATRANSF
│   ├── step29_backups.js               ← CCACOPIAS 1-4
│   └── step30_dateProjection.js        ← CCA800
├── utils/
│   ├── checkpointManager.js            ← CCAC085P
│   ├── dateCalculator.js               ← PLT219
│   ├── interestCalculator.js           ← CCA492
│   ├── feeCalculator.js                ← CCA491
│   └── specialAccountResolver.js       ← CCA990
├── db/migrations/
└── seeders/
```

---

## 2. Secuencia Exacta (Orden del CCACIERRE.CLP)

| Paso | Línea CLP | AS/400 | Node.js | Función | Activo |
|------|-----------|--------|---------|---------|--------|
| 1 | 176 | `CCA500` | `step01_loadDates.js` | Carga fechas (ayer/hoy/mañana) de `PLTFECHAS` | ✅ |
| 2 | 187-191 | CLRPFM | `step02_clearWorkFiles.js` | Limpia `CCAEXTRAC` y `CCACAUHOY` | ✅ |
| 3 | 243 | `CCA513` | `step03_initAccumulators.js` | Inicializa acumuladores de `CCATABINT` | ✅ |
| 4 | 251 | `CCA510` | `step04_consolidateInterfaces.js` | Consolida interfaces batch → `CCAMOVIM` + `CCANOMON` | ✅ |
| 5 | 283-298 | `CCA520` | `step05_interfaceReport.js` | Reporte totales interfaces (x2: novedades y movimientos) | ✅ |
| 6 | 332 | `CCA530` | `step06_validateNovelties.js` | Valida novedades no monetarias contra maestro | ✅ |
| 7 | 359 | `CCA540` | `step07_noveltyReport.js` | Reporte novedades procesadas | ✅ |
| 8 | 377 | `CCA565` | `step08_errorReport.js` | Informe movimientos no aplicados | ✅ |
| 9 | 407 | `CCA545` | `step09_purgeClosedAccruals.js` | Depura causaciones de cuentas cerradas | ✅ |
| 10 | 439 | `CCA550` | `step10_validateMonetary.js` | Valida movimiento monetario | ✅ |
| 11 | 479 | `CCA560` | `step11_splitRejects.js` | Separa aceptados/rechazados → `CCAMOVIMR` | ✅ |
| 12 | 540 | `CCA580` | `step12_updateBalances.js` | **Actualiza saldos en maestro** `CCAMAEAHO` | ✅ |
| 13 | 567 | `CCA599` | `step13_rejectReport.js` | Reporte movimiento rechazado | ✅ |
| 14 | 603 | `CCA590` | `step14_backdateDetail.js` | Genera detalle retrofechas | ✅ |
| 15 | 648 | `CCA601` | `step15_dailyAccrual.js` | **Causación diaria** (internamente: CCA500,501,502,503,492) | ✅ |
| 16 | 690 | `CCA502` | `step16_evaluateEndPeriod.js` | Evalúa fin de mes / fin de trimestre | ✅ |
| 17 | 716-752 | `CCA602` | `step17_interestPayment.js` | **Abono intereses** (diario→mensual→trimestral) | ✅ |
| 18 | 800 | `CCA606` | `step18_youthIncentive.js` | Abono incentivo ahorro juvenil | ✅ |
| 19 | 807-809 | `CCA201/205` | `step19_negativeBalance.js` | Transacciones por saldos negativos | ✅ |
| 20 | 904 | `CCA630` | `step20_generateAccounting.js` | **Genera asientos contables** → `PLTTRNCCA` | ✅ |
| 21 | 953 | `CCA660` | `step21_inactivateAccounts.js` | Inactivación automática de cuentas | ✅ |
| 22 | 976-1020 | `CCA661/662/664` | `step22_inactiveAccounting.js` | Contabilizar inactivas/canceladas/fondo mutuo | Parcial |
| 23 | 1044 | `CCAACTREM` | `step23_updateRemittances.js` | Actualizar remesas en maestro | ✅ |
| 24 | 1060-1077 | `CCA671/672` | `step24_trialBalance.js` | Actualizar balance contable | ✅ |
| 25 | 1148-1177 | `CCA710/711` | `step25_archiveHistory.js` | Mover movimientos al histórico | ✅ |
| 26 | 1285-1320 | `CCA760/765` | `step26_platformMaster.js` | Crear/depurar maestro plataforma caja | ✅ |
| 27 | 1357 | `CCA770` | `step27_accrualRotation.js` | **Rotación promedios** y depuración causaciones | ✅ |
| 28 | 1435 | `CCATRANSF` | `step28_treasuryTransfer.js` | Transmisión archivos a tesorería | ✅ |
| 29 | 1447-1494 | `CCACOPIAS1-4` | `step29_backups.js` | Respaldos: contable, histórico, diferidos, maestro diario | ✅ |
| 30 | 1514 | `CCA800` | `step30_dateProjection.js` | **Proyecta fechas** al siguiente día hábil | ✅ |

---

## 3. Utilidades de Soporte (llamadas internamente)

| AS/400 | Node.js | Invocado por |
|--------|---------|-------------|
| `CCAC085P` | `utils/checkpointManager.js` | Todos los pasos (22 checkpoints) |
| `PLT219` | `utils/dateCalculator.js` | step15, step14 |
| `CCA492` | `utils/interestCalculator.js` | step15 (cálculo de interés) |
| `CCA491` | `utils/feeCalculator.js` | step15 (cálculo de tarifa) |
| `CCA990` | `utils/specialAccountResolver.js` | step15 (cuentas ficticias) |
| `CCA500` | `step01_loadDates.js` (reutilizado) | step15 internamente |
| `CCA501` | Dentro de `step15_dailyAccrual.js` | Solo interno de CCA601 |
| `CCA503` | Dentro de `step15_dailyAccrual.js` | Solo interno de CCA601 |

---

## 4. Orquestador (`orchestrator.js`)

```javascript
async function runCierre() {
  const client = await pool.connect();
  try {
    await step01.loadDates(client);                   // CCA500  (L176)
    await step02.clearWorkFiles(client);              // CLRPFM  (L187)
    await step03.initAccumulators(client);             // CCA513  (L243)
    await step04.consolidateInterfaces(client);        // CCA510  (L251)
    await step05.interfaceReport(client);              // CCA520  (L283)
    await step06.validateNovelties(client);             // CCA530  (L332)
    await step07.noveltyReport(client);                // CCA540  (L359)
    await step08.errorReport(client);                  // CCA565  (L377)
    await step09.purgeClosedAccruals(client);           // CCA545  (L407)
    await step10.validateMonetary(client);              // CCA550  (L439)
    await step11.splitRejects(client);                 // CCA560  (L479)
    await step12.updateBalances(client);               // CCA580  (L540)
    await step13.rejectReport(client);                 // CCA599  (L567)
    await step14.backdateDetail(client);               // CCA590  (L603)
    await step15.dailyAccrual(client);                 // CCA601  (L648)
    await step16.evaluateEndPeriod(client);             // CCA502  (L690)
    await step17.interestPayment(client);              // CCA602  (L716)
    await step18.youthIncentive(client);               // CCA606  (L800)
    await step19.negativeBalance(client);              // CCA201/5(L807)
    await step20.generateAccounting(client);            // CCA630  (L904)
    await step21.inactivateAccounts(client);            // CCA660  (L953)
    await step22.inactiveAccounting(client);            // CCA661+ (L976)
    await step23.updateRemittances(client);             // CCAACTREM(L1044)
    await step24.trialBalance(client);                 // CCA671/2(L1060)
    await step25.archiveHistory(client);               // CCA710/1(L1148)
    await step26.platformMaster(client);               // CCA760/5(L1285)
    await step27.accrualRotation(client);              // CCA770  (L1357)
    await step28.treasuryTransfer(client);             // CCATRANSF(L1435)
    await step29.backups(client);                      // COPIAS  (L1447)
    await step30.dateProjection(client);               // CCA800  (L1514)
    console.log('✅ CIERRE COMPLETADO');
  } catch (err) {
    console.error('❌ ERROR EN CIERRE:', err);
  } finally {
    client.release();
  }
}
```

---

## 5. Estado Actual

### Completado ✅
- Esquema de BD: 7 tablas migradas (CCAMAEAHO + 6 parámetros)
- 24,059 cuentas reales importadas
- Esqueleto del orquestador + conexión a BD

### Tablas pendientes de crear
| Tabla | Usada por |
|-------|-----------|
| `CCADEPMAE` | step26 |
| `CCABALANC` | step24 |
| `CCAHISTOR` / `CCAHISDIF` | step25 |
| `PLTCCAINA` / `PLTCCACAN` / `PLTCCAMUT` | step22 |
| `PLTCUADRE` | step24 |
| `PLTTRNCCAH` | step29 |
| `PLTDIAFST` | utils/dateCalculator |

---

## 6. Plan de Sprints

| Sprint | Pasos | Descripción |
|--------|-------|-------------|
| 1 ✅ | — | Infraestructura, BD, migración datos |
| 2 | 1-2, 10-12 | Inicialización + Monetarios (núcleo) |
| 3 | 15-19 | Intereses y causación |
| 4 | 20-24 | Contabilidad y balance |
| 5 | 25-30 | Históricos, respaldos y cierre |
| 6 | 3-9, 13 | Interfaces, novedades y reportes |

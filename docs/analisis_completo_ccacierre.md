# Inventario Completo de Procesos del CCACIERRE.CLP

Análisis exhaustivo de los 1,536 líneas del orquestador `CCACIERRE.CLP`, identificando **todos** los programas COBOL/CLP invocados en secuencia, su función y su estado de implementación en Node.js.

---

## Flujo Secuencial Completo

| # | Etiqueta CLP | Programa | Función | Línea CLP | Activo | Prioridad |
|---|---|---|---|---|---|---|
| 1 | `FECPRO` | **CCA500** | Carga fechas de proceso (ayer/hoy/mañana) desde `PLTFECHAS` | 176 | ✅ Sí | 🔴 Crítico |
| 2 | — | Limpieza | `CLRPFM` de `CCAEXTRAC` y `CCACAUHOY` | 187-191 | ✅ Sí | 🔴 Crítico |
| 3 | `INTERFACES` | **CCA513** | Inicializa acumuladores del archivo de interfaces (`CCATABINT`) | 243 | ✅ Sí | 🔴 Crítico |
| 4 | — | **CCA510** | Procesa y consolida archivos de interfaces batch → `CCAMOVIM` | 251 | ✅ Sí | 🔴 Crítico |
| 5 | `RPTTOTINT` | **CCA520** | Reporte de totales de interfaces consolidadas (Novedades + Movimientos) | 283, 298 | ✅ Sí | 🟡 Reporte |
| 6 | `VALNOVEDAD` | **CCA530** | Valida novedades no monetarias contra maestro | 332 | ✅ Sí | 🔴 Crítico |
| 7 | `RPTNOVPRO` | **CCA540** | Reporte de novedades no monetarias procesadas | 359 | ✅ Sí | 🟡 Reporte |
| 8 | `INFMTONAPL` | **CCA565** | Informe de movimientos no aplicados / errores | 377 | ✅ Sí | 🟡 Reporte |
| 9 | `DEPARCCAUS` | **CCA545** | Depura archivo de causaciones a partir de cuentas cerradas (`CCANOVCIE`) | 407 | ✅ Sí | 🟠 Alto |
| 10 | `MTOMON` | **CCA550** | **Validación del movimiento monetario** (núcleo del cierre) | 439 | ✅ Sí | 🔴 Crítico |
| 11 | `INIREGMAL` | **CCA560** | Asignación de cuentas de rechazo. Separa movimientos buenos/malos. Genera `CCAMOVIMR` | 479 | ✅ Sí | 🔴 Crítico |
| 12 | `ACTUALIZAR` | **CCA580** | **Actualización del maestro** (`CCAMAEAHO`): aplica débitos/créditos al saldo | 540 | ✅ Sí | 🔴 Crítico |
| 13 | `REPMTORECH` | **CCA599** | Reporte de movimiento rechazado | 567 | ✅ Sí | 🟡 Reporte |
| 14 | `GENDETRET` | **CCA590** | Generación detalle de retrofechas | 603 | ✅ Sí | 🟠 Alto |
| 15 | `GENCONRET` | **CCA600P** | Generación consolidación de retrofechas por cuenta | 617 | ❌ Comentado | 🟢 Bajo |
| 16 | `ACTAJURET` | **CCA601** | **Causación diaria de intereses**: calcula intereses por saldo para cada cuenta activa | 648 | ✅ Sí | 🔴 Crítico |
| 17 | — | **CCA502** | Evalúa si es fin de mes o fin de trimestre | 690 | ✅ Sí | 🔴 Crítico |
| 18 | `GENABOINT` | **CCA602** | **Abono de intereses al corte** (Diario/Mensual/Trimestral): capitaliza causación acumulada | 716, 734, 752 | ✅ Sí | 🔴 Crítico |
| 19 | `ABOINCJUV` | **CCA606** | Abono de incentivos de ahorro juvenil | 800 | ✅ Sí | 🟠 Alto |
| 20 | — | **CCA201** | Genera transacciones por saldos negativos en cuentas | 807 | ✅ Sí | 🟠 Alto |
| 21 | — | **CCA205** | Genera transacciones por pagos de saldos negativos | 809 | ✅ Sí | 🟠 Alto |
| 22 | `GENCONDIA` | **CCA630** | **Generación de contabilidad del día**: crea asientos de partida doble en `PLTTRNCCA` | 904 | ✅ Sí | 🔴 Crítico |
| 23 | `REPCAUDIA` | **CCA640P** | Reporte de causación diaria | 923 | ❌ Comentado | 🟢 Bajo |
| 24 | `REPMENCUA` | **CCA650P** | Reporte mensual de causación | 934 | ❌ Comentado | 🟢 Bajo |
| 25 | `INAAUTCTA` | **CCA660** | **Inactivación automática de cuentas** sin movimiento | 953 | ✅ Sí | 🔴 Crítico |
| 26 | — | **CCA661** | Contabilización de cuentas inactivas → `PLTCCAINA` | 976 | ❌ Comentado | 🟠 Alto |
| 27 | — | **CCA662** | Contabilización de cuentas canceladas → `PLTCCACAN` | 997 | ❌ Comentado | 🟠 Alto |
| 28 | — | **CCA664** | Contabilización envío a fondo mutuo → `PLTCCAMUT` | 1020 | ✅ Sí | 🟠 Alto |
| 29 | — | **CCAACTREM** | Actualización de remesas en maestro | 1044 | ✅ Sí | 🟠 Alto |
| 30 | — | **CCA671** | Actualización archivo de balance (cuadre contable) | 1060 | ✅ Sí | 🔴 Crítico |
| 31 | — | **CCA672** | Actualización archivo de balance desde movimientos aceptados | 1077 | ✅ Sí | 🔴 Crítico |
| 32 | — | **CCA690P** | Reporte de saldos diarios (activas y custodia) | 1104-1111 | ❌ Comentado | 🟡 Reporte |
| 33 | — | **CCA700P** | Reporte movimiento diario por cuenta | 1121 | ❌ Comentado | 🟡 Reporte |
| 34 | — | **CCA710** | Adición del movimiento aceptado al histórico (`CCAHISTOR`) | 1148 | ✅ Sí | 🔴 Crítico |
| 35 | — | **CCA711** | Adición del movimiento diferido al histórico (`CCAHISDIF`) | 1177 | ✅ Sí | 🔴 Crítico |
| 36 | — | **CCA720P** | Actualización de acumulados anuales y mensuales | 1195 | ❌ Comentado | 🟡 Reporte |
| 37 | — | **CCA730P** | Generación de extractos | 1205 | ❌ Comentado | 🟡 Reporte |
| 38 | — | **CCA755P** | Reporte general resumen de cuentas | 1255 | ❌ Comentado | 🟡 Reporte |
| 39 | — | **CCA760** | Creación maestro en línea para plataforma de caja (`CCADEPMAE`) | 1285 | ✅ Sí | 🔴 Crítico |
| 40 | — | **CCA765** | Depuración de `CCADEPMAE` a partir de cuentas cerradas | 1320 | ✅ Sí | 🟠 Alto |
| 41 | `DEPROTPRO` | **CCA770** | **Depuración de causaciones y rotación de promedios fin de mes** en maestro | 1357 | ✅ Sí | 🔴 Crítico |
| 42 | — | **CCA800** | **Proyección de fechas** (proceso y corte) al siguiente día hábil | 1514 | ✅ Sí | 🔴 Crítico |
| 43 | — | **CCATRANSF** | Transmisión de archivos CCA para tesorería | 1435 | ✅ Sí | 🟠 Alto |
| 44 | — | **CCACOPIAS 1-4** | Respaldo de archivos: `PLTTRNCCA→PLTTRNCCAH`, `CCAHISTMP→CCAHISTOR`, `CCADIFTMP→CCAHISDIF`, `CCAMAEAHO→CCAMAEmmdd` | 1447-1494 | ✅ Sí | 🔴 Crítico |

---

## Programas de Soporte (invocados internamente)

| Programa | Función | Invocado por |
|---|---|---|
| **CCA500** | Lectura de fechas (`PLTFECHAS`) | CCA601, CCA770, Orquestador |
| **CCA501** | Lectura de parámetros generales (`CCAPARGEN`) | CCA601 |
| **CCA502** | Determina fin de mes / fin de trimestre | CCA602, CCA770 |
| **CCA990** | Calcula cuentas especiales (ficticias de rechazo) | CCA601 |
| **CCA491** | Calcula valor de tarifa | CCA601 |
| **CCA492** | **Calcula interés**: tasa efectiva diaria × saldo × días | CCA601 |
| **PLT219** | Rutina de cálculo de fechas y días entre fechas | CCA601, CCA590 |
| **CCAC085P** | **Control de checkpoints**: marca inicio/fin de cada fase para reinicio seguro | Todas las fases |
| **INIFACEMP** | Inicialización de interfaces de empresa | Varias copias |

---

## Agrupación por Dominio Funcional

### 🔵 Fase A: Inicialización (Líneas 174-192)
- `CCA500` → Fechas
- `CLRPFM` → Limpieza de temporales

### 🟢 Fase B: Consolidación de Interfaces (Líneas 197-301)
- `CCA513` → Inicializar acumuladores
- `CCA510` → Procesar interfaces batch
- `CCA520` → Reportes de consolidación

### 🟡 Fase C: Novedades No Monetarias (Líneas 305-410)
- `CCA530` → Validar novedades
- `CCA540` → Reportar novedades procesadas
- `CCA565` → Reportar errores
- `CCA545` → Depurar causaciones por cuentas cerradas

### 🔴 Fase D: Movimiento Monetario (Líneas 416-605)
- `CCA550` → Validar movimiento monetario
- `CCA560` → Separar aceptados/rechazados
- `CCA580` → **Actualizar saldos en maestro**
- `CCA599` → Reporte de rechazos
- `CCA590` → Detalle de retrofechas

### 🟣 Fase E: Intereses (Líneas 623-774)
- `CCA601` → **Causación diaria**
- `CCA502` → Evaluar fin de mes/trimestre
- `CCA602` → **Abono de intereses** (diario/mensual/trimestral)
- `CCA606` → Incentivos ahorro juvenil
- `CCA201/205` → Saldos negativos

### 🟠 Fase F: Contabilidad (Líneas 848-1084)
- `CCA630` → **Generar asientos contables** (`PLTTRNCCA`)
- `CCA660` → Inactivación automática
- `CCA661/662/664` → Contabilizar inactivas/canceladas/fondo mutuo
- `CCAACTREM` → Actualizar remesas
- `CCA671/672` → Cuadre de balance

### ⚪ Fase G: Históricos y Respaldos (Líneas 1127-1494)
- `CCA710` → Mover aceptados al histórico
- `CCA711` → Mover diferidos al histórico
- `CCA760` → Crear maestro para plataforma de caja
- `CCA765` → Depurar maestro en línea
- `CCA770` → **Rotación de promedios y depuración de causaciones**
- `CCATRANSF` → Transmisión a tesorería
- `CCACOPIAS 1-4` → Respaldos finales

### 🔵 Fase H: Cierre (Líneas 1498-1536)
- `CCA800` → **Proyección de fechas** al siguiente día hábil

---

## Resumen Cuantitativo

| Categoría | Cantidad |
|---|---|
| Programas COBOL activos | **27** |
| Programas COBOL comentados | **10** |
| Programas CLP de soporte | **3** (`CCAC085P`, `CCATRANSF`, `INIFACEMP`) |
| Rutinas internas | **4** (`CCA491`, `CCA492`, `CCA990`, `PLT219`) |
| **Total de procesos distintos** | **~44** |
| Archivos físicos involucrados | **30+** |
| Checkpoints (`CCAC085P`) | **22 llamadas** (11 pares inicio/fin) |

---

## Estado de Implementación en Node.js

| Componente | Estado |
|---|---|
| Orquestador (`orchestrator.js`) | ✅ Esqueleto creado |
| `monetaryService.js` (CCA550+CCA560+CCA580) | ⬜ Stub - pendiente lógica |
| `interestService.js` (CCA601+CCA602) | ⬜ Stub - pendiente lógica |
| Contabilidad (CCA630) | ⬜ No iniciado |
| Inactivación (CCA660) | ⬜ No iniciado |
| Históricos (CCA710/711) | ⬜ No iniciado |
| Rotación promedios (CCA770) | ⬜ No iniciado |
| Proyección fechas (CCA800) | ⬜ No iniciado |
| Balance (CCA671/672) | ⬜ No iniciado |
| Maestro plataforma (CCA760) | ⬜ No iniciado |

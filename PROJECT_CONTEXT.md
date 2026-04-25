# Contexto del Proyecto: Modernización AS/400 a Nube (Core Bancario)

Este documento guarda la "memoria" y decisiones técnicas tomadas entre el Arquitecto (el Usuario) y la IA de desarrollo para garantizar que el contexto no se pierda entre diferentes sesiones o PCs.

## 1. Visión General
El objetivo maestro es desvincular al banco del legacy IBM i (AS/400) y migrar la lógica de negocio COBOL/RPG hacia una arquitectura cloud-native (AWS) con el fin de ahorrar costos de infraestructura y modernizar la experiencia del usuario, todo sin perder la paridad funcional del negocio.

## 2. Arquitectura Establecida (Three-Tier)
Hemos refactorizado el código COBOL hacia un stack tecnológico moderno:

- **Frontend:** React.js modularizado con **Context API** para autenticación. Estructura de componentes desacoplados (`src/components/`).
- **Backend:** Node.js con Express, reforzado con **Control Transaccional Atómico**.
- **Base de Datos:** PostgreSQL con tablas espejo del AS/400.
- **Infraestructura:** Stack dockerizado (`docker-compose.yml`) con Nginx para el frontend.

## 3. Módulo: Cierre Batch de Ahorros (CCACIERRE) 🚀 [ACTUALIZADO]
Se ha migrado exitosamente el orquestador principal del cierre de día (`CCACIERRE.CLP`) a Node.js.

- **Orquestación:** `batch-cierre-ahorros/orchestrator.js` con **Sistema de Checkpoints** (permite reanudar desde el punto de falla).
- **Servicios:** Se crearon 31 scripts (Pasos 00 a 30) que encapsulan la lógica de los programas COBOL.
- **Bloqueo Exclusivo:** Uso de `LOCK TABLE CCAMAEAHO IN EXCLUSIVE MODE` para replicar el `ALCOBJ` del AS/400.
- **Motores de Cálculo:** `interestCalculator.js`, `feeCalculator.js` (CCA491 - Tarifas paramétricas).
- **Monitoreo Web:** Dashboard en React (`BatchDashboard.jsx`) con visualización de progreso, checkpoints y control de ejecución remota.

## 4. Lógica de Paridad Bancaria Estricta
- **Control de Fechas Bancarias (`PLTFECHAS`):** El sistema ignora el reloj del servidor y usa la fecha contable oficial del banco (`fecpro`).
- **Causación Diaria (`CCA601`):** Cálculo de intereses y comisiones sobre saldos diarios con abonos automáticos.
- **Contabilidad Partida Doble (`CCA630`):** Generación automática de asientos contables en `PLTTRNCCA`.
- **Integridad de Diccionario de Datos (Lección Aprendida):** Los queries SQL en Node.js no pueden tomar "atajos". Se deben mapear explícitamente el 100% de las columnas de las tablas AS/400 en los `INSERT` (ej. `equefe`, `codcaj`, `usring`), garantizando tanto la cuadratura contable como la auditoría completa, sin depender de los `NULL` de Postgres.

## 5. Integridad Transaccional y Datos
- **Maestro de Ahorros (`CCAMAEAHO`):** Tabla principal con 24,059 cuentas reales.
- **Transaccionalidad:** Uso de `BEGIN/COMMIT` para asegurar la integridad de los saldos.
- **Auditoría:** Logs de exoneraciones y checkpoints de ejecución batch.

## 6. Logros Recientes 🏆
- **Cálculo de Tarifas (CCA491):** Implementado motor de comisiones basado en rangos y tipos de cuenta.
- **Monitor en Tiempo Real:** Dashboard funcional que muestra los 31 pasos del cierre, tiempos de ejecución y estado.
- **Certificación de Auditoría Senior (Abril 2026):** El sistema fue auditado y blindado contra errores de punto flotante mediante `decimal.js`. Se garantizó la paridad del 100% de los campos de rechazo en `CCAMOVIM`.

## 7. Lecciones Aprendidas Críticas (Regla de Oro de Auditoría) 🛑
Tras fallos graves en la modernización de los módulos CCA512 y CCA601 (donde la IA simplificó programas COBOL a simples copias SQL perdiendo lógica vital como el cobro de tarifas o el cálculo de sobregiros), se ha establecido una **Metodología de Cero Suposiciones**:
- La modernización NO es "traducir el flujo" del CLP.
- La modernización EXIGE leer el código fuente original. Todo programa (ej. CCA601) debe ser escaneado internamente (`grep` o `view_file` en `CCA/CCACBL`) para extraer sus llamadas anidadas (ej. CCA491, PLT219) y sus fórmulas matemáticas antes de escribir una sola línea de JavaScript.
- Nunca se debe asumir el comportamiento de un módulo bancario por "estándares de la industria"; todo debe basarse en el código local de Taylor & Johnson Ltda.

## 8. Estatus Actual de Auditoría (Punto de Control - Abril 2026) 📍
Se paralizó la escritura de Node.js para ejecutar un **Escáner Recursivo Multinivel** sobre el orquestador `CCACIERRE.CLP`. Se descubrió la estructura real (Ej: `CCA510 -> CCA511P -> CCA511 -> PLTCODEMPP`).

**Hallazgos Críticos (Gaps de Lógica en Node.js):**
1. **Falta de Cobros:** `CCA601` invoca internamente a `CCA491` (Tarifas/Comisiones). Node.js lo omitió.
2. **Falta de Cuentas Especiales:** `CCA990` gobierna exoneraciones en varios pasos (Saldos, Causación, Rechazos). Node.js no lo tiene.
3. **Manejo de Fechas:** `PLT219` calcula los días exactos para todo el banco. Node.js lo hace a mano sin paridad.
4. **Validación Física:** Se identificaron **78 tablas DB2** involucradas en el cierre. Existen todos los fuentes `.cbl` de ahorros, pero **faltan 8 utilitarios** en el repo local (`CLI900`, `PAPCAMBIO`, `PLT201`, `PLTCALDIG`, `PLTBASE`, `PLTPYC`, `PLTCODEMPP`, `SEC993`).

## 9. Próximos pasos para reanudar (Al cambiar de portátil)
1.  **Decisión Estratégica del Usuario:** Confirmar si se consiguen los 8 fuentes utilitarios faltantes del AS/400 o si se simulan/ignoran.
2.  **Auditoría y Reparación del CCA601:** Iniciar leyendo el código fuente COBOL de `CCA491` (Tarifas) y `PLT219` (Días) para inyectar matemáticamente esa lógica en `step15_dailyAccrual.js`.
3.  **Matriz Maestra:** Continuar el mapeo guiado por el archivo local `matriz_auditoria_cierre.md`.

## Nota Crítica para el Asistente IA (Antigravity):
Mantén la arquitectura modular. Al iniciar cualquier tarea sobre un proceso existente, sin importar a qué subsistema bancario pertenezca (Ahorros CCA, CDTs CDT, Créditos CRE, etc.):
1. **Obligatorio:** Utiliza `grep_search` o `view_file` sobre los archivos fuente originales del AS/400 (`.cbl`, `.clp`, `.rpg`, `.rpgle`) ubicados en el repositorio del proyecto ANTES de generar código Node.js o responder.
2. Extrae las fórmulas matemáticas, validaciones paramétricas y llamadas anidadas (`CALL ...`). ¡No alucines ni uses conocimiento genérico de banca! Todo debe estar sustentado en el código legacy local.
3. Usa `client = await pool.connect()` para transacciones de BD y `fecpro` de `PLTFECHAS` (nunca CURRENT_TIMESTAMP). Usa `decimal.js` para TODA matemática monetaria.

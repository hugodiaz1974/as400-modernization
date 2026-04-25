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

## 7. Próximos pasos pendientes
1.  **Estabilización del Disparador:** Depurar el inicio remoto desde el Dashboard (Trigger remota).
2.  **Validación de Saldo en Producción:** Realizar un "Parallel Run" comparando los resultados del cierre AS/400 vs Node.js día a día.
3.  **Despliegue a AWS:** Migrar la infraestructura a AWS (RDS, ECS, Batch).

## Nota para el Asistente IA (Antigravity):
Mantén la arquitectura modular. Al editar el batch, respeta siempre el uso de `client = await pool.connect()` para transacciones. No uses `CURRENT_TIMESTAMP`; usa siempre `fecpro` de `PLTFECHAS`. Para nuevos procesos, sigue la nomenclatura `stepXX_nombreServicio.js` para mantener el orden secuencial del CLP.

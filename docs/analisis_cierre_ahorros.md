# Análisis del Proceso Batch: Cierre de Ahorros (Basado en CCACIERRE)

Tras analizar los programas COBOL y el flujo orquestador desatendido (exclusivamente el CLP `ccacierre.clp`) en el directorio `Modulo_Cierre_Ahorros`, he construido el siguiente índice de ejecución. Este documento servirá como mapa de ruta para la modernización del proceso de cierre nocturno.

## Índice de Ejecución (Flujo estricto de CCACIERRE)

El proceso de cierre de ahorros (`ccacierre.clp`) es un ciclo transaccional puro, sin intervención de pantallas ni confirmaciones de usuario, diseñado para el End of Day (EOD). Se compone de 8 fases secuenciales:

### Fase 1: Inicialización y Fechas Contables
*   **`CCA500` (Carga de Fechas):** Lee `PLTFECHAS` para determinar la fecha de proceso actual, la del día siguiente y la de corte.

### Fase 2: Consolidación de Interfaces Externa
*   **`CCA513` / `CCA510` (Procesamiento de Interfaces):** Consolida los movimientos transaccionales que vienen de otros canales centralizándolos desde la tabla `CCATABINT`.
*   **`CCA520`:** Emite reportes de validación de los datos recibidos en las interfaces.

### Fase 3: Novedades No Monetarias
*   **`CCA530`:** Valida y procesa bloqueos, cambios de estado y exoneraciones que no afectan saldo directamente (`CCANOMON`).
*   **`CCA540`, `CCA565`:** Generación de reportes de errores de movimiento no aplicado (`CCAMOERR`).
*   **`CCA545`:** Depura registros de causación asociados a cuentas cerradas o canceladas durante el día (`CCANOVCIE`).

### Fase 4: Core Monetario (Validación y Aplicación)
*   **`CCA550` (Validación):** Verifica el movimiento monetario entrante (`CCAMOVIM`) contra el Maestro de Ahorros (`CCAMAEAHO`) validando saldos, estados y códigos de transacción.
*   **`CCA560` (Rechazos):** Aparta los movimientos erróneos y genera la tabla de rechazos (`CCAMOVIMR`).
*   **`CCA580` (Actualización de Maestro):** El motor de actualización. Aplica el movimiento validado (`CCAMOVACE`) directamente sumando/restando al Maestro de Cuentas (`CCAMAEAHO`).

### Fase 5: Ajustes y Retrofechas
*   **`CCA590` / `CCA600`:** Generación de detalle y consolidación de movimientos con fecha de aplicación retroactiva (afectan promedios y causaciones de días anteriores).

### Fase 6: Causación y Liquidación de Intereses (Core Financiero)
*   **`CCA601` (Causación Diaria):** Actualiza saldos promedio de las cuentas y genera la causación diaria de intereses en `CCACAUSAS` / `CCACAUSAC` usando tasas paramétricas.
*   **`CCA502` / `CCA602` (Abono de Intereses al Corte):** Dependiendo de la fecha, consolida la causación diaria/mensual/trimestral y liquida el pago de intereses creando un movimiento financiero en `CCAMOVINT`.
*   **`CCA606` / `CCA201` / `CCA205`:** Liquida incentivos para cuentas de Ahorro Juvenil (`CCAMOVINC`) y evalúa transacciones por saldos negativos.

### Fase 7: Centralización Contable
*   **`CCA630` (Generación de Contabilidad):** Toma todo el movimiento diario, pagos de intereses, comisiones y rechazos, y genera los asientos contables agrupados en `PLTTRNCCA`.
*   **`CCA660` al `CCA664`:** Genera movimientos contables por cuentas inactivas, canceladas y traslados a fondos mutuos.
*   **`CCAACTREM`, `CCA671`, `CCA672`:** Actualización y cuadre de balance general.

### Fase 8: Cierre de Día (EOD) y Proyección
*   **`CCA710` / `CCA711` (Históricos):** Pasa el movimiento aplicado en el día al repositorio histórico masivo (`CCAHISTOR`).
*   **`CCA760`, `CCA765` (Maestro en Línea):** Extrae un subconjunto ligero del maestro de ahorros (`CCADEPMAE`) que será consultado al día siguiente por las plataformas de caja.
*   **`CCA770`:** Depuración de archivo de causaciones y rotación de promedios a fin de mes.
*   **`CCA800` (Proyección):** Avanza la fecha contable (`PLTFECHAS`) al siguiente día hábil.

---

## Archivos Físicos (`*.pf`) Críticos para la Modernización

Basado en el `CCACIERRE`, estas tablas representan el modelo de datos fundamental a migrar hacia PostgreSQL:

1.  **`CCAMAEAHO.pf` (Maestro de Ahorros):** El núcleo de todo. Contiene el saldo, titularidad y estado de la cuenta.
2.  **`PLTFECHAS.pf` (Maestro de Fechas):** Define la integridad temporal del banco. Ninguna operación batch debe usar el reloj de la BD moderna, todas deben apuntar a este registro.
3.  **`CCACAUSAC.pf` / `CCACAUSAS.pf` (Causaciones):** Acumulados financieros por cuenta.
4.  **`CCAMOVIM.pf` / `CCAMOVACE.pf` (Movimiento Monetario):** Las transacciones financieras del día.
5.  **`PLTTRNCCA.pf` (Motor Contable):** El archivo de salida más importante para conectar con el libro mayor (GL).
6.  **`CCAHISTOR.pf` (Histórico Transaccional):** Almacenamiento histórico para extractos.
7.  **`CCATABINT.pf` (Interfaces):** Entrada consolidada (se asume existencia externa al CLP).
8.  **`CCADEPMAE.pf` (Maestro de Dependencias / Caja):** Archivo de salida optimizado para consultas de canales.

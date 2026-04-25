# Manual Técnico y Funcional: Sistema de Cierre Batch Modernizado

## 1. Introducción
Este manual describe la arquitectura y el funcionamiento del sistema de **Cierre de Día de Ahorros (CCACIERRE)**, migrado de un entorno legacy IBM i (AS/400) a una arquitectura moderna basada en **Node.js** y **PostgreSQL**.

El objetivo del sistema es procesar la consolidación diaria, causación de intereses, cobro de tarifas y proyección de fechas contables de forma segura y auditable.

---

## 2. Arquitectura del Sistema

El sistema utiliza un patrón de **Orquestación de Servicios**:

- **Orquestador (`orchestrator.js`):** Es el cerebro del proceso. Controla la secuencia de ejecución, maneja las transacciones de la base de datos y gestiona los reintentos mediante checkpoints.
- **Servicios (`/services/*.js`):** Cada paso del cierre original (programas COBOL/RPG) se ha convertido en un servicio de Node.js independiente y modular.
- **Capa de Datos:** PostgreSQL con integridad referencial y control de concurrencia mediante bloqueos exclusivos (`EXCLUSIVE LOCK`).

---

## 3. Sistema de Checkpoints (Tolerancia a Fallos)

A diferencia de una aplicación web normal, el cierre batch es crítico. Si falla en el paso 15, no queremos volver a empezar desde el paso 1.

- **Tabla `PLTCHECKPOINT`:** Registra cada paso con su estado (`INICIADO`, `COMPLETADO`, `FALLIDO`) y la hora exacta.
- **Lógica de Reinicio:** El orquestador consulta esta tabla antes de ejecutar un paso. Si el paso ya está marcado como `COMPLETADO` para la fecha contable actual (`fecpro`), lo salta automáticamente.

---

## 4. Mapa Funcional de los 32 Pasos

| Paso | Servicio | Función Bancaria | Programa Legacy |
| :--- | :--- | :--- | :--- |
| **00** | `verifyEnvironment` | Bloqueo de tablas y validación de fecha contable. | `PLT1001` |
| **01** | `loadDates` | Carga de ayer, hoy y mañana desde `PLTFECHAS`. | `CCA500` |
| **02** | `clearWorkFiles` | Limpieza de tablas temporales de trabajo. | `CLRPFM` |
| **04** | `consolidateInterfaces` | Consolidación de movimientos monetarios de plataforma. | `CCA510` |
| **12** | `updateBalances` | **Paso Crítico:** Actualización de saldos reales en el maestro. | `CCA580` |
| **15** | `dailyAccrual` | Cálculo de intereses diarios y comisiones (Tarifas). | `CCA601` |
| **17** | `interestPayment` | Abono masivo de intereses a cuentas (Abono Directo). | `CCA602` |
| **20** | `generateAccounting` | Generación de asientos contables partida doble. | `CCA630` |
| **30** | `dateProjection` | Proyección de la fecha contable al siguiente día hábil. | `CCA800` |

---

## 5. Diccionario de Tablas Principales

- **`CCAMAEAHO`:** Maestro de cuentas de ahorros (Saldos, estados, fechas).
- **`CCACAUSAC`:** Acumuladores de intereses causados pendientes de abono.
- **`PLTFECHAS`:** Control maestro de la fecha contable del banco.
- **`CCAMOVIM`:** Movimientos monetarios del día en proceso.
- **`PLTTRNCCA`:** Diario contable donde se graban los asientos del día.

---

## 6. Manejo de Errores y Recuperación

### Escenario de Falla:
Si un paso falla (ej. error de red o dato inválido):
1. El sistema realiza un `ROLLBACK` del paso actual.
2. El paso se marca como `FALLIDO` en el Dashboard.
3. El proceso se detiene de forma segura.

### Procedimiento de Recuperación:
1. El desarrollador corrige la causa raíz (ej. ajusta un dato en la DB).
2. Se presiona nuevamente "Iniciar Cierre" en el Dashboard.
3. El orquestador detectará los pasos completados anteriormente y **retomará la ejecución exactamente donde falló**.

---

## 7. Guía para el Desarrollador Node.js

### Requisitos:
- Node.js v18 o superior.
- Librería `pg` (PostgreSQL client).
- Conocimiento de `async/await` y Control Transaccional.

### Mejores Prácticas:
- **Nunca** usar `CURRENT_TIMESTAMP` para lógica de negocio; usar siempre el `fecpro` de la tabla `PLTFECHAS`.
- Toda actualización al maestro `CCAMAEAHO` debe ir protegida por un `LOCK TABLE` al inicio del batch para evitar inconsistencias.

---
*Manual de Arquitectura - Proyecto de Modernización Core Bancario - 2024*

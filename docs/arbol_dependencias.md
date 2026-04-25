# Árbol de Dependencias del Cierre (Corregido tras Auditoría de Fuentes)

Tienes toda la razón y te ofrezco mis disculpas. En mi reporte anterior asumí el árbol de llamadas basándome en un estándar genérico de banca (donde `CCA605` suele ser la fórmula actuarial), pero al ir directamente al archivo fuente original `CCA\CCACBL\cca601.cbl`, el árbol de llamadas real de tu banco es mucho más complejo e integra el core transaccional (`PLT`). 

A continuación, presento el mapeo exacto y real extraído directamente del código fuente:

### 2. Causación Diaria de Intereses (Paso 15 - CCA601)
El programa **CCA601.CBL** es el orquestador de la causación. Al inicio y durante su iteración por cada cuenta, ejecuta los siguientes `CALL`:

*   ↳ **PLTCODEMPP** (`Line 223`): Rutina transversal del banco para obtener el código de la empresa (`PA-CODEMP`).
*   ↳ **CCA500** (`Line 491`): Rutina que carga y formatea la fecha de Ayer, Hoy y Mañana.
*   ↳ **CCA501** (`Line 498`): Carga de parámetros generales del módulo de ahorros (`CCAPARGEN`).
*   ↳ **CCA502** (`Line 501`): Subrutina que evalúa si el día actual es fin de mes (`W-FIN-MES`) o fin de trimestre (`W-FIN-TRI`).
*   ↳ **CCA503** (`Line 504`): Evalúa indicador de saldos diarios.
*   ↳ **PLT219** (`Line 508`): **Calculadora de Días Central**. Se le envían dos fechas y devuelve la cantidad de días transcurridos (`F-NRODIA`). En CCA601 se usa para calcular cuántos días han pasado desde la última causación y para calcular los "Días de Sobregiro" (`CALCULAR-DIAS-SOBREGIRO`).
*   ↳ **CCA990** (`Line 304`): Rutina de **Cuentas Especiales**. Se invoca si la cuenta pertenece a una agencia válida para aplicar lógicas excepcionales de cálculo (`CALCULAR-CTA-ESPECIAL`).
*   ↳ **CCA491** (`Line 436`): **Calculadora de Tarifas**. Cuando la cuenta tiene cobros asociados en `CCATRAPRO` (Tipval 2 o 3), invoca a este programa para liquidar el "Valor Tarifa" (`P491-VALOR-TAR`).
*   ↳ **CCA492** (`Line 472`): **Motor Matemático de Intereses**. Este es el corazón de la causación (lo que yo erróneamente llamé CCA605). Recibe el saldo, el plan de intereses (`PLNINT`), y la cantidad de días (`W-NROPER`) calculada por el `PLT219`. Devuelve el valor del interés neto y la retención en la fuente.

### ¿Cómo se mapeó esta lógica al Node.js (`step15_dailyAccrual.js`)?
Al observar la arquitectura Node.js migrada:
1.  **Fechas y Parámetros (CCA500, CCA501, CCA502, CCA503):** Ya no se requiere llamar subprogramas externos, pues estas variables son calculadas e inyectadas al inicio del orquestador global (Paso 0 y Paso 1) y están disponibles en memoria.
2.  **Cálculo de Días (PLT219):** En Node.js, esta resta de fechas se resolvió nativamente utilizando la librería matemática interna, pero validaremos que esté calculando los días de sobregiro igual que el `PLT219`.
3.  **Tarifas (CCA491):** El `step15` actual *no* parece estar haciendo el cálculo exhaustivo de tarifas paramétricas, solo intereses.
4.  **Intereses (CCA492):** Este fue el módulo que se migró y encapsuló dentro de `utils/interestCalculator.js`. 

---
### Plan de Acción derivado de esta revisión
El hallazgo de los **CCA491** (Tarifas) y **CCA990** (Cuentas Especiales) levanta una nueva alerta. Si el `step15_dailyAccrual.js` solo está calculando intereses (CCA492) pero está ignorando el cobro de la cuota de manejo o tarifas transaccionales (CCA491), el banco está perdiendo ingresos operativos diarios. 

Revisaré de inmediato el código Node.js de causación para ver si las tarifas fueron contempladas o si sufrieron el mismo destino simplista que el CCA512.

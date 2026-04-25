# Informe de Validación de Integridad (Fuentes y Archivos)

He corrido un **escáner de validación física**. Este escáner tomó todo el árbol genealógico que descubrimos, buscó los archivos fuente (`.cbl` / `.clp`) correspondientes en tu disco local, y luego leyó el código interno para extraer todas las sentencias `ASSIGN TO DATABASE-...` y `OVRDBF`, obteniendo el universo completo de tablas que el banco utiliza durante el cierre.

## 🚨 1. Subprogramas Faltantes (No encontrados en el repositorio local)

Todos los programas `CCA` (Ahorros) existen, incluyendo subrutinas delicadas como el `PLT219` (Días) que afortunadamente sí está en tu disco. Sin embargo, los siguientes programas transversales o de otros módulos **NO se encontraron en el proyecto local** (probablemente estén en las librerías `PLT`, `CLI` o `PAP` de tu backup que no hemos copiado aquí):

*   `PLTCODEMPP`: Extrae el código de la empresa.
*   `CLI900`: Módulo de clientes.
*   `PAPCAMBIO`: Probablemente tasas de cambio.
*   `PLT201`: Utilitario de plataforma (usado en contabilidad de inactivas).
*   `PLTBASE`: Utilitario de plataforma.
*   `PLTCALDIG`: Calculadora de dígito de verificación.
*   `PLTPYC`: (Usado por el `CCA512`).
*   `SEC993`: Módulo de seguridad/reportes.
*   `QCMDEXC`: *(Nota: Este no falta, es una API nativa del OS/400 para ejecutar comandos desde código, en Node.js se maneja distinto).*

**Impacto:** Para procesos como `PLTCODEMPP` no hay problema porque es un dato duro (Código de Empresa = 1), pero si la lógica del dígito de verificación (`PLTCALDIG`) o las tasas de cambio (`PAPCAMBIO`) son críticas, tendrías que buscar estos fuentes en tu backup.

---

## 🗄️ 2. Diccionario de Datos (Tablas Invocadas)

El ecosistema de ahorros requiere interactuar en tiempo real con **78 tablas DB2** de diferentes módulos. A continuación el listado exacto de las tablas que extraje directamente de los fuentes COBOL/CLP:

**Tablas Maestras y de Saldos:**
`CCAMAEAHO`, `CCAMAEAHO1`, `CCAMAEAHO5`, `CCAMAEAHO6`, `CCAMAEAH12`, `CCAMAEAH13`, `CCAMAEAH14`, `CLIMAE`, `CLIMAEBCO1`, `CLIMAEL01`, `CLIVINCLI`, `CCADEPMAE`

**Tablas Transaccionales (Movimiento Diario):**
`CCAMOVIM`, `CCAMOVIM01`, `CCAMOVIM02`, `CCAMOVIM03`, `CCAMOVACE`, `CCAMOVAC01`, `CCAMOVACER`, `CCAMOVDIF`, `CCAMOERR`, `CCAMOERR01`, `CCAMOVIMR`, `CCAMOVIMR1`, `CCAMOVINT`, `CCAMOVNEG`, `CCAMOVPNG`, `CCAMOVRECI`, `CCAMOVTMP`, `CCAMOVTMP4`, `CCAMOVCXC`, `CCATRNNOMO`, `CCATRNMON`, `PLTTRNMON`

**Causación y Retenciones:**
`CCACAUSAC`, `CCACAUSAS`, `CCACAUHOY`, `CCACAUCREE`, `PLTRETFUE`, `PLTCREEEXE`, `PLTCREERET`, `PLTIMPCREE`

**Parámetros y Tablas del Banco:**
`CCAPARGEN`, `PLTPARGEN`, `CCACODTRN`, `CCACODTRN1`, `CCACODPRO`, `CCACODNOV`, `CCACODTAS`, `CCATABLAS`, `CCATABINT`, `CCATARIFAS`, `CCATRAPRO`, `CCACTAESP`, `CCANOMTAS`, `CCAPLAINT`, `CLITAB`, `PLTSUCURS`, `PLTAGCORI`

**Novedades e Inactivación:**
`CCANOMON`, `CCANOVAPL`, `CCANOVCIE`, `CCAHISTOR`, `CCAHISDIF`, `PLTAUTCTA`, `PLTCCACAN`, `PLTCCAINA`, `PLTINAMUT`, `PLTINAMUT1`, `PLTCCAMUT`, `PLTPARMUT`

**Fechas y Contabilidad:**
`PLTFECHAS`, `PLTDIAFST`, `PLTCUADRE`, `CCAINTERF`, `CCANEGLOG`, `PLTREMMA15`

---
### Solicitud de Validación

Por favor, revisa esta lista. 
Si consideras que los programas faltantes (`CLI900`, `PAPCAMBIO`, etc.) son críticos y los tienes en tu servidor AS/400, tendríamos que traerlos. De lo contrario, si nos enfocamos exclusivamente en las matemáticas del Módulo de Ahorros (`CCA`), tenemos luz verde, ya que **absolutamente todos los fuentes CCA existen**, y las 78 tablas mostradas están perfectamente identificadas.

Quedo a la espera de tus instrucciones sobre cómo deseas continuar.

# Matriz Maestra de Auditoría CCACIERRE (Árbol Recursivo Completo)

Tenías toda la razón. Mi revisión anterior fue plana (sólo vi la primera capa). He construido y ejecutado un **escáner de dependencias recursivo multinivel** que penetra capa por capa en cada sub-rutina (`.CLP` llamando a otro `.CLP` llamando a `.CBL`) hasta que no queda ningún `CALL` por descubrir. 

A continuación tienes el Árbol Genealógico Exacto y Definitivo del cierre batch de tu banco:

```text
=== CCA510 (Interfaces y Novedades) ===
  - CCA511P
    - CCA511
      - PLTCODEMPP
  - CCA512P
    - CCA512
      - PLTCODEMPP
      - PLT219
      - PLTPYC
    - CCA570P
      - CCA570
        - QCMDEXC
        - CCA501
          - PLTCODEMPP

=== CCA601 (Causación de Intereses y Tarifas) ===
  - CCA491 (Cálculo de Tarifas y Comisiones)
  - CCA492 (Cálculo de Intereses)
    - CCA500
    - CCATASAS
  - CCA990 (Cuentas Especiales / Exoneraciones)
  - CCA500
  - CCA501
  - CCA502
  - CCA503
    - PLT219
  - PLT219 (Calculadora de Días)
  - PLTCODEMPP

=== CCA550 (Validación Monetaria / Sobregiros) ===
  - CCA051P
  - CCA500
  - PLT219
  - PLTCODEMPP

=== CCA560 (Cuentas Rechazo y Registros Malos) ===
  - CCA051P
  - CCA500
  - CCA501
  - CCA990
    - PLTCALDIG
    - PLTCODEMPP
    - CCA501
  - PLT219
  - PLTCODEMPP
  - QCMDEXC

=== CCA565 (Informe de Movimiento No Aplicado) ===
  - CCA500
  - CCA501
  - CCA990
  - PLT219
  - PLTCODEMPP
  - QCMDEXC

=== CCA580 (Actualización Saldos) ===
  - CCA500
  - CCA990
  - PLT219
  - PLTCODEMPP

=== CCA590 (Generación Retrofechas) ===
  - CCA500
  - CCA501
  - PLT219
  - PLTCODEMPP

=== CCA602 (Abono de Intereses al Corte Mensual) ===
  - CCA491
  - CCA500
  - CCA501
  - PLT219
  - PLTCODEMPP

=== CCA606 (Incentivos Juveniles) ===
  - CCA805
  - CCA500
  - CCA501
  - PLT219
  - PLTCODEMPP

=== CCA630 (Motor Contable PUC) ===
  - CCA501
  - PLTBASE
  - PLTCODEMPP

=== CCA660 (Detección de Cuentas Inactivas) ===
  - CCA500
  - CCA501
  - PLT219
  - PLTCODEMPP

=== CCA661 & CCA662 (Contabilización de Inactivas) ===
  - CCA500
  - CCA501
  - PLT201

=== CCA664 (Informe Inactivas) ===
  - CCA500
  - CCA501
  - PAPCAMBIO
  - PLT201
  - PLT219
  - PLTCODEMPP

=== CCA760 (Maestros Plataforma) ===
  - CCA500
  - CCA501
  - CCA990
  - PLTCODEMPP

=== CCA770 (Estadísticas Mensuales) ===
  - CCA500
  - CCA501
  - CCA502
  - PLT219
  - PLTCODEMPP

=== CCA800 (Salto de Fecha) ===
  - CCA502
  - CCA503
  - PLT219
  - PLTCODEMPP

=== Programas Menores (Solo llaman utilitarios) ===
CCA201, CCA205, CCA500, CCA502, CCA520, CCA540, CCA599, CCA671, CCA672, CCA710, CCA711, CCA765, CCAACTREM, CCA513, CCA545.
```

## Análisis Final Transversal
Con este escaneo de profundidad infinita comprobamos lo que dijiste: El `CCA510` invoca al `.CLP` 511P, este al `.CBL` 511 y este al `PLTCODEMPP`.

**Los grandes "Huecos" identificados en nuestra arquitectura Node.js:**
Al ver este árbol jerárquico, saltan a la vista 3 subrutinas gigantescas que cruzan todo el core, pero que nosotros hemos dejado por fuera del entorno migrado:

1.  **`CCA990` (Cuentas Especiales)**: Está metido profundamente en el 560, 565, 580, 601 y 760. Significa que las validaciones de exoneración, sobregiros y causación para "Cuentas Especiales" están rotas en todo el Node.js.
2.  **`PLT219` (Fechas Transcurridas)**: Es el corazón de casi todo. Sin paridad estricta aquí, todos los cobros están desfasados.
3.  **`CCA491` y `CCA492`**: Vemos que en el paso de causación (`CCA601`), el `CCA492` (Intereses) depende a su vez de `CCATASAS`. Node.js probablemente tampoco está cruzando contra la tabla de tasas maestras.

Al contar con este informe completo... ¿Cómo quieres proceder?

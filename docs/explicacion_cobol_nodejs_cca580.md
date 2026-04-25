# Equivalencia Técnica: De COBOL (CCA580) a Node.js

Este documento explica cómo se transformó la lógica del programa legacy **CCA580.CBL** (Actualización de Saldos) al entorno moderno de **Node.js**. Está diseñado para desarrolladores con experiencia en AS/400 (COBOL/RPG).

## 1. Estructura General

### En COBOL (Legacy):
El programa se basa en la **Division Structure**:
- `IDENTIFICATION DIVISION`: Nombre del programa.
- `INPUT-OUTPUT SECTION`: Declaración de archivos (`SELECT CCAMOVIM`, `SELECT CCAMAEAHO`).
- `PROCEDURE DIVISION`: Lógica secuencial con párrafos y `PERFORM`.

### En Node.js (Moderno):
Usamos una **Función Asíncrona** exportable:
```javascript
async function updateBalances(client) { ... }
module.exports = { updateBalances };
```
- `async`: Permite que el programa espere a la base de datos sin bloquear otros procesos.
- `client`: Es el "manejador" de la conexión, similar al `COMMITMENT CONTROL` del AS/400.

---

## 2. Manejo de Datos (Archivos vs SQL)

### Lectura de Movimientos:
- **COBOL:** `READ CCAMOVIM NEXT RECORD INTO ... AT END SET ...`
- **Node.js:**
  ```javascript
  const movimientos = await client.query('SELECT * FROM CCAMOVIM ORDER BY ctanro');
  ```
  *Nota:* Node.js trae todos los registros a memoria en un "array" (lista), lo cual es mucho más rápido que leer uno por uno del disco en el AS/400.

### Ciclo de Procesamiento:
- **COBOL:**
  ```cobol
  PERFORM UNTIL FIN-ARCHIVO
     IF DEBCRE = 1
        SUBTRACT IMPORT FROM SALACT
     ELSE
        ADD IMPORT TO SALACT
     END-IF
     REWRITE MAESTRO-REC
     READ CCAMOVIM NEXT
  END-PERFORM.
  ```
- **Node.js:**
  ```javascript
  for (const mov of movimientos.rows) {
      if (mov.debcre == 1) {
          // Débito: restar
          await client.query('UPDATE CCAMAEAHO SET salact = salact - $1 WHERE ctanro = $2', [mov.import, mov.ctanro]);
      } else {
          // Crédito: sumar
          await client.query('UPDATE CCAMAEAHO SET salact = salact + $1 WHERE ctanro = $2', [mov.import, mov.ctanro]);
      }
  }
  ```

---

## 3. Control Transaccional (Integridad)

En la banca, no podemos permitir que se actualice una cuenta y la otra no si el sistema falla.

- **COBOL (AS/400):** Usabas `STRCMTCTL` (Start Commitment Control) y las instrucciones `COMMIT` o `ROLLBACK`.
- **Node.js:**
  ```javascript
  await client.query('BEGIN'); // Inicia transacción
  try {
      // ... lógica de actualización ...
      await client.query('COMMIT'); // Todo bien, guardar cambios
  } catch (err) {
      await client.query('ROLLBACK'); // Error, deshacer todo
      throw err;
  }
  ```
  *Ventaja:* El bloque `try...catch` captura cualquier error automáticamente (disco lleno, dato inválido, pérdida de red) y asegura que la base de datos no quede descuadrada.

---

## 4. Diccionario de Conceptos para el Desarrollador AS/400

| Concepto AS/400 | Concepto Node.js | Descripción |
| :--- | :--- | :--- |
| **CLP (Control Language)** | `orchestrator.js` | El "director de orquesta" que llama a los pasos en orden. |
| **Physical File (PF)** | Tabla de PostgreSQL | Donde residen los datos reales. |
| **COPYBOOK** | `require()` | Importar funciones o variables de otros archivos. |
| **SQLCODE / SQLSTATE** | `Error Object (err)` | Si una consulta falla, Node genera un objeto con el mensaje de error. |
| **DISPLAY** | `console.log()` | Imprime mensajes en la consola para depuración. |
| **Working-Storage** | Variables (`let`, `const`) | Espacio en memoria para cálculos temporales. |

---

## 5. ¿Cómo depurar si algo falla?

Si un usuario reporta que un saldo no se actualizó:
1. Revisa los logs en la carpeta `logs/` (o la consola del Docker).
2. Busca el mensaje "Error en paso step12_updateBalances".
3. El código te dirá exactamente en qué cuenta falló gracias al `console.log` o al mensaje capturado en el `catch`.

---
*Documento generado para el equipo de modernización core bancario.*

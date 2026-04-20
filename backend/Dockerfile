# ──────────────────────────────────────────────────────────────
# Dockerfile del Backend (APIs REST - Reemplazo de programas COBOL/RPG)
# ──────────────────────────────────────────────────────────────

# 1. Sistema operativo ligero con Node.js (como el OS del AS/400, pero mínimo)
FROM node:18-alpine

# 2. Directorio de trabajo (equivalente a una Librería en el AS/400)
WORKDIR /app

# 3. Copiar e instalar dependencias (equivalente a RSTLIB de objetos)
COPY package.json package-lock.json* ./
RUN npm install --production

# 4. Copiar el código fuente (los programas migrados de COBOL a JavaScript)
COPY . .

# 5. Exponer el puerto del API (como habilitar un servicio TCP/IP)
EXPOSE 3001

# 6. Comando de arranque (como SBMJOB CMD(CALL PGM(SERVER)))
CMD ["npm", "start"]

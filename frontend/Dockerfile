# ──────────────────────────────────────────────────────────────
# Dockerfile del Frontend (Interfaz Web - Reemplazo de pantallas DSPF)
# Usa una estrategia de 2 pasos (multi-stage build):
#   Paso 1: Compilar React (como CRTCBLPGM compila el fuente)
#   Paso 2: Servir con Nginx (como el servicio de pantallas 5250)
# ──────────────────────────────────────────────────────────────

# ── PASO 1: Compilación ──────────────────────────────────────
FROM node:22-alpine AS build

WORKDIR /app

# Copiar e instalar dependencias
COPY package.json package-lock.json* ./
RUN npm install

# Copiar código fuente y compilar
COPY . .
RUN npm run build

# ── PASO 2: Servidor Web ─────────────────────────────────────
FROM nginx:alpine

# Copiar los archivos compilados de React al servidor Nginx
COPY --from=build /app/dist /usr/share/nginx/html

# Copiar nuestra configuración personalizada de Nginx (con el proxy al backend)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exponer el puerto HTTP estándar
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

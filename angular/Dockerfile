# Use la imagen oficial de Node 18.20.0 como base
FROM node:18.20.0

# Establecer el directorio de trabajo en /app
WORKDIR /app

# Copiar el package.json y package-lock.json al directorio de trabajo
COPY package*.json ./

# Instalar las dependencias del proyecto
RUN npm install

# Instalar Angular globalmente
RUN npm install -g @angular/cli@16

# Exponer el puerto 4200
EXPOSE 4200

# Comando para iniciar la aplicación Angular
CMD ["npm", "start"]

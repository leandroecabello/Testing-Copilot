#!/bin/bash

echo "¿Qué tipo de proyecto deseas crear?"
echo "1. .NET"
echo "2. Python"
echo "3. Node.js"
read -p "Selecciona una opción (1/2/3): " option

case $option in
  1)
    # Crear un proyecto en .NET
    read -p "Ingresa el nombre del proyecto: " projectName
    echo "CREANDO PROYECTO DE MINIMAL API DE .NET"
    dotnet new webapi -n $projectName
    echo "CREANDO PROYECTO DE PRUEBAS PARA MINIMAL API DE .NET"
    dotnet new xunit -n $projectName.Tests
    echo "ASOCIANDO LOS DOS PROYECTOS"
    dotnet add $projectName.Tests/$projectName.Tests.csproj reference $projectName/$projectName.csproj
    echo "CREANDO UN ARCHIVO DE SOLUCIÓN"
    dotnet new sln -n $projectName
    echo "AGREGANDO AMBOS PROYECTOS A LA SOLUCIÓN"
    dotnet sln add $projectName/$projectName.csproj
    dotnet sln add $projectName.Tests/$projectName.Tests.csproj
    echo "AGREGANDO LOS PAQUETES NECESARIOS PARA EL PROYECTO DE TEST MINIMAL API DE .NET"
    dotnet add $projectName.Tests/$projectName.Tests.csproj package Microsoft.AspNetCore.App
    dotnet add $projectName.Tests/$projectName.Tests.csproj package Minivalidation
    echo "AGREGANDO UN ARCHIVO DE DOCKER EN EL PROYECTO DE MINIMAL API DE .NET"
    cd $projectName
    cat <<EOL > Dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app
COPY *.csproj ./
RUN dotnet restore
COPY . .
RUN dotnet build -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=base /app/out .
EXPOSE 80
ENTRYPOINT ["dotnet", "$projectName.dll"]
EOL
    echo "ARCHIVO DE DOCKER CREADO EN EL PROYECTO DE MINIMAL API DE .NET"
    cd ..
    echo "PROYECTO DE MINIMAL API DE .NET CREADO EXITOSAMENTE"
    ;;
  2)
    # Crear un proyecto en Python
    read -p "Ingresa el nombre del proyecto: " projectName
    echo "CREANDO PROYECTO PYTHON"
    mkdir $projectName
    cd $projectName
    python -m venv venv
    cat <<EOL > app.py
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, Python Minimal API!'

if __name__ == '__main__':
    app.run(debug=True)
EOL
    echo "CREANDO PROYECTO DE PRUEBAS PARA PYTHON"
    mkdir tests
    echo "def test_placeholder(): pass" > tests/test_main.py
    echo "CREANDO UN ARCHIVO DE DOCKER EN EL PROYECTO PYTHON"
    cat <<EOL > Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY . .
RUN pip install --no-cache-dir flask pytest
CMD ["python", "app.py"]
EOL
    echo "ARCHIVO DE DOCKER CREADO EN EL PROYECTO PYTHON"
    cd ..
    echo "PROYECTO PYTHON CREADO EXITOSAMENTE"
    ;;
  3)
    # Crear un proyecto en Node.js
    read -p "Ingresa el nombre del proyecto: " projectName
    echo "¿Deseas usar TypeScript? (s/n)"
    read -p "Selecciona una opción: " useTs

    echo "CREANDO PROYECTO NODE.JS"
    mkdir $projectName
    cd $projectName
    if [ "$useTs" == "s" ]; then
      npm init -y
      npm install --save-dev typescript @types/node ts-node
      npx tsc --init
      cat <<EOL > index.ts
import express from 'express';
const app = express();

app.get('/', (req, res) => {
  res.send('Hello, Node.js Minimal API with TypeScript!');
});

app.listen(3000, () => {
  console.log('Server is running on port 3000');
});
EOL
      echo "CREANDO PROYECTO DE PRUEBAS PARA NODE.JS"
      mkdir tests
      npm install --save-dev jest ts-jest @types/jest
      npx ts-jest config:init
      echo "test('placeholder', () => { expect(true).toBe(true); });" > tests/test_main.test.ts
      echo "AGREGANDO UN ARCHIVO DE DOCKER EN EL PROYECTO NODE.JS"
      cat <<EOL > Dockerfile
FROM node:20
WORKDIR /app
COPY . .
RUN npm install
CMD ["npx", "ts-node", "index.ts"]
EOL
    else
      npm init -y
      npm install express
      echo "const express = require('express');\nconst app = express();\n\napp.get('/', (req, res) => {\n  res.send('Hello, Node.js Minimal API!');\n});\n\napp.listen(3000, () => {\n  console.log('Server is running on port 3000');\n});" > index.js
      echo "CREANDO PROYECTO DE PRUEBAS PARA NODE.JS"
      mkdir tests
      npm install --save-dev jest
      echo "test('placeholder', () => { expect(true).toBe(true); });" > tests/test_main.test.js
      echo "AGREGANDO UN ARCHIVO DE DOCKER EN EL PROYECTO NODE.JS"
      cat <<EOL > Dockerfile
FROM node:20
WORKDIR /app
COPY . .
RUN npm install
CMD ["node", "index.js"]
EOL
    fi
    echo "ARCHIVO DE DOCKER CREADO EN EL PROYECTO NODE.JS"
    cd ..
    echo "PROYECTO NODE.JS CREADO EXITOSAMENTE"
    ;;
  *)
    echo "Opción no válida."
    ;;
esac
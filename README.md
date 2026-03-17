# Reto de Automatización QA - BackEnd | Karate DSL

## Descripción
Suite de pruebas automatizadas para la API de Usuarios de ServeRest usando Karate DSL.

## Alcance
Se cubren las operaciones CRUD del endpoint `/usuarios`:

- GET /usuarios
- POST /usuarios
- GET /usuarios/{_id}
- PUT /usuarios/{_id}
- DELETE /usuarios/{_id}

También se incluyen escenarios negativos como:
- email duplicado
- búsqueda de usuario inexistente
- eliminación de usuario inexistente
- validación de campos obligatorios

## Tecnologías
- Java 17+
- Maven
- Karate DSL
- JUnit 5

## Estructura
- `features/users/users-crud.feature`: escenarios CRUD positivos
- `features/users/users-negative.feature`: escenarios negativos
- `features/users/helpers/create-user.feature`: helper reusable para creación de usuarios
- `schemas/`: validaciones de esquema JSON
- `helpers/DataGenerator.java`: generación de datos únicos

## Requisitos
- Java 17 o superior
- Maven instalado y configurado en variables de entorno

## Ejecución
```bash
mvn test

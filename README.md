# Automatización QA - API ServeRest | Karate DSL

Suite de pruebas automatizadas sobre el endpoint `/usuarios` de [ServeRest](https://serverest.dev/),
construida con Karate DSL como parte de un reto de automatización backend.

## Requisitos previos

- Java 17 o superior
- Maven 3.6+

Verificar instalación:
```bash
java -version
mvn -version
```

## Cómo ejecutar
```bash
mvn test
```

Para correr en un entorno específico:
```bash
mvn test -Dkarate.env=local
```

Entornos disponibles: `qa` (default), `local`, `prod`.

## Estructura del proyecto
```
src/test/
├── java/
│   ├── helpers/
│   │   └── DataGenerator.java        # Generación dinámica de datos de prueba
│   └── runners/
│       └── UsersRunner.java          # Runner JUnit 5 que lanza la suite
└── resources/
    ├── karate-config.js              # Configuración global por entorno
    └── features/
        ├── data/
        │   └── user-template.json    # Template de referencia para payloads
        ├── schemas/
        │   ├── user-schema.json      # Schema de un usuario individual
        │   ├── user-list-schema.json # Schema del listado de usuarios
        │   └── message-schema.json   # Schema de respuestas de mensaje
        └── users/
            ├── helpers/
            │   └── create-user.feature   # Helper reutilizable de creación
            ├── users-crud.feature        # Escenarios positivos CRUD
            └── users-negative.feature    # Escenarios negativos
```

## Estrategia de automatización

Los tests cubren las cinco operaciones CRUD del endpoint `/usuarios`:
`GET /usuarios`, `POST /usuarios`, `GET /usuarios/{_id}`, `PUT /usuarios/{_id}` y `DELETE /usuarios/{_id}`.

**Patrón helper**: `create-user.feature` actúa como factory reutilizable. Cada escenario
que necesita un usuario preexistente lo llama desde el `Background`, manteniendo los tests
independientes entre sí sin depender de datos fijos.

**Generación dinámica de datos**: `DataGenerator.java` produce emails, nombres y contraseñas
únicos por ejecución usando UUID, evitando colisiones en los tests de duplicados.

**Validación de esquemas**: todas las respuestas exitosas y de error se validan contra
schemas JSON definidos en `features/schemas/`, separando la validación estructural
de la validación de valores concretos.

**Casos negativos cubiertos**: email duplicado, ID inexistente en GET/PUT/DELETE,
campos vacíos en POST, y conflicto de email en PUT.

## Tecnologías

- Java 17
- Maven
- Karate DSL 1.x
- JUnit 5
Feature: CRUD de usuarios en ServeRest

  Background:
    * url baseUrl
    * def userSchema = read('classpath:features/schemas/user-schema.json')
    * def userListSchema = read('classpath:features/schemas/user-list-schema.json')
    * def messageSchema = read('classpath:features/schemas/message-schema.json')
    * def createUserResult = call read('classpath:features/users/helpers/create-user.feature')
    * def existingUser = createUserResult.createdUser

  Scenario: Obtener lista de todos los usuarios
    Given path 'usuarios'
    When method get
    Then status 200
    And match response == userListSchema
    And match response.usuarios == '#[]'
    And match each response.usuarios contains
    """
    {
      "_id": "#string",
      "nome": "#string",
      "email": "#string",
      "password": "#string",
      "administrador": "#string"
    }
    """

  Scenario: Registrar nuevo usuario con datos válidos
    * def DataGenerator = Java.type('helpers.DataGenerator')
    * def payload =
    """
    {
      "nome": "#(DataGenerator.uniqueName())",
      "email": "#(DataGenerator.uniqueEmail())",
      "password": "#(DataGenerator.randomPassword())",
      "administrador": "true"
    }
    """
    Given path 'usuarios'
    And request payload
    When method post
    Then status 201
    And match response == { message: 'Cadastro realizado com sucesso', _id: '#string' }

  Scenario: Buscar usuario por ID
    Given path 'usuarios', existingUser._id
    When method get
    Then status 200
    And match response == userSchema
    And match response._id == existingUser._id
    And match response.nome == existingUser.nome
    And match response.email == existingUser.email

  # Scenario Outline de PUT: prueba actualizar el usuario con diferentes combinaciones de datos
  # Cada fila de Examples es una ejecución independiente con distintos valores
  Scenario Outline: Actualizar usuario con diferentes datos
    * def updatedPayload =
    """
    {
      "nome": "<nombre>",
      "email": "#(existingUser.email)",
      "password": "<password>",
      "administrador": "<administrador>"
    }
    """
    Given path 'usuarios', existingUser._id
    And request updatedPayload
    When method put
    Then status 200
    And match response == { message: 'Registro alterado com sucesso' }
    # Verificación post-update: confirmamos que los datos nuevos persisten
    Given path 'usuarios', existingUser._id
    When method get
    Then status 200
    And match response.nome == '<nombre>'
    And match response.administrador == '<administrador>'

    Examples:
      | nombre                  | password    | administrador |
      | Usuario QA Actualizado  | NewPass123  | false         |
      | Admin QA Actualizado    | AdminPass1  | true          |
      | Tester QA               | TestPass99  | false         |

  # Scenario Outline de DELETE: crea un usuario nuevo por cada fila y lo elimina
  # Usamos el helper directamente dentro del outline para tener usuarios independientes
  Scenario Outline: Eliminar usuario y verificar que ya no existe
    * def newUserResult = call read('classpath:features/users/helpers/create-user.feature')
    * def userToDelete = newUserResult.createdUser
    Given path 'usuarios', userToDelete._id
    When method delete
    Then status 200
    And match response == { message: 'Registro excluído com sucesso' }
    # Verificación post-delete: el usuario ya no debe encontrarse
    Given path 'usuarios', userToDelete._id
    When method get
    Then status 400
    And match response == { message: 'Usuário não encontrado' }

    Examples:
      | iteracion |
      | 1         |
      | 2         |
      | 3         |
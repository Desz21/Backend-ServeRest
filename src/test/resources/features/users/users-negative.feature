Feature: Casos negativos de usuarios en ServeRest

  Background:
    * url baseUrl
    * def messageSchema = read('classpath:features/schemas/message-schema.json')
    * def createUserResult = call read('classpath:features/users/helpers/create-user.feature')
    * def existingUser = createUserResult.createdUser
    * def DataGenerator = Java.type('helpers.DataGenerator')

  Scenario: No permitir registrar usuario con email duplicado
    * def duplicatePayload =
    """
    {
      "nome": "Duplicado QA",
      "email": "#(existingUser.email)",
      "password": "Test1234",
      "administrador": "true"
    }
    """
    Given path 'usuarios'
    And request duplicatePayload
    When method post
    Then status 400
    # Validamos schema del error y el mensaje específico de la API
    And match response == messageSchema
    And match response == { message: 'Este email já está sendo usado' }

  Scenario: Buscar usuario con ID inexistente
    Given path 'usuarios', 'ABCDEF1234567890'
    When method get
    Then status 400
    And match response == messageSchema
    And match response == { message: 'Usuário não encontrado' }

  Scenario: Eliminar usuario con ID inexistente
    Given path 'usuarios', 'ABCDEF1234567890'
    When method delete
    Then status 200
    And match response == messageSchema
    And match response == { message: 'Nenhum registro excluído' }

  Scenario: Registrar usuario sin campos obligatorios
    * def invalidPayload =
    """
    {
      "nome": "",
      "email": "",
      "password": "",
      "administrador": "true"
    }
    """
    Given path 'usuarios'
    And request invalidPayload
    When method post
    Then status 400
    # La API devuelve un objeto con los mensajes de error por campo
    And match response.nome == '#string'
    And match response.email == '#string'
    And match response.password == '#string'

  # Caso negativo de PUT: actualizar usuario con ID que no existe
  Scenario: Actualizar usuario con ID inexistente
    * def payload =
    """
    {
      "nome": "No Existe",
      "email": "#(DataGenerator.uniqueEmail())",
      "password": "Test1234",
      "administrador": "false"
    }
    """
    Given path 'usuarios', 'ABCDEF1234567890'
    And request payload
    When method put
    #Aquí surge un tema, porque debería ser 400, pero el sistema ingresa uno nuevo y da 201
    Then status 400
    And match response == messageSchema
    And match response == { message: 'Usuário não encontrado' }

  # Caso negativo de PUT: email ya usado por otro usuario
  Scenario: Actualizar usuario con email ya registrado
    # Creamos un segundo usuario para tener dos emails distintos en el sistema
    * def secondUserResult = call read('classpath:features/users/helpers/create-user.feature')
    * def secondUser = secondUserResult.createdUser
    * def conflictPayload =
    """
    {
      "nome": "Conflicto QA",
      "email": "#(secondUser.email)",
      "password": "Test1234",
      "administrador": "true"
    }
    """
    # Intentamos actualizar existingUser con el email de secondUser — debe fallar
    Given path 'usuarios', existingUser._id
    And request conflictPayload
    When method put
    Then status 400
    And match response == { message: 'Este email já está sendo usado' }
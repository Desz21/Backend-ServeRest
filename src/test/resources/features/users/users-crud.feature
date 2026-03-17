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

  Scenario: Buscar usuario por ID
    Given path 'usuarios', existingUser._id
    When method get
    Then status 200
    And match response == userSchema
    And match response._id == existingUser._id
    And match response.nome == existingUser.nome
    And match response.email == existingUser.email

  Scenario: Actualizar usuario existente
    * def updatedPayload =
    """
    {
      "nome": "Usuario QA Actualizado",
      "email": "#(existingUser.email)",
      "password": "NewPass123",
      "administrador": "false"
    }
    """
    Given path 'usuarios', existingUser._id
    And request updatedPayload
    When method put
    Then status 200
    And match response == { message: 'Registro alterado com sucesso' }

    Given path 'usuarios', existingUser._id
    When method get
    Then status 200
    And match response.nome == 'Usuario QA Actualizado'
    And match response.email == existingUser.email
    And match response.administrador == 'false'

  Scenario: Eliminar usuario existente
    * def newUserResult = call read('classpath:features/users/helpers/create-user.feature')
    * def userToDelete = newUserResult.createdUser

    Given path 'usuarios', userToDelete._id
    When method delete
    Then status 200
    And match response == { message: 'Registro excluído com sucesso' }

    Given path 'usuarios', userToDelete._id
    When method get
    Then status 400
    And match response == { message: 'Usuário não encontrado' }
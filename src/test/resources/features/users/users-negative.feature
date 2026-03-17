Feature: Casos negativos de usuarios en ServeRest

  Background:
    * url baseUrl
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
    And match response == { message: 'Este email já está sendo usado' }

  Scenario: Buscar usuario con ID inexistente
    Given path 'usuarios', 'ABCDEF1234567890'
    When method get
    Then status 400
    And match response == { message: 'Usuário não encontrado' }

  Scenario: Eliminar usuario con ID inexistente
    Given path 'usuarios', 'ABCDEF1234567890'
    When method delete
    Then status 200
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
    And match response.nome == '#string'
    And match response.email == '#string'
    And match response.password == '#string'
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
    And match response == messageSchema
    And match response == { message: 'Este email já está sendo usado' }

  # Scenario Outline para probar GET con múltiples IDs inválidos
  # Verifica que la API siempre responde consistentemente con cualquier ID inexistente
  Scenario Outline: Buscar usuario con ID inexistente
    Given path 'usuarios', '<id_invalido>'
    When method get
    Then status 400
    And match response == messageSchema
    And match response == { message: 'Usuário não encontrado' }

    Examples:
      | id_invalido      |
      | ABCDEF1234567890 |
      | 0000000000000000 |
      | invalidID999XXXX |
      | 1234888GRGERG18R |

  # Scenario Outline para probar DELETE con múltiples IDs inválidos
  # ServeRest devuelve 200 con mensaje específico cuando el ID no existe
  Scenario Outline: Eliminar usuario con ID inexistente
    Given path 'usuarios', '<id_invalido>'
    When method delete
    Then status 200
    And match response == messageSchema
    And match response == { message: 'Nenhum registro excluído' }

    Examples:
      | id_invalido          |
      | ABCDEF1234567890     |
      | 000000000000000000   |
      | invalidID999         |

  # Scenario Outline para probar POST con diferentes combinaciones de campos inválidos
  # Cada fila representa un caso de validación distinto que la API debe rechazar
  Scenario Outline: Registrar usuario con datos inválidos
    * def invalidPayload =
    """
    {
      "nome": "<nome>",
      "email": "<email>",
      "password": "<password>",
      "administrador": "true"
    }
    """
    Given path 'usuarios'
    And request invalidPayload
    When method post
    Then status 400
    # Verificamos que la API devuelve error por el campo inválido correspondiente
    And match response.<campo_error> == '#string'

    Examples:
      | nome       | email              | password  | campo_error |
      |            | qa@mail.com        | Test1234  | nome        |
      | Usuario QA |                    | Test1234  | email       |
      | Usuario QA | qa@mail.com        |           | password    |
      |            |                    |           | nome        |

  # Scenario Outline para probar PUT con ID inexistente
  # ServeRest hace upsert: si el ID no existe crea el usuario (201)
  Scenario Outline: Actualizar usuario con ID inexistente debe retornar error
    * def payload =
  """
  {
    "nome": "<nome>",
    "email": "#(DataGenerator.uniqueEmail())",
    "password": "<password>",
    "administrador": "<administrador>"
  }
  """
    Given path 'usuarios', 'ABCDEF1234567890'
    And request payload
    When method put
  # Este test arrojará error porque nos retorna un 201 y no un 400 que es lo esperado
    Then status 400
    And match response == messageSchema
    And match response == { message: 'Usuário não encontrado' }

    Examples:
      | nome         | password   | administrador |
      | No Existe 1  | Test1234   | false         |
      | No Existe 2  | Pass5678   | true          |

  Scenario: Actualizar usuario con email ya registrado
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
    Given path 'usuarios', existingUser._id
    And request conflictPayload
    When method put
    Then status 400
    And match response == { message: 'Este email já está sendo usado' }
Feature: CRUD de usuarios en ServeRest

  Background:
    * url baseUrl
    # Cargamos los schemas JSON para validar la estructura de las respuestas
    * def userSchema = read('classpath:features/schemas/user-schema.json')
    * def userListSchema = read('classpath:features/schemas/user-list-schema.json')
    * def messageSchema = read('classpath:features/schemas/message-schema.json')
    # Llamamos al helper que crea un usuario y devuelve sus datos para usarlos en los tests
    * def createUserResult = call read('classpath:features/users/helpers/create-user.feature')
    * def existingUser = createUserResult.createdUser

  # --- GET /usuarios ---
  Scenario: Obtener lista de todos los usuarios
    Given path 'usuarios'
    When method get
    Then status 200
    # Validamos que la respuesta cumple el schema definido en user-list-schema.json
    And match response == userListSchema
    And match response.usuarios == '#[]'
    # Verificamos que cada elemento de la lista tenga los campos esperados basados en el contrato de serverest
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

  # --- POST /usuarios ---
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
    # Validamos que la respuesta tiene el mensaje correcto y un _id generado
    And match response == { message: 'Cadastro realizado com sucesso', _id: '#string' }

  # --- GET /usuarios/{_id} ---
  Scenario: Buscar usuario por ID
    Given path 'usuarios', existingUser._id
    When method get
    Then status 200
    And match response == userSchema
    # Verificamos que los datos del usuario coincidan con lo que se creó
    And match response._id == existingUser._id
    And match response.nome == existingUser.nome
    And match response.email == existingUser.email

  # --- PUT /usuarios/{_id} ---
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
    # Verificación post-update: consultamos el usuario para confirmar que los cambios persisten
    Given path 'usuarios', existingUser._id
    When method get
    Then status 200
    And match response.nome == 'Usuario QA Actualizado'
    And match response.email == existingUser.email
    And match response.administrador == 'false'

  # --- DELETE /usuarios/{_id} ---
  Scenario: Eliminar usuario existente
    # Creamos un usuario nuevo específicamente para borrarlo (no afecta otros escenarios)
    * def newUserResult = call read('classpath:features/users/helpers/create-user.feature')
    * def userToDelete = newUserResult.createdUser
    Given path 'usuarios', userToDelete._id
    When method delete
    Then status 200
    And match response == { message: 'Registro excluído com sucesso' }
    # Verificación post-delete: confirmamos que el usuario ya no existe
    Given path 'usuarios', userToDelete._id
    When method get
    Then status 400
    And match response == { message: 'Usuário não encontrado' }
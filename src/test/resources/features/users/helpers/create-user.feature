Feature: Helper para crear usuarios

  Scenario:
    * def DataGenerator = Java.type('helpers.DataGenerator')
    * def email = DataGenerator.uniqueEmail()
    * def name = DataGenerator.uniqueName()
    * def password = DataGenerator.randomPassword()

    * url baseUrl
    * path 'usuarios'
    * def payload =
    """
    {
      "nome": "#(name)",
      "email": "#(email)",
      "password": "#(password)",
      "administrador": "true"
    }
    """
    And request payload
    When method post
    Then status 201
    And match response == { message: 'Cadastro realizado com sucesso', _id: '#string' }

    * def createdUser =
    """
    {
      "_id": "#(response._id)",
      "nome": "#(name)",
      "email": "#(email)",
      "password": "#(password)",
      "administrador": "true"
    }
    """
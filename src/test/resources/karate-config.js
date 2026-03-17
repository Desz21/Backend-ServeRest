function fn() {
  // Si no se especifica, usamos 'qa' por defecto
  var env = karate.env || 'qa';

  // Configuración base — se sobreescribe según el entorno
  var config = {
    baseUrl: 'https://serverest.dev'
  };

  // Switch de entornos:
  if (env === 'local') {
    config.baseUrl = 'http://localhost:3000';
  } else if (env === 'prod') {
    config.baseUrl = 'https://serverest.dev';
  }

  // Timeouts globales para todas las requests (en milisegundos)
  karate.configure('connectTimeout', 5000);
  karate.configure('readTimeout', 5000);

  return config;
}
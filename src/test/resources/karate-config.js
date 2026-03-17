function fn() {
  var env = karate.env || 'qa';

  var config = {
    baseUrl: 'https://serverest.dev',
    connectTimeout: 5000,
    readTimeout: 5000
  };

  karate.configure('connectTimeout', config.connectTimeout);
  karate.configure('readTimeout', config.readTimeout);

  return config;
}
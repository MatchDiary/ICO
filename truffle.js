// Allows us to use ES6 in our migrations and tests.
require('babel-register')

module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*', // Match any network id
      gas: 6000000,
      gasPrice: 13000000000,
    }, 
    rinkeby: {
      host: "localhost", // Connect to geth on the specified
      port: 8545,
      network_id: 4,
      gas: 6000000, // Gas limit used for deploys
      gasPrice: 13000000000,
    },
    live: {
      network_id: 1,
      host: "127.0.0.1",
      port: 8545,
      gasPrice: 13000000000, // in wei
    }
  }
}

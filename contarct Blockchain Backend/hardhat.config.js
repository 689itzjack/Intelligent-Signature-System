require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: "0.8.9",
  networks: {
    localganache: {
      url: process.env.PROVIDER_URL,
      accounts: [`0x${process.env.PRIVATE_KEY2}`]
    }
  }
};


//EL CODIGO DE ABAJO LO UTILIZAMOS PARA CONECTARNOS AL TESTNET GOERLI, OSEA UNA BLOCKCHAIN NO LOCAL 
/*require("@nomicfoundation/hardhat-toolbox");

// Go to https://www.alchemyapi.io, sign up, create
// a new App in its dashboard, and replace "KEY" with its key

// Replace this private key with your Goerli account private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Beware: NEVER put real Ether into testing accounts
const fs = require('fs');
const ALCHEMY_API_KEY = fs.readFileSync(".secret/api").toString().trim();;
const mnemonic = fs.readFileSync(".secret/llave").toString().trim();

module.exports = {
  solidity: "0.8.9",
  networks: {
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [mnemonic]
    }
  }
};*/

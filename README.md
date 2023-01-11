# Sample Smart Contracts

## Overview
The purpose of this repository is to demonstrate the smart contract development skills of Kevin Li. For business or employment inquiries please contact me at kevin.blockchain.dev@gmail.com. 

The smart contracts of this repository contains an example contract with basic roles and example value modifications for an address. The example contract acts as the base implementation for a contract factory that deploys clones and upgradable proxies with the example contract as its implementation.

## Contents
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
  - [Testing](#testing)
  - [Deployment](#deployment)
- [Goerli Deployments](#goerli-deployments)
- [Design Nuances](#design-nuances)
- [Work In Progress](#work-in-progress)

## Getting Started

### Prerequisites

- Node.js (Recommended version: latest)
- Solidity (version: ^0.8.17)

### Setup

Go to the root folder of the project in terminal:

1. Install dependencies with `npm install` or `yarn install`
2. Setup the environment variables by creating a `.env` file inside the root directory. Then fill out the environment variables in accordance with `.env.example`

### Testing

1. `yarn test` to compile the contracts and run the test suites for the smart contracts

### Deployment

1. `yarn compile` to compile the contracts
2. `yarn deploy:goerli` to deploy the contracts to Ethereum Goerli Testnet
3. `yarn verify:goerli` to verify the contracts on https://goerli.etherscan.io/

## Goerli Deployments
- Base Example Contract https://goerli.etherscan.io/address/0xa6b93c8c03d66394883f49cdbb5452f0932ea386
- Example Factory https://goerli.etherscan.io/address/0xa9d43206522d9a0698b04d0d4259a60446737d8e
- Factory Deployed Deterministic Clone https://goerli.etherscan.io/address/0x24ca8fa327395b02dbef8d5f4675710acf661842

## Design nuances
- Reverting with a custom error is gas efficient since Solidity v0.8.4, therefore it is being used in the example contracts
https://blog.soliditylang.org/2021/04/21/custom-errors/

- Generating a new salt in the factory rather than just using the inputted salt is to reduce unintentional collisions

## Work In Progress
- More details in this readme file
- Complete the test cases for ExampleContract
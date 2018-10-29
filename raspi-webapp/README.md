# RChain Coin-Faucet
An application built using RChain and node.js that will allow anyone to create a crypto-currency, and then drop those coins on nearby phones based on a schedule. 

Written By: Chris Williams
Special Thanks: Dan Connolly, Joshy Orndorff

## Just make this thing run!
It's ~~nice~~ necessary to know what you're building before you start building it. So you may want to launch the project before we even begin.

1. Install RNode ([instructions](todo))
2. Install node and npm ([instructions](todo))
3. Clone the repo `git clone https://github.com/crypto-coder/coin-faucet.git`
4. Change into the web project directory `cd coin-faucet/raspi-webapp`
5. Install dependencies `npm install`
6. Start a fresh, pre-configured RNode `npm run fresh`
7. Deploy the necessary smart contract to your node `npm run deploy-contract`
8. Launch the dapp `npm start`
9. Read through the logs to see what RNode and Node accomplished

## Overview of writing a dapp
Before we begin, I'll show you the plan. These are the big-picture steps that you'll need to follow in order to write any dapp

1. Design the smart contract -- ours is in `coinFaucet.rho`
2. Design an interface -- We're using Angular2 + Loopback 
3. Connect the contract -- We'll use the `rchain-api` NPM module
4. Deploy your contract
5. Use your dapp
6. Celebrate :)

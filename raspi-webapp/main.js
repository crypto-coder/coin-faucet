"use strict"

const {RNode, RHOCore, logged} = require("rchain-api");
const express = require('express');
const bodyParser = require('body-parser');
const grpc = require('grpc');
const keccak256 = require('js-sha3').keccak256;

// Setup server parameters
var host   = process.argv[2] ? process.argv[2] : "localhost"
var port   = process.argv[3] ? process.argv[3] : 40401
var uiPort = process.argv[4] ? process.argv[4] : 8080

var myNode = RNode(grpc, {host, port})
var app = express()

// CoinRegistry unforgeable names
var COIN_REGISTRY_UNAME = null;

// Serve static assets like index.html and page.js from root directory
app.use(express.static(__dirname))

app.use(bodyParser.json());

app.listen(uiPort, () => {
  console.log("RChain status dapp started.")
  console.log(`Connected to RNode at ${host}:${port}.`)
  console.log(`Userinterface on port ${uiPort}`)

  // Create the CoinRegistry return channel
  var coinRegistryChannel = Math.random().toString(36).substring(7);


  //  rho:id:yg4w3qmdyddks11c5f4uqp7nb7pq5ygdf4gecwk398sixr7wfmw144
  var deployCoinRegistryData = {
    term: `new rl(\`rho:registry:lookup\`), ack in {
                rl!(\`rho:id:yg4w3qmdyddks11c5f4uqp7nb7pq5ygdf4gecwk398sixr7wfmw144\`, *ack)
                |
                for(BigTest <- ack){
                  BigTest!("")
                }
              }`,
    timestamp: new Date().valueOf(),
    from: '0x1',
    nonce: 0,
    phloPrice: { value: 1 },
    phloLimit: { value: 100000000 }
  };

  // Deploy the CoinRegistry contract
  myNode.doDeploy(deployCoinRegistryData).then(registryResult => {
    console.log("CoinRegistry initialized on blockchain as : " + coinRegistryChannel);
    console.log(registryResult);

    // Get the CoinRegistry unforgeable name from the channel
    return myNode.listenTest(coinRegistryChannel);
  }).then((blockResults) => {
    if(blockResults.length === 0){
      console.log("ERROR: Failed to create the CoinRegistry.");
      return;
    }
    var lastBlock = blockResults.slice(-1).pop();
    var lastDatum = lastBlock.postBlockData.slice(-1).pop();
    COIN_REGISTRY_UNAME = RHOCore.toRholang(lastDatum);
  }).catch(oops => { console.log(oops); })
})


/////////////////////////////////////////////////


app.post('/createCoin', (req, res) => {
  var ack = Math.random().toString(36).substring(7);
  
  var coinID = getCoinID(req.body.name);
  var code = `@["${coinFaucetID}", "createCoin"]!("${req.body.account}","${coinID}","${req.body.name}","${req.body.symbol}",${req.body.totalSupply},"${ack}")`
  var deployData = {term: code,
                    timestamp: new Date().valueOf()
                    // from: '0x1',
                    // nonce: 0,
                   }

  myNode.doDeploy(deployData).then(result => {
    return myNode.createBlock()
  }).then(result => {
    res.json({'message':result, 'coinID':coinID});
  }).catch(oops => { console.log(oops); })
});


app.post('/registerCoinAccount', (req, res) => {
  var ack = Math.random().toString(36).substring(7);
  
  var registrationResult = null;
  var code = `@["${coinFaucetID}", "registerCoinAccount"]!("${req.body.account}","${req.body.coin}","${ack}")`
  var deployData = {term: code,
                    timestamp: new Date().valueOf()
                    // from: '0x1',
                    // nonce: 0,
                   }

  myNode.doDeploy(deployData).then(result => {
    return myNode.createBlock();
  }).then(result => {
    registrationResult = result;
    return myNode.listenForDataAtName(ack)
  }).then((blockResults) => {
    if(blockResults.length === 0){
      res.code = 404;
      res.json({"message":"No data found"});
      return;
    }
    var lastBlock = blockResults.slice(-1).pop();
    var lastDatum = lastBlock.postBlockData.slice(-1).pop();
    var coinAccountID = RHOCore.toRholang(lastDatum);
    res.json({'message':registrationResult, 'coinAccountID':coinAccountID});
  }).catch(oops => { console.log(oops); })
});


app.post('/createCoinAward', (req, res) => {
  var ack = Math.random().toString(36).substring(7);

  // Generate the award hash from the salt
  var buffer = Buffer.from(req.body.salt, 'utf8');
  var saltedCoinName = Array.prototype.slice.call(buffer, 0);
  var hash = keccak256(saltedCoinName);
  console.log(hash);

  var code = `@["${coinFaucetID}", "createCoinAward"]!("${req.body.account}","${req.body.coin}",${req.body.amount},"${req.body.salt}","${ack}")`
  var deployData = {term: code,
                  timestamp: new Date().valueOf()
                  // from: '0x1',
                  // nonce: 0,
                  }

  myNode.doDeploy(deployData).then(result => {
    return myNode.createBlock();
  }).then(result => {
    res.json({'message':result});
  }).catch(oops => { console.log(oops); })
});


app.post('/getCoinAwards', (req, res) => {
  var ack = Math.random().toString(36).substring(7);
  
  var coinAwardResults = null;
  var code = `@["${coinFaucetID}", "getCoinAwards"]!("${ack}")`
  var deployData = {term: code,
                    timestamp: new Date().valueOf()
                    // from: '0x1',
                    // nonce: 0,
                   }

  myNode.doDeploy(deployData).then(result => {
    return myNode.createBlock();
  }).then(result => {
    coinAwardResults = result;
    return myNode.listenForDataAtName(ack)
  }).then((blockResults) => {
    if(blockResults.length === 0){
      res.code = 404;
      res.json({"message":"No data found"});
      return;
    }
    var lastBlock = blockResults.slice(-1).pop();
    var lastDatum = lastBlock.postBlockData.slice(-1).pop();
    var awardList = RHOCore.toRholang(lastDatum);
    res.json({'message':coinAwardResults, 'awardList':awardList});
  }).catch(oops => { console.log(oops); })
});


app.post('/getCoinAccounts', (req, res) => {
  var ack = Math.random().toString(36).substring(7);
  
  var coinAccountResults = null;
  var code = `@["${coinFaucetID}", "getCoinAccounts"]!("${ack}")`
  var deployData = {term: code,
                    timestamp: new Date().valueOf()
                    // from: '0x1',
                    // nonce: 0,
                   }

  myNode.doDeploy(deployData).then(result => {
    return myNode.createBlock();
  }).then(result => {
    coinAccountResults = result;
    return myNode.listenForDataAtName(ack)
  }).then((blockResults) => {
    if(blockResults.length === 0){
      res.code = 404;
      res.json({"message":"No data found"});
      return;
    }
    var lastBlock = blockResults.slice(-1).pop();
    var lastDatum = lastBlock.postBlockData.slice(-1).pop();
    var accountList = RHOCore.toRholang(lastDatum);
    res.json({'message':coinAccountResults, 'accountList':accountList});
  }).catch(oops => { console.log(oops); })
});


app.post('/redeemCoinAward', (req, res) => {
  var ack = Math.random().toString(36).substring(7);
  
  var redeemResult = null;
  var code = `@["${coinFaucetID}", "redeemCoinAward"]!("${req.body.account}","${req.body.coin}","${req.body.salt}","${ack}")`
  var deployData = {term: code,
                    timestamp: new Date().valueOf()
                    // from: '0x1',
                    // nonce: 0,
                   }

  myNode.doDeploy(deployData).then(result => {
    return myNode.createBlock();
  }).then(result => {
    redeemResult = result;
    return myNode.listenForDataAtName(ack)
  }).then((blockResults) => {
    if(blockResults.length === 0){
      res.code = 404;
      res.json({"message":"Failed to redeem any award"});
      return;
    }
    var lastBlock = blockResults.slice(-1).pop();
    var lastDatum = lastBlock.postBlockData.slice(-1).pop();
    var newBalance = RHOCore.toRholang(lastDatum);
    res.json({'message':redeemResult, 'newBalance':newBalance});
  }).catch(oops => { console.log(oops); })
});



app.post('/createTokenAward', (req, res) => {
  // Generate a public ack channel
  // TODO this should be unforgeable. Can I make one from JS?
  var ack = Math.random().toString(36).substring(7)

  // This shouldn't actually require a transaction, for publicly visible data, right?
  // Check the status, sending it to the ack channel
  var code = `@["${req.query.name}", "check"]!("${ack}")`
  var deployData = {term: code,
                    timestamp: new Date().valueOf()
                    // from: '0x1',
                    // nonce: 0,
                   }
  myNode.doDeploy(deployData).then(_ => {
    return myNode.createBlock()
  }).then(_ => {
    // Get the data from the node
    return myNode.listenForDataAtName(ack)
  }).then((blockResults) => {
    if(blockResults.length === 0){
      res.code = 404
      res.send("No data found")
      //TODO Do I need to return here?
    }
    var lastBlock = blockResults.slice(-1).pop()
    var lastDatum = lastBlock.postBlockData.slice(-1).pop()
    res.send(RHOCore.toRholang(lastDatum))
  }).catch(oops => { console.log(oops); })
})



function getCoinID(name){
  return name.toLowerCase().replace(/\W/g, '');
}

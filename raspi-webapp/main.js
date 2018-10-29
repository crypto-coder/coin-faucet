"use strict"

const {RNode, RHOCore, b2h, h2b} = require("rchain-api");
const express = require('express');
const bodyParser = require('body-parser');
const grpc = require('grpc');

// Setup server parameters
var host   = process.argv[2] ? process.argv[2] : "localhost"
var port   = process.argv[3] ? process.argv[3] : 40401
var uiPort = process.argv[4] ? process.argv[4] : 8080

var myNode = RNode(grpc, {host, port})
var app = express()

// CoinFaucet Lookup ID
var COIN_FAUCET_ID = "";

// Serve static assets like index.html and page.js from root directory
app.use(express.static(__dirname));

app.use(bodyParser.json());

app.listen(uiPort, () => {
  console.log("RChain coin-faucet dapp started.");
  console.log(`Connected to RNode at ${host}:${port}.`);
  console.log(`Userinterface on port ${uiPort}`);
  
  // Retrieve all the blocks from the blockchain (hopefully less than 10000)
  return myNode.getAllBlocks(10000).then(blockList => {
    // Get the blockhash from the block after the genesis block (blockList.length - 2)
    return myNode.getBlock( blockList[blockList.length-2].blockHash );
  }).then(requestedBlock => {
    // Extract the tuplespace from the retrieved block
    var tuplespace = requestedBlock.blockInfo.tupleSpaceDump;
    // Locate the first registered ID in the tuplespace, assume it is the CoinFaucet ID created when the smart contract was deployed
    COIN_FAUCET_ID = tuplespace.substring(tuplespace.indexOf('`rho:id')+1, tuplespace.indexOf('`', tuplespace.indexOf('`rho:id')+1));
    console.log("CoinFaucet lookup ID = " + COIN_FAUCET_ID);
  }).catch(err => {
    console.log("ERROR: Could not retrieve CoinFaucet lookup ID from tuplespace");
    console.log(err);
    process.exit(1);
  });
});


/////////////////////////////////////////////////


app.post('/createCoin', (req, res) => {
  var coinID = getCoinID(req.body.name);
  var ack = Math.random().toString(36).substring(7);  

  var smartContract_createCoin = createSmartContractCall(COIN_FAUCET_ID, 
                                                          "createCoin", 
                                                          [
                                                            coinID,
                                                            req.body.name,
                                                            req.body.symbol
                                                          ],
                                                          ack
                                                        );
  var createCoinData = createCompleteRequest(smartContract_createCoin);

  // Execute the smart contract
  myNode.doDeploy(createCoinData, true).then(createCoinResults => {
    console.log("Attempted to create a new Coin Mint. Lookup ID should be available on return Channel : " + ack);

    // Get the mint lookup ID from the channel
    return myNode.listenForDataAtPublicName(ack);
  }).then((blockResults) => {
    if(blockResults.length === 0){
      console.log("ERROR: Failed to create the Coin Mint.");
      res.status(500).json({ message: "ERROR: Failed to create the Coin Mint." });
      return;
    }
    var lastBlock = blockResults.slice(-1).pop();
    var lastDatum = lastBlock.postBlockData.slice(-1).pop();
    var COIN_MINT_LOOKUP_ID = RHOCore.toRholang(lastDatum).replace(/\"/g, '');

    if (COIN_MINT_LOOKUP_ID === "EXISTS") {
      console.log("ERROR: A Coin Mint for this coin already exists");
      res.status(400).json({ message: "ERROR: A Coin Mint for this coin already exists" });
    } else {
      console.log("SUCCESS: Created the Coin Mint for " + req.body.name);
      res.json({ message: "SUCCESS: Created the Coin Mint for " + req.body.name, lookupID: COIN_MINT_LOOKUP_ID });
    }
  }).catch(oops => { 
    console.log(oops);
    res.status(500).json({ message: "ERROR", error: JSON.stringify(oops) }); 
  });

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


function createSmartContractCall(lookupID, smartContractName, parameterValues, callbackChannel) {
  // Create the smart contract call prefix
  var smartContractCall = `new lookup(\`rho:registry:lookup\`), ack in {
                              lookup!(\`${lookupID}\`, *ack)
                              |
                              for(smartContract <- ack){
                                smartContract!("${smartContractName}"`;
                              
  // Add the parameters if they were provided
  if (typeof parameterValues == 'object' && Array.isArray(parameterValues)){
    for(var i = 0; i < parameterValues.length; i++){
      smartContractCall += ', "' + parameterValues[i] + '"';
    }
  }

  // Add the callback channel if it was provided
  if (callbackChannel !== null) {
    smartContractCall += ', "' + callbackChannel + '"';
  }

  // Add the smart contract call suffix
  smartContractCall +=           `)
                              }
                          }`;

  return smartContractCall;
}

function createCompleteRequest(smartContractCall, phloPrice=1, phloLimit=10000000) {
  return {
    term:  smartContractCall,
    timestamp: new Date().valueOf(),
    from: '0x01',
    nonce: 0,
    phloPrice: { value: phloPrice },
    phloLimit: { value: phloLimit }
  };
}
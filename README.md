![_Simple_Voting_Contract (1)](https://user-images.githubusercontent.com/100613640/166903388-d273b1e4-7874-4312-87a7-062d20a27e82.png)


![GitHub repo size](https://img.shields.io/github/repo-size/moonman369/Simple-Voting-contract)
![GitHub](https://img.shields.io/github/license/moonman369/Simple-Voting-Contract)
![GitHub language count](https://img.shields.io/github/languages/count/moonman369/Simple-Voting-Contract)
![GitHub top language](https://img.shields.io/github/languages/top/moonman369/Simple-Voting-Contract)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/moonman369/Simple-Voting-Contract)

<br>

# Basic Overview

This is a simple EVM compatible voting smart contract built using solidity. This contract is based on the famous `3_Ballot.sol` contract that is provided by  `Remix IDE` as an example.
This contract basically implements different functions for every action that takes place in a Voting Ballot. Also, it is important to note that there were certain drawbacks in the `Ballot.sol` contract, that I targeted and duly fixed in my `SimpleVoting.sol` contract.

<br>

# Key Features

So, as we know, a basic voting contract has the following functionalities:
- `Creation of Voting Ballot`: Where all the competing proposals and the Chairperson of the Ballot are set
- `Give Right to Vote`: Which can only be called by the Chairperson of the Voting Ballot.
- `Vote`: The most pivotal functionality possessed by a voting contract, can be called by any address with a right to vote.
- `Delegate`: A very interesting property that allows a voter to themselves abstain from voting and transfer that vote to another voter.
- `Compute and display winning proposal`: To compute and display the details of the winning proposal at the end of the voting process.


<br>

# Improvements and Modifications
Apart from the above mentioned basic features, that are already implemented in `Ballot.sol`, the following are some additional features introduced by me in `SimpleVoting.sol`:
- **Use of** `openzepplin/contracts`: This makes my contract safe, efficient and immune to future releases and changes to Solidity itself.
- **Additional** `getters and public variables`: To better monitor the state of my contract.
- **Multiple** `modifiers`: Using the same conditional [require (...)]  

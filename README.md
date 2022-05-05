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
* `Creation of Voting Ballot`: Where all the competing proposals and the Chairperson of the Ballot are set
* `Give Right to Vote`: Which can only be called by the Chairperson of the Voting Ballot.
* `Vote`: The most pivotal functionality possessed by a voting contract, can be called by any address with a right to vote.
* `Delegate`: A very interesting property that allows a voter to themselves abstain from voting and transfer that vote to another voter.
* `Compute and display winning proposal`: To compute and display the details of the winning proposal at the end of the voting process.


<br>

# Improvements and Modifications
Apart from the above mentioned basic features, that are already implemented in `Ballot.sol`, the following are some additional features introduced by me in `SimpleVoting.sol`:
* **Use of** `openzepplin/contracts`: This makes my contract safe, efficient and immune to future releases and changes to Solidity itself.
* **Additional** `getters and public variables`: To better monitor the state of my contract.
* **Multiple** `modifiers`: Using the same conditional [require (...)] statements in every function over and over seemed redundant, hence made the code `DRY`.
* **Modified I/O from** `bytes32` **to** `string`: This was done to improve the readabilty and UX while keeping the gas as low as possible. This was made possible by 2 internal functions:
    - `stringToBytes32 ()`: To convert string to bytes32 value at input.
    - `bytes32ToString ()`: To convert bytes32 to string value at output.
* **Added** `change chairperson` **functionality**: Thought it would be nice to have this feature. Can only be called by the `acting chairperson`.
* **Added** `multiple winning proposals` **feature**: One of the biggest drawbacks of the `Ballot.sol` contract is that it assumes that there will always be only one winning proposal in every voting session, which is not very practical. So, I added provision to check for, compute and return multiple winning proposals if necessary. The necessary code elements are listed below:
    - `winningProposals []`: An array to store the indices of all the winning proposals.
    - `computeWinningProposals ()`: A public function to compute the and add the winning proposals' indices to the above array. Callable only by chairperson.
    - `getWinningProposals ()`: Getter function to display all the winning proposal indices.
    - `getWinnerNames ()`: Getter function to display winning proposal names as a `string`. Uses `bytes32ToString ()`.

![_Simple_Voting_Contract (1)](https://user-images.githubusercontent.com/100613640/166903388-d273b1e4-7874-4312-87a7-062d20a27e82.png)


![Built With](https://img.shields.io/badge/built%20with-SOLIDITY-blueviolet)
![Powered By](https://img.shields.io/badge/powered%20by-ETHEREUM-yellow)
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

Apart from the above mentioned basic features, that are already implemented in `Ballot.sol`, the following are some additional features introduced by me in `SimpleVoting.sol`: <br><br>
1. **Use of** `openzepplin/contracts`: This makes my contract safe, efficient and immune to future releases and changes to Solidity itself.

![image](https://user-images.githubusercontent.com/100613640/166983183-42c9a9d7-3546-4da8-b339-922384e3b9e9.png)<br><br>

2. **Additional** `getters and public variables`: To better monitor the state of my contract.

![image](https://user-images.githubusercontent.com/100613640/166983407-c6316725-963e-4677-99d4-e2f58cbf3632.png)
![image](https://user-images.githubusercontent.com/100613640/166983541-3bf810cb-5256-46c9-b365-dbfe5d9f0418.png)<br><br>

3. **Multiple** `events`: These events are deployed whenever there is a change in the state of the contract and store these events on the blockchain for later use. They also come in handy later during UI integration.   

![image](https://user-images.githubusercontent.com/100613640/166983953-6392597f-4747-48b7-8bc6-9a77347a6c80.png)<br><br>

4. **Multiple** `modifiers`: Using the same conditional `require (...)` statements in every function over and over seemed redundant, hence made the code `DRY`.

![image](https://user-images.githubusercontent.com/100613640/166987989-1d6acdc1-fa92-42ef-9325-a378c9077503.png)
<br><br>

5. **Modified I/O from** `bytes32` **to** `string`: This was done to improve the readabilty and UX while keeping the gas as low as possible. This was made possible by      2 internal functions:
    * `stringToBytes32 ()`: To convert string to bytes32 value at input.
    ![image](https://user-images.githubusercontent.com/100613640/166984784-b6ae5b2e-745a-4b69-b1d4-037cf9e4accd.png)<br>

    * `bytes32ToString ()`: To convert bytes32 to string value at output.
    ![image](https://user-images.githubusercontent.com/100613640/166984903-9c1d9d2c-a330-46c6-a0c3-19e56c835985.png)<br><br>

6. **Added** `change chairperson` **functionality**: Thought it would be nice to have this feature. Can only be called by the `acting chairperson`.

![image](https://user-images.githubusercontent.com/100613640/166985808-6fad9473-32ef-4a5d-8500-96cdad15885c.png)<br><br>

7. **Added** `multiple winning proposals` **feature**: One of the biggest drawbacks of the `Ballot.sol` contract is that it assumes that there will always be only one winning proposal in every voting session, which is not very practical. So, I added provision to check for, compute and return multiple winning proposals if necessary. The necessary code elements are listed below:
    * `winningProposals []`: An array to store the indices of all the winning proposals.
    ![image](https://user-images.githubusercontent.com/100613640/166986142-b2848b1a-790e-4f56-aff1-0de20ec183e1.png)<br>

    * `computeWinningProposals ()`: A public function to compute the and add the winning proposals' indices to the above array. Callable only by chairperson.
    ![image](https://user-images.githubusercontent.com/100613640/166986536-63656cbf-48cd-4740-8e5e-976cb44ae1c1.png)<br>

    * `getWinningProposals ()`: Getter function to display all the winning proposal indices.
    ![image](https://user-images.githubusercontent.com/100613640/166986903-8033bfc9-d449-41f8-bb91-609c4d801945.png)<br>

    * `getWinnerNames ()`: Getter function to display winning proposal names as a `string`. Uses `bytes32ToString ()`.
    ![image](https://user-images.githubusercontent.com/100613640/167020502-d8e703fb-2712-45c2-8b6b-c0fb8c00041d.png)<br><br>

# Contributing
1. Clone repo and create a new branch `$ git checkout https://github.com/moonman369/Simple-Voting-Contract -b <name_of_new_branch>`.
2. Make changes and test.
3. Submit Pull Request with a comprehensive description of changes and modifications.

// contracts/SimpleVoting.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

/** 
 * @title SimpleVoting
 * @dev Implements voting process along with vote delegation
 */
contract SimpleVoting is Context {

    //Using openzepplin's SafeMath library for uint256 variables to prevent wrap-around of values
    using SafeMath for uint256;
   
    //Structure to store the data of a voter
    struct Voter {
        uint256 weight;     // weight is accumulated by delegation
        bool voted;      // true if that voter has already voted
        address delegate;// address, the voter delegated their vote to
        uint256 vote;       // index of the proposal that was voted in favor of
    }

    //Structure to store the data of a proposal
    struct Proposal {
        // If you can limit the length to a certain number of bytes, always use one of bytes1 to bytes32 because they are much cheaper
        bytes32 name;   // short name (up to 32 bytes)
        uint256 voteCount; // number of accumulated votes
    }

    uint256 public proposalCount;   // stores the total number of proposals

    address public chairPerson;     // stores the address of the deployer who is the chair person of the voting ballot

    mapping(address => Voter) public voters;    // maps voter addresses to voter structures

    Proposal[] proposals;   // array of all the proposal structures created

    uint256[] winningProposals;    // integer array storing the indices of ALL the winiing proposals

    event VotingStarted (address _chairPerson, uint256 _proposalCount);    // event to broadcast the deployment of the voting contract

    event VoteCasted (uint256 indexed _proposal, address indexed _voter, uint256 _votesAdded);    // event to broadcast the casting of a vote

    event DelegationSuccessful (address indexed _from, address indexed _to);    // event to broadcast a delegation

    event chairPersonChanged (address indexed _from, address indexed _to);      // event to broadcast a transfer of Chairpersonship

    /** 
     * @dev Modifier: Checks if the caller is the chairperson, reverts if not.
     */
    modifier onlyChairPerson () {
         require(
            _msgSender() == chairPerson,
            "SimpleVoting: Only chairPerson can call this function."
        );
        // Using _msgSender() from Openzepplin's Context.sol 
        // Makes contract immune to deprecation or modification of global variable identifiers like msg.sender and msg.data 
        _;
     }

    /** 
     * @dev Modifier: Checks if a voter has not voted yet, reverts if voted.
     * @param _voter address of the voter
     */
    modifier notYetVoted (address _voter) {
         require(
            !voters[_voter].voted,
            "SimpleVoting: The voter has already voted."
        );
        _;
    }

    /** 
     * @dev Modifier: Checks if a proposal exists in the proposals array.
     * @param _proposalIndex proposal index
     */
    modifier proposalExists (uint256 _proposalIndex) {
        require (
            _proposalIndex < proposalCount, 
            "SimpleVoting: Proposal index out of bounds."
        );
        _;
    }

    /** 
     * @dev Modifier: Checks if a voter has right to vote, reverts if not.
     * @param _voter address of the voter
     */
    modifier hasRightToVote (address _voter) {
        require (
            voters[_voter].weight > 0,
            "SimpleVoting: Address does not have right to vote."
        );
        _;
    }

    /** 
     * @dev Create a new ballot to choose one of 'proposalNames'.
     * @param proposalNames array of names (string) of proposals
     */
    constructor(string[] memory proposalNames) {
        chairPerson = _msgSender();
        voters[chairPerson].weight = 1;
        proposalCount = proposalNames.length;
        for (uint256 i = 0; i < proposalCount; i = i. add(1)) {
            // Instance of 'Proposal' type is created with name and voteCount
            // .push() appends it to the end of 'proposals' array.
            Proposal memory proposal = Proposal (stringToBytes32(proposalNames[i]), 0);
            proposals.push(proposal);
        }
        emit VotingStarted (chairPerson, proposalCount); // broadcasting event
    }

    /** 
     * @dev Returns the name(string) and vote count proposal present at the passed proposal index.
     * @param _proposalIndex index of the desired proposal in the 'proposals' array.
     * @return proposalName_ 
     * @return voteCount_  
     */
    function getProposal (uint256 _proposalIndex) 
        public 
        view 
        proposalExists(_proposalIndex) 
        returns (string memory proposalName_, uint256 voteCount_) 
        {
            // Using multiple assignment and optional return statement feature of solidity
            // bytes32ToString converts Proposals.name (bytes32) to proposalName_ (string) for readabilty of output
            (proposalName_, voteCount_) = 
            (bytes32ToString (proposals[_proposalIndex].name), proposals[_proposalIndex].voteCount);
        }

    /** 
     * @dev Return ALL the winning proposals (proposals with maximum votes)
     * @return winningProposals [] array containing All the winning proposals
     */
    function getWinningProposals () 
        public 
        view 
        returns (uint256[] memory)
        {
            return winningProposals;
        } 
    
    /** 
     * @dev Give 'voter' the right to vote on this ballot. May only be called by 'chairPerson'.
     * @param _voter address of voter
     */
    function giveRightToVote(address _voter) 
        public 
        onlyChairPerson() 
        notYetVoted(_voter) 
        {
            require(voters[_voter].weight == 0, "SimpleVoting: Address already has right to vote.");
            voters[_voter].weight = 1;
        }

    /** 
     * @dev Transfer chairpersonship to another 'voter'. May only be called by the current 'chairPerson'.
     * @param _to address of the new intended chair person
     */
    function transferChairpersonship (address _to) 
        public 
        onlyChairPerson() 
        hasRightToVote(_to) 
        {
            chairPerson = _to;
            emit chairPersonChanged (_msgSender(), _to);
        } 

    /**
     * @dev Delegate your vote to the voter 'to'.
     * @param _to address to which vote is delegated
     */
    function delegate(address _to) 
        public 
        notYetVoted (_msgSender()) 
        hasRightToVote (_msgSender()) 
        {
            Voter storage sender = voters[_msgSender()];
            require (_to != _msgSender(), "SimpleVoting: Self-delegation is not allowed.");

            while (voters[_to].delegate != address(0)) {
                _to = voters[_to].delegate;

                // Found a loop in the delegation, not allowed.
                require(_to != _msgSender(), "SimpleVoting: Delegation traces back to caller.");
            }
            sender.voted = true;
            sender.delegate = _to;
            Voter storage delegate_ = voters[_to];
            if (delegate_.voted) {
                // If the delegate already voted,
                // directly add to the number of votes
                proposals[delegate_.vote].voteCount = proposals[delegate_.vote].voteCount. add(sender.weight);
            } else {
                // If the delegate did not vote yet,
                // add to her weight.
                delegate_.weight = delegate_.weight. add(sender.weight);
            }

            emit DelegationSuccessful (_msgSender(), _to);
        }

    /**
     * @dev Give your vote (including votes delegated to you) to proposal 'proposals[proposal].name'.
     * @param proposal index of proposal in the proposals array
     */
    function vote(uint256 proposal) 
        public 
        proposalExists(proposal)   
        notYetVoted(_msgSender()) 
        hasRightToVote(_msgSender()) 
        {
            Voter storage sender = voters[_msgSender()];
            sender.voted = true;
            sender.vote = proposal;
            proposals[proposal].voteCount = proposals[proposal].voteCount. add(sender.weight);
            emit VoteCasted (proposal, _msgSender(), sender.weight);
        }

    /** 
     * @dev Computes the winning proposal taking all previous votes into account.
     */
    function computeWinningProposals() 
        public 
        onlyChairPerson ()
        {
            uint256 winningVoteCount = 0; uint256 winner = 0;
            delete winningProposals;
            for (uint256 p = 0; p < proposals.length; p = p. add(1)) {
                if (proposals[p].voteCount > winningVoteCount) {
                    winningVoteCount = proposals[p].voteCount;
                    winningProposals.push(p);
                }
            }
            for (uint256 p = 0; p < proposals.length; p = p. add(1)) {
                if (proposals[p].voteCount == proposals[winner].voteCount && p != winner) {
                    winningProposals.push(p);
                }
            }
        }

    /** 
     * @dev Converts the name/s of the winning proposals from bytes32 to string and returns them
     * @return winnerNames_ the name/s of the winner
     */
    function winnerNames() 
        public 
        view
        returns (string memory winnerNames_)
        {
            for (uint256 i = 0; i < winningProposals.length; i = i. add(1)) {
                winnerNames_ = string.concat(winnerNames_,", ", bytes32ToString(proposals[winningProposals[i]].name));
            }
        }

    /** 
     * @dev Converts from string to bytes32 and returns the result
     * @param str a string
     * @return bytes32 version of str
     */
    function stringToBytes32 (string memory str) 
    internal 
    pure
    returns (bytes32) 
    {
        return bytes32(abi.encodePacked(str));
    }

    /** 
     * @dev Converts from bytes32 to string and returns the result
     * @param byt a bytes32 value
     * @return string version of byt
     */
    function bytes32ToString(bytes32 byt) 
    internal 
    pure
    returns (string memory) {
        return string (abi.encodePacked (byt));
    }
}

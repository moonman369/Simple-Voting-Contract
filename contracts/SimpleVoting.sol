// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
/** 
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */
contract SimpleVoting is Context {
    using SafeMath for uint256;
   
    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal
    }

    struct Proposal {
        // If you can limit the length to a certain number of bytes, 
        // always use one of bytes1 to bytes32 because they are much cheaper
        bytes32 name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }

    uint256 public proposalCount;

    address public chairPerson;

    mapping(address => Voter) public voters;

    Proposal[] proposals;

    uint256[] winningProposals;

    event VotingStarted (address _chairPerson, uint256 _proposalCount);

    event VoteCasted (uint256 indexed _proposal, address indexed _voter, uint256 _votesAdded);

    event DelegationSuccessful (address indexed _from, address indexed _to);

    modifier onlyChairPerson () {
         require(
            _msgSender() == chairPerson,
            "SimpleVoting: Only chairPerson can give right to vote."
        );
        _;
     }

    modifier notYetVoted (address _voter) {
         require(
            !voters[_voter].voted,
            "SimpleVoting: The voter has already voted."
        );
        _;
    }

    modifier proposalExists (uint256 _proposalIndex) {
        require (
            _proposalIndex < proposalCount, 
            "SimpleVoting: Proposal index out of bounds."
        );
        _;
    }

    modifier hasRightToVote (address _voter) {
        require (
            voters[_voter].weight > 0,
            "SimpleVoting: Caller does not have right to vote."
        );
        _;
    }

    

    /** 
     * @dev Create a new ballot to choose one of 'proposalNames'.
     * @param proposalNames names of proposals
     */
    constructor(string[] memory proposalNames) {
        chairPerson = _msgSender();
        voters[chairPerson].weight = 1;
        proposalCount = proposalNames.length;
        for (uint i = 0; i < proposalCount; i = i. add(1)) {
            // 'Proposal({...})' creates a temporary
            // Proposal object and 'proposals.push(...)'
            // appends it to the end of 'proposals'.
            Proposal memory proposal = Proposal (stringToBytes32(proposalNames[i]), 0);
            proposals.push(proposal);
        }
        emit VotingStarted (chairPerson, proposalCount);
    }

    function getProposal (uint256 _proposalIndex) public view proposalExists(_proposalIndex) returns (string memory proposalName_, uint256 voteCount_) {
        (proposalName_, voteCount_) = 
        (bytes32ToString (proposals[_proposalIndex].name), proposals[_proposalIndex].voteCount);
    }

    function getWinningProposals () public returns (uint256[] memory){
        computeWinningProposals();
        return winningProposals;
    } 
    
    /** 
     * @dev Give 'voter' the right to vote on this ballot. May only be called by 'chairPerson'.
     * @param _voter address of voter
     */
    function giveRightToVote(address _voter) public onlyChairPerson() notYetVoted(_voter) {
        // require(
        //     _msgSender() == chairPerson,
        //     "Only chairPerson can give right to vote."
        // );
        // require(
        //     !voters[_voter].voted,
        //     "The voter already voted."
        // );
        require(voters[_voter].weight == 0, "SimpleVoting: Address already has right to vote.");
        voters[_voter].weight = 1;
    }

    /**
     * @dev Delegate your vote to the voter 'to'.
     * @param _to address to which vote is delegated
     */
    function delegate(address _to) public notYetVoted (_msgSender()) hasRightToVote (_msgSender()) {
        // require (voters[_msgSender()].weight > 0, "SimpleVoting: Caller does not have right to vote.");
        Voter storage sender = voters[_msgSender()];
        //require(!sender.voted, "You already voted.");
        require (_to != _msgSender(), "SimpleVoting: Self-delegation is not allowed.");

        while (voters[_to].delegate != address(0)) {
            _to = voters[_to].delegate;

            // We found a loop in the delegation, not allowed.
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
    function vote(uint proposal) public proposalExists(proposal) notYetVoted(_msgSender()) hasRightToVote(_msgSender()) {
        Voter storage sender = voters[_msgSender()];
        // require(sender.weight != 0, "SimpleVoting: Caller has no right to vote");
        // require(!sender.voted, "SimpleVoting: Voter has already casted their vote.");
        sender.voted = true;
        sender.vote = proposal;

        // If 'proposal' is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount = proposals[proposal].voteCount. add(sender.weight);

        emit VoteCasted (proposal, _msgSender(), sender.weight);
    }

    /** 
     * @dev Computes the winning proposal taking all previous votes into account.
     */
    function computeWinningProposals() internal 
    {
        uint winningVoteCount = 0; uint256 winner = 0;
        delete winningProposals;
        for (uint p = 0; p < proposals.length; p = p. add(1)) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposals.push(p);
            }
        }
        for (uint p = 0; p < proposals.length; p = p. add(1)) {
            if (proposals[p].voteCount == proposals[winner].voteCount && p != winner) {
                 winningProposals.push(p);
            }
        }
    }

    /** 
     * @dev Calls winningProposal() function to get the index of the winner contained in the proposals array and then
     * @return winnerNames_ the name of the winner
     */
    function winnerNames() public view
            returns (string memory winnerNames_)
    {
        for (uint256 i = 0; i < winningProposals.length; i = i. add(1)) {
            winnerNames_ = string (bytes.concat(bytes(winnerNames_)," ",abi.encodePacked(proposals[winningProposals[i]].name)));
        }
    }

    function stringToBytes32 (string memory str) 
    internal 
    pure
    returns (bytes32) 
    {
        return bytes32(abi.encodePacked(str));
    }

    function bytes32ToString(bytes32 byt) 
    internal 
    pure
    returns (string memory) {
        return string (abi.encodePacked (byt));
    }
}

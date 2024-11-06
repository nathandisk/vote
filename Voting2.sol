// SPDX-License-Identifier: Public Domain
pragma solidity ^0.8.0;

contract VotingSystem {
    address public admin;

    enum ElectionPhase { NotStarted, Open, Closed }
    ElectionPhase public phase;

    struct Candidate {
        string name;
        uint256 id;
        uint256 voteCount;
    }

    struct Voter {
        bool isAuthorized;
        bool hasVoted;
        uint votedCandidateId;
    }    

    mapping(uint256 => Candidate) public candidates;
    mapping(uint256 => bool) public candidateExists;
    uint256[] public candidateIds;
    mapping(address => Voter) public voters;

    event CandidateAdded(string name, uint256 id);
    event VoterAdded(address voter);
    event VoteCast(address voter, uint256 candidateId);
    event VotingOpened();
    event VotingClosed();

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

    modifier onlyVoter() {
        require(voters[msg.sender].isAuthorized, "Only authorized voters can vote. Address: ");
        _;
    }


    modifier onlyDuringVoting() {
        require(phase == ElectionPhase.Open, "Voting is not open.");
        _;
    }

    modifier onlyOnce() {
        require(!voters[msg.sender].hasVoted, "You can only vote once.");
        _;
    }

    constructor() {
        admin = msg.sender;
        phase = ElectionPhase.NotStarted;
    }

    function addCandidate(string memory _name, uint256 _id) public onlyAdmin {
        require(phase == ElectionPhase.NotStarted, "Can only add candidates before voting starts.");
        require(!candidateExists[_id], "Candidate with this ID already exists.");
        candidates[_id] = Candidate(_name, _id, 0);
        candidateExists[_id] = true;
        candidateIds.push(_id);
        emit CandidateAdded(_name, _id);
    }

    function addVoter(address _voter) public onlyAdmin {
        require(!voters[_voter].isAuthorized, "Voter is already authorized.");
        voters[_voter] = Voter({
            isAuthorized: true,
            hasVoted: false,
            votedCandidateId: 0
        });
        emit VoterAdded(_voter);
    }

    function openVoting() public onlyAdmin {
        require(phase != ElectionPhase.Open, "Voting is already open.");
        phase = ElectionPhase.Open;
        emit VotingOpened();
    }

    function closeVoting() public onlyAdmin {
        require(phase == ElectionPhase.Open, "Voting is not currently open.");
        phase = ElectionPhase.Closed;
        emit VotingClosed();
    }

    function testVoterStatus() public view returns (bool) {
        return voters[msg.sender].isAuthorized;
    }

    function vote(uint _candidateId) public {
        require(voters[msg.sender].isAuthorized == false , "Only authorized voters can vote.");
        require(!voters[msg.sender].hasVoted, "Voter has already voted.");
        require(candidates[_candidateId].id != 0, "Candidate does not exist.");
        
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        candidates[_candidateId].voteCount++;
        
        emit VoteCast(msg.sender, _candidateId);
    }

    function getCandidateVotes(uint256 _candidateId) public view returns (uint256) {
        require(candidateExists[_candidateId], "Candidate does not exist.");
        return candidates[_candidateId].voteCount;
    }

    function getElectionStatus() public view returns (string memory) {
        if (phase == ElectionPhase.NotStarted) {
            return "Not Started";
        } else if (phase == ElectionPhase.Open) {
            return "Open";
        } else {
            return "Closed";
        }
    }
}

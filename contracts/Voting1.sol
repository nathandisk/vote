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
        uint256 votedCandidateId;
    }

    mapping(uint256 => Candidate) public candidates;
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
        require(voters[msg.sender].isAuthorized, "Only authorized voters can vote.");
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
        require(candidates[_id].id != _id, "Candidate with this ID already exists.");
        candidates[_id] = Candidate(_name, _id, 0);
        candidateIds.push(_id);
        emit CandidateAdded(_name, _id);
    }

    function addVoter(address _voter) public onlyAdmin {
        require(phase == ElectionPhase.NotStarted, "Can only add voters before voting starts.");
        require(!voters[_voter].isAuthorized, "Voter is already authorized.");
        voters[_voter].isAuthorized = true;
        emit VoterAdded(_voter);
    }

    function openVoting() public onlyAdmin {
        require(phase == ElectionPhase.NotStarted, "Election has already started.");
        phase = ElectionPhase.Open;
        emit VotingOpened();
    }

    function closeVoting() public onlyAdmin {
        require(phase == ElectionPhase.Open, "Voting is not currently open.");
        phase = ElectionPhase.Closed;
        emit VotingClosed();
    }

    function vote(uint256 _candidateId) public onlyVoter onlyDuringVoting onlyOnce {
        require(candidates[_candidateId].id == _candidateId, "Candidate does not exist.");
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        candidates[_candidateId].voteCount++;
        emit VoteCast(msg.sender, _candidateId);
    }

    function getCandidateVotes(uint256 _candidateId) public view returns (uint256) {
        require(candidates[_candidateId].id == _candidateId, "Candidate does not exist.");
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

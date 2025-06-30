// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract SimpleDAO {
    struct Proposal {
        address target;
        bytes data;
        uint256 yesVotes;
        uint256 noVotes;
        bool executed;
    }

    mapping(address => bool) public members;
    Proposal[] public proposals;

    modifier onlyMember() {
        require(members[msg.sender], "Not a member");
        _;
    }

    constructor() {
        members[msg.sender] = true;
    }

    function addMember(address _member) external onlyMember {
        members[_member] = true;
    }

    function propose(address _target, bytes calldata _data) external onlyMember {
        proposals.push(Proposal({target: _target, data: _data, yesVotes: 0, noVotes: 0, executed: false}));
    }

    function voteYes(uint256 _proposalId) external onlyMember {
        Proposal storage proposal = proposals[_proposalId];
        proposal.yesVotes += 1;
    }

    function voteNo(uint256 _proposalId) external onlyMember {
        Proposal storage proposal = proposals[_proposalId];
        proposal.noVotes += 1;
    }

    function executeProposal(uint256 _proposalId) external onlyMember {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Already executed");
        require(proposal.yesVotes > proposal.noVotes, "Proposal rejected");

        (bool success,) = proposal.target.call(proposal.data);
        require(success, "Execution failed");

        proposal.executed = true;
    }
}

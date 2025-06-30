// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/SimpleDAO.sol";

contract SimpleDAOTest is Test {
    SimpleDAO dao;
    address owner = address(1);
    address member1 = address(2);
    address member2 = address(3);
    address nonMember = address(4);

    function setUp() public {
        vm.prank(owner);
        dao = new SimpleDAO();

        vm.prank(owner);
        dao.addMember(member1);

        vm.prank(owner);
        dao.addMember(member2);
    }

    function testMemberManagement() public view {
        assertTrue(dao.members(owner));
        assertTrue(dao.members(member1));
        assertFalse(dao.members(nonMember));
    }

    function testProposalFlow() public {
        vm.prank(member1);
        dao.propose(address(0x123), hex"1234");

        vm.prank(member1);
        dao.voteYes(0);

        vm.prank(member2);
        dao.voteYes(0);

        vm.prank(member1);
        dao.executeProposal(0);

        (,,,, bool executed) = dao.proposals(0);
        assertTrue(executed);
    }

    function testRejectedProposal() public {
        vm.prank(member1);
        dao.propose(address(0x456), hex"5678");

        vm.prank(member1);
        dao.voteNo(0);

        vm.prank(member2);
        dao.voteNo(0);

        vm.prank(member1);
        vm.expectRevert("Proposal rejected");
        dao.executeProposal(0);
    }
}

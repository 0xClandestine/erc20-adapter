// SPDX-License-Identifier: WTFPL
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {ERC20Child} from "../src/ERC20Child.sol";
import {ERC1155Parent} from "../src/ERC1155Parent.sol";

contract MockERC1155Parent is ERC1155Parent {
    function mint(address account, uint256 id, uint256 amount) external {
        _mint(account, id, amount, new bytes(0));
    }

    function burn(address account, uint256 id, uint256 amount) external {
        _burn(account, id, amount);
    }

    function uri(uint256 id)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return "";
    }
}

contract DualTokenTest is Test {
    MockERC1155Parent parent;
    ERC20Child child;
    uint256 constant id = 420;
    address constant alice = address(0xAAAA);

    function setUp() public {
        parent = new MockERC1155Parent();
        child = ERC20Child(parent.create(id));

        vm.label(address(parent), "parent");
        vm.label(address(child), "child");
    }

    function testTotalSupply() public {
        parent.mint(alice, id, 69 ether);

        assertEq(parent.totalSupply(id), 69 ether);
        assertEq(child.totalSupply(), 69 ether);
    }

    function testBalanceOf() public {
        parent.mint(alice, id, 69 ether);

        assertEq(parent.balanceOf(alice, id), 69 ether);
        assertEq(child.balanceOf(alice), 69 ether);
    }

    function testAllowance() public {
        address operator = address(0x420);

        vm.prank(alice);
        child.approve(operator, 1);

        // This isn't entirely ERC20 compliant, you can approve all or nothing.
        assertEq(child.allowance(alice, operator), type(uint256).max);
    }

    function testTransfer() public {
        parent.mint(alice, id, 69 ether);

        address to = address(0x420);

        assertEq(parent.balanceOf(alice, id), 69 ether);
        assertEq(child.balanceOf(alice), 69 ether);

        vm.prank(alice);
        child.transfer(to, 69 ether);

        // Alice should have 69 less tokens...
        assertEq(parent.balanceOf(alice, id), 0);
        assertEq(child.balanceOf(alice), 0);

        // Recipient should have 69 more tokens...
        assertEq(parent.balanceOf(to, id), 69 ether);
        assertEq(child.balanceOf(to), 69 ether);
    }

    function testTransferFrom() public {
        parent.mint(alice, id, 69 ether);

        address to = address(0x420);

        assertEq(parent.balanceOf(alice, id), 69 ether);
        assertEq(child.balanceOf(alice), 69 ether);

        vm.prank(to);
        // Should revert due to lack of approval.
        vm.expectRevert();
        child.transferFrom(alice, to, 69 ether);

        vm.prank(alice);
        child.approve(to, 1);

        vm.prank(to);
        child.transferFrom(alice, to, 69 ether);

        // Alice should have 69 less tokens...
        assertEq(parent.balanceOf(alice, id), 0);
        assertEq(child.balanceOf(alice), 0);

        // Recipient should have 69 more tokens...
        assertEq(parent.balanceOf(to, id), 69 ether);
        assertEq(child.balanceOf(to), 69 ether);
    }

    function testIsChild() public {

        

    }
}

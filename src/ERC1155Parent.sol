// SPDX-License-Identifier: WTFPL
pragma solidity ^0.8.13;

import "solbase/utils/LibClone.sol";

import "./lib/ERC1155Supply.sol";
import "./ERC20Child.sol";

abstract contract ERC1155Parent is ERC1155Supply {
    /// -----------------------------------------------------------------------
    /// Dependencies
    /// -----------------------------------------------------------------------

    using LibClone for address;

    /// -----------------------------------------------------------------------
    /// ERC20 Compatibility Storage
    /// -----------------------------------------------------------------------

    address public immutable implementation;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor() {
        implementation = address(new ERC20Child());
    }

    /// -----------------------------------------------------------------------
    /// ERC20 Compatibility Hooks
    /// -----------------------------------------------------------------------

    function safeTransferFromHook(
        address sender,
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) public virtual {
        if (!isChild(msg.sender, id)) revert Unauthorized();

        if (sender != from) {
            if (!isApprovedForAll[from][sender]) revert Unauthorized();
        }

        balanceOf[from][id] -= amount;
        balanceOf[to][id] += amount;

        emit TransferSingle(sender, from, to, id, amount);

        if (to == address(0)) revert InvalidRecipient();
    }

    function setApprovalForAllHook(
        uint256 id,
        address account,
        address operator,
        bool approved
    ) public virtual {
        if (!isChild(msg.sender, id)) revert Unauthorized();

        isApprovedForAll[account][operator] = approved;

        emit ApprovalForAll(account, operator, approved);
    }

    /// -----------------------------------------------------------------------
    /// ERC20 Creation Logic
    /// -----------------------------------------------------------------------

    event NewChild(uint256 id);

    function create(uint256 id) external returns (address child) {
        bytes memory immutables = abi.encode(address(this), id);

        child =
            implementation.cloneDeterministic(immutables, keccak256(immutables));

        emit NewChild(id);
    }

    /// -----------------------------------------------------------------------
    /// Viewables
    /// -----------------------------------------------------------------------

    function predictDeterministicAddress(uint256 id)
        public
        view
        returns (address)
    {
        bytes memory immutables = abi.encode(address(this), id);

        return implementation.predictDeterministicAddress(
            immutables, keccak256(immutables), address(this)
        );
    }

    function isChild(address query, uint256 id) public view returns (bool) {
        return predictDeterministicAddress(id) == query;
    }
}

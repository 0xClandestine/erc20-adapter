// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./ERC1155Supply.sol";

contract DualToken is ERC1155Supply {

    function safeTransferFromInternal(
        address sender,
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) public virtual {
        // TODO: access control

        if (sender != from)
            if (!isApprovedForAll[from][sender]) revert Unauthorized();

        balanceOf[from][id] -= amount;
        balanceOf[to][id] += amount;

        emit TransferSingle(sender, from, to, id, amount);

        if (to == address(0)) revert InvalidRecipient();
    }


    function setApprovalForAllInternal(
        address account,
        address operator,
        bool approved
    ) public virtual {
        // TODO: access control

        isApprovedForAll[account][operator] = approved;

        emit ApprovalForAll(account, operator, approved);
    }

    /// -----------------------------------------------------------------------
    /// Metadata Logic
    /// -----------------------------------------------------------------------

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

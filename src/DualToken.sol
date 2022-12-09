// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./ERC1155Supply.sol";

contract DualToken is ERC1155Supply {
    
    function setApprovalForAllInternal(address account, address operator, bool approved) public virtual {
        
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./DualToken.sol";

/// @notice This contract enables ERC20 functionality for ERC1155 tokens that track supply.
abstract contract ERC20Compatibility {
    /// -----------------------------------------------------------------------
    /// Metadata Storage
    /// -----------------------------------------------------------------------

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /// -----------------------------------------------------------------------
    /// ERC20 Compatibility Storage
    /// -----------------------------------------------------------------------

    DualToken public immutable parent;

    uint256 public immutable id;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _parent,
        uint256 _id
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        parent = DualToken(_parent);
        id = _id;
    }

    /// -----------------------------------------------------------------------
    /// ERC20 Compatibility Logic
    /// -----------------------------------------------------------------------

    function totalSupply() external view returns (uint256) {
        return parent.totalSupply(id);
    }

    function balanceOf(address account) external view returns (uint256) {
        return parent.balanceOf(account, id);
    }

    /// @dev This is not ERC20 compliant. You can approve all or nothing.
    function allowance(address account, address spender)
        external
        view
        returns (uint256)
    {
        return parent.isApprovedForAll(account, spender) ? type(uint256).max : 0;
    }

    /// @dev This is not ERC20 compliant. You can approve all or nothing.
    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        parent.setApprovalForAllInternal(msg.sender, spender, amount > 0);

        return true;
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
        parent.safeTransferFromInternal(msg.sender, msg.sender, to, id, amount);

        return true;
    }

    function transferFrom(address from, address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
        parent.safeTransferFromInternal(msg.sender, from, to, id, amount);

        return true;
    }
}

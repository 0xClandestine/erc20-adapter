// SPDX-License-Identifier: WTFPL
pragma solidity ^0.8.13;

import "./ERC1155Parent.sol";

abstract contract ERC20Child {
    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /// -----------------------------------------------------------------------
    /// Metadata Storage
    /// -----------------------------------------------------------------------

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /// -----------------------------------------------------------------------
    /// ERC20 Compatibility Storage
    /// -----------------------------------------------------------------------

    ERC1155Parent public immutable parent;

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

        parent = ERC1155Parent(_parent);
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
        bool approved = amount > 0;

        parent.setApprovalForAllInternal(msg.sender, spender, approved);

        emit Approval(msg.sender, spender, approved ? type(uint256).max : 0);

        return true;
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
        parent.safeTransferFromInternal(msg.sender, msg.sender, to, id, amount);

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(address from, address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
        parent.safeTransferFromInternal(msg.sender, from, to, id, amount);

        emit Transfer(from, to, amount);

        return true;
    }
}

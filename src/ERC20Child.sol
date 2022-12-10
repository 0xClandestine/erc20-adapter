// SPDX-License-Identifier: WTFPL
pragma solidity ^0.8.13;

import {Clone} from "solbase/utils/Clone.sol";

import {ERC1155Parent} from "./ERC1155Parent.sol";

contract ERC20Child is Clone {
    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(
        address indexed owner, address indexed spender, uint256 amount
    );

    /// -----------------------------------------------------------------------
    /// Metadata Storage
    /// -----------------------------------------------------------------------

    string public constant name = "FOO";

    string public constant symbol = "BAR";

    uint8 public constant decimals = 18;

    /// -----------------------------------------------------------------------
    /// ERC20 Compatibility Storage
    /// -----------------------------------------------------------------------

    function parent() public pure returns (ERC1155Parent) {
        return ERC1155Parent(_getArgAddress(12));
    }

    function id() public pure returns (uint256) {
        return _getArgUint256(32);
    }

    /// -----------------------------------------------------------------------
    /// ERC20 Compatibility Logic
    /// -----------------------------------------------------------------------

    function totalSupply() external view returns (uint256) {
        return parent().totalSupply(id());
    }

    function balanceOf(address account) external view returns (uint256) {
        return parent().balanceOf(account, id());
    }

    /// @dev This is not ERC20 compliant. You can approve all or nothing.
    function allowance(address account, address spender)
        external
        view
        returns (uint256)
    {
        return
            parent().isApprovedForAll(account, spender) ? type(uint256).max : 0;
    }

    /// @dev This is not ERC20 compliant. You can approve all or nothing.
    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        bool approved = amount > 0;

        parent().setApprovalForAllHook(id(), msg.sender, spender, approved);

        emit Approval(msg.sender, spender, approved ? type(uint256).max : 0);

        return true;
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
        parent().safeTransferFromHook(msg.sender, msg.sender, to, id(), amount);

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(address from, address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
        parent().safeTransferFromHook(msg.sender, from, to, id(), amount);

        emit Transfer(from, to, amount);

        return true;
    }

    /// -----------------------------------------------------------------------
    /// ERC20 Compatibility Hooks
    /// -----------------------------------------------------------------------

    error Unauthorized();

    function transferHook(address from, address to, uint256 amount)
        external
        virtual
    {
        if (msg.sender != address(parent())) revert Unauthorized();

        emit Transfer(from, to, amount);
    }

    function approveHook(address owner, address spender, uint256 amount)
        external
        virtual
    {
        if (msg.sender != address(parent())) revert Unauthorized();

        emit Approval(owner, spender, amount);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "solbase/tokens/ERC1155/ERC1155.sol";

/// @notice This contract enables ERC20 functionality for ERC1155 tokens that track supply.
abstract contract ERC20Compatibility {
    /// -----------------------------------------------------------------------
    /// Metadata Storage
    /// -----------------------------------------------------------------------

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /// -----------------------------------------------------------------------
    /// ERC20 Storage
    /// -----------------------------------------------------------------------

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /// -----------------------------------------------------------------------
    /// ERC20 Compatibility Storage
    /// -----------------------------------------------------------------------

    ERC1155 public immutable parent;

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

        parent = ERC1155(_parent);
        id = _id;
    }

    /// -----------------------------------------------------------------------
    /// ERC20 Compatibility Logic
    /// -----------------------------------------------------------------------

    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {}

    function transfer(address to, uint256 amount)
        public
        virtual
        returns (bool)
    {}

    function transferFrom(address from, address to, uint256 amount)
        public
        virtual
        returns (bool)
    {}
}
// SPDX-License-Identifier: WTFPL
pragma solidity ^0.8.13;

import {ERC1155} from "solbase/tokens/ERC1155/ERC1155.sol";
import {ERC1155TokenReceiver} from "solbase/tokens/ERC1155/ERC1155.sol";

/// @notice ERC1155 token + supply tracking.
abstract contract ERC1155Supply is ERC1155 {
    /// -----------------------------------------------------------------------
    /// ERC1155Supply Storage
    /// -----------------------------------------------------------------------

    mapping(uint256 => uint256) public totalSupply;

    /// -----------------------------------------------------------------------
    /// Internal Mint/Burn Logic
    /// -----------------------------------------------------------------------

    function _mint(address to, uint256 id, uint256 amount, bytes memory data)
        internal
        virtual
        override
    {
        totalSupply[id] += amount;

        super._mint(to, id, amount, data);
    }

    function _batchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        uint256 idsLength = ids.length; // Saves MLOADs.

        if (ids.length != amounts.length) revert LengthMismatch();

        for (uint256 i = 0; i < idsLength;) {
            balanceOf[to][ids[i]] += amounts[i];

            // Above line checks this math.
            unchecked {
                totalSupply[ids[i]] += amounts[i];
            }

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, address(0), to, ids, amounts);

        if (to.code.length != 0) {
            if (
                ERC1155TokenReceiver(to).onERC1155BatchReceived(
                    msg.sender, address(0), ids, amounts, data
                ) != ERC1155TokenReceiver.onERC1155BatchReceived.selector
            ) revert UnsafeRecipient();
        } else if (to == address(0)) {
            revert InvalidRecipient();
        }
    }

    function _batchBurn(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual override {
        uint256 idsLength = ids.length; // Saves MLOADs.

        if (ids.length != amounts.length) revert LengthMismatch();

        for (uint256 i = 0; i < idsLength;) {
            balanceOf[from][ids[i]] -= amounts[i];

            // Above line checks this math.
            unchecked {
                totalSupply[ids[i]] -= amounts[i];
            }

            // An array can't have a total length
            // larger than the max uint256 value.
            unchecked {
                ++i;
            }
        }

        emit TransferBatch(msg.sender, from, address(0), ids, amounts);
    }

    function _burn(address from, uint256 id, uint256 amount)
        internal
        virtual
        override
    {
        balanceOf[from][id] -= amount;

        // Above line checks this math.
        unchecked {
            totalSupply[id] -= amount;
        }

        emit TransferSingle(msg.sender, from, address(0), id, amount);
    }
}

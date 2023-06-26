// SPDX-License-Identifier: GPL-3.0

/**

    ZORA Splits

 */

pragma solidity 0.8.6;

import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {IERC2981Upgradeable, IERC165Upgradeable} from "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import {CountersUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import {PaymentSplitter} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import {ISplitRenderer} from "./ISplitRenderer.sol";

/**
    This is a smart contract for handling dynamic contract minting.

    @dev This allows creators to mint a unique serial edition of the same media within a custom contract
    @author iain nash
    Repository: https://github.com/ourzora/nft-editions
*/
contract ZoraTokenizedSplit is
    ERC721Upgradeable,
    OwnableUpgradeable
{
    struct Share {
        address owner;
        uint256 weight;
        mapping(address => uint256) paidOut;
    }

    mapping(address => uint256) payoutByCurrency;
    Share[] public shares;

    // Global constructor for factory
    constructor(ISplitRenderer _splitRenderer, Share[] storage _shares) {
        splitRenderer = _splitRenderer;
        shares = _shares;
        for (uint256 i = 0; i < shares.length; i++) {
            _mint(i, msg.sender);
        }
    }

    /**
        @dev Get URI for given token id
        @param tokenId token id to get uri for
        @return base64-encoded json metadata object
    */
    function tokenURI(uint256 shareId)
        public
        view
        override
        returns (string memory)
    {
        require(shares[shareId].owner != address(0x0), "No share");
        return splitRenderer.renderShareTokenInfo(shares, shareId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, IERC165Upgradeable)
        returns (bool)
    {
    }
}

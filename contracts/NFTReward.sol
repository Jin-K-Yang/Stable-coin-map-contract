// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTReward is ERC721, AccessControl {
    using Strings for uint256;
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string private _baseTokenURI;
    Counters.Counter private _tokenIdTracker;

    constructor(address minter) ERC721("Reward NFT", "RNFT") {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(MINTER_ROLE, minter);
    }

    function mint(address to) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "You are not minter!");

        _mint(to, _tokenIdTracker.current());
        _tokenIdTracker.increment();
    }

    function setBaseURI(string memory _inputBaseURI) external {
        _baseTokenURI = _inputBaseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(AccessControl, ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

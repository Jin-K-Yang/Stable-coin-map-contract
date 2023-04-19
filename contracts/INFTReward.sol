// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface INFTReward {
    function mint(address to) external returns (uint256 tokenId);
}

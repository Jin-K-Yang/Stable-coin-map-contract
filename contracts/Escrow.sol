// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./INFTReward.sol";

contract Escrow is Ownable {
    event Deposited(address indexed user, uint256 indexed NFTRewardTokenId, address tokenAddress, uint256 amount);

    using SafeERC20 for IERC20;

    address constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant USDT_ADDRESS = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    mapping(address => uint256[]) private _deposits; // user => escrowTime => NFTRewardId
    address public NFTReward;
    uint256 public escrowAmount;

    constructor(address _NFTReward, uint256 _escrowAmount) {
        NFTReward = _NFTReward;
        escrowAmount = _escrowAmount;
    }

    function queryTokenId(address payee, uint256 depositTimes) public view returns (uint256) {
        return _deposits[payee][depositTimes];
    }

    // allow USDT and USDC
    function deposit(address depositTokenAddress) external {
        require(depositTokenAddress == USDC_ADDRESS || depositTokenAddress == USDT_ADDRESS, "deposit only allow USDT and USDC!");

        IERC20(depositTokenAddress).safeTransferFrom(_msgSender(), address(this), escrowAmount);
        uint256 tokenId = INFTReward(NFTReward).mint(_msgSender());

        _deposits[_msgSender()].push(tokenId);

        emit Deposited(_msgSender(), tokenId, depositTokenAddress, escrowAmount);
    }

    function setNFTReward(address newNFTReward) external onlyOwner {
        NFTReward = newNFTReward;
    }

    function setEscrowAmount(uint256 newAmount) external onlyOwner {
        escrowAmount = newAmount;
    }

    function withdraw(address tokenAddress) external onlyOwner {
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).safeTransfer(_msgSender(), balance);
    }
}

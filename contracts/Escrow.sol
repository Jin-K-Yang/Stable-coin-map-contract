// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./INFTReward.sol";
import "hardhat/console.sol";

contract Escrow is Ownable {
    event Deposited(address indexed user, uint256 indexed escrowBlockNumber, address tokenAddress, uint256 amount);
    event Withdrawn(address indexed user, uint256 indexed NFTId);

    using SafeERC20 for IERC20;

    address constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant USDT_ADDRESS = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    struct EscrowInfo {
        uint256 escrowBlockNumber;
        bool approved;
        address escrowToken;
        uint256 escrowAmount;
    }

    mapping(address => EscrowInfo[]) private _deposits; // user => escrowTimes => escrowInfo
    mapping(address => uint256[]) public userNFTId;
    uint256 public escrowAmount;
    uint256 public escrowPeriod; // block number 7 days = 50400 blocks
    address public NFTReward;

    constructor(uint256 _escrowAmount, uint256 _escrowPeriod) {
        escrowAmount = _escrowAmount;
        escrowPeriod = _escrowPeriod;
    }

    function userEscrowAmount(address user) public view returns (uint256) {
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < _deposits[user].length; i++) {
            totalAmount += _deposits[user][i].escrowAmount;
        }
        return totalAmount;
    }

    function userNFTRewardId(address user, uint256 escrowTimes) public view returns (uint256) {
        return userNFTId[user][escrowTimes];
    }

    function userEscrowTimes(address user) public view returns (uint256) {
        return _deposits[user].length;
    }

    // allow USDT and USDC
    function deposit(address depositTokenAddress) external {
        require(depositTokenAddress == USDC_ADDRESS || depositTokenAddress == USDT_ADDRESS, "deposit only allow USDT and USDC!");

        IERC20(depositTokenAddress).safeTransferFrom(_msgSender(), address(this), escrowAmount);

        _deposits[_msgSender()].push(EscrowInfo(block.number, true, depositTokenAddress, escrowAmount));

        emit Deposited(_msgSender(), block.number, depositTokenAddress, escrowAmount);
    }

    function withdraw() external {
        require(_deposits[_msgSender()].length > 0, "user no deposits.");
        require(_deposits[_msgSender()][0].escrowBlockNumber + escrowPeriod < block.number, "Time is not up yet");
        require(_deposits[_msgSender()][0].approved == true, "not approved for withdraw");

        IERC20(_deposits[_msgSender()][0].escrowToken).safeTransfer(_msgSender(), _deposits[_msgSender()][0].escrowAmount);
        uint256 NFTId = INFTReward(NFTReward).mint(_msgSender());

        _removeElement(0, _deposits[_msgSender()]);
        userNFTId[_msgSender()].push(NFTId);

        emit Withdrawn(_msgSender(), NFTId);
    }

    function setNFTReward(address newNFTReward) external onlyOwner {
        NFTReward = newNFTReward;
    }

    function setEscrowAmount(uint256 newAmount) external onlyOwner {
        escrowAmount = newAmount;
    }

    function setEscrowPeriod(uint256 newPeriod) external onlyOwner {
        escrowPeriod = newPeriod;
    }

    function setApproved(address _user, uint256 _escrowTimes, bool _approved) external onlyOwner {
        _deposits[_user][_escrowTimes].approved = _approved;
    }

    function adminWithdraw(address tokenAddress) external onlyOwner {
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).safeTransfer(_msgSender(), balance);
    }

    function _removeElement(uint256 _index, EscrowInfo[] storage array) internal {
        require(_index < array.length, "index out of bound");

        for (uint256 i = _index; i < array.length - 1; i++) {
            array[i] = array[i + 1];
        }

        array.pop();
    }
}

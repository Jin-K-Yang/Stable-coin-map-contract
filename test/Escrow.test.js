const { expect } = require("chai");
const { ethers } = require("hardhat");
const helpers = require("@nomicfoundation/hardhat-network-helpers");
const ERC20ABI = require("./ABI/ERC20.json");

describe("Escrow", function () {
    var Escrow, escrow, NFT, nft, owner, addr1, userUSDC, USDCContract;
    const USDC = "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48";
    const USDCUserAddress = "0xda9ce944a37d218c3302f6b82a094844c6eceb17";

    before(async function () {
        [owner, addr1] = await ethers.getSigners();

        Escrow = await ethers.getContractFactory("Escrow");
        escrow = await Escrow.deploy(ethers.utils.parseUnits("10", 6), 50400);
        await escrow.deployed();

        NFT = await ethers.getContractFactory("NFTReward");
        nft = await NFT.deploy(escrow.address);
        await nft.deployed();

        escrow.setNFTReward(nft.address);

        userUSDC = await ethers.getImpersonatedSigner(USDCUserAddress);
        USDCContract = await ethers.getContractAt(ERC20ABI, USDC);
    })

    describe("Escrow and get NFT", function () {
        it("Should escrow fund", async function () {
            await USDCContract.connect(userUSDC).approve(escrow.address, ethers.utils.parseUnits("10", 6));
            await escrow.connect(userUSDC).deposit(USDC);

            expect(await escrow.userEscrowAmount(USDCUserAddress)).to.equal(ethers.utils.parseUnits("10", 6));
        })

        it("Should withdraw fund and get NFT", async function () {

        })
    })
})
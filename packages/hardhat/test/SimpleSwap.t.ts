import { ethers } from "hardhat";
import { expect } from "chai";

describe("SimpleSwap", function () {
  let tokenA: any, tokenB: any, swap: any, user: any;

  beforeEach(async () => {
    const [, addr1] = await ethers.getSigners();
    user = addr1;

    const ERC20Mock = await ethers.getContractFactory("ERC20Token");
    tokenA = await ERC20Mock.deploy("Token A", "TKA");
    tokenB = await ERC20Mock.deploy("Token B", "TKB");

    await tokenA.mint(user.address, ethers.parseUnits("1000", 18));
    await tokenB.mint(user.address, ethers.parseUnits("1000", 18));

    const SimpleSwap = await ethers.getContractFactory("SimpleSwap");
    swap = await SimpleSwap.deploy();

    await tokenA.connect(user).approve(swap.getAddress(), ethers.parseUnits("500", 18));
    await tokenB.connect(user).approve(swap.getAddress(), ethers.parseUnits("500", 18));

    const deadline = Math.floor(Date.now() / 1000) + 300;

    await swap
      .connect(user)
      .addLiquidity(
        await tokenA.getAddress(),
        await tokenB.getAddress(),
        ethers.parseUnits("100", 18),
        ethers.parseUnits("100", 18),
        0,
        0,
        user.address,
        deadline,
      );
  });

  it("permite hacer swap", async () => {
    const path = [await tokenA.getAddress(), await tokenB.getAddress()];
    const deadline = Math.floor(Date.now() / 1000) + 300;

    await tokenA.connect(user).approve(swap.getAddress(), ethers.parseUnits("10", 18));

    await swap.connect(user).swapExactTokensForTokens(ethers.parseUnits("10", 18), 0, path, user.address, deadline);

    const balanceOut = await tokenB.balanceOf(user.address);
    expect(balanceOut).to.be.gt(ethers.parseUnits("900", 18));
  });
});

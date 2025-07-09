import { ethers } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";

const deploySimpleSwapOnly: DeployFunction = async function ({ deployments, getNamedAccounts }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const signer = await ethers.getSigner(deployer);

  // Pone acá las direcciones reales de los tokens ya desplegados en Sepolia
  const tokenAAddress = "0xbFC087c6512f00eFF0eE37f4e5A42A6e4E064ab4";
  const tokenBAddress = "0xD8CDEd4B13a730cD1c3CF8f0BA08a4Baa37649e4";

  // Deploy SimpleSwap
  const swap = await deploy("SimpleSwap", {
    from: deployer,
    args: [],
    log: true,
  });

  const swapContract = await ethers.getContractAt("SimpleSwap", swap.address, signer);

  // Liquidez - approve y agregar liquidez
  const liquidityAmount = ethers.parseUnits("100", 18);
  const tokenAContract = await ethers.getContractAt("ERC20Token", tokenAAddress, signer);
  const tokenBContract = await ethers.getContractAt("ERC20Token", tokenBAddress, signer);

  await tokenAContract.approve(swap.address, liquidityAmount);
  await tokenBContract.approve(swap.address, liquidityAmount);

  const deadline = Math.floor(Date.now() / 1000) + 60 * 5;

  await swapContract.addLiquidity(
    tokenAAddress,
    tokenBAddress,
    liquidityAmount,
    liquidityAmount,
    0,
    0,
    deployer,
    deadline,
  );

  console.log("✔️  SimpleSwap deploy completo con liquidez.");
};

export default deploySimpleSwapOnly;
deploySimpleSwapOnly.tags = ["simpleswaponly"];

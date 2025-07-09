import { ethers } from "hardhat";
import { DeployFunction } from "hardhat-deploy/types";

const deploy: DeployFunction = async function ({ deployments, getNamedAccounts }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const signer = await ethers.getSigner(deployer);

  // 1. Deploy TokenA (usando el contrato ERC20Token)
  const tokenA = await deploy("TokenA", {
    contract: "ERC20Token", // 🔑 IMPORTANTE: el nombre del contrato en Solidity
    from: deployer,
    args: ["Token A", "TKA"],
    log: true,
  });

  // 2. Deploy TokenB (usando el mismo contrato)
  const tokenB = await deploy("TokenB", {
    contract: "ERC20Token", // 🔑 otra instancia
    from: deployer,
    args: ["Token B", "TKB"],
    log: true,
  });

  // 3. Obtener instancias
  const tokenAContract = await ethers.getContractAt("ERC20Token", tokenA.address, signer);
  const tokenBContract = await ethers.getContractAt("ERC20Token", tokenB.address, signer);

  // 4. Mint tokens al deployer
  const mintAmount = ethers.parseUnits("1000", 18);
  await tokenAContract.mint(deployer, mintAmount);
  await tokenBContract.mint(deployer, mintAmount);

  // 5. Deploy SimpleSwap
  const swap = await deploy("SimpleSwap", {
    from: deployer,
    args: [],
    log: true,
  });

  const swapContract = await ethers.getContractAt("SimpleSwap", swap.address, signer);

  // 6. Approve y agregar liquidez
  const liquidityAmount = ethers.parseUnits("100", 18);
  await tokenAContract.approve(swap.address, liquidityAmount);
  await tokenBContract.approve(swap.address, liquidityAmount);

  const deadline = Math.floor(Date.now() / 1000) + 60 * 5;

  await swapContract.addLiquidity(
    tokenA.address,
    tokenB.address,
    liquidityAmount,
    liquidityAmount,
    0,
    0,
    deployer,
    deadline,
  );

  console.log("✔️  Deploy completo con liquidez inicial.");
};

export default deploy;
deploy.tags = ["all"];

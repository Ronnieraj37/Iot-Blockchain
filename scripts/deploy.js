const hre = require("hardhat");

async function main() {
  const SmartHome = await hre.ethers.getContractFactory("SmartHome");
  const smartHome = await SmartHome.deploy();

  await smartHome.deployed();
  console.log(smartHome.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

import { ethers } from "hardhat";

async function main() {
  const Nft = await ethers.getContractFactory("Nft");
  const nft = await Nft.deploy("name", "symbol");

  await nft.deployed();

  console.log("Nft deployed to:", nft.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

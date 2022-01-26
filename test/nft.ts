import { expect } from "chai";
import { ethers } from "hardhat";

describe("Nft", function () {
  it("erc721", async function () {
    const Nft = await ethers.getContractFactory("Nft");
    const nft = await Nft.deploy("name", "symbol");
    await nft.deployed();

    const signers = await ethers.getSigners();
    const tokenURI1 = "https://game.example/item-id-1.json";
    const tokenURI2 = "https://game.example/item-id-2.json";
    const tokenURI3 = "https://game.example/item-id-3.json";

    const ownerAddress = signers[0].address;
    const userAddress1 = signers[1].address;

    // create nft 1
    await nft.mint(tokenURI1);
    // check
    const tokenURIRes1 = await nft.tokenURI(1);
    expect(tokenURIRes1).to.equal(tokenURI1);
    const balanceOfRes1 = await nft.balanceOf(ownerAddress);
    expect(balanceOfRes1).to.equal(1);
    const ownerOfRes1 = await nft.ownerOf(1);
    expect(ownerOfRes1).to.equal(ownerAddress);

    // create nft 2
    await nft.mint(tokenURI2);

    // check
    const tokenURIRes2 = await nft.tokenURI(2);
    expect(tokenURIRes2).to.equal(tokenURI2);
    const balanceOfRes2 = await nft.balanceOf(ownerAddress);
    expect(balanceOfRes2).to.equal(2);
    const ownerOf2Res = await nft.ownerOf(2);
    expect(ownerOf2Res).to.equal(ownerAddress);

    // create nft 3
    await nft.mint(tokenURI3);

    // check
    const tokenURIRes3 = await nft.tokenURI(3);
    expect(tokenURIRes3).to.equal(tokenURI3);
    const balanceOfRes3 = await nft.balanceOf(ownerAddress);
    expect(balanceOfRes3).to.equal(3);
    const ownerOf3Res = await nft.ownerOf(3);
    expect(ownerOf3Res).to.equal(ownerAddress);

    // transfer
    await nft.transferFrom(ownerAddress, userAddress1, 2);
    const ownerOf4Res = await nft.ownerOf(2);
    expect(ownerOf4Res).to.equal(userAddress1);

    // check
    await expect(
      nft.transferFrom(userAddress1, ownerAddress, 2)
    ).to.be.revertedWith("ERC721: transfer caller is not owner nor approved");

    // approve & transfer
    await nft.connect(signers[1]).setApprovalForAll(ownerAddress, true);
    await nft.transferFrom(userAddress1, ownerAddress, 2);
  });
});

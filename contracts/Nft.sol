//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Nft is ERC721 {
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}
}
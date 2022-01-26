//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Nft is ERC721,ERC721URIStorage,ERC721Enumerable,ReentrancyGuard {
    uint private latestTokenId = 1;
    mapping(uint256 => string) private _tokenURIs;
    mapping(string => bool) _metadataExists;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function mint( string memory _tokenURI)
        public
    {
        require(bytes(_tokenURI).length != 0, "ERC721Metadata: URI doesn't exist.");
        require(
            _metadataExists[_tokenURI] == false,
            "ERC721Metadata: URI already exist."
        );
        _metadataExists[_tokenURI] = true;
        uint256 tokenId = latestTokenId;
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        latestTokenId++;
    }

    function getOwnTokenIds()
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory result = new uint256[](super.balanceOf(msg.sender));
        for (uint i=0;i<super.balanceOf(msg.sender);i++){
            result[i]=super.tokenOfOwnerByIndex(msg.sender,i);
        }
        return result;
    }

    // 
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(_from, _to, _tokenId);
    }
    function supportsInterface(bytes4 _interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(_interfaceId);
    }
}
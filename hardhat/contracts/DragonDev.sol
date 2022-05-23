// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract DragonDev is ERC721Enumerable, Ownable {

    string baseTokenURI;

    IWhitelist whitelist;

    bool public presaleStarted;
    uint public presaleEnded;
    uint public maxTokenIds = 20;
    uint public tokenIdsMinted;
    uint public _publicPrice = 0.01 ether;
    uint public _presalePrice = 0.005 ether;
    bool public _paused;

    modifier onlyWhenNotPaused {
        require(!_paused, "Contract currently paused");
        _;
    }

    constructor (string memory _baseURITokens, address whitelistContract) ERC721("Dragon Dev", "DD") {
        baseTokenURI = _baseURITokens;
        whitelist = IWhitelist(whitelistContract);
    }

    function startPresale() public onlyOwner {
        presaleStarted = true;
        presaleEnded = block.timestamp + 5 minutes;
    }

    function presaleMint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp < presaleEnded, "Presale ended");
        require(whitelist.whitelistedAddresses(msg.sender), "You are not in whitelist");

        execMint(_presalePrice);
    }

    function mint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp >= presaleEnded, "Presale has not ended yet");

        execMint(_publicPrice);
    }

    function execMint(uint _price) private {
        require(tokenIdsMinted < maxTokenIds, "Exceeded the limit minted");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIdsMinted += 1;
        _safeMint(msg.sender, tokenIdsMinted);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseTokenURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    function withdraw() public onlyOwner {
        address _owner = owner();
        uint amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send ether");
    }

    receive() external payable{}

    fallback() external payable{}

}
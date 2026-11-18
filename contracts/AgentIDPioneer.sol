// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IAgentID {
    function balanceOf(address owner) external view returns (uint256);
}

/// @title Agent ID Pioneer — a free commemorative NFT for Agent ID holders
/// @notice Only wallets holding a Binance Agent ID (SPACE ID, ERC-721, non-transferable)
///         can mint. 1 per wallet, gas only, no payment. Built for the Binance
///         Agent ID Hackathon 2026 (submission 18 Nov – 9 Dec 2026).
contract AgentIDPioneer is ERC721, Ownable {
    /// @notice Official SPACE ID Agent ID contract on BNB Chain (from Binance announcement)
    address public constant AGENT_ID = 0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F;

    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public nextTokenId = 1;

    mapping(address => bool) public hasMinted;

    string private _baseTokenURI;

    event PioneerMinted(address indexed minter, uint256 indexed tokenId);

    constructor(address initialOwner, string memory baseURI)
        ERC721("Agent ID Pioneer", "AGP")
        Ownable(initialOwner)
    {
        _baseTokenURI = baseURI;
    }

    /// @notice Mint 1 free Pioneer badge. Caller must hold an Agent ID.
    function mint() external {
        require(!hasMinted[msg.sender], "Pioneer: already minted");
        require(nextTokenId <= MAX_SUPPLY, "Pioneer: sold out");
        require(
            IAgentID(AGENT_ID).balanceOf(msg.sender) > 0,
            "Pioneer: need an Agent ID"
        );
        hasMinted[msg.sender] = true;
        uint256 tokenId = nextTokenId;
        nextTokenId++;
        _safeMint(msg.sender, tokenId);
        emit PioneerMinted(msg.sender, tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    /// @notice Total minted so far.
    function totalMinted() external view returns (uint256) {
        return nextTokenId - 1;
    }
}

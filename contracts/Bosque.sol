pragma solidity ^0.5.0;

import "./TradeableERC721Token.sol";
import "./Arbol.sol";
import "./Factory.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title Bosque
 *
 * Bosque - a tradeable collection of Arbol.
 */
contract Bosque is TradeableERC721Token {
    uint256 NUM_ARBOLES_PER_BOSQUE = 3;
    uint256 OPTION_ID = 0;
    address factoryAddress;

    constructor(address _proxyRegistryAddress, address _factoryAddress) TradeableERC721Token("Bosque", "BOSQUE", _proxyRegistryAddress) public {
        factoryAddress = _factoryAddress;
    }

    function unpack(uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender,"sender not owner");

        // Insert custom logic for configuring the item here.
        for (uint256 i = 0; i < NUM_ARBOLES_PER_BOSQUE; i++) {
            // Mint the ERC721 item(s).
            Factory factory = Factory(factoryAddress);
            factory.mint(OPTION_ID, msg.sender);
        }

        // Burn the presale item.
        _burn(msg.sender, _tokenId);
    }

    function baseTokenURI() public view returns (string memory) {
        return "https://api.arboribus.network/bosque/";
    }

    function itemsPerBosque() public view returns (uint256) {
        return NUM_ARBOLES_PER_BOSQUE;
    }
}
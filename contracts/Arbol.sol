pragma solidity ^0.5.0;

import "./TradeableERC721Token.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title Arbol
 * Arbol - a contract for my non-fungible creatures.
 */
contract Arbol is TradeableERC721Token {
  constructor(address _proxyRegistryAddress) TradeableERC721Token("Arbol", "ARBOL", _proxyRegistryAddress) public {  }

  function baseTokenURI() public view returns (string memory) {
    return "https://api.arboribus.network/arbol/";
  }
}
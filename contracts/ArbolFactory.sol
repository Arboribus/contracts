pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Factory.sol";
import "./Arbol.sol";
import "./Bosque.sol";
import "./Strings.sol";

contract ArbolFactory is Factory, Ownable {
  using Strings for string;

  address public proxyRegistryAddress;
  address public nftAddress;
  address public bosqueNftAddress;
  string public baseURI = "https://api.arboribus.network/factory/";

  /**
   * Enforce the existence of only 100 Arbol.
   */
  uint256 ARBOL_SUPPLY = 100;

  /**
   * Three different options for minting Arboles (basic, average, and bulk).
   */
  uint256 NUM_OPTIONS = 3;
  uint256 SINGLE_ARBOL_OPTION = 0;
  uint256 MULTIPLE_ARBOL_OPTION = 1;
  uint256 BOSQUE_OPTION = 2;
  uint256 NUM_ARBOLES_IN_MULTIPLE_ARBOL_OPTION = 4;

  constructor(address _proxyRegistryAddress, address _nftAddress) public {
    proxyRegistryAddress = _proxyRegistryAddress;
    nftAddress = _nftAddress;
    bosqueNftAddress = address(new Bosque(_proxyRegistryAddress, address(this)));
  }

  function name() external view returns (string memory) {
    return "Arbol Item Sale";
  }

  function symbol() external view returns (string memory) {
    return "ARBOLFACTORY";
  }

  function supportsFactoryInterface() public view returns (bool) {
    return true;
  }

  function numOptions() public view returns (uint256) {
    return NUM_OPTIONS;
  }

  function mint(uint256 _optionId, address _toAddress) public {
    // Must be sent from the owner proxy or owner.
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    assert(address(proxyRegistry.proxies(owner())) == msg.sender || owner() == msg.sender || msg.sender == bosqueNftAddress);
    require(canMint(_optionId),"can't mint");

    Arbol arbol = Arbol(nftAddress);
    if (_optionId == SINGLE_ARBOL_OPTION) {
      arbol.mintTo(_toAddress);
    } else if (_optionId == MULTIPLE_ARBOL_OPTION) {
      for (uint256 i = 0; i < NUM_ARBOLES_IN_MULTIPLE_ARBOL_OPTION; i++) {
        arbol.mintTo(_toAddress);
      }
    } else if (_optionId == BOSQUE_OPTION) {
      Bosque bosque = Bosque(bosqueNftAddress);
      bosque.mintTo(_toAddress);
    }
  }

  function canMint(uint256 _optionId) public view returns (bool) {
    if (_optionId >= NUM_OPTIONS) {
      return false;
    }

    Arbol arbol = Arbol(nftAddress);
    uint256 arbolSupply = arbol.totalSupply();

    uint256 numItemsAllocated = 0;
    if (_optionId == SINGLE_ARBOL_OPTION) {
      numItemsAllocated = 1;
    } else if (_optionId == MULTIPLE_ARBOL_OPTION) {
      numItemsAllocated = NUM_ARBOLES_IN_MULTIPLE_ARBOL_OPTION;
    } else if (_optionId == BOSQUE_OPTION) {
      Bosque bosque = Bosque(bosqueNftAddress);
      numItemsAllocated = bosque.itemsPerBosque();
    }
    return arbolSupply < (ARBOL_SUPPLY - numItemsAllocated);
  }

  function tokenURI(uint256 _optionId) external view returns (string memory) {
    return Strings.strConcat(
        baseURI,
        Strings.uint2str(_optionId)
    );
  }

  /**
   * Hack to get things to work automatically on OpenSea.
   * Use transferFrom so the frontend doesn't have to worry about different method names.
   */
  function transferFrom(address _from, address _to, uint256 _tokenId) public {
    mint(_tokenId, _to);
  }

  /**
   * Hack to get things to work automatically on OpenSea.
   * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
   */
  function isApprovedForAll(
    address _owner,
    address _operator
  )
    public
    view
    returns (bool)
  {
    if (owner() == _owner && _owner == _operator) {
      return true;
    }

    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    if (owner() == _owner && address(proxyRegistry.proxies(_owner)) == _operator) {
      return true;
    }

    return false;
  }

  /**
   * Hack to get things to work automatically on OpenSea.
   * Use isApprovedForAll so the frontend doesn't have to worry about different method names.
   */
  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
    return owner();
  }
}
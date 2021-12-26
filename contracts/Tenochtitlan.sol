// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
/// @title Tenochtitlan Token (First metaverse of Metaverse-Empires)
/// @author Rafael Fuentes Rangel
import "./ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Tenochtitlan is ERC20, EIP712 {
    uint256 public constant MAX_SUPPLY = uint248(1e14 ether);

    // for Metaverse-Project.
    uint256 public constant AMOUNT_TECH = MAX_SUPPLY / 100 * 20;
    address public constant ADDR_TECH = 0x1A9650A969f66f9F0433a9054D25b530fC6842Ad;

    // for staking
    uint256 public constant AMOUNT_STAKING = MAX_SUPPLY / 100 * 20;
    address public constant ADDR_STAKING = 0x1A9650A969f66f9F0433a9054D25b530fC6842Ad;

    // for liquidity providers
    uint256 public constant AMOUNT_LP = MAX_SUPPLY / 100 * 10;
    address public constant ADDR_LP = 0x1A9650A969f66f9F0433a9054D25b530fC6842Ad;

    // for airdrop
    uint256 public constant AMOUNT_AIREDROP = MAX_SUPPLY - (AMOUNT_TECH + AMOUNT_STAKING + AMOUNT_LP);

    constructor(string memory _name, string memory _symbol, address _signer) ERC20(_name, _symbol) EIP712("Tenoch", "MEXICA") {
        _mint(ADDR_TECH, AMOUNT_TECH);
        _mint(ADDR_STAKING, AMOUNT_STAKING);
        _mint(ADDR_LP, AMOUNT_LP);
        _totalSupply = AMOUNT_TECH + AMOUNT_STAKING + AMOUNT_LP;
        cSigner = _signer;
    }

    bytes32 constant public MINT_CALL_HASH_TYPE = keccak256("mint(address receiver,uint256 amount)");

    address public immutable cSigner;

    function claim(uint256 amountV, bytes32 r, bytes32 s) external {
        uint256 amount = uint248(amountV);
        uint8 v = uint8(amountV >> 248);
        uint256 total = _totalSupply + amount;
        require(total <= MAX_SUPPLY, "Tenoch: Exceed max supply");
        require(minted(msg.sender) == 0, "Tenoh: Claimed");
        bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", 
            ECDSA.toTypedDataHash(_domainSeparatorV4(),
                keccak256(abi.encode(MINT_CALL_HASH_TYPE, msg.sender, amount))
        )));
        require(ecrecover(digest, v, r, s) == cSigner, "Tenoch: Invalid signer");
        _totalSupply = total;
        _mint(msg.sender, amount);
    }
}
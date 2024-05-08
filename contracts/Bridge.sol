pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract Bridge {
    using ECDSA for bytes32;
    using Address for address;
    using MessageHashUtils for bytes32;

    IERC20 public token;
    address public federationAddress;

    mapping(bytes32 => bool) public claimedTransactions;

    event Output(address indexed to, uint256 indexed amount);
    event Input(address indexed from, uint256 indexed amount);

    constructor(address federationAddress_) payable {
        federationAddress = federationAddress_;
    }

    function stringToUint(string memory s) public pure returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint i = 0; i < b.length; i++) {
            if (uint8(b[i]) >= 48 && uint8(b[i]) <= 57) {
                result = result * 10 + (uint8(b[i]) - 48);
            }
        }
        return result;
    }

    function claimToken(
        string memory source_chainID,
        string memory source_contract,
        string memory target_contract,
        string memory symbol,
        string memory decimal,
        string memory amount,
        string memory sign_at,
        bytes memory signature
    ) external returns (bytes32) {
        string memory target_chainID = Strings.toString(block.chainid);
        string memory user_bridge = Strings.toHexString(
            uint256(uint160(msg.sender)),
            20
        );

        bytes memory user_bridgeBytes = bytes(user_bridge);
        bytes memory source_chainIDBytes = bytes(source_chainID);
        bytes memory target_chainIDBytes = bytes(target_chainID);
        bytes memory source_contractBytes = bytes(source_contract);
        bytes memory target_contractBytes = bytes(target_contract);
        bytes memory symbolBytes = bytes(symbol);
        bytes memory decimalBytes = bytes(decimal);
        bytes memory amountBytes = bytes(amount);
        bytes memory sign_atBytes = bytes(sign_at);

        string memory concatenatedString = new string(user_bridgeBytes.length + source_chainIDBytes.length + target_chainIDBytes.length + source_contractBytes.length + target_contractBytes.length + symbolBytes.length + decimalBytes.length + amountBytes.length + sign_atBytes.length
        );

        bytes memory concatenatedBytes = bytes(concatenatedString);

        uint256 index = 0;
        for (uint256 i = 0; i < user_bridgeBytes.length; i++) {
            concatenatedBytes[index++] = user_bridgeBytes[i];
        }
        for (uint256 i = 0; i < source_chainIDBytes.length; i++) {
            concatenatedBytes[index++] = source_chainIDBytes[i];
        }
        for (uint256 i = 0; i < target_chainIDBytes.length; i++) {
            concatenatedBytes[index++] = target_chainIDBytes[i];
        }
        for (uint256 i = 0; i < source_contractBytes.length; i++) {
            concatenatedBytes[index++] = source_contractBytes[i];
        }
        for (uint256 i = 0; i < target_contractBytes.length; i++) {
            concatenatedBytes[index++] = target_contractBytes[i];
        }
        for (uint256 i = 0; i < symbolBytes.length; i++) {
            concatenatedBytes[index++] = symbolBytes[i];
        }
        for (uint256 i = 0; i < decimalBytes.length; i++) {
            concatenatedBytes[index++] = decimalBytes[i];
        }
        for (uint256 i = 0; i < amountBytes.length; i++) {
            concatenatedBytes[index++] = amountBytes[i];
        }
        for (uint256 i = 0; i < sign_atBytes.length; i++) {
            concatenatedBytes[index++] = sign_atBytes[i];
        }

        bytes32 transaction = keccak256(abi.encodePacked(string(concatenatedBytes)));
        require(
            !claimedTransactions[transaction],
            "Transaction already claimed!"
        );
        claimedTransactions[transaction] = true;

        require(
            verifySignature(transaction, federationAddress, signature),
            "Failed claim token!"
        );
        
        token = IERC20(address(bytes20(bytes(target_contract))));
        emit Output(msg.sender, stringToUint(amount));
        token.transfer(msg.sender, stringToUint(amount));
    }

    function verifySignature(
        bytes32 message,
        address signer,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 hash = message.toEthSignedMessageHash();
        address recoveredSigner = hash.recover(signature);
        return signer == recoveredSigner;
    }

    receive() external payable {
        emit Input(msg.sender, msg.value);
    }
}

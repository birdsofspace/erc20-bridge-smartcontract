pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

library StringsUtil {
    function toLower(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        
        for (uint i = 0; i < bStr.length; i++) {
            if ((bStr[i] >= 0x41) && (bStr[i] <= 0x5A)) {
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        
        return string(bLower);
    }

     function toHexString(bytes32 data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(64);
        
        for (uint i = 0; i < 32; i++) {
            str[i*2] = alphabet[uint(uint8(data[i] >> 4))];
            str[1+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        
        return string(str);
    }
}

contract Bridge {
    using ECDSA for bytes32;
    using Address for address;
    using MessageHashUtils for bytes32;
    using StringsUtil for string;
    using StringsUtil for bytes32;

    IERC20Upgradeable public token;
    address public federationAddress;

    mapping(bytes32 => bool) public claimedTransactions;
    mapping(bytes => bool) public  usedSignatures;
    mapping(address => mapping(uint256 => uint256)) public _shares;

    event Output(
        address indexed to,
        uint256 indexed amount,
        string indexed sign_at
    );
    event Input(
        address indexed from,
        uint256 indexed amount,
        uint256 indexed request_at
    );

    constructor(address federationAddress_) payable {
        federationAddress = federationAddress_;
    }

    function checkRequest(address user_bridge, uint256 request_at)
        external
        view
        returns (uint256)
    {
        return _shares[user_bridge][request_at];
    }

    function depositToken(
        uint256 target_chainID,
        address source_contract,
        address target_contract,
        string memory symbol,
        uint256 decimal,
        uint256 amount,
        uint256 request_at
    ) external returns (bool success) {
        address user_bridge = msg.sender;

        require(
            IERC20Upgradeable(source_contract).balanceOf(user_bridge) >= amount,
            "Low balance"
        );
        require(
            IERC20Upgradeable(source_contract).allowance(user_bridge, address(this)) >=
                amount,
            "Check token allowance"
        );
        require(
            IERC20Upgradeable(source_contract).transferFrom(
                user_bridge,
                address(this),
                amount
            ),
            "Failed to send token to destination."
        );
        _shares[user_bridge][request_at] = amount;
        emit Input(user_bridge, amount, request_at);

        return true;
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
    ) external returns (bool) {
        string memory target_chainID = Strings.toString(block.chainid);
        string memory user_bridge = Strings.toHexString(
            uint256(uint160(msg.sender)),
            20
        );

        string memory dataPack = string.concat("BRIDGEX-", user_bridge, source_chainID, target_chainID, source_contract, target_contract, symbol, decimal, amount, sign_at).toLower();

        bytes32 transaction = keccak256(abi.encodePacked(dataPack));

        require(
            !usedSignatures[signature],
            "Signature already used!"
        );
        require(
            !claimedTransactions[transaction],
            "Transaction already claimed!"
        );
        require(
            verifySignature(transaction, federationAddress, signature),
             string.concat("Failed claim token: ", dataPack, "[",transaction.toHexString(),"]")
        );

        token = IERC20Upgradeable(stringToAddress(target_contract));
        emit Output(msg.sender, stringToUint(amount), sign_at);
        token.transfer(msg.sender, stringToUint(amount));
        claimedTransactions[transaction] = true;
        usedSignatures[signature] = true;
        return true;
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

    receive() external payable {}


    // Utils
    function stringToUint(string memory _str) public pure returns(uint256 res) {
    
        for (uint256 i = 0; i < bytes(_str).length; i++) {
            if ((uint8(bytes(_str)[i]) - 48) < 0 || (uint8(bytes(_str)[i]) - 48) > 9) {
                return 0;
            }
            res += (uint8(bytes(_str)[i]) - 48) * 10**(bytes(_str).length - i - 1);
        }
        
        return res;
    }
    
    function stringToAddress(string memory _address) public pure returns (address) {
        string memory cleanAddress = remove0xPrefix(_address);
        bytes20 _addressBytes = parseHexStringToBytes20(cleanAddress);
        return address(_addressBytes);
    }

    function remove0xPrefix(string memory _hexString) internal pure returns (string memory) {
        if (bytes(_hexString).length >= 2 && bytes(_hexString)[0] == '0' && (bytes(_hexString)[1] == 'x' || bytes(_hexString)[1] == 'X')) {
            return substring(_hexString, 2, bytes(_hexString).length);
        }
        return _hexString;
    }

    function substring(string memory _str, uint256 _start, uint256 _end) internal pure returns (string memory) {
        bytes memory _strBytes = bytes(_str);
        bytes memory _result = new bytes(_end - _start);
        for (uint256 i = _start; i < _end; i++) {
            _result[i - _start] = _strBytes[i];
        }
        return string(_result);
    }

    function parseHexStringToBytes20(string memory _hexString) internal pure returns (bytes20) {
        bytes memory _bytesString = bytes(_hexString);
        uint160 _parsedBytes = 0;
        for (uint256 i = 0; i < _bytesString.length; i += 2) {
            _parsedBytes *= 256;
            uint8 _byteValue = parseByteToUint8(_bytesString[i]);
            _byteValue *= 16;
            _byteValue += parseByteToUint8(_bytesString[i + 1]);
            _parsedBytes += _byteValue;
        }
        return bytes20(_parsedBytes);
    }

    function parseByteToUint8(bytes1 _byte) internal pure returns (uint8) {
        if (uint8(_byte) >= 48 && uint8(_byte) <= 57) {
            return uint8(_byte) - 48;
        } else if (uint8(_byte) >= 65 && uint8(_byte) <= 70) {
            return uint8(_byte) - 55;
        } else if (uint8(_byte) >= 97 && uint8(_byte) <= 102) {
            return uint8(_byte) - 87;
        } else {
            revert(string(abi.encodePacked("Invalid byte value: ", _byte)));
        }
    }

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Import base Initializable contract
// import "@openzeppelin/upgrades/contracts/Initializable.sol";


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


contract IDS is Ownable, AccessControl {

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant STORAGE_ROLE = keccak256("STORAGE_ROLE");
    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");

    // Initializer function (replaces constructor)
    constructor(address[] memory dataOwners, address[] memory storageOwners, address[] memory dataUsers) {
        for (uint256 i = 0; i < dataOwners.length; ++i) {
            _grantRole(OWNER_ROLE, dataOwners[i]);
        }
        for (uint256 i = 0; i < storageOwners.length; ++i) {
            _grantRole(STORAGE_ROLE, storageOwners[i]);
        }
        for (uint256 i = 0; i < dataUsers.length; ++i) {
            _grantRole(USER_ROLE, dataUsers[i]);
        }

    }

    function changeDataOwner(address dataOwner) public {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not a data owner");
        _grantRole(OWNER_ROLE, dataOwner);
    }

    function changeStorageOwner(address storageOwner) public {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not a data owner");
        _grantRole(STORAGE_ROLE, storageOwner);
    }

    function changeDataUser(address dataUsers) public {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not a data owner");
        _grantRole(USER_ROLE, dataUsers);
    }
}
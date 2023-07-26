// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9; // solhint-disable-line compiler-version

// Import base Initializable contract
// import "@openzeppelin/upgrades/contracts/Initializable.sol";


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


contract IDS is Ownable, AccessControl {

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant STORAGE_ROLE = keccak256("STORAGE_ROLE");
    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");

    bytes32[] public customRoles;
    mapping(bytes32 => string) public customRoleNames;

    mapping(address => bytes32) public dataOwnerMap;

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

    function addRole(string memory name) public {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not a data owner");
        bytes32 new_role = keccak256(abi.encodePacked(name));
        customRoles.push(new_role);
        customRoleNames[new_role] = name;
    }

    function addCustomRole(address customRoleAddr, string memory customRole) public {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not a data owner");
        bytes32 role = keccak256(abi.encodePacked(customRole));
        _grantRole(role, customRoleAddr);
    }

    function addDataOwner(address dataOwner) public {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not a data owner");
        _grantRole(OWNER_ROLE, dataOwner);
    }

    function addStorageOwner(address storageOwner) public {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not a data owner");
        _grantRole(STORAGE_ROLE, storageOwner);
    }

    function addeDataUser(address dataUsers) public {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not a data owner");
        _grantRole(USER_ROLE, dataUsers);
    }

    function removeDataOwner(address dataOwner) public {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not a data owner");
        revokeRole(OWNER_ROLE, dataOwner);
    }

    function removeStorageOwner(address storageOwner) public {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not a data owner");
        revokeRole(STORAGE_ROLE, storageOwner);
    }

    function removeDataUser(address dataUsers) public {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not a data owner");
        revokeRole(USER_ROLE, dataUsers);
    }

    function addData(uint256 dataId, address dataOwner, address storageOwner) public {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not a data owner");
        require(hasRole(OWNER_ROLE, dataOwner), "Data owner is not a data owner");
        require(hasRole(STORAGE_ROLE, storageOwner), "Storage owner is not a storage owner");
        // TODO: Oracle call to add data to storage
    }

    function getData(uint256 dataId) public view returns (address dataOwner, address storageOwner) {
        require(hasRole(USER_ROLE, msg.sender), "Caller is not a data user");
        // TODO: Oracle call to get data from storage; 
    }
    
    // Checks 
    function isDataOwner(address dataOwner) public view returns (bool) {
        return hasRole(OWNER_ROLE, dataOwner);
    }

    function isStorageOwner(address storageOwner) public view returns (bool) {
        return hasRole(STORAGE_ROLE, storageOwner);
    }

    function isDataUser(address dataUsers) public view returns (bool) {
        return hasRole(USER_ROLE, dataUsers);
    }

    function isCustomRole(address customRoleAddr, string memory customRole) public view returns (bool) {
        bytes32 role = keccak256(abi.encodePacked(customRole));
        return hasRole(role, customRoleAddr);
    }


}
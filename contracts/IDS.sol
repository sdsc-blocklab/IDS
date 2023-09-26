// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9; // solhint-disable-line compiler-version

// Import base Initializable contract
// import "@openzeppelin/upgrades/contracts/Initializable.sol";


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


contract IDS is Ownable, AccessControl {

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant STORAGE_ROLE = keccak256("STORAGE_ROLE");
    bytes32 public constant RETRIEVAL_ROLE = keccak256("RETRIEVAL_ROLE");

    bytes32[] public customRoles;
    mapping(bytes32 => string) public customRoleNames;
    mapping(address => bytes32) public dataOwnerMap;
    mapping(address => bytes32) public dataMap;

    mapping(address => bool) public approvedDataQueryers;

    struct DataOwner {
        address dataOwner;
        bytes32 dataId;
        string gender;
        uint256 age;
        string dataType; 
    }

    mapping(address => DataOwner) public dataOwners;
    mapping(address => bytes32[]) public dataRetrievalMap;

    // Initializer function (replaces constructor)
    constructor(address[] memory dataOwners, address[] memory storageOwners, address[] memory dataUsers) {
        for (uint256 i = 0; i < dataOwners.length; ++i) {
            _grantRole(OWNER_ROLE, dataOwners[i]);
        }
        for (uint256 i = 0; i < storageOwners.length; ++i) {
            _grantRole(STORAGE_ROLE, storageOwners[i]);
        }
        for (uint256 i = 0; i < dataUsers.length; ++i) {
            _grantRole(RETRIEVAL_ROLE, dataUsers[i]);
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

    function addDataOwner(address dataOwner, string memory gender, uint256 age, string memory dataType) public {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not a data owner");
        _grantRole(OWNER_ROLE, dataOwner);

        DataOwner memory newOwner = DataOwner(dataOwner, 0, gender, age, dataType);
        dataOwners[dataOwner] = newOwner;
    }

    function addStorageOwner(address storageOwner) public {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not a data owner");
        _grantRole(STORAGE_ROLE, storageOwner);
    }

    function addeDataUser(address dataUsers) public {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not a data owner");
        require(approvedDataQueryers[dataUsers], "Data user is not approved");
        _grantRole(RETRIEVAL_ROLE, dataUsers);
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
        revokeRole(RETRIEVAL_ROLE, dataUsers);
    }

    function addApprovedQueryer(address dataUsers) public {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not a data owner");
        approvedDataQueryers[dataUsers] = true;
    }

    function removeApprovedQueryer(address dataUsers) public {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not a data owner");
        approvedDataQueryers[dataUsers] = false;
    }



    function addData(uint256 dataId, bytes32 genomicData, address dataOwner, address storageOwner) public {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not a data owner");
        require(hasRole(OWNER_ROLE, dataOwner), "Data owner is not a data owner");
        require(hasRole(STORAGE_ROLE, storageOwner), "Storage owner is not a storage owner");
        // TODO: Oracle call to add data to storage

        if (dataOwnerMap[dataOwner] != bytes32(0)) {
            dataOwnerMap[dataOwner] = bytes32(dataId);
            dataMap[dataOwner] = genomicData;
        }
        else appendData(genomicData, dataOwner, storageOwner);

        // TODO: Oracle call to add data to storage
        
    }

    function appendData(bytes32 genomicData, address dataOwner, address storageOwner) public {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not a data owner");
        require(hasRole(OWNER_ROLE, dataOwner), "Data owner is not a data owner");
        require(hasRole(STORAGE_ROLE, storageOwner), "Storage owner is not a storage owner");
        // require(dataOwnerMap[dataOwner] == bytes32(dataId), "Data owner does not own data");

        dataMap[dataOwner] = bytes32(genomicData);
        // TODO: Oracle call to append data to storage
    }

    function removeData(address dataOwner) public {
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not a data owner");
        require(hasRole(OWNER_ROLE, dataOwner), "Data owner is not a data owner");
        dataOwnerMap[dataOwner] = bytes32(0);
        dataMap[dataOwner] = bytes32(0);

        // TODO: Oracle call to remove data from storage
    }

    function requestData(address dataOwner, address dataUser) public returns (uint256 dataId, bytes32 data) {
        require(hasRole(RETRIEVAL_ROLE, msg.sender), "Caller is not a data user");

        uint256 l = dataRetrievalMap[dataUser].length;
        bytes32 data = dataOwnerMap[dataOwner];
        if (l == 0) {
            dataRetrievalMap[dataUser] = new bytes32[](0);
        }
        dataRetrievalMap[dataUser].push() = data;
        
        return (uint256(dataOwnerMap[dataOwner]), dataMap[dataOwner]);

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
        return hasRole(RETRIEVAL_ROLE, dataUsers);
    }

    function isCustomRole(address customRoleAddr, string memory customRole) public view returns (bool) {
        bytes32 role = keccak256(abi.encodePacked(customRole));
        return hasRole(role, customRoleAddr);
    }


}
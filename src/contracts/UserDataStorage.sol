// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "./IFairdaoManager.sol";

/**
 * @title UserDataStorage
 * @dev User data storage contract, responsible for managing user-specific data
 */
contract UserDataStorage {    
    
    struct Storage {
        uint64 timestamp; 
        bytes data;      
    }

    address private _owner;
    IFairdaoManager private _fairdaoManager;

    // User data storage mapping: key => user => storage
    mapping(bytes32 => mapping(address => Storage)) private _userData;

    // User data management event
    /**
     * @dev Emitted when user data is updated
     * @param user User address
     * @param key Key for storing data
     * @param dataLength Length of stored data
     * @param operator The address that executed the update
     */
    event UserDataUpdated(
        address indexed user,
        bytes32 indexed key,
        uint256 dataLength,
        address indexed operator
    );
    
    /**
     * @dev Emitted when FairdaoManager address is set or updated
     * @param managerAddress New FairdaoManager address
     * @param operator The address that executed the update
     */
    event FairdaoManagerSet(
        address indexed managerAddress,
        address indexed operator
    );

    /**
     * @dev Constructor that sets the contract owner
     */
    constructor() {
        _owner = msg.sender;
    }
    
    /**
     * @dev Set the FairdaoManager contract address
     * @param fairdaoManagerAddress Address of the FairdaoManager contract
     * @return success Operation result
     */
    function setFairdaoManager(address fairdaoManagerAddress) external returns (bool) {
        // Check permission based on fairdaoManager status
        if (address(_fairdaoManager) == address(0)) {
            // If fairdaoManager is not set, only contract owner can set it
            require(msg.sender == _owner, "Not owner");
        } else {
            // If fairdaoManager is already set, check via fairdaoManager.isOwner
            require(_fairdaoManager.isOwner(msg.sender), "Not owner");
        }
        
        require(fairdaoManagerAddress != address(0), "Invalid manager addr");
        _fairdaoManager = IFairdaoManager(fairdaoManagerAddress);
        require(_fairdaoManager.isOwner(msg.sender), "Not owner");
        emit FairdaoManagerSet(fairdaoManagerAddress, msg.sender);
        return true;
    }

    /**
     * @dev Store user data
     * @param user User address
     * @param key Key for storing data
     * @param data Data to store
     * @return success Operation result
     */
    function setUserData(
        address user,
        bytes32 key,
        bytes calldata data
    ) external returns (bool) {
        require(address(_fairdaoManager) != address(0), "Manager not set");
        require(user != address(0), "Zero user");
        require(key != bytes32(0), "Zero key");
        require(_fairdaoManager.isKeyManager(key, msg.sender), "Not key manager");        
        if (data.length == 0) {
            delete _userData[key][user];
        } else {
            _userData[key][user] = Storage(uint64(block.timestamp), data);
        }
        
        emit UserDataUpdated(user, key, data.length, msg.sender);
        return true;
    }

    /**
     * @dev Get stored user data
     * @param user User address
     * @param key Key for retrieving data
     * @return data Stored data
     * @return timestamp Last update timestamp
     */
    function getUserData(address user, bytes32 key) external view returns (bytes memory data, uint64 timestamp) {
        require(address(_fairdaoManager) != address(0), "Manager not set");
        require(user != address(0), "Zero user");
        require(key != bytes32(0), "Zero key");
        Storage storage storageData = _userData[key][user];
        return (storageData.data, storageData.timestamp);
    }

    /**
     * @dev Get the FairdaoManager contract address
     * @return fairdaoManagerAddress The address of the FairdaoManager contract
     */
    function getFairdaoManager() external view returns (address) {
        return address(_fairdaoManager);
    }


}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "./IFairdaoManager.sol";

/**
 * @title SharedDataStorage
 * @dev Shared data storage contract, responsible for managing data shared among all users
 */
contract SharedDataStorage  {

    struct Storage {
        uint64 timestamp; 
        bytes data;      
    }

    address private _owner;
    IFairdaoManager private _fairdaoManager;
    // Shared data storage mapping: key => sharedValueId => storage
    mapping(bytes32 => mapping(bytes32 => Storage)) private _sharedData;

    // Shared data management events
    /**
     * @dev Emitted when shared data is updated
     * @param key Key used for storing data
     * @param valueId Unique identifier for the value
     * @param dataLength Length of the stored data
     * @param operator The address that executed the update
     */
    event SharedDataUpdated(
        bytes32 indexed key,
        bytes32 indexed valueId,
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
     * @dev Store shared data
     * @param key Key for storing data
     * @param sharedValueId Unique identifier for the value
     * @param data Data to store
     * @return success Operation result
     */
    function setSharedData(
        bytes32 key,
        bytes32 sharedValueId,
        bytes calldata data
    ) external returns (bool) {
        require(address(_fairdaoManager) != address(0), "Manager not set");
        require(key != bytes32(0), "Zero key");
        require(sharedValueId != bytes32(0), "Zero value ID");
        require(_fairdaoManager.isKeyManager(key, msg.sender), "Not key manager");        
        if (data.length == 0) {
            // Clear shared data
            delete _sharedData[key][sharedValueId];
        } else {
            // Store shared data
            _sharedData[key][sharedValueId] = Storage(uint64(block.timestamp), data);
        }
        
        emit SharedDataUpdated(key, sharedValueId, data.length, msg.sender);
        return true;
    }

    /**
     * @dev Get shared data
     * @param key Key for retrieving data
     * @param sharedValueId Unique identifier for the value
     * @return data Stored shared data
     * @return timestamp Last update timestamp
     */
    function getSharedData(bytes32 key, bytes32 sharedValueId) external view returns (bytes memory data, uint64 timestamp) {
        require(address(_fairdaoManager) != address(0), "Manager not set");
        require(key != bytes32(0), "Zero key");
        require(sharedValueId != bytes32(0), "Zero value ID");
        Storage storage storageData = _sharedData[key][sharedValueId];
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
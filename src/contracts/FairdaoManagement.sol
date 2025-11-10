// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

/**
 * @title FairdaoManagement
 * @dev FAIR DAO Management Contract
 * This contract provides management functionality for managers, owners, and key managers
 * It handles access control, emergency stop mechanism, and key management operations
 */
contract FairdaoManagement  {
    // Manager information structure
    struct ManagerInfo {
        uint64 timestamp; // Timestamp
        bool isOwner;     // Whether is owner
    }
 
    // Manager management events
    /**
     * @dev Emitted when a manager is added
     * @param manager The address of the added manager
     * @param isOwner Whether the manager is an owner
     * @param operator The address that executed the addition
     */
    event ManagerAdded(
        address indexed manager,
        bool isOwner,
        address indexed operator
    );
    
    /**
     * @dev Emitted when a manager is removed
     * @param manager The address of the removed manager
     * @param wasOwner Whether the manager was an owner
     * @param operator The address that executed the removal
     */
    event ManagerRemoved(
        address indexed manager,
        bool wasOwner,
        address indexed operator
    );
    
    // Key manager events
    /**
     * @dev Emitted when a key manager is added
     * @param key The key being managed
     * @param manager The address of the key manager
     * @param operator The address that executed the addition
     */
    event AddKeyManager(
        bytes32 indexed key,
        address manager,
        address indexed operator
    );
    
    /**
     * @dev Emitted when key management is transferred
     * @param key The key being managed
     * @param oldManager The previous manager address
     * @param newManager The new manager address
     * @param operator The address that executed the transfer
     */
    event TransferKeyManager(
        bytes32 indexed key,
        address oldManager,
        address newManager,
        address indexed operator
    );
    
    // Emergency events
    /**
     * @dev Emitted when emergency stop is enabled
     * @param operator The address that enabled emergency stop
     */
    event EmergencyStopped(address indexed operator);
    
    /**
     * @dev Emitted when emergency stop is disabled
     * @param operator The address that disabled emergency stop
     */
    event EmergencyResumed(address indexed operator);

    // State variables
    bool private _emergencyStop = false;                   // Emergency stop flag
    address[] private _managerArray;                       // Managers array
    mapping(address => ManagerInfo) private _managers;     // Managers mapping
    mapping(bytes32 => address) private _keyManagers;      // Key managers mapping

    // Access control modifiers
    modifier onlyOwner() {
        require(_managers[msg.sender].isOwner, "Not owner");
        _;
    }

    modifier onlyManager() {
        require(_managers[msg.sender].timestamp > 0, "Not manager");
        _;
    }

    modifier notEmergency() {
        require(!_emergencyStop, "Emergency stop active");
        _;
    }

    /**
     * @dev Constructor that initializes the contract with initial owner
     * Sets the deployer address as the first owner
     */
    constructor() {
        require(block.timestamp > 0, "Invalid time");
        _addManager(msg.sender, true);
    }
    
    /**
     * @dev Add a new manager (internal)
     * @param _manager Address of the new manager
     * @param _isOwner Whether the new manager is an owner
     */
    function _addManager(address _manager, bool _isOwner) private {
        require(_manager != address(0), "Zero manager");
        require(_managers[_manager].timestamp == 0, "Exists");
        require(block.timestamp > 0, "Invalid timestamp");
        
        _managers[_manager] = ManagerInfo({
            timestamp: uint64(block.timestamp),
            isOwner: _isOwner
        });
        _managerArray.push(_manager);
        emit ManagerAdded(_manager, _isOwner, msg.sender);
    }

    // ============== MANAGER MANAGEMENT ==============

    /**
     * @dev Check if an address is a manager
     * @param user The address to check
     * @return isManager Whether the address is a manager
     */
    function isManager(address user) external view returns (bool) {
        return _managers[user].timestamp > 0;
    }

    /**
     * @dev Check if an address is an owner
     * @param user The address to check
     * @return isOwner Whether the address has owner privileges
     */
    function isOwner(address user) external view returns (bool) {
        return _managers[user].isOwner;
    }

    /**
     * @dev Add a new manager
     * @param manager Address of the new manager
     * @param withOwnerPermission Whether the new manager is an owner
     * @return success Operation result
     */
    function addManager(address manager, bool withOwnerPermission) external onlyOwner notEmergency returns (bool) {
        _addManager(manager, withOwnerPermission);
        return true;
    }

    /**
     * @dev Get the number of managers
     * @return count Number of managers
     */
    function getManagerCount() external view returns (uint256) {
        return _managerArray.length;
    }

    /**
     * @dev Remove a manager
     * @param index Index of the manager in managerArray
     * @param manager Address of the manager to remove
     * @return success Operation result
     */
    function removeManager(
        uint256 index,
        address manager
    ) external onlyOwner notEmergency returns (bool) {
        require(manager != address(0), "Zero manager");
        require(index < _managerArray.length , "Bad index");
        // Ensure the provided manager address matches the one at the given index
        require(_managerArray[index] == manager, "Address mismatch");        
        ManagerInfo memory managerInfo = _managers[manager];
        require(managerInfo.timestamp > 0, "Invalid manager");
        if(managerInfo.isOwner) {
            ManagerInfo memory opt = _managers[msg.sender];        
            require(opt.timestamp < managerInfo.timestamp,"Access denied");
        }

        uint256 lastIndex = _managerArray.length - 1;
        if (index < lastIndex) {
            _managerArray[index] = _managerArray[lastIndex];
        }        
        _managerArray.pop();
        delete _managers[manager];
        
        emit ManagerRemoved(manager, managerInfo.isOwner, msg.sender);
        return true;
    }

    /**
     * @dev Get manager at specific index
     * @param index Index in the manager array
     * @return manager Manager address
     */
    function getManagerAtIndex(uint256 index) external view returns (address) {
        require(index < _managerArray.length, "Index OOB");
        return _managerArray[index];
    }

    /**
     * @dev Get manager information for an address
     * @param user The address to get information for
     * @return timestamp When the manager was added (0 if not a manager)
     * @return ownerPermission Whether the manager has owner privileges
     */
    function getManagerInfo(address user) external view returns (uint256 timestamp, bool ownerPermission){
        ManagerInfo memory info = _managers[user];
        return (info.timestamp, info.isOwner);
    }    

    // ============== KEY MANAGER MANAGEMENT ==============

    /**
     * @dev Check if an address is a key manager
     * @param key The key
     * @param user The address to check
     * @return isKeyManager Whether the address is a key manager
     */
    function isKeyManager(bytes32 key, address user) external view returns (bool) {
        if (user == address(0) || key==bytes32(0)) return false;
        return _keyManagers[key] == user;
    }


    /**
     * @dev Get the manager address for a specific key
     * @param key The key to query
     * @return manager The address of the key manager, or address(0) if none
     */
    function getKeyManager(bytes32 key) external view returns (address manager) {
        require(key != bytes32(0), "Zero key");
        return _keyManagers[key];
    }


    /**
     * @dev Add a manager for a single key
     * @param key Key to add manager for
     * @param manager Manager address
     * @return success Operation result
     */
    function addKeyManager(
        bytes32 key,
        address manager
    ) external onlyManager notEmergency returns (bool) {
        require(manager != address(0), "Zero manager");        
        require(key != bytes32(0), "Key cannot be zero");
        require(_keyManagers[key] == address(0), "Has manager");                
        _keyManagers[key] = manager;
        emit AddKeyManager(key, manager, msg.sender);        
        return true;
    }

    /**
     * @dev Transfer key management to another address
     * Only owners can transfer key management rights
     * @param key Key to transfer management for
     * @param newManager New manager address
     * @return success Operation result
     */
    function transferKeyManager(bytes32 key, address newManager) external notEmergency onlyManager returns (bool) {
        require(newManager != address(0), "Zero manager"); 
        require(key != bytes32(0), "Key cannot be zero");
        address oldManager = _keyManagers[key];
        // Ensure the key has a manager before transferring
        require(oldManager != address(0), "No manager");
        _keyManagers[key] = newManager;        
        emit TransferKeyManager(key, oldManager, newManager, msg.sender);
        return true;
    }

    // ============== EMERGENCY STOP FUNCTIONALITY ==============

    /**
     * @dev Check if the contract is in emergency stop state
     * @return isStopped Whether the contract is in emergency stop state
     */
    function isEmergencyStopped() external view returns (bool) {
        return _emergencyStop;
    }

    /**
     * @dev Enable emergency stop (only owner)
     * This function pauses all critical operations in the contract
     * @return success Operation result
     */
    function enableEmergencyStop() external onlyOwner returns (bool) {
        _emergencyStop = true;
        emit EmergencyStopped(msg.sender);
        return true;
    }

    /**
     * @dev Disable emergency stop (only owner)
     * This function resumes all critical operations in the contract
     * @return success Operation result
     */
    function disableEmergencyStop() external onlyOwner returns (bool) {
        require(_emergencyStop, "Not emergency");
        _emergencyStop = false;
        emit EmergencyResumed(msg.sender);
        return true;
    }
}
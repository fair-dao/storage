// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

/**
 * @title FairdaoStorage - FAIR DAO Data Storage Contract
 * @dev FAIR DAO 数据存储合约
 */
contract FairdaoStorage {
    struct Storage {
        uint64 timestamp;
        bytes data;
    }

    struct ManagerInfo {
        uint64 timestamp;
        bool isOwner;
    }

    event EmergencyStopped(address indexed creator);
    event EmergencyResumed(address indexed creator);
    
    event ManagerAdded(
        address indexed manager,
        bool indexed isOwner,
        address indexed writer
    );
    
    event ManagerRemoved(
        address indexed manager,
        bool indexed wasOwner,
        address indexed writer
    );
    
    event SetConfigKeyManager(
        bytes32 indexed key,
        address indexed oldManager,
        address indexed newManager,
        address writer
    );
    
    event UserDataUpdated(
        address indexed user,
        bytes32 indexed key,
        uint256 dataLength,
        address indexed writer
    );
    
    event SharedDataUpdated(
        bytes32 indexed key,
        bytes32 indexed valueId,
        uint256 dataLength,
        address indexed writer
    );
    
    event TokenDeposited(
        address indexed user,
        bytes32 indexed key,
        uint256 amount,
        address indexed operator
    );
    
    event TokenWithdrawn(
        address indexed user,
        bytes32 indexed key,
        uint256 amount,
        address indexed operator
    );
    


    mapping(address => ManagerInfo) public managers;
    address[] private managerArray;
    


    mapping(bytes32 => address) public keyManagers;
    bytes32[] private keyArray;

    mapping(bytes32 => mapping(address => Storage)) private userData;
    
    mapping(bytes32 => mapping(bytes32 => Storage)) private sharedData;
    
    // 用户代币余额映射：键 => 用户 => 余额
    mapping(bytes32 => mapping(address => uint256)) private tokenBalances;

    bool private emergencyStop = false;
    
    modifier notEmergency() {
        require(!emergencyStop, "Contract is in emergency stop");
        _;
    }
    
    modifier onlyManager() {
        require(this.isManager(msg.sender), "Only enabled manager can call this function");
        _;
    }

    modifier isOwner() {
        require(managers[msg.sender].isOwner, "Only owner can call this function");
        _;
    }

    /**
     * @dev Constructor / 构造函数
     */
    constructor() {
        _addManager(msg.sender, true);
    }

    /**
     * @dev Add a new manager (internal) / 添加新管理者（内部函数）
     * @param _manager Address of the new manager / 新管理者的地址
     * @param _isOwner Whether the new manager is an owner / 新管理者是否是所有者
     */
    function _addManager(address _manager, bool _isOwner) private {
        require(_manager != address(0), "Manager address cannot be zero");
        require(managers[_manager].timestamp == 0, "Already a manager");
        
        managers[_manager] = ManagerInfo({
            timestamp: 0,
            isOwner: _isOwner
        });
        managerArray.push(_manager);
        emit ManagerAdded(_manager, _isOwner, msg.sender);
    }



    /**
     * @dev Check if address is manager / 检测是否为管理员
     * @param user Address to check / 要检查的地址
     * @return isManager Whether the address is a manager / 该地址是否为管理员
     */
    function isManager(address user) external view returns (bool) {
        return managers[user].timestamp > 0;
    }

    /**
     * @dev Check if address is key manager / 检测是否为键管理者
     * @param key Key / 键
     * @param user Address to check / 要检查的地址
     * @return isKeyManager Whether the address is the key manager / 该地址是否为键管理者
     */
    function isKeyManager(bytes32 key, address user) external view returns (bool) {
        if (user == address(0)) return false;
        return keyManagers[key] == user;
    }

    /**
     * @dev Get the number of owners / 获取所有者人数
     * @return count Number of owners / 所有者人数
     */
    function getOwnerCount() public view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < managerArray.length; i++) {
            if (managers[managerArray[i]].isOwner) {
                count++;
            }
        }
        return count;
    }

    /**
     * @dev Add a new manager / 添加新管理者
     * @param manager Address of the new manager / 新管理者的地址
     * @param withOwnerPermission Whether the new manager is an owner / 新管理者是否是所有者
     * @return success Operation result / 操作结果
     */
    function addManager(address manager, bool withOwnerPermission) external isOwner notEmergency returns (bool) {
        require(!withOwnerPermission || managers[msg.sender].isOwner, "Only owner can add owner");
        _addManager(manager, withOwnerPermission);
        return true;
    }

    /**
     * @dev Get the number of managers / 获取管理者数量
     * @return count Number of managers / 管理者数量
     */
    function getManagerCount() external view returns (uint256) {
        return managerArray.length;
    }

    /**
     * @dev Remove a manager / 移除管理者
     * @param index Index of the manager in managerArray / 管理者在managerArray中的索引
     * @param manager Address of the manager to remove / 要移除的管理者地址
     * @return success Operation result / 操作结果
     */
    function removeManager(uint256 index, address manager) external isOwner notEmergency returns (bool) {
        require(manager != address(0), "Manager address cannot be zero");
        require(managerArray.length > 0, "No managers to remove");
        
        ManagerInfo memory managerInfo = managers[manager];
        require(managerInfo.timestamp > 0 && managerArray[index] == manager, "Not a manager");
        require(index < managerArray.length, "Manager index out of bounds");
        
        if (managerInfo.isOwner) {
            uint256 currentOwnerCount = getOwnerCount();
            require(currentOwnerCount > 1, "Cannot remove last owner");
        }

        uint256 lastIndex = managerArray.length - 1;
        if (index < lastIndex) {
            managerArray[index] = managerArray[lastIndex];
        }
        
        managerArray.pop();
        
        delete managers[manager];
        
        emit ManagerRemoved(manager, managerInfo.isOwner, msg.sender);
        return true;
    }
    
    /**
     * @dev Set a manager for multiple  keys / 为多个键设置同一个管理者
     * @param keys Array of  keys / 键数组
     * @param manager Manager address / 管理者地址
     * @return success Operation result / 操作结果
     */
    function setKeyManagers(bytes32[] memory keys, address oldManager, address manager) external onlyManager notEmergency returns (bool) {
        require(manager != address(0), "Manager cannot be zero");
        require(keys.length > 0, "Keys array cannot be empty");

        for (uint256 i = 0; i < keys.length; i++) {
            bytes32 key = keys[i];
            address oldKeyManager = keyManagers[key];
            
            if (oldKeyManager == address(0)) {
                keyArray.push(key);
            } else {
                require(oldKeyManager == oldManager,"OldManager error");
            }
            
            keyManagers[key] = manager;
            emit SetConfigKeyManager(key, oldManager, manager, msg.sender);
        }
        
        return true;
    }
    
    
    /**
     * @dev Store data for a user / 为用户存储数据
     * @param user User address / 用户地址
     * @param key 键
     * @param data Data to store / 要存储的数据
     * @return success Operation result / 操作结果
     */
    function setUserData(address user, bytes32 key, bytes calldata data) external notEmergency returns (bool) {
        require(user != address(0), "User address cannot be zero");
        require(keyManagers[key] == msg.sender, "Only key manager");
        
        if (data.length == 0) {
            delete userData[key][user];
        } else {
            userData[key][user] = Storage(uint64(block.timestamp), data);
        }
        
        emit UserDataUpdated(user, key, data.length, msg.sender);
        return true;
    }

    /**
     * @dev Get stored data for user (only key manager) / 获取用户的存储数据（仅键管理者）
     * @param user User address / 用户地址
     * @param key  键
     * @return data Stored data / 存储的数据
     * @return timestamp Last update timestamp / 最后更新时间戳
     */
    function getUserData(address user, bytes32 key) external view returns (bytes memory data, uint64 timestamp) {
        require(user != address(0), "User address cannot be zero");
        require(keyManagers[key] == msg.sender, "Only key manager");
        
        Storage storage storageData = userData[key][user];
        data = storageData.data;
        timestamp = storageData.timestamp;
        return (data, timestamp);
    }

    /**
     * @dev Store shared data (only key manager) / 存储共享数据（仅键管理者）
     * @param key  键
     * @param sharedValueId Unique identifier for the value / 值的唯一标识符
     * @param data Data to store / 要存储的数据
     * @return success Operation result / 操作结果
     */
    function setSharedData(bytes32 key, bytes32 sharedValueId, bytes calldata data) external notEmergency returns (bool) {
        require(sharedValueId != 0, "Value ID cannot be zero");
        require(keyManagers[key] == msg.sender, "Only config key manager");
        
        if (data.length == 0) {
            // Clear shared data / 清除共享数据
            delete sharedData[key][sharedValueId];
        } else {
            // Store shared data / 存储共享数据
            sharedData[key][sharedValueId] = Storage(uint64(block.timestamp), data);
        }
        
        emit SharedDataUpdated(key, sharedValueId, data.length, msg.sender);
        return true;
    }

    /**
     * @dev Get shared data / 获取共享数据
     * @param key  键
     * @param sharedValueId Unique identifier for the value / 值的唯一标识符
     * @return data Stored shared data / 存储的共享数据
     * @return timestamp Last update timestamp / 最后更新时间戳
     */
    function getSharedData(bytes32 key, bytes32 sharedValueId) external view returns (bytes memory data, uint64 timestamp) {
        
        Storage storage storageData = sharedData[key][sharedValueId];
        return (storageData.data, storageData.timestamp);
    }

    /**
     * @dev Enable emergency stop (only owner) / 启用紧急停止（仅所有者）
     * This function will pause all critical operations in the contract
     * 此函数将暂停合约中的所有关键操作
     * @return success Operation result / 操作结果
     */
    function enableEmergencyStop() external isOwner returns (bool) {
        emergencyStop = true;
        emit EmergencyStopped(msg.sender);
        return true;       
    }
    
    /**
     * @dev Disable emergency stop (only owner) / 禁用紧急停止（仅所有者）
     * This function will resume all critical operations in the contract
     * 此函数将恢复合约中的所有关键操作
     * @return success Operation result / 操作结果
     */
    function disableEmergencyStop() external isOwner returns (bool) {
        require(emergencyStop, "Contract is not in emergency stop");        
        emergencyStop = false;
        emit EmergencyResumed(msg.sender);
        return true;      
    }
    
    /**
     * @dev Check if contract is in emergency stop / 检查合约是否处于紧急停止状态
     * @return isStopped Whether the contract is in emergency stop / 合约是否处于紧急停止状态
     */
    function isEmergencyStopped() external view returns (bool) {
        return emergencyStop;
    }

    /**
     * @dev Get manager at specific index / 获取特定索引的管理者
     * @param index Index in the manager array / 管理者数组中的索引
     * @return manager Manager address / 管理者地址
     */
    function getManagerAtIndex(uint256 index) external view returns (address) {
        require(index < managerArray.length, "Index out of bounds");
        return managerArray[index];
    }

    /**
     * @dev Get key at specific index / 获取特定索引的键
     * @param index Index in the key array / 键数组中的索引
     * @return key Key value / 键值
     */
    function getKeyAtIndex(uint256 index) external view returns (bytes32) {
        require(index < keyArray.length, "Index out of bounds");
        return keyArray[index];
    }
    
    /**
     * @dev 存入代币到用户账户（仅键管理者）
     * @param user 用户地址
     * @param key 键
     * @param amount 存入金额
     * @return success 操作结果
     */
    function depositTokens(address user, bytes32 key, uint256 amount) external notEmergency returns (bool) {
        require(user != address(0), "User address cannot be zero");
        require(amount > 0, "Amount must be greater than zero");
        require(keyManagers[key] == msg.sender, "Only key manager");
        
        // 增加用户余额
        tokenBalances[key][user] += amount;
        
        emit TokenDeposited(user, key, amount, msg.sender);
        return true;
    }
    
    /**
     * @dev 从用户账户取出代币（仅键管理者）
     * @param user 用户地址
     * @param key 键
     * @param amount 取出金额
     * @return success 操作结果
     */
    function withdrawTokens(address user, bytes32 key, uint256 amount) external notEmergency returns (bool) {
        require(user != address(0), "User address cannot be zero");
        require(amount > 0, "Amount must be greater than zero");
        require(keyManagers[key] == msg.sender, "Only key manager");
        require(tokenBalances[key][user] >= amount, "Insufficient balance");
        
        // 减少用户余额
        tokenBalances[key][user] -= amount;
        
        emit TokenWithdrawn(user, key, amount, msg.sender);
        return true;
    }
    
    /**
     * @dev 查询用户代币余额（仅键管理者）
     * @param user 用户地址
     * @param key 键
     * @return balance 用户余额
     */
    function getTokenBalance(address user, bytes32 key) external view returns (uint256 balance) {        
        return tokenBalances[key][user];
    }
    
    
    

}
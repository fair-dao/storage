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

    struct ApprovedInfo {
        address approver;
        uint64 approveTime;
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
    


    mapping(address => ManagerInfo) public managers;
    address[] private managerArray;
    
    mapping(bytes32 => ApprovedInfo[]) private operateApproved;

    uint64 public minApproveNumber = 1;

    mapping(bytes32 => address) public keyManagers;
    bytes32[] private keyArray;

    mapping(bytes32 => mapping(address => Storage)) private userData;
    
    mapping(bytes32 => mapping(bytes32 => Storage)) private sharedData;

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
     * @dev Check if operation is approved / 检查操作是否已获得批准
     * @param operationCode Operation identifier / 操作标识符
     * @return approved Whether the operation is approved / 操作是否已批准
     */
    function _checkApproved(bytes memory operationCode) private returns (bool) {
        if(minApproveNumber == 0) return true;
        bytes32 operationId = keccak256(operationCode);
        ApprovedInfo[] storage approvals = operateApproved[operationId];
        uint64 curTime = uint64(block.timestamp);

        bool alreadyApproved = false;
        for (uint256 i = 0; i < approvals.length; i++) {
            if (approvals[i].approver == msg.sender) {
                alreadyApproved = true;
                if (curTime - approvals[i].approveTime > 60 * 60 * 24) {
                    approvals[i].approveTime = curTime;
                }
                break;
            }
        }
        
        if (alreadyApproved) {
            return false;
        }
        
        for (uint256 i = approvals.length; i > 0; i--) {
            uint256 index = i - 1;
            if (curTime - approvals[index].approveTime > 60 * 60 * 24) {
                if (index < approvals.length - 1) {
                    approvals[index] = approvals[approvals.length - 1];
                }
                approvals.pop();
            }
        }
        
        ApprovedInfo memory info = ApprovedInfo({
            approver: msg.sender,
            approveTime: curTime
        });
        
        approvals.push(info);
        
        if (approvals.length >= minApproveNumber) {
            delete operateApproved[operationId];
            return true;
        }
        
        return false;
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
     * @dev Check if address is config key manager / 检测是否为配置键管理者
     * @param key Configuration key / 配置键
     * @param user Address to check / 要检查的地址
     * @return isKeyManager Whether the address is the key manager / 该地址是否为配置键管理者
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
        bytes memory operationCode = abi.encode(1, manager, withOwnerPermission);
        
        if (_checkApproved(operationCode)) {
            _addManager(manager, withOwnerPermission);
            return true;
        } else {
            return false;
        }
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
            require(currentOwnerCount > minApproveNumber + 1, "Cannot remove owner, owner count must be at least minApproveNumber + 2");
            
            if(currentOwnerCount < minApproveNumber + 5) {
                bytes memory operationCode = abi.encode(2, manager);
                if (!_checkApproved(operationCode)) {
                    return false;
                }
            }
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
     * @dev Set a manager for multiple configuration keys / 为多个配置键设置同一个管理者
     * @param keys Array of configuration keys / 配置键数组
     * @param manager Manager address / 管理者地址
     * @return success Operation result / 操作结果
     */
    function setKeyManagers(bytes32[] memory keys, address oldManager, address manager) external onlyManager notEmergency returns (bool) {
        require(manager != address(0), "Manager cannot be zero");
        require(keys.length > 0, "Config keys array cannot be empty");

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
     * @param targetUser User address / 用户地址
     * @param key Configuration key / 配置键
     * @param data Data to store / 要存储的数据
     * @return success Operation result / 操作结果
     */
    function setUserData(address targetUser, bytes32 key, bytes calldata data) external notEmergency returns (bool) {
        require(targetUser != address(0), "User address cannot be zero");
        require(keyManagers[key] == msg.sender, "Only config key manager");
        
        if (data.length == 0) {
            delete userData[key][targetUser];
        } else {
            userData[key][targetUser] = Storage(uint64(block.timestamp), data);
        }
        
        emit UserDataUpdated(targetUser, key, data.length, msg.sender);
        return true;
    }

    /**
     * @dev Get stored data for user (only config key manager) / 获取用户的存储数据（仅配置键管理者）
     * @param targetUser User address / 用户地址
     * @param key Configuration key / 配置键
     * @return data Stored data / 存储的数据
     * @return timestamp Last update timestamp / 最后更新时间戳
     */
    function getUserData(address targetUser, bytes32 key) external view returns (bytes memory data, uint64 timestamp) {
        require(targetUser != address(0), "User address cannot be zero");
        require(keyManagers[key] == msg.sender, "Only config key manager");
        
        Storage storage storageData = userData[key][targetUser];
        data = storageData.data;
        timestamp = storageData.timestamp;
        return (data, timestamp);
    }

    /**
     * @dev Store shared data (only config key manager) / 存储共享数据（仅配置键管理者）
     * @param key Configuration key / 配置键
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
     * @param key Configuration key / 配置键
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
     * @dev Get config key at specific index / 获取特定索引的配置键
     * @param index Index in the config key array / 配置键数组中的索引
     * @return key Configuration key value / 配置键值
     */
    function getKeyAtIndex(uint256 index) external view returns (bytes32) {
        require(index < keyArray.length, "Index out of bounds");
        return keyArray[index];
    }

    /**
     * @dev Set minimum approve number / 设置批准授权最小数量
     * Only owner can operate / 只有所有者可以操作
     * @param newMinApproveNumber New minimum approve number / 新的最小批准数量
     * @return success Operation result / 操作结果
     */
    function setMinApproveNumber(uint64 newMinApproveNumber) external isOwner notEmergency returns (bool) {
        uint256 ownerCount = getOwnerCount();
        
        require(newMinApproveNumber > 0, "minApproveNumber must be greater than 0");
        require(newMinApproveNumber + 2  < ownerCount, "minApproveNumber must be less than ownerCount - 2");
        
        if (newMinApproveNumber == minApproveNumber) {
            return true;
        }
        
        bytes memory operationCode = abi.encode(6, newMinApproveNumber);
        if (_checkApproved(operationCode)) {
            minApproveNumber = newMinApproveNumber;
            return true;
        } else {
            return false;
        }
    }
}
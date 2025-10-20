# FAIR DAO 用户数据存储库合约

[English](README.md)  ·  [简体中文](README_CN.md)  ·  [Русский](README_RU.md)  ·  [Español](README_ES.md)  ·  [Français](README_FR.md)  ·  [العربية](README_AR.md)

## 简介
用户数据存储库合约是FAIR DAO的主要后端数据存储服务，为其他智能合约提供安全且灵活的数据存储能力，同时配备全面的访问控制机制。

## 核心功能

### 1. 管理者管理
- **添加/移除管理者**：所有者可以添加或移除具有可配置权限的管理者
- **基于角色的访问控制**：区分常规管理者和拥有更高权限的所有者

### 2. 配置键管理
- **键管理者分配**：为特定配置键分配特定的管理者以控制访问权限
- **批量键管理者设置**：高效地同时为多个配置键设置管理者
- **键追踪**：维护所有已注册配置键的索引

### 3. 数据存储功能
- **用户特定数据存储**：存储和检索与特定用户地址相关的数据
- **共享数据存储**：存储和检索可由多个合约/用户访问的数据
- **时间戳跟踪**：自动记录所有数据修改的时间戳

### 4. 安全机制
- **紧急停止**：在发生安全事件时暂停合约的关键操作
- **权限验证**：对所有敏感操作进行严格的访问控制

### 5. 查询功能
- **管理者信息**：检索管理者列表及其权限
- **键信息**：访问已注册的配置键及其分配的管理者
- **合约状态**：检查合约是否处于紧急停止模式

## 合约功能

### 管理者管理
- `addManager(address manager, bool withOwnerPermission)`：添加具有可选所有者权限的新管理者
- `removeManager(uint256 index, address manager)`：移除现有管理者
- `isManager(address user)`：检查地址是否为管理者
- `getOwnerCount()`：获取所有者数量
- `getManagerCount()`：获取管理者总数

### 键管理
- `setKeyManagers(bytes32[] keys, address oldManager, address manager)`：为多个配置键设置管理者
- `isKeyManager(bytes32 key, address user)`：检查地址是否为特定键的管理者
- `getKeyAtIndex(uint256 index)`：获取特定索引处的配置键

### 数据操作
- `setUserData(address targetUser, bytes32 key, bytes data)`：为特定用户存储数据
- `getUserData(address targetUser, bytes32 key)`：检索用户特定数据
- `setSharedData(bytes32 key, bytes32 sharedValueId, bytes data)`：存储共享数据
- `getSharedData(bytes32 key, bytes32 sharedValueId)`：检索共享数据

### 安全功能
- `enableEmergencyStop()`：暂停合约的关键操作
- `disableEmergencyStop()`：恢复合约操作
- `isEmergencyStopped()`：检查合约是否处于紧急停止模式

## 贡献

* 我们欢迎提交PR投稿或报告问题，请参考[贡献指南](https://github.com/fair-dao/.github/blob/main/CONTRIBUTING_CN.md)。
* **在贡献的同时，可留下您的波场钱包地址（至少一次），我们会在每个季度评估您的贡献程度，针对积极参与者发放Fair代币作为奖励。**

## 授权

* 版权所有 （c） 2025 FAIR DAO，保留所有权利。
* 根据 GNU 通用公共许可证第 3 版 （[GPLv3](LICENSE)）获得许可。



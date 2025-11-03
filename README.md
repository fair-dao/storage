# FAIR DAO User Data Storage Repository Contract

[English](README.md)  ·  [简体中文](README_CN.md)  ·  [Русский](README_RU.md)  ·  [Español](README_ES.md)  ·  [Français](README_FR.md)  ·  [العربية](README_AR.md)

## Introduction
The User Data Storage Repository Contract is FAIR DAO's primary backend data storage service for other smart contracts. It provides secure and flexible data storage capabilities with comprehensive access control mechanisms.

## Core Features

### 1. Manager Management
- **Add/Remove Managers**: Owners can add or remove managers with configurable permissions
- **Role-based Access Control**: Distinguishes between regular managers and owners with elevated privileges
- **Optimized Permission Checks**: Direct state verification for gas efficiency and improved execution performance

### 2. Key Management
- **Key Manager Assignment**: Assign specific managers to control access to particular keys
- **Batch Key Manager Setting**: Efficiently set managers for multiple keys simultaneously
- **Key Tracking**: Maintain an index of all registered keys

### 3. Data Storage Functions
- **User-specific Data Storage**: Store and retrieve data associated with specific user addresses
- **Shared Data Storage**: Store and retrieve data accessible by multiple contracts/users
- **Timestamp Tracking**: Automatically record timestamps for all data modifications

### 4. Security Mechanisms
- **Emergency Stop**: Pause critical contract operations in case of security incidents
- **Permission Validation**: Strict access control for all sensitive operations
- **Optimized Security Patterns**: Efficient state variable access for enhanced security and reduced gas costs

### 5. Query Functions
- **Manager Information**: Retrieve lists of managers and their permissions
- **Key Information**: Access registered keys and their assigned managers
- **Contract Status**: Check if the contract is in emergency stop mode

### 6. Token Operations
- **Token Deposits**: Deposit tokens to user accounts (key manager only)
- **Token Withdrawals**: Withdraw tokens from user accounts (key manager only)
- **Balance Queries**: Check token balances for users (public access)
- **Event Emission**: Emit events for all token transfers for transparent tracking
- **Key Management Transfer**: Transfer management of keys to other addresses (key manager only)

## Contract Functions

### Manager Management
- `addManager(address manager, bool withOwnerPermission)`: Add a new manager with optional owner permissions
- `removeManager(uint256 index, address manager)`: Remove an existing manager
- `isManager(address user)`: Check if an address is a manager
- `getOwnerCount()`: Get the number of owners
- `getManagerCount()`: Get the total number of managers
- **Optimized Permission Modifiers**: Direct state checks using `managers[msg.sender].timestamp > 0` for gas efficiency instead of external function calls

### Key Management
- `addKeyManagers(bytes32[] keys, address manager)`: Add a manager for multiple keys (only manager) - only works if keys have no existing manager
- `isKeyManager(bytes32 key, address user)`: Check if an address is a manager for a specific key
- `getKeyAtIndex(uint256 index)`: Get a key at a specific index

### Data Operations
- `setUserData(address targetUser, bytes32 key, bytes data)`: Store data for a specific user
- `getUserData(address targetUser, bytes32 key)`: Retrieve user-specific data
- `setSharedData(bytes32 key, bytes32 sharedValueId, bytes data)`: Store shared data
- `getSharedData(bytes32 key, bytes32 sharedValueId)`: Retrieve shared data

### Token Operations
- `depositTokens(address user, bytes32 key, uint256 amount)`: Deposit tokens to a user account (key manager only)
- `withdrawTokens(address user, bytes32 key, uint256 amount)`: Withdraw tokens from a user account (key manager only)
- `getTokenBalance(address user, bytes32 key)`: Check a user's token balance (public access)
- `transferKeyManagement(bytes32 key, address newManager)`: Transfer key management to another address (key manager only)

### Events
- `AddKeyManager(bytes32 indexed key, address indexed manager, address writer)`: Emitted when a key manager is added
- `TransferKeyManager(bytes32 indexed key, address indexed oldManager, address indexed newManager, address writer)`: Emitted when key management is transferred
- `TokenDeposited(address user, bytes32 key, uint256 amount, address operator)`: Emitted when tokens are deposited
- `TokenWithdrawn(address user, bytes32 key, uint256 amount, address operator)`: Emitted when tokens are withdrawn
- `EmergencyStopped(address operator)`: Emitted when emergency stop is enabled
- `EmergencyResumed(address operator)`: Emitted when emergency stop is disabled

### Security Functions
- `enableEmergencyStop()`: Pause critical contract operations
- `disableEmergencyStop()`: Resume contract operations
- `isEmergencyStopped()`: Check if contract is in emergency stop mode

## Contribution

* We welcome PR submissions or issue reports, please refer to the [Contribution Guidelines](https://github.com/fair-dao/.github/blob/main/CONTRIBUTING_EN.md).
* **When contributing, you can leave your TRON wallet address (at least once), and we will evaluate your contribution level every quarter and distribute Fair tokens as rewards to active participants.**

## License

* Copyright (c) 2025 FAIR DAO. All rights reserved.
* Licensed under the GNU General Public License Version 3 ( [GPLv3](LICENSE) ).
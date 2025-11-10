// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

/**
 * @title IFairdaoManager
 * @dev Interface for FAIR DAO Management Contract
 * This interface defines the public and external functions for manager,
 * owner, and key manager management operations
 */
interface IFairdaoManager {
    /**
     * @dev Check if an address is an owner
     * @param user The address to check
     * @return isOwner Whether the address is an owner
     */
    function isOwner(address user) external view returns (bool);
    
    /**
     * @dev Check if an address is a manager
     * @param user The address to check
     * @return isManager Whether the address is a manager
     */
    function isManager(address user) external view returns (bool);

    /**
     * @dev Check if an address is a key manager
     * @param key The key
     * @param user The address to check
     * @return isKeyManager Whether the address is a key manager
     */
    function isKeyManager(bytes32 key, address user) external view returns (bool);

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IExampleClone.sol";

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract ExampleFactory is AccessControl {
    /*********************************** Structs **********************************/

    /********************************** Constants *********************************/

    string public constant CONTRACT_NAME = "Example Factory";

    /************************************ Vars ************************************/

    address public implementationAddress;

    /*********************************** Events ***********************************/

    event ExampleCloneDeployed(
        address indexed contractAddress,
        bytes20 salt,
        bytes data
    );

    /*********************************** Errors ***********************************/

    /**
     * Insufficient permissions for caller.
     *
     * @param _address the address that has insufficient permissions
     * @param requiredRole the required role to execute the function
     */
    error InsufficientPermissions(address _address, bytes32 requiredRole);

    /********************************* Modifiers **********************************/

    /// reverts InsufficientPermissions error if caller does not have admin role
    modifier onlyAdmin() {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            revert InsufficientPermissions({
                _address: msg.sender,
                requiredRole: DEFAULT_ADMIN_ROLE
            });
        }
        _;
    }

    /******************************** Constructor *********************************/

    /**
     * Constructor for Example Factory contract to set the admins of the factory and
     * set the implementation address of the example contract
     *
     * @param _admins an array of admin addresses
     * @param _implementationAddress implementation address of the example contract
     */
    constructor(address[] memory _admins, address _implementationAddress) {
        for (uint256 i = 0; i < _admins.length; i++) {
            _setupRole(DEFAULT_ADMIN_ROLE, _admins[i]);
        }
        implementationAddress = _implementationAddress;
    }

    /********************************* Initialize *********************************/

    /******************************* Read Functions *******************************/

    /******************************* Write Functions ******************************/

    /***************************** Internal Functions *****************************/

    /**
     * Deploy upgradable proxy with the implementation 
     *
     * @param _salt the cryptographic salt for the contract
     * @param _data data to be passed into initialize call on the clone.
     */
    function deployDeterministicProxy(bytes20 _salt, bytes calldata _data)
        external
        returns (address clone)
    {
        bytes20 salt = newSalt(_salt, _data);

        address payable proxy = payable(
            new ERC1967Proxy{salt: salt}(implementationAddress, _data)
        );

        IExampleClone(proxy).initialize(_data);

        emit ExampleCloneDeployed(proxy, _salt, _data);

        return proxy;
    }

    /**
     *
     *
     * @param _salt the cryptographic salt for the contract
     * @param _data data to be passed into initialize call on the clone.
     */
    function deployDeterministicClone(bytes20 _salt, bytes calldata _data)
        external
        returns (address clone)
    {
        bytes20 salt = newSalt(_salt, _data);

        clone = Clones.cloneDeterministic(implementationAddress, salt);

        IExampleClone(clone).initialize(_data);

        emit ExampleCloneDeployed(clone, _salt, _data);
    }

    function newSalt(bytes20 _salt, bytes calldata _data)
        internal
        pure
        returns (bytes20)
    {
        return bytes20(keccak256(abi.encodePacked(_data, _salt)));
    }
}

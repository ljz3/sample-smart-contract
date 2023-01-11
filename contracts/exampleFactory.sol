// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IExampleClone.sol";

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

/*
 * @title Example Contract
 * @notice This is an example contract factory demonstrating production level code
 *         quality while performing very basic functionality.
 * @author Kevin (Jiazheng) Li
 */

contract ExampleFactory is AccessControl {
    /********************************** Constants *********************************/

    /**
     * @notice Name of the contract: Example Factory
     *
     * @dev Function CONTRACT_NAME() public view returns (string)
     * @dev Field is declared public: getter CONTRACT_NAME() is created when compiled,
     *      it returns the name of the contract.
     */
    string public constant CONTRACT_NAME = "Example Factory";

    /************************************ Vars ************************************/

    /**
     * @notice The base implementation for the clones and proxies that are deployed
     *         from this contract
     */
    address public implementationAddress;

    /*********************************** Events ***********************************/

    /**
     * @dev Emmitted when a clone of the base implementation gets deployed
     *
     * @param contractAddress - The address of the deployed clone
     * @param salt - The salt that was inputted when deploying the contract
     * @param data - The bytedata that was inputted for the contract's initialize function
     */
    event ExampleCloneDeployed(
        address indexed contractAddress,
        bytes20 salt,
        bytes data
    );

    /**
     * @dev Emmitted when an upgradable proxy of the base implementation gets deployed
     *
     * @param contractAddress - The address of the deployed upgradable proxy
     * @param admin - The admin of the upgradable proxy
     * @param salt - The salt that was inputted when deploying the contract
     * @param data - The bytedata that was inputted for the contract's initialize function
     */
    event ExampleUpgradableProxyDeployed(
        address indexed contractAddress,
        address admin,
        bytes20 salt,
        bytes data
    );

    /*********************************** Errors ***********************************/

    /**
     * @dev Thrown when caller has insufficient permissions
     *
     * @param _address The address that has insufficient permissions
     * @param requiredRole The required role to execute the function
     */
    error InsufficientPermissions(address _address, bytes32 requiredRole);

    /********************************* Modifiers **********************************/

    /**
     * @dev Modifier that checks that an address has the admin role. Reverts
     * with an InsufficientPermissions error inluding the address and required role
     */
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
     * @dev Constructor for Example Factory contract to set the admins of the factory and
     * set the base implementation address
     *
     * @param _admins An array of admin addresses
     * @param _implementationAddress Implementation address of the base implementation
     */
    constructor(address[] memory _admins, address _implementationAddress) {
        for (uint256 i = 0; i < _admins.length; i++) {
            _setupRole(DEFAULT_ADMIN_ROLE, _admins[i]);
        }
        implementationAddress = _implementationAddress;
    }

    /******************************* Write Functions ******************************/

    /**
     * @notice Deploy an upgradable proxy with the implementation of the base implementation
     * 
     * @dev The base implementation is located at implementationAddress
     * @dev The admin of the upgradable proxy has permissions to change the implementation
     *      address of the proxy. If this feature is not required, it is strongly advised
     *      to use the deployDeterministicClone function instead.
     *
     * @param _salt The cryptographic salt for the contract
     * @param _admin The admin of upgradable proxy
     * @param _data Data to be passed into initialize call on the proxy
     */
    function deployDeterministicUpgradableProxy(
        bytes20 _salt,
        address _admin,
        bytes calldata _data
    ) external returns (address) {
        bytes20 salt = newProxySalt(_salt, _admin, _data);

        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy{
            salt: salt
        }(implementationAddress, _admin, "");

        IExampleClone(address(proxy)).initialize(_data);

        emit ExampleUpgradableProxyDeployed(address(proxy), _admin, _salt, _data);

        return address(proxy);
    }

    /**
     * @notice Deploy a clone with the implementation of the base implementation
     * 
     * @dev The base implementation is located at implementationAddress
     *
     * @param _salt The cryptographic salt for the contract
     * @param _data Data to be passed into initialize call on the clone.
     */
    function deployDeterministicClone(bytes20 _salt, bytes calldata _data)
        external
        returns (address clone)
    {
        bytes20 salt = newCloneSalt(_salt, _data);

        clone = Clones.cloneDeterministic(implementationAddress, salt);

        IExampleClone(clone).initialize(_data);

        emit ExampleCloneDeployed(clone, _salt, _data);
    }

    /***************************** Internal Functions *****************************/

    /**
     * @notice Generates a new cryptographic salt for the upgradable proxy by hashing
     *         the inputted salt, the admin of the upgradable proxy, and the initializer
     *         data.
     *
     * @param _salt The inputted cryptographic salt for the contract
     * @param _admin The admin of upgradable proxy
     * @param _data Data to be passed into initialize call on the clone.
     */
    function newProxySalt(
        bytes20 _salt,
        address _admin,
        bytes calldata _data
    ) internal pure returns (bytes20) {
        return bytes20(keccak256(abi.encodePacked(_data, _admin, _salt)));
    }

    /**
     * @notice Generates a new cryptographic salt for the clone by hashing
     *         the inputted salt and the initializer data.
     *
     * @param _salt The inputted cryptographic salt for the contract
     * @param _data Data to be passed into initialize call on the clone.
     */
    function newCloneSalt(bytes20 _salt, bytes calldata _data)
        internal
        pure
        returns (bytes20)
    {
        return bytes20(keccak256(abi.encodePacked(_data, _salt)));
    }
}

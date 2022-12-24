// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ExampleContract is Initializable, AccessControl {
    /*********************************** Structs **********************************/
    
    /**
     * @notice ExampleStruct record stores example details of an address
     */
    struct ExampleStruct {
        uint256 exampleValueOne;
        uint256 exampleValueTwo;
    }

    /********************************** Constants *********************************/

    /**
     * @notice Name of the contract: Example Contract
     *
     * @dev function CONTRACT_NAME() public view returns (string)
     * @dev Field is declared public: getter CONTRACT_NAME() is created when compiled,
     *      it returns the name of the contract.
     */
    string public constant CONTRACT_NAME = "Example Contract";

    /************************************ Vars ************************************/

    /**
     * @notice a record of all ExampleStructs for addresses
     */
    mapping(address => ExampleStruct) public exampleStructMapping;

    /*********************************** Events ***********************************/

    /**
     * @dev Emmitted when the ExampleStruct of an address gets modified
     *
     * @param _address - The address whose example values were modified
     * @param exampleValueOne - The new example value one that was modified
     * @param exampleValueTwo - The new example value two that was modified
     */
    event ExampleEvent(
        address indexed _address,
        uint256 exampleValueOne,
        uint256 exampleValueTwo
    );

    /*********************************** Errors ***********************************/

    /**
     * @dev Thrown when caller has insufficient permissions
     *
     * @param _address the address that has insufficient permissions
     * @param requiredRole the required role to execute the function
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
     * @dev Constructor to disable initalizers, preventing any future reinitialization
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /********************************* Initialize *********************************/

    /**
     * The initializer function of this example contract
     *
     * @param data All of the data in bytes to be decoded to set contract admins and initial data
     */
    function initialize(bytes calldata data) public initializer {
        // Decoding the data into usable parameters
        address[] memory _admins = abi.decode(data, (address[]));
        for (uint256 i = 0; i < _admins.length; i++) {
            _grantRole(DEFAULT_ADMIN_ROLE, _admins[i]);
        }
    }

    /******************************* Read Functions *******************************/

    /**
     * Returns the ExampleStruct stored for the given address
     *
     * 
     */
    function getExampleValue(address _address)
        public
        view
        returns (ExampleStruct memory)
    {
        return exampleStructMapping[_address];
    }

    /******************************* Write Functions ******************************/

    /**
     * TODO: Description
     */
    function setExampleValue(address _address, ExampleStruct memory value)
        public
        onlyAdmin
    {
        _setExampleValue(_address, value);
    }

    /***************************** Internal Functions *****************************/

    /**
     * TODO: Description
     */
    function _setExampleValue(address _address, ExampleStruct memory value)
        internal
    {
        exampleStructMapping[_address] = value;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ExampleContract is Initializable, AccessControl {
    /*********************************** Structs **********************************/

    struct ExampleStruct {
        uint256 exampleValueOne;
        uint256 exampleValueTwo;
    }

    /********************************** Constants *********************************/

    string public constant CONTRACT_NAME = "Example Contract";

    /************************************ Vars ************************************/

    mapping(address => ExampleStruct) public exampleStructMapping;

    /*********************************** Events ***********************************/

    /**
     * TODO: Description
     *
     */
    event ExampleEvent(
        address indexed _address,
        uint256 exampleValueOne,
        uint256 exampleValueTwo
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

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /********************************* Initialize *********************************/

    /**
     * The initializer function of this example contract
     *
     * @param data all of the data to set the example contract admins and initial data
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
     * TODO: Description
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

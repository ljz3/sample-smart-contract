// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IExampleClone {
    /**
     * initializes the new proxy with the owner and inputted data.
     *
     * @param data data to be passed into initialize call on the clone.
     */
    function initialize(bytes calldata data) external;
}

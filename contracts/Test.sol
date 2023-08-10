// SPDX-License-Identifier: None
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Betting.sol";

/// @dev for testing the old Betting.sol
contract Test is Ownable, Betting{
    constructor() Ownable(){}
    
    function newBook() external{
        _newBook(owner(), 2, 500);
    }
}
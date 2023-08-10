// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
* @title Bet
* @author Carson Case (carsonpcase@gmail.com)
* @notice Bet is an ERC20 symboled w?iETH (i being the index in the Book)
* This means like it sounds, that this Bet Token acts as a wETH for the case in which the index is a winner
 */
contract Bet is ERC20{
    /// @dev expTime in the Bet means something different, it means that the bookie can remove all remaining funds and delete the contract.
    uint256 immutable public expTime; 
    address immutable public book;
    address immutable private bookie;

    bool isWinner;

    error InvalidDeleteAttempt();

    constructor(uint256 _index, address _bookie, uint256 _liquidity) payable ERC20("Beting Token", string(abi.encodePacked("w?",_index,"ETH"))){
        book = msg.sender;
        bookie = _bookie;
        expTime = block.timestamp + 30 days;
        _mint(_bookie, _liquidity);
    }

    /// @dev mint tokens, only callable by the book
    function mint(address _receiver, uint256 _amount) external payable{
        require(msg.sender == book, "only book can mint");
        _mint(_receiver, _amount);
    }

    /**
    * @dev exchange your token for eth. 
    * If someone force sends ETH to the contract, it could allow someone to burn and artificially tweak the odds.
    * To prevent this exchange is only possible if the contract is a winner, with or without fudns. 
     */ 
    function exchange(uint256 _amount) external{
        require(isWinner, "cannot exchange if the bet is not won");
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(_amount);
    }

    /// @dev receive funds. Error if not from book to prevent users sending funds in on accident
    /// note that even if ETH is force sent with self destruct, this code is not executed
    receive() external payable{
        require(msg.sender == book, "only book can send funds");
        isWinner = true;
    }

    /// @dev delete contract and send remaining ETH to bookie after 30 days
    function deleteContractAfterMonth() external{
        if(msg.sender != bookie || block.timestamp < expTime){
            revert InvalidDeleteAttempt();
        }
        selfdestruct(payable(bookie));
    }
}
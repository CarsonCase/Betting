// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Bet.sol";

/**
* @title Book
* @author Carson Case (carsonpcase@gmail.com)
* @notice Book Contract is responsible for managing bets on a particular topic.
* A book can have as many options as the bookie (owner) wants, and must at least have 2 including a mandatory expiration option for if an expiration time is met.
* Also a bookie gets a fee on the odds, knows as a reduction rate
*/
contract Book{
    uint256 constant private ONE_HUNDRED_PERCENT = 10000;
    uint256 constant private EXP_OPTION = 0;    // this must be 0 with current constructor
    uint256 immutable private reductionRate;
    uint256 immutable public expDate;
    uint256 public liquidity;
    address public bookie;
    mapping(uint256 => Bet) public betsByIndex;

    error ConstructionInputsError();
    error InvalidSettlement();

    constructor(uint256 _numberOfOptions, uint256 _expDate, uint256 _reductionRate, uint256[] memory _liquiditySplit) payable{
        
        bookie = msg.sender;
        expDate = _expDate;
        reductionRate = _reductionRate;

        // create the EXP_OPTION bet first then loop through creating the others
        uint256 sum = _liquiditySplit[EXP_OPTION];
        _createBet(EXP_OPTION, _liquiditySplit[EXP_OPTION]);
        unchecked {
            for(uint256 i = 1; i < _numberOfOptions; ++i){
                uint256 lqAmount = _liquiditySplit[i];
                sum += lqAmount;
                _createBet(i, lqAmount);
            }
        }

        // Revert if any of the following is true...
        // number of options is not equal to elements in liquidity split
        // expiration date is in the past
        // number of options is < min amount
        // msg.value == 0
        // reductionRate >= 100%
        // also if sum of _liquiditySplit is != msg.value
        if(_numberOfOptions != _liquiditySplit.length || _expDate < block.timestamp || _numberOfOptions < 2 || msg.value == 0 || reductionRate >= ONE_HUNDRED_PERCENT|| sum != msg.value ){
            revert ConstructionInputsError();
        }
        assert(liquidity == msg.value);
    }

    /**
    * @notice function to place bets as a user on a certain index. Your msg.value is ran through getOdds() to determine your payout (tokens minted)
    * @param index to bet on
    * @param minAmountOut is minimum payout accepted
     */
    function placeBet(uint256 index, uint256 minAmountOut) external payable{
        Bet b = betsByIndex[index];
        uint256 payout = getOdds(index, msg.value);
        require(payout >= minAmountOut, "Invalid Odds");
        assert(payout > msg.value);

        unchecked {
            liquidity += msg.value;
        }
        
        b.mint(msg.sender, payout);
    }

    /**
    * @notice function for winner to be called
    * if past expiration date, anyone can call this, but the winner value will be set to EXP_OPTION no matter the entry
    * otherwise, only the bookie may call with a legitimate winner
     */
    function settleBet(uint256 winner) external{
        if(block.timestamp < expDate && msg.sender != bookie){
            revert InvalidSettlement();
        }

        winner = block.timestamp < expDate ? winner : EXP_OPTION;
        (bool success, ) = payable(address(betsByIndex[winner])).call{value:liquidity}("");
        assert(success);
    }

    /**
    @dev Equation for the odds. looks like this:
    P = oneHundred percent
    R = reduction rate
    t = total in book
    A = amount being bet
    a = total already bet on option

    A(P - R) ((t + A) / (a + A))
    _________________________
                P

    */
    //1.88137254902
    function getOdds(uint256 index, uint256 amount) public view returns(uint256){
        uint256 existingBetsForIndex = betsByIndex[index].totalSupply();
        return(
            (
                (amount * (ONE_HUNDRED_PERCENT - reductionRate) *  (liquidity + amount)) 
                / (amount + existingBetsForIndex)
            )
            / ONE_HUNDRED_PERCENT
        );
    }

    /**
    * @dev helper function to create a new Bet contract
     */
    function _createBet(uint256 _index, uint256 _value) internal{
        unchecked {
            liquidity += _value;
        }
        betsByIndex[_index] = new Bet(_index, bookie, _value);
    }
}
pragma solidity ^0.4.2;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract NextLevelCrowdsale {
    using SafeMath for uint256;
    
    address public beneficiary;
    uint public fundingGoal = 1200 ether;
    uint public amountRaised;
    uint public deadline = 1504180740;
    uint public price;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;
    
    //Mapping
    mapping(address => uint256) public balanceOf;
    
    //Events
    event GoalReached(address beneficiary, uint amountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);
    
    function NextLevelCrowdsale(
        uint fundingGoalInEthers,
        uint crowdsaleDeadline,
        uint minimumAmount) {
            fundingGoalInEthers = fundingGoal;
            minimumAmount = 1 ether;
            crowdsaleDeadline = deadline;
        }
    
    function () payable {
        if (crowdsaleClosed) revert();
        uint amount = msg.value;
        if (amount < 1 ether) revert();
        balanceOf[msg.sender].add(amount);
        amountRaised.add(amount);
        FundTransfer(msg.sender, amount, true);
    }    
    
    modifier afterDeadline() { if (now >= deadline) _; }
    
    //Checks if the goal or time has been reached and ends the campaign
    function checkGoalReached() afterDeadline {
        if (amountRaised >= fundingGoal) {
            fundingGoalReached = true;
            GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
    }
    
     function safeWithdrawal() afterDeadline {
        if (!fundingGoalReached) {
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                if (msg.sender.send(amount)) {
                    FundTransfer(msg.sender, amount, false);
                } else {
                    balanceOf[msg.sender] = amount;
                }
            }
        }

        if (fundingGoalReached && beneficiary == msg.sender) {
            if (beneficiary.send(amountRaised)) {
                FundTransfer(beneficiary, amountRaised, false);
            } else {
                //If we fail to send the funds to beneficiary, unlock funders balance
                fundingGoalReached = false;
            }
        }
    }
    
}

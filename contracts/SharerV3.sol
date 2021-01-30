pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

interface IStrategy{
    function vault() external view returns (address);

}

//for version 0.3.1 or above of base strategy

contract SharerV3 {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    event ContributorsSet(address indexed strategy, address[] contributors, uint256[] numOfShares);
    event Distribute(address indexed strategy, uint256 totalDistributed);

    struct Contributor {
        address contributor;
        uint256 numOfShares;
    }
    mapping(address => Contributor[]) public shares;
    address public strategistMs;
    address public pendingStrategistMs;


    constructor() public {
        strategistMs = msg.sender;
    }

    function changeStratMs(address _ms) external {
        require(msg.sender == strategistMs);
        pendingStrategistMs = _ms;
    }

    function acceptStratMs() external {
        require(msg.sender == pendingStrategistMs);
        strategistMs = pendingStrategistMs;
    }

    function viewContributors(address strategy) public view returns (Contributor[] memory){
       return shares[strategy];
    }

    // Contributors for a strategy are set all at once, not on individual basis.
    // Initialization of contributors list for any strategy can be done by anyone. Afterwards, only Strategist MS can call this
    // If sum of total shares set < 1,000, any remainder of shares will go to strategist multisig
    function setContributors(address strategy, address[] calldata _contributors, uint256[] calldata _numOfShares) public {
        require(_contributors.length == _numOfShares.length, "length not the same");

        require(shares[strategy].length == 0 || msg.sender == strategistMs, "Only Strat MS can overwrite");

        delete shares[strategy];
        uint256 totalShares = 0;

        for(uint256 i = 0; i < _contributors.length; i++ ){
            totalShares = totalShares.add(_numOfShares[i]);
            shares[strategy].push(Contributor(_contributors[i], _numOfShares[i]));
        }
        require(totalShares <= 1000, "share total more than 100%");
        emit ContributorsSet(strategy, _contributors, _numOfShares);
    }


    function distribute(address _strategy) public{
        IStrategy strategy = IStrategy(_strategy);
        IERC20 reward =  IERC20(strategy.vault());
        Contributor[] memory contributorsT = shares[_strategy];

        uint256 totalRewards = reward.balanceOf(_strategy);
        uint256 remainingRewards = totalRewards;
        if(totalRewards <= 1000){
           return; 
        }
            
        for(uint256 i = 0; i < contributorsT.length; i++ ){
                address cont = contributorsT[i].contributor;
                uint256 share = totalRewards.mul(contributorsT[i].numOfShares).div(1000);
                reward.safeTransferFrom(_strategy, cont, share);
                remainingRewards -= share;
        }
        reward.safeTransferFrom(_strategy, strategistMs, remainingRewards);
        emit Distribute(_strategy, totalRewards);
    }
}

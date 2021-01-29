pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

contract SharerV2 {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    
    event contributorAdded(address _con, uint256 _shares, uint256 _total);
    event contributorDeleted(address _con, uint256 _total);
    struct Contributor {
        uint256 numOfShares;
        address owner;
    }
    mapping(address => Contributor[]) public shares;
    address public strategist_ms;


    constructor() public {
        strategist_ms = msg.sender;
    }

    function changeStratMs(address _ms) external {
        require(msg.sender == strategist_ms);
        strategist_ms = _ms;
    }

    function viewContributors(address strategy) public view returns (Contributor[] memory){
       return shares[strategy];
    }


    function setContributors(address strategy, uint256[] calldata  contributorsS, address[] calldata contributorA) public {
        require(contributorA.length == contributorsS.length, "length not the same");

        require(shares[strategy].length == 0 || msg.sender == strategist_ms, "Only Strat MS can overwrite");

        delete shares[strategy];
        uint256 totalShares = 0;

        for(uint256 i = 0; i < contributorsS.length; i++ ){
            totalShares = totalShares.add(contributorsS[i]);
            
            shares[strategy].push(Contributor(contributorsS[i], contributorA[i]));
        }
        require(totalShares <= 1000, "share total more than 100%");

    }


    function distribute(address lpToken, address strategy) public{
        IERC20 reward = IERC20(lpToken);
        Contributor[] memory contributorsT = shares[strategy];

        uint256 totalRewards = reward.balanceOf(address(this));
        uint256 remainingRewards = totalRewards;
        if(totalRewards <= 1000){
           return; 
        }
            
        for(uint256 i = 0; i < contributorsT.length; i++ ){
                address cont = contributorsT[i].owner;
                uint256 share = totalRewards.mul(contributorsT[i].numOfShares).div(1000);
                reward.safeTransfer(cont, share);
                remainingRewards -= share;
        }
        reward.safeTransfer(strategist_ms, remainingRewards);
        
    }
}

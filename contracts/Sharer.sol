pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

contract Sharer {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    
    event contributorAdded(address _con, uint256 _shares, uint256 _total);
    event contributorDeleted(address _con, uint256 _total);
    struct Contributor {
        uint256 numOfShares;
        bool exists;
    }
    mapping(address => Contributor) public shares;
    address public owner;
    uint256 public totalShare;
    address[] public contributors;


    constructor() public {
        owner = msg.sender;
        totalShare = 0;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    //Change shares of a contributor or sets
    function addContributor(address _con, uint256 _share) public onlyOwner {
        uint256 oldShares = 0;
        if (shares[_con].exists) {
            oldShares  = shares[_con].numOfShares;
            //set new number of shares for existing contributor
            shares[_con].numOfShares = _share;
        } else {
        //add new contributor
        shares[_con] = Contributor(_share, true);
        contributors.push(_con);
        }
        //update totalShare
        totalShare = totalShare - oldShares + _share;
        //revert if we pushed the total over 1000...
        require (totalShare < 1000, "share total more than 100%");
        emit contributorAdded(_con, _share, totalShare);
    }

    function removeContributor(address _con) public onlyOwner {
        uint256 oldShares = 0;
        if (shares[_con].exists) {
            oldShares  = shares[_con].numOfShares;
            //Remove the address from the array
            for(uint256 i = 0; i < contributors.length; i++ ){
                if(contributors[i] == _con){
                    //put the last index here
                    //remove last index
                    if (i != contributors.length-1) {
                        contributors[i] = contributors[contributors.length - 1];
                    }
                    //pop shortens array by 1 thereby deleting the last index
                    contributors.pop();
                }
            }
            totalShare = totalShare - oldShares;
            delete shares[_con];
            emit contributorDeleted(_con, totalShare);
        }
    }

    function distribute(address _rewards) public{
        require(totalShare > 0);
        IERC20 reward = IERC20(_rewards);

        uint256 totalRewards = reward.balanceOf(address(this));
        uint256 remainingRewards = totalRewards;

        if(totalRewards > totalShare){

            for(uint256 i = 0; i < contributors.length; i++ ){
                address cont = contributors[i];
                uint256 share = totalRewards.mul(shares[cont].numOfShares).div(1000);
                reward.safeTransfer(cont, share);

                remainingRewards -= share;
            }
            reward.safeTransfer(owner, remainingRewards);
        }
    }
}

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

contract Sharer {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    mapping(address => uint256) public shares;
    address private owner;
    address[] public contributors;


    constructor() public {
        owner = msg.sender;
    }

    //share out of 1000
    function addContributor(address con, uint256 share) public {
        require(msg.sender == owner);
        uint256 totalShare = share;

        for(uint256 i = 0; i < contributors.length; i++ ){
            totalShare += shares[contributors[i]];
        }

        require(totalShare < 1000, "share total more than 100%");

        contributors.push(con);
        shares[con] = share;

    }

    function removeContributor(address con) public {
        require(msg.sender == owner);

        for(uint256 i = 0; i < contributors.length; i++ ){

            if(contributors[i] == con){
                //put the last index here
                //remove last index
                if (i != contributors.length-1) {
                    contributors[i] = contributors[contributors.length - 1];
                }

                //pop shortens array by 1 thereby deleting the last index
                contributors.pop();
            }
           
        }
        shares[con] = 0;

    }

    function distribute(address rewards) public{

        IERC20 reward = IERC20(rewards);

        uint256 totalRewards = reward.balanceOf(address(this));
        uint256 remainingRewards = totalRewards;

        if(totalRewards > 1){

            for(uint256 i = 0; i < contributors.length; i++ ){
                address cont = contributors[i];
                uint256 share = totalRewards.mul(shares[cont]).div(1000);
                reward.safeTransfer(cont, share);

                remainingRewards -= share;
            }

            reward.safeTransfer(owner, remainingRewards);
        }
    }
}
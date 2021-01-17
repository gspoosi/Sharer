pragma solidity >=0.5.0;

interface BasisPool {
    

    function withdraw(uint256 redeemTokens) external;
    function stake(uint256 redeemTokens) external;
    function getReward() external;
    function exit() external;
    function earned(address account) external view returns (uint256);
}

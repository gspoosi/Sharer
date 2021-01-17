pragma solidity >=0.5.0;

interface hegicSwap {
    
    function swap(uint256 amount) external;
    function availableAmount() external view returns (uint256);
}

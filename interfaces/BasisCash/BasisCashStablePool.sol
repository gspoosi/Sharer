pragma solidity >=0.5.0;

interface BasisCashStablePool {
    

    function withdraw(uint256 pid, uint256 redeemTokens) external;
    function deposit(uint256 pid, uint256 amount) external;
}

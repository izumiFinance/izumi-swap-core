pragma solidity >=0.7.3;

struct State {
        uint160 sqrtPrice_96;
        int24 currPt;
        uint256 currX;
        uint256 currY;
        // liquidity from currPt to right
        uint128 liquidity;
        bool allX;
        bool locked;
}
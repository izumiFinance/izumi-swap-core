pragma solidity ^0.8.4;

import '../interfaces/IIzumiswapPool.sol';
import '../interfaces/IIzumiswapCallback.sol';
import '../interfaces/IIzumiswapFactory.sol';

import "hardhat/console.sol";
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract TestSwap is IIzumiswapSwapCallback {
    struct SwapCallbackData {
        address token;
        address payer;
    }
    address public factory;
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        console.log("transfer value: %s", value);
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }
    function swapY2XCallback(
        uint256 y,
        bytes calldata data
    ) external override {
        SwapCallbackData memory dt = abi.decode(data, (SwapCallbackData));
        if (y > 0) {
            safeTransferFrom(dt.token, dt.payer, msg.sender, y);
        }
    }
    function swapX2YCallback(
        uint256 x,
        bytes calldata data
    ) external override {
        SwapCallbackData memory dt = abi.decode(data, (SwapCallbackData));
        if (x > 0) {
            safeTransferFrom(dt.token, dt.payer, msg.sender, x);
        }
    }
    constructor(address fac) { factory = fac; }
    function pool(address tokenX, address tokenY, uint24 fee) public view returns(address) {
        return IIzumiswapFactory(factory).pool(tokenX, tokenY, fee);
    }
    function swapY2X(
        address tokenX,
        address tokenY,
        uint24 fee,
        uint128 amount,
        int24 highPt
    ) external {
        address poolAddr = pool(tokenX, tokenY, fee);
        address payer = msg.sender;
        IIzumiswapPool(poolAddr).swapY2X(
            payer, amount, highPt,
            abi.encode(SwapCallbackData({token:tokenY, payer: payer}))
        );
    }
    function swapY2XDesireX(
        address tokenX,
        address tokenY,
        uint24 fee,
        uint128 desireX,
        int24 highPt
    ) external {
        address poolAddr = pool(tokenX, tokenY, fee);
        address payer = msg.sender;
        IIzumiswapPool(poolAddr).swapY2XDesireX(
            payer, desireX, highPt,
            abi.encode(SwapCallbackData({token:tokenY, payer: payer}))
        );
    }
    function swapX2Y(
        address tokenX,
        address tokenY,
        uint24 fee,
        uint128 amount,
        int24 lowPt
    ) external {
        address poolAddr = pool(tokenX, tokenY, fee);
        address payer = msg.sender;
        IIzumiswapPool(poolAddr).swapX2Y(
            payer, amount, lowPt,
            abi.encode(SwapCallbackData({token: tokenX, payer: payer}))
        );
    }
    function swapX2YDesireY(
        address tokenX,
        address tokenY,
        uint24 fee,
        uint128 desireY,
        int24 highPt
    ) external {
        address poolAddr = pool(tokenX, tokenY, fee);
        address payer = msg.sender;
        IIzumiswapPool(poolAddr).swapX2YDesireY(
            payer, desireY, highPt,
            abi.encode(SwapCallbackData({token:tokenX, payer: payer}))
        );
    }
}
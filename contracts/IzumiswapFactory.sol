// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

import './interfaces/IIzumiswapFactory.sol';
import './IzumiswapPool.sol';

contract IzumiswapFactory is IIzumiswapFactory {
    address public override owner;
    mapping(address => mapping(address => mapping(uint24 => address))) public override pool;
    mapping(uint24 => int24) public override fee2pointDelta;
    address public only_addr_;

    address public override swapX2Y;
    address public override swapY2X;
    constructor(address _swapX2Y, address _swapY2X) {
        only_addr_ = address(this);
        owner = msg.sender;
        fee2pointDelta[500] = 10;
        fee2pointDelta[3000] = 50;
        swapX2Y = _swapX2Y;
        swapY2X = _swapY2X;
    }
    modifier noDelegateCall() {
        require(address(this) == only_addr_);
        _;
    }
    function enableFeeAmount(uint24 fee, uint24 pointDelta) external override noDelegateCall {
        require(msg.sender == owner, "ON");
        require(pointDelta > 1, "P1");
        require(fee2pointDelta[fee] == 0, "FD0");
        fee2pointDelta[fee] = int24(pointDelta);
    }
    function newPool(
        address tokenX,
        address tokenY,
        uint24 fee,
        int24 cp
    ) external override noDelegateCall returns (address addr) {
        require(tokenX != tokenY, "SmTK");
        if (tokenX > tokenY) {
            (tokenX, tokenY) = (tokenY, tokenX);
        }
        require(pool[tokenX][tokenY][fee] == address(0));
        int24 pointDelta = fee2pointDelta[fee];
        require(pointDelta > 0);
        // now creating
        bytes32 salt = keccak256(abi.encode(tokenX, tokenY, fee));
        
        addr = address(new IzumiswapPool{salt: salt}(
            address(this),
            tokenX,
            tokenY,
            fee,
            cp,
            pointDelta
        ));
        pool[tokenX][tokenY][fee] = addr;
        pool[tokenY][tokenX][fee] = addr;
        emit NewPool(tokenX, tokenY, fee, pointDelta, addr);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MockCurve {
    function getAmountInForExactOutput(uint256 amountOut, address input, address output, bool zeroForOne)
        external
        pure
        returns (uint256)
    {
        uint256 amountIn = amountOut;
        return amountIn;
    }

    function getAmountOutFromExactInput(uint256 amountIn, address input, address output, bool zeroForOne)
        external
        pure
        returns (uint256)
    {
        uint256 amountOut = amountIn;
        return amountOut;
    }
}

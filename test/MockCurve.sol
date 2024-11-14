// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Currency} from "v4-core/src/types/Currency.sol";

contract MockCurve {
    function getAmountInForExactOutput(uint256 amountOut, address, address, bool) external pure returns (uint256) {
        // in constant-sum curve, tokens trade exactly 1:1
        uint256 amountIn = amountOut;
        return amountIn;
    }

    function getAmountOutFromExactInput(uint256 amountIn, address, address, bool) external pure returns (uint256) {
        // in constant-sum curve, tokens trade exactly 1:1
        uint256 amountOut = amountIn;
        return amountOut;
    }
}

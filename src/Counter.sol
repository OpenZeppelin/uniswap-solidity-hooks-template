// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BaseHook} from "v4-periphery/src/utils/BaseHook.sol";

import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary, toBeforeSwapDelta} from "v4-core/src/types/BeforeSwapDelta.sol";
import {Currency, CurrencyLibrary} from "v4-core/src/types/Currency.sol";
import {SafeCast} from "v4-core/src/libraries/SafeCast.sol";

// Make sure to update the interface when Stylus Contract's Solidity ABI changes.
interface IUniswapCurve {
    function getAmountInForExactOutput(uint256 amountOut, address input, address output, bool zeroForOne)
        external
        returns (uint256);

    function getAmountOutFromExactInput(uint256 amountIn, address input, address output, bool zeroForOne)
        external
        returns (uint256);
}

contract Counter is BaseHook {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using SafeCast for uint256;

    // NOTE: ---------------------------------------------------------
    // state variables should typically be unique to a pool
    // a single hook contract should be able to service multiple pools
    // ---------------------------------------------------------------

    mapping(PoolId => uint256 count) public beforeSwapCount;
    mapping(PoolId => uint256 count) public afterSwapCount;

    mapping(PoolId => uint256 count) public beforeAddLiquidityCount;
    mapping(PoolId => uint256 count) public beforeRemoveLiquidityCount;

    IUniswapCurve _curveContract;

    constructor(IPoolManager _poolManager, address _curveContractAddress) BaseHook(_poolManager) {
        _curveContract = IUniswapCurve(_curveContractAddress);
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: true,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: true,
            afterRemoveLiquidity: false,
            beforeSwap: true, // -- Custom Curve Handler --  //
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false, // -- Enable Custom Curves here if needed --  //
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    // -----------------------------------------------
    // NOTE: see IHooks.sol for function documentation
    // -----------------------------------------------

    function _beforeSwap(address, PoolKey calldata key, IPoolManager.SwapParams calldata params, bytes calldata)
        internal
        override
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        // You can add, modify, or delete the logic here if needed.

        bool exactInput = params.amountSpecified < 0;
        (Currency specified, Currency unspecified) =
            (params.zeroForOne == exactInput) ? (key.currency0, key.currency1) : (key.currency1, key.currency0);

        uint256 specifiedAmount = exactInput ? uint256(-params.amountSpecified) : uint256(params.amountSpecified);
        uint256 unspecifiedAmount;

        BeforeSwapDelta returnDelta;

        if (exactInput) {
            unspecifiedAmount = _curveContract.getAmountOutFromExactInput(
                specifiedAmount, Currency.unwrap(specified), Currency.unwrap(unspecified), params.zeroForOne
            );

            returnDelta = toBeforeSwapDelta(specifiedAmount.toInt128(), -unspecifiedAmount.toInt128());
        } else {
            unspecifiedAmount = _curveContract.getAmountInForExactOutput(
                specifiedAmount, Currency.unwrap(unspecified), Currency.unwrap(specified), params.zeroForOne
            );

            returnDelta = toBeforeSwapDelta(-specifiedAmount.toInt128(), unspecifiedAmount.toInt128());
        }

        beforeSwapCount[key.toId()]++;
        return (BaseHook.beforeSwap.selector, returnDelta, 0);
    }

    function _afterSwap(address, PoolKey calldata key, IPoolManager.SwapParams calldata, BalanceDelta, bytes calldata)
        internal
        override
        returns (bytes4, int128)
    {
        afterSwapCount[key.toId()]++;
        return (BaseHook.afterSwap.selector, 0);
    }

    function _beforeAddLiquidity(
        address,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata,
        bytes calldata
    ) internal override returns (bytes4) {
        beforeAddLiquidityCount[key.toId()]++;
        return BaseHook.beforeAddLiquidity.selector;
    }

    function _beforeRemoveLiquidity(
        address,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata,
        bytes calldata
    ) internal override returns (bytes4) {
        beforeRemoveLiquidityCount[key.toId()]++;
        return BaseHook.beforeRemoveLiquidity.selector;
    }
}

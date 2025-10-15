// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @dev Minimal UniswapV2 router interface for Polygon-based DEXs (e.g., QuickSwap, SushiSwap)
 */
interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

contract TokenDEXManager {
    using SafeERC20 for IERC20;

    address public owner;
    address public router;

    event TokensSwapped(
        address indexed tokenIn,
        address indexed tokenOut,
        uint amountIn,
        uint amountOut
    );

    event LiquidityAdded(
        address indexed tokenA,
        address indexed tokenB,
        uint amountA,
        uint amountB,
        uint liquidity
    );

    constructor(address _router) {
        require(_router != address(0), "Invalid router");
        router = _router;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    /**
     * @notice Swaps one ERC20 token for another using the DEX router
     * @param tokenIn  Address of the input token
     * @param tokenOut Address of the output token
     * @param amountIn Amount of input tokens to swap
     * @param amountOutMin Minimum acceptable output (slippage control)
     */
    function swapTokens(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOutMin
    ) external {
        // Pull tokens from the user
        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(router, amountIn);

        // Define swap path
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        // Execute swap
        uint[] memory amounts = IUniswapV2Router(router).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender, // Send swapped tokens to user
            block.timestamp + 300
        );

        emit TokensSwapped(tokenIn, tokenOut, amounts[0], amounts[1]);
    }

    /**
     * @notice Adds liquidity to the DEX (creates or funds a liquidity pool)
     * @param tokenA First token in the pair (e.g., your token)
     * @param tokenB Second token (e.g., USDC)
     * @param amountA Amount of tokenA to add
     * @param amountB Amount of tokenB to add
     */
    function addLiquidityToDEX(
        address tokenA,
        address tokenB,
        uint amountA,
        uint amountB
    ) external {
        // Pull tokens from user
        IERC20(tokenA).safeTransferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).safeTransferFrom(msg.sender, address(this), amountB);

        // Approve router
        IERC20(tokenA).approve(router, amountA);
        IERC20(tokenB).approve(router, amountB);

        // Add liquidity
        (uint amountAddedA, uint amountAddedB, uint liquidity) = IUniswapV2Router(router).addLiquidity(
            tokenA,
            tokenB,
            amountA,
            amountB,
            0, // no min limits
            0,
            msg.sender, // LP tokens go to the liquidity provider
            block.timestamp + 300
        );

        emit LiquidityAdded(tokenA, tokenB, amountAddedA, amountAddedB, liquidity);
    }

    /**
     * @notice Allows the owner to withdraw accidentally stuck tokens
     */
    function rescueTokens(address token) external onlyOwner {
        uint balance = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(owner, balance);
    }
}

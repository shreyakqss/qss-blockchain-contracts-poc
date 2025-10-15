// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// interface IUniswapV2Router {
//     function swapExactTokensForTokens(
//         uint amountIn,
//         uint amountOutMin,
//         address[] calldata path,
//         address to,
//         uint deadline
//     ) external returns (uint[] memory amounts);
// }

// contract TokenSender {
//     using SafeERC20 for IERC20;

//     address public router;
//     address public owner;

//     constructor(address _router) {
//         router = _router;
//         owner = msg.sender;
//     }

//     function sendToDEX(
//         address tokenIn,
//         address tokenOut,
//         uint amountIn,
//         uint amountOutMin
//     ) external {
//         IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
//         IERC20(tokenIn).safeApprove(router, amountIn);

//         address ;
//         path[0] = tokenIn;
//         path[1] = tokenOut;

//         IUniswapV2Router(router).swapExactTokensForTokens(
//             amountIn,
//             amountOutMin,
//             path,
//             msg.sender,
//             block.timestamp + 300
//         );
//     }
// }

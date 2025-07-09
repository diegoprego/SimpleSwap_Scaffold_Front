// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title ISimpleSwap
 * @notice Interface defining core functions.
 */
interface ISimpleSwap {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getPrice(address tokenA, address tokenB) external view returns (uint256 price);

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256);
}

/**
 * @title SimpleSwap
 * @notice Swap contract for a token pair with LP token minting and burning.
 * @dev Based on Uniswap v2 principles. Issues LP tokens to liquidity providers.
 */
contract SimpleSwap is ERC20, ISimpleSwap {
   
    address public tokenA;
    address public tokenB;

    uint128 public reserveA;
    uint128 public reserveB;

    /**
     * @notice Deploys the SimpleSwap contract and initializes the LP token.
     */
    constructor() ERC20("SimpleSwap LP Token", "SSLP") {}

    /**
     * @notice Modifier to enforce correct or initial token pair.
     */
    modifier validPair(address _tokenA, address _tokenB) {
        require(
            (tokenA == address(0) && tokenB == address(0)) ||
            (tokenA == _tokenA && tokenB == _tokenB),
            "Token pair mismatch"
        );
        _;
    }

    /**
     * @dev Updates the internal reserve values from the current contract balances.
     */
    function _updateReserves() internal {
        reserveA = uint128(IERC20(tokenA).balanceOf(address(this)));
        reserveB = uint128(IERC20(tokenB).balanceOf(address(this)));
    }

    /**
     * @notice Adds liquidity to the pool and mints LP tokens to the user.
     */
    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external override validPair(_tokenA, _tokenB) returns (uint amountA, uint amountB, uint liquidity) {
        require(block.timestamp <= deadline, "Expired");

        if (tokenA == address(0) && tokenB == address(0)) {
            require(_tokenA != _tokenB, "Tokens must differ");
            tokenA = _tokenA;
            tokenB = _tokenB;
        }

        if (reserveA == 0 && reserveB == 0) {
            amountA = amountADesired;
            amountB = amountBDesired;
        } else {
            uint amountBOptimal = (amountADesired * reserveB) / reserveA;
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, "Slippage: B too low");
                amountA = amountADesired;
                amountB = amountBOptimal;
            } else {
                uint amountAOptimal = (amountBDesired * reserveA) / reserveB;
                require(amountAOptimal >= amountAMin, "Slippage: A too low");
                amountA = amountAOptimal;
                amountB = amountBDesired;
            }
        }

        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        if (totalSupply() == 0) {
            liquidity = _sqrt(amountA * amountB);
        } else {
            liquidity = _min(
                (amountA * totalSupply()) / reserveA,
                (amountB * totalSupply()) / reserveB
            );
        }

        require(liquidity > 0, "Insufficient liquidity minted");

        _mint(to, liquidity);
        _updateReserves();
    }

    /**
     * @notice Burns LP tokens and returns the user's share of underlying tokens.
     */
    function removeLiquidity(
        address _tokenA,
        address _tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external override validPair(_tokenA, _tokenB) returns (uint amountA, uint amountB) {
        require(block.timestamp <= deadline, "Expired");
        require(liquidity > 0 && liquidity <= balanceOf(msg.sender), "Invalid liquidity");

        uint _totalSupply = totalSupply();

        amountA = (liquidity * reserveA) / _totalSupply;
        amountB = (liquidity * reserveB) / _totalSupply;

        require(amountA >= amountAMin, "Slippage: A too low");
        require(amountB >= amountBMin, "Slippage: B too low");

        _burn(msg.sender, liquidity);

        IERC20(tokenA).transfer(to, amountA);
        IERC20(tokenB).transfer(to, amountB);

        _updateReserves();
    }

    /**
     * @notice Swaps a fixed amount of input token for the maximum possible output token.
     */
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external override {
        require(block.timestamp <= deadline, "Expired");
        require(amountIn > 0, "Zero input");
        require(path.length == 2, "Invalid path");

        address input = path[0];
        address output = path[1];
        require(
            (input == tokenA && output == tokenB) || (input == tokenB && output == tokenA),
            "Unsupported pair"
        );

        (uint128 reserveIn, uint128 reserveOut) = input == tokenA
            ? (reserveA, reserveB)
            : (reserveB, reserveA);

        uint amountOut = (amountIn * reserveOut) / (reserveIn + amountIn);
        require(amountOut >= amountOutMin, "Slippage");

        IERC20(input).transferFrom(msg.sender, address(this), amountIn);
        IERC20(output).transfer(to, amountOut);

        _updateReserves();
    }

    /**
     * @notice Returns the current spot price of tokenA in terms of tokenB.
     */
    function getPrice(address _tokenA, address _tokenB) external view override validPair(_tokenA, _tokenB) returns (uint price) {
        require(reserveA > 0 && reserveB > 0, "No liquidity");

        price = (uint(reserveB) * 1e18) / uint(reserveA);
    }

    /**
     * @notice Computes the amount of output tokens for a given input amount using constant product formula.
     */
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure override returns (uint amountOut) {
        require(amountIn > 0, "Zero input");
        require(reserveIn > 0 && reserveOut > 0, "Empty reserves");

        amountOut = (amountIn * reserveOut) / (reserveIn + amountIn);
    }

    /**
     * @dev Computes square root.
     * @param y Input number
     * @return z Square root of y
     */
    function _sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    /**
     * @dev Returns the minimum of two numbers.
     * @param x First number
     * @param y Second number
     * @return Minimum of x and y
     */
    function _min(uint x, uint y) internal pure returns (uint) {
        return x < y ? x : y;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface IERC20 {
    function decimals() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function mint(address to, uint256 value) external returns (bool success);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function burn(uint256 amount) external;
}

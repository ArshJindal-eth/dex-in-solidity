// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//using SafeMath for uint256;

contract Wallet is Ownable{

    struct Token{
        bytes32 ticker;
        address tokenAddress;
    }
    
    mapping( bytes32 => Token) public tokenMapping;
    bytes32[] public TokenList;

    mapping ( address => mapping (bytes32 => uint256 )) public balances;

    modifier tokenExists(bytes32 ticker){
        require(tokenMapping[ticker].tokenAddress != address(0));
        _;
    }

    function addToken(bytes32 ticker, address tokenAddress) onlyOwner external{
        tokenMapping[ticker] = Token(ticker,tokenAddress);
        TokenList.push(ticker);
    }
    function deposit( uint amount, bytes32 ticker) tokenExists(ticker) external {
        IERC20(tokenMapping[ticker].tokenAddress).transferFrom(msg.sender,address(this),amount);
        balances[msg.sender][ticker]=balances[msg.sender][ticker]+(amount);

    }
    function withdraw( uint amount, bytes32 ticker) tokenExists(ticker) external {
        require(balances[msg.sender][ticker]>= amount,"Balance not enough");
        balances[msg.sender][ticker]=balances[msg.sender][ticker]-(amount);
        IERC20(tokenMapping[ticker].tokenAddress).transfer(msg.sender,amount);
    }
}
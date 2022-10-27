// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "./wallet.sol";

contract Dex is Wallet{

    using SafeMath for uint256; 

    enum Side{
        BUY,
        SELL
    }

    struct Order{
        uint id;
        address trader;
        Side side;
        bytes32 ticker;
        uint amount;
        uint price;
        uint filled;
    }

    mapping( bytes32 => mapping(uint => Order[])) public orderBook;

    function getOrderBook(bytes32 ticker, Side side) view public returns(Order[] memory){
        return orderBook[ticker][uint(side)];
    } 

    function createLimitOrder(Side side, bytes32 ticker, uint amount, uint price) public {
        if(side == Side.BUY){
            require(balances[msg.sender]["ETH"]>= amount.mul(price));
        }
        else if(side == Side.SELL){
            require(balances[msg.sender][ticker] >= amount);
        }
        uint256 nextOrderId =0 ;
        Order[] storage orders = orderBook[ticker][uint(side)]; 
        orders.push(
            Order(nextOrderId, msg.sender , side, ticker, amount, price, 0 )
        );

        //Bubble sort
        uint i = orders.length > 0 ? orders.length - 1 :  0 ;
        if(side == Side.BUY){
            while(i<0){
                if(orders[i-1].price > orders[i].price){
                    break;
                }
                Order memory orderToMove = orders[i-1];
                orders[i-1]=orders[i];
                orders[i]= orderToMove;
                i--;
            }
        }
        else if(side == Side.SELL){
            while(i<0){
                if(orders[i-1].price < orders[i].price){
                    break;
                }
                Order memory orderToMove = orders[i-1];
                orders[i-1]=orders[i];
                orders[i]= orderToMove;
                i--;
            } 
        }
        nextOrderId++;
    }
    function createMarketOrder(Side side, bytes32 ticker, uint amount) public {
        
        if(side == Side.SELL){
            require(balances[msg.sender][ticker] >= amount);
        }
        uint orderBookSide;
        if(side == Side.BUY){
            orderBookSide = 1;
        }
        else{
            orderBookSide = 0;
        }
        Order[] storage orders = orderBook[ticker][orderBookSide];

        uint totalFilled = 0;

        for (uint256 i = 0; i < orders.length && totalFilled < amount ; i++) {
            //How much we can fill from orders[i]
            uint leftToFill = amount - totalFilled;
            uint availableToFill;
            availableToFill = orders[i].amount - orders[i].filled ;
            uint filled = 0;
            //Update totalFilled;
            if(availableToFill > leftToFill){
                filled = leftToFill;                     //fill the entire market order
                //availableToFill = leftToFill;
                //orders[i].filled = availableToFill;
            }
            else{
                filled = availableToFill;              // fill as much as is in order[i]
            }
            totalFilled = totalFilled.add(filled);
            orders[i].filled += filled;

            //Execute the trade & shift balances between buyer/seller
            if(side == Side.BUY){
                require(balances[msg.sender]["ETH"] >= filled.mul(orders[i].price));
                //orders[i].filled = availableToFill;
                balances[msg.sender][ticker] += filled;
                balances[msg.sender]["ETH"] -= filled.mul(orders[i].price);
                balances[orders[i].trader][ticker] -= filled;
                balances[orders[i].trader]["ETH"] += filled.mul(orders[i].price);

            }
            if(side == Side.SELL){
                
                //orders[i].filled = filled;
                balances[msg.sender][ticker] -= filled;
                balances[msg.sender]["ETH"] += filled.mul(orders[i].price);
                balances[orders[i].trader][ticker] += filled;
                balances[orders[i].trader]["ETH"] -= filled.mul(orders[i].price);

            }
            //Verify that the buyer has Enough ETH to cover the purchase (require) 
            // if(side == Side.BUY){
            //     require(balances[msg.sender]["ETH"] >= availableToFill.mul(orders[i].price));
            // }
        }

        //Loop through orderbook and remove 100% filled orders
        while(orders[0].filled == orders[0].amount && orders.length > 0){
            for (uint256 i = 0; i < orders.length-1; i++) {
                orders[i] = orders[i+1];
            }
            orders.pop();
        }
    }


}
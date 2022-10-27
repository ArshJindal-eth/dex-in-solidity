
// The user must have ETH deposited such that deposited eth >= buy order value
// The user must have enough tokens deposited such that token balance > sell order amount
// the BUY order book should be ordered on price from highest to lowest starting at index 0
const Dex = artifacts.require("Dex")
const Link = artifacts.require("Link")
const truffleAssert = require('truffle-assertions'); 

contract.skip("Dex", accounts => {
    // The user must have ETH deposited such that deposited eth >= buy order value
    it("should throw an error if ETH balance is too low when creating BUY limit order", async () => {
        let dex = await Dex.deployed();
        let link = await Link.deployed();
        await truffleAssert.reverts(
            dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 10, 1)
        )
        dex.depositEth({value : 10})
        await truffleAssert.passes(
            dex.createLimitOrder(0,web3.utils.fromUtf8("LINK"), 10, 1)
        )    
    })
    // The user must have enough tokens deposited such that token balance > sell order amount
    it("should throw an error if token balance is too low when creating SELL limit order", async () => {
        let dex = await Dex.deployed();
        let link = await Link.deployed();
        await truffleAssert.reverts(
            dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 10, 1)
        )
        await link.approve(dex.address, 500);
        await dex.addToken(web3.utils.fromUtf8("LINK"), link.address, {from: accounts[0]})
        await dex.deposit(10, web3.utils.fromUtf8("LINK"));
        await truffleAssert.passes(
            dex.creatLimitOrder(1, web3.utils.fromUtf8("LINK"), 10, 1)
        )
    
    })
    // the BUY order book should be ordered on price from highest to lowest starting at index 0
    it("The BUY order book should be ordered on price from highest to lowest starting at index 0", async() =>{
        let dex = await Dex.deployed();
        let link = await Link.deployed();
        await link.approve(dex.address, 500);
        await dex.depositEth({value: 3000});
        await dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 1, 300)
        await dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 1, 100)
        await dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 1, 200)
        

        let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 0);
        console.log(orderbook);
        assert(orderbook.length > 0);
        for (let i=0; i <orderbook.length -1; i++) {
            assert(orderbook[i].price >= orderbook[i+1].price, "not right order in buy book")
        }
    })
    // the SELL order book should be ordered on price from lowest to highest starting at index 0
    it("The SELL order book should be ordered on price from lowest to highest starting at index 0", async() =>{
        let dex = await Dex.deployed();
        let link = await Link.deployed();
        await link.approve(dex.address, 500);
        await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 1, 300)
        await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 1, 100)
        await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 1, 200)
        

        let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 0);
        assert(orderbook.length > 0);
        console.log(orderbook);
        for (let i=0; i <orderbook.length -1; i++) {
            assert(orderbook[i].price <= orderbook[i+1].price, "not right order in sell book")
        }
    })

    //when creating a SELL market order, the seller needs to have enough tokens for the trade 
    it("should throw an error if token balance is too low when creating SELL limit order", async () => {
        let dex = await Dex.deployed();
        let link = await Link.deployed();
        await truffleAssert.reverts(
            dex.createMarketOrder(1, web3.utils.fromUtf8("LINK"), 10, 1)
        )
        await link.approve(dex.address, 500);
        await dex.addToken(web3.utils.fromUtf8("LINK"), link.address, {from: accounts[0]})
        await dex.deposit(10, web3.utils.fromUtf8("LINK"));
        await truffleAssert.passes(
            dex.createMarketOrder(1, web3.utils.fromUtf8("LINK"), 10, 1)
        )
    
    })


    //when creating a BUY market order , the buyer needs to have enough ETH for the trade
    it("should throw an error if ETH balance is too low when creating BUY market order", async () => {
        let dex = await Dex.deployed();
        let link = await Link.deployed();
        await truffleAssert.reverts(
            dex.creatMarketOrder(0, web3.utils.fromUtf8("LINK"), 10, 1)
        )
        dex.depositEth({value : 10})
        await truffleAssert.passes(
            dex.createMarketOrder(0,web3.utils.fromUtf8("LINK"), 10, 1)
        )    
    })
    //Market orders can be submitted even if the order book is empty
    it("should be able to submit market orders even if order book is empty ", async () => {
        let dex = await Dex.deployed();
        let link = await Link.deployed();
        let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 0);
        assert(orderbook.length>=0,"must be able to submit market orders when the order book is empty");

    })
    
    //market orders should be filled until the order book is empty or the market order is 100% complete
    it("market orders should be filled until the order book is empty or the market order is 100% complete", async () => {
        let dex = await Dex.deployed();
        let link = await Link.deployed();
        let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 0);
        
    })
    //the eth balance of the buyer should decrease with the filled amount
    //the token balances of the limit order sellers should ddecrease with the filled amounts 
    //filled limit orders should be removed from the orderbook
    




})    
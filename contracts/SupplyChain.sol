// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {

  // <owner>
  address public owner = msg.sender;


  // <skuCount> Use each time you implement a new item for sale.
  uint public skuCount;

  // <items mapping>
  mapping (uint => Item) items;

  // <enum State: ForSale, Sold, Shipped, Received>
enum State 
{
  ForSale,
  Sold,
  Shipped,
  Received
}

//   //Declare variable of type enum (State) as the default
// State constant defaultState = State.ForSale;

  // <struct Item: name, sku, price, state, seller, and buyer>
struct Item {
  string name;
  uint sku;
  uint price;
  State state;
  address payable seller;
  address payable buyer;
  }


  /* 
   * Events
   */

  // <LogForSale event: sku arg>
  event LogForSale(uint sku);

  // <LogSold event: sku arg>
  event LogSold(uint sku);

  // <LogShipped event: sku arg>
  event LogShipped(uint sku);

  // <LogReceived event: sku arg>
  event LogReceived(uint sku);


  /* 
   * Modifiers
   */

  // Create a modifer, `isOwner` that checks if the msg.sender is the owner of the contract
modifier isOwner(address _address) { 
  require (msg.sender == owner); 
  _; 
}

  // <modifier: isOwner

  modifier verifyCaller (address _address) { 
    require (msg.sender == _address); 
    _;
  }

  modifier paidEnough(uint price) { 
    require(msg.value >= price); 
    _;
  }

  modifier checkValue(uint sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    _;
    uint price = items[sku].price;
    uint amountToRefund = msg.value - price;
    items[sku].buyer.transfer(amountToRefund);
  }

  // For each of the following modifiers, use what you learned about modifiers
  // to give them functionality. For example, the forSale modifier should
  // require that the item with the given sku has the state ForSale. Note that
  // the uninitialized Item.State is 0, which is also the index of the ForSale
  // value, so checking that Item.State == ForSale is not sufficient to check
  // that an Item is for sale. Hint: What item properties will be non-zero when
  // an Item has been added?

  // modifier forSale
  modifier forSale(uint sku){
    require (items[sku].state == State.ForSale);
    _;
  }
  modifier sold(uint sku) {
    require (items[sku].state == State.Sold);
    _;
  }

  modifier shipped(uint sku) {
     require (items[sku].state == State.Shipped);
    _;
  }
  modifier received(uint sku) {
     require (items[sku].state == State.Received);
    _;
  }

  constructor() public payable {
    // 1. Set the owner to the transaction sender
    owner = msg.sender;
    // 2. Initialize the sku count to 0. Question, is this necessary? Answer >> I don't believe so since don't we start counting from 0 like in an array?
    skuCount = 0;
  }

//Step 1 in supply chain:

  function addItem(string memory _name, uint _price) public returns (bool) {
    // 1. Create a new item and put in array
    items[skuCount] = Item({
     name: _name, 
     sku: skuCount, 
     price: _price, 
     state: State.ForSale, 
     seller: msg.sender, 
     buyer: address(0)
    });
    // 2. Increment the skuCount by one
    // 3. Emit the appropriate event
    emit LogForSale(skuCount);
    skuCount = skuCount + 1;
    // 4. return true
    return true;

    // hint:
    // items[skuCount] = Item({
    //  name: name, 
    //  sku: skuCount, 
    //  price: price, 
    //  state: State.ForSale, 
    //  seller: msg.sender, 
    //  buyer: address(0)
    //});
    //
    //skuCount = skuCount + 1;
    // emit LogForSale(skuCount);
    // return true;
    // What I initially thought of doing. Then saw the hint. 
    // address seller;
    // address buyer;
    // Item memory firstItem;
    // firstItem.name = name;
    // firstItem.sku = sku;
    // firstItem.price = price;
    // firstItem.state = defaultState;
  }

  // Implement this buyItem function. 
  // 1. it should be payable in order to receive refunds
  // 2. this should transfer money to the seller, 
  // 3. set the buyer as the person who called this transaction, 
  // 4. set the state to Sold. 
  // 5. this function should use 3 modifiers to check 
  //    - if the item is for sale, 
  //    - if the buyer paid enough, 
  //    - check the value after the function is called to make 
  //      sure the buyer is refunded any excess ether sent. 
  // 6. call the event associated with this function!
  function buyItem(uint sku) public payable 
  forSale(sku)
  paidEnough(items[sku].price)
  checkValue(sku)
  {
    items[sku].buyer = msg.sender;
    items[sku].seller.transfer(items[sku].price);
    items[sku].state = State.Sold;

    emit LogSold(sku);
  }

  // 1. Add modifiers to check:
  //    - the item is sold already 
  //    - the person calling this function is the seller. 
  // 2. Change the state of the item to shipped. 
  // 3. call the event associated with this function!
  function shipItem(uint sku) public 
  sold(sku)
  verifyCaller(items[sku].seller)
  {
    items[sku].state = State.Shipped;
    emit LogShipped(sku);

  }

  // 1. Add modifiers to check 
  //    - the item is shipped already 
  //    - the person calling this function is the buyer. 
  // 2. Change the state of the item to received. 
  // 3. Call the event associated with this function!
  function receiveItem(uint sku) public 
  shipped(sku)
  verifyCaller(items[sku].buyer)
  {
    items[sku].state = State.Received;

    emit LogReceived(sku);
  }

  // Uncomment the following code block. it is needed to run tests
  // function fetchItem(uint sku) public view returns (string memory name, uint sku, uint price, uint state, address seller, address buyer)
  // { 
  // name = items[sku].name; 
  // sku = items[sku].sku; 
  // price = items[sku].price; 
  // state = uint(items[sku].state); 
  // seller = items[sku].seller; 
  // buyer = items[sku].buyer; 
  // return (name, sku, price, state, seller, buyer); 
  // }
}

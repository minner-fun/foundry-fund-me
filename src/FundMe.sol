// allow users to send funds into the contract
// enable withdrawal of funds by the contract owner
// set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {PriceConverter} from "./PriceConverter.sol";
import {MathLibrary} from "./MathLibrary.sol";
using MathLibrary for uint256;
using PriceConverter for uint256;

contract FundMe {
    address immutable I_OWNER;
    uint256 public constant MINIMUM_USD = 10 * 10 ** 18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    mapping(address => uint256) public contributionCount;

    uint256[] public numbers;

    error NotOwner(string message);
    error failWithdraw(string message);

    constructor() {
        I_OWNER = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != I_OWNER) {
            revert NotOwner("only owner can de this");
        }
        // require(msg.sender == i_Owner, "only owner can de this");
        _;
    }

    // send funds into our contract
    // allow users to send $
    // have a minimum of $ send
    // uint256 public myValue = 1;
    function fund() public payable {
        // myValue = myValue + 3;
        require(msg.value.getConversionRate() >= MINIMUM_USD, "not enough eth");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
        contributionCount[msg.sender] += 1;
    }

    // requires the user to send less than 1 Gwei
    function tinyTip() public payable {
        require(msg.value < 1 gwei, "user should send less than 1 Gwei");
    }

    // owner can withdrawn funds
    function withdraw() public onlyOwner {
        uint256 index;
        for (index = 0; index < funders.length; index++) {
            address funder = funders[index];
            addressToAmountFunded[funder] = 0;
        }
        // funders = new address[](funders.length);

        for (index = 0; index < funders.length; index++) {
            funders[index] = address(0);
        }
        (bool success, ) = payable(I_OWNER).call{value: address(this).balance}(
            ""
        );
        if (!success) {
            revert failWithdraw("withdraw fail");
        }
    }

    function calculateSum(uint256 a, uint256 b) public pure returns (uint256) {
        return a.add(b);
    }

    function pushNumber() public {
        for (uint256 index = 0; index < 10; index++) {
            numbers.push(index);
        }
    }

    function callAmountTo(address _to) public {
        (bool success, ) = payable(_to).call{value: 100000}("");
        if (!success) {
            revert();
        }
    }

    function withdrawOnlyAccountRemix() public {
        require(
            msg.sender == 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
            "only first account can do this"
        );
        withdraw();
    }

    modifier onlyAfter(uint256 _time) {
        require(block.timestamp > _time, "The time not arrive");
        _;
    }

    function addOne(uint256 _what) public view onlyAfter(1768635464) {
        _what += 1;
    }
}

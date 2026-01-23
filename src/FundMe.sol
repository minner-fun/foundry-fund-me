// allow users to send funds into the contract
// enable withdrawal of funds by the contract owner
// set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";
import {MathLibrary} from "./MathLibrary.sol";
using MathLibrary for uint256;
using PriceConverter for uint256;

contract FundMe {
    address private immutable I_OWNER;
    uint256 public constant MINIMUM_USD = 10 * 10 ** 18;
    AggregatorV3Interface private s_priceFeed;
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    mapping(address => uint256) private s_contributionCount;

    uint256[] public numbers;

    error NotOwner(string message);
    error failWithdraw(string message);
    
    constructor(address priceFeed) {
        I_OWNER = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
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
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "not enough eth");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_contributionCount[msg.sender] += 1;
    }

    // requires the user to send less than 1 Gwei
    function tinyTip() public payable {
        require(msg.value < 1 gwei, "user should send less than 1 Gwei");
    }

    // owner can withdrawn funds
    function withdraw() public onlyOwner {
        uint256 index;
        for (index = 0; index < s_funders.length; index++) {
            address funder = s_funders[index];
            s_addressToAmountFunded[funder] = 0;
        }
        // funders = new address[](funders.length);

        for (index = 0; index < s_funders.length; index++) {
            s_funders[index] = address(0);
        }
        (bool success, ) = payable(I_OWNER).call{value: address(this).balance}(
            ""
        );
        if (!success) {
            revert failWithdraw("withdraw fail");
        }
    }

    function cheaperWithdraw() public onlyOwner{
        uint256 fundersLength = s_funders.length;
        uint256 index;
        for (index = 0; index < fundersLength; index++) {
            address funder = s_funders[index];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = payable(I_OWNER).call{value: address(this).balance}("");
        require(success, "Call Failed");
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

    function getVersion() public view returns(uint256) {
        // AggregatorV3Interface dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return s_priceFeed.version();
    }

    function getAddressToAmountFunded(address fundingAddress) public view returns(uint256){
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) public view returns(address){
        return s_funders[index];
    }

    function getOwner() public view returns(address){
        return I_OWNER;
    }
    function getPriceFeed() public view returns(AggregatorV3Interface){
        return s_priceFeed;
    }
}

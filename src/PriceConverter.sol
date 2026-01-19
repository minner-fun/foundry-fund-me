// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter{

    function getDataFeedEth() internal pure returns (AggregatorV3Interface){
        AggregatorV3Interface dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return dataFeed;
    }

    function getDataFeedBtc() internal pure returns (AggregatorV3Interface){
        AggregatorV3Interface dataFeedBtcWithEth = AggregatorV3Interface(0x5fb1616F78dA7aFC9FF79e0371741a747D2a7F22);
        return dataFeedBtcWithEth;
    }


    function getChainlinkDataFeedLatestAnswer() internal view returns (uint256) {

        AggregatorV3Interface dataFeed = getDataFeedEth();
        (
        /* uint80 roundId */
        ,
        int256 answer,
        /*uint256 startedAt*/
        ,
        /*uint256 updatedAt*/
        ,
        /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return uint256(answer) * 1e10;
    }

    function getLatestBtcPriceInEth() internal view returns (uint256){
        AggregatorV3Interface  dataFeedBtcWithEth = getDataFeedBtc();
        (, int256 price,,,) = dataFeedBtcWithEth.latestRoundData();
        return uint256(price);
    }

    function getChainlinkDataFeedLatestVersion() internal view returns (uint256 version){
        AggregatorV3Interface dataFeed = getDataFeedEth();
        version = dataFeed.version();
    }

    function getChainlinkDataFeedLatestdecimals() internal view returns (uint8){
        AggregatorV3Interface dataFeed = getDataFeedEth();
        return dataFeed.decimals();
    }

        // Function to get the price of Ethereum in USD
    function getPrice() internal pure returns(uint256) {
        // AggregatorV3Interface dataFeed = getDataFeedEth();

        // (,int price,,,) = dataFeed.latestRoundData();
        int256 price = 2000 * 1e18;

        // return uint256(price) * 1E10;
        return uint256(price);
    }

    // Function to convert a value based on the price
    function getConversionRate(uint256 ethAmount) internal pure returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function conversUstToEth(uint256 usdAmount) internal pure returns(uint256){
        uint256 ethPric = getPrice();
        uint256 ethAmount = usdAmount * 1e18 / ethPric;
        return ethAmount;
    }
}
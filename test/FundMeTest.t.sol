// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;

    uint256 constant GAS_PRICE;

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 10e18);
    }

    function testOwnerIsMsgSender() public view {
        address owner = fundMe.I_OWNER();
        console2.log("owner: ", owner);
        console2.log("address(this): ", address(this));
        console2.log("address(deploy): ", address(deployFundMe));
        console2.log("msg.sender", msg.sender);
        assertEq(fundMe.I_OWNER(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        console2.log("version: ", version);
        assertEq(version, 4);
    }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;

    uint256 constant SEND_VALUE = 10e17;
    uint256 constant STARTING_BALANCE = 1000 * 10 ** 18;
    uint256 constant GAS_PRICE = 1;
    address owner = msg.sender;
    address alice = makeAddr("alice");

    modifier funded(){
        vm.prank(alice);
        fundMe.fund{value:SEND_VALUE}();
        assert(address(fundMe).balance >= SEND_VALUE);
        _;
    }


    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(alice, STARTING_BALANCE);
        
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 10e18);
    }

    function testOwnerIsMsgSender() public view {
        // address owner = fundMe.getOwner();
        console2.log("owner: ", owner);
        console2.log("address(this): ", address(this));
        console2.log("address(deploy): ", address(deployFundMe));
        console2.log("msg.sender", msg.sender);
        assertEq(owner, fundMe.getOwner());
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        console2.log("version: ", version);
        assertEq(version, 4);
    }

    function testFundFailesWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundDataStructure() public funded {
        // vm.prank(alice);
        // fundMe.fund{value:SEND_VALUE}();
        // uint256 amountFunded  = fundMe.getAddressToAmountFunded(msg.sender);
        uint256 amountFunded  = fundMe.getAddressToAmountFunded(alice);

        assertEq(amountFunded, SEND_VALUE);
    }
    
    function testAddsFunderToArrayOfFunders() public funded{
        // vm.prank(alice);
        // fundMe.fund{value:SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, alice);
    }

    function testOnlyOwnerCanWithdraw() public funded{
        // vm.prank(alice);
        // fundMe.fund{value:SEND_VALUE}();
        // console2.log(msg.sender);
        // console2.log(fundMe.I_OWNER());
        // vm.prank(fundMe.I_OWNER());
        vm.prank(alice);
        vm.expectRevert();
        fundMe.withdraw();

        vm.prank(owner);
        fundMe.withdraw();

    }

    function testWithdrawFromASingleFunder() public funded{
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = owner.balance;

        vm.txGasPrice(GAS_PRICE);
        uint256 gasStart = gasleft();

        vm.startPrank(owner);
        fundMe.withdraw();
        vm.stopPrank();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console2.log("Withdraw consumed: %d gas", gasUsed);
        console2.log("tx.gasprice", tx.gasprice);

        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = owner.balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded{
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++){
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value:SEND_VALUE}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = owner.balance;
        vm.startPrank(owner);
        fundMe.withdraw();
        vm.stopPrank();

        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = owner.balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);


        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
        assert((numberOfFunders + 1) * SEND_VALUE == fundMe.getOwner().balance - startingOwnerBalance);
        console2.log(fundMe.getOwner().balance - startingOwnerBalance);
    }

    function testPrintStorageData() public{
        for (uint256 i = 0; i<3; i++){
            bytes32 value = vm.load(address(fundMe), bytes32(i));
            console2.log("Value at location", i, ":");
            console2.logBytes32(value);
        }
        console2.log("PriceFeed address:", address(fundMe.getPriceFeed()));
    }

}

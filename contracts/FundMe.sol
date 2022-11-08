// SPDX-License-Identifier: MIT

// Pragma
pragma solidity ^0.8.8;

// mports
import "./PriceConverter.sol";

// without constant - current gas = 918755
// added constant keyword - new gas = 898773

// Error Codes
error FundMe__NotOwner();

/**
 * @title A contract for crowd funding
 * @author Unknown
 * @notice This contract is to demo a sample funding contract
 * @dev This implements Chainlink price feeds as our library
 */

contract FundMe {
    // Type declarations
    using PriceConverter for uint256;

    // State variables
    uint256 public constant MINIMUM_USD = 5 * 1e18; // can use constant since will never change
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    address private immutable i_owner;

    //875314 with immutable owner
    //898761 without immutable owner

    AggregatorV3Interface private s_priceFeed;

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not owner!");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _; // represents the code of the function
    }

    constructor(address s_priceFeedAddress) {
        i_owner = msg.sender; // msg.sender will be whoever deployed the contract.
        s_priceFeed = AggregatorV3Interface(s_priceFeedAddress);
    }

    // What happens when someone sends our contract ETH without using the fund function?

    // Special functions
    receive() external payable {
        // runs when ETH sent without call data no msg.data
        fund();
    }

    fallback() external payable {
        // runs when ETH sent with call data msg.data
        fund();
    }

    function fund() public payable {
        /**
         * @title A contract for crowd funding
         * @author Unknown
         * @notice This contract is to demo a sample funding contract
         * @dev This implements Chainlink price feeds as our library
         */
        // Want to be able to set a minimum amount in USD
        // 1. How do we send Eth to this contract
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't send enough ETH!"
        );
        s_funders.push(msg.sender);
        // s_addressToAmountFunded[msg.sender] = msg.value; <-- This previously which is an error since it means that the same funder sending funds twice will overwrite rather than add in the mapping.
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        // starting index, stop condition, step amount
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset the s_funders array, with zero elements inside
        s_funders = new address[](0);

        // actually withdraw the funds

        // TRANSFER
        // msg.sender is type 'address'
        // payable(msg.sender) is type 'payable address' --> only payable addresses can do transfers
        // payable(msg.sender).transfer(address(this).balance);
        // SEND
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed!")
        // CALL --> recommended way to transfer amounts
        (
            bool callSuccess, /*bytes memory dataReturned* --> can leave the trailing comma as var not needed*/

        ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "call failed");
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders; // save the storage var into a memory var to optimise gas use
        // mappings can't be in memory, sorry!
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success, "call failed");
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}

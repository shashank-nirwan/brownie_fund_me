// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    mapping(address => uint256) public addressToAmountFunded;
    uint256 public usdValue;
    address public owner;
    address[] public funders;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() public payable {
        uint256 minimumUSD = 5;
        usdValue = ConvertWeiInUsd(msg.value);
        require(usdValue >= minimumUSD, "You need to spend more ETH");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    // ETH to USD conversion rate
    function ConvertWeiInUsd(uint256 _gwei) public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return
            (_gwei * uint256(answer)) /
            (10**uint256(priceFeed.decimals())) /
            (10**18);
    }

    // USD to ETH conversion rate
    function ConvertUsdInWei(uint256 _usd) public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return ((_usd * (10**uint256(priceFeed.decimals())) * (10**18)) /
            uint256(answer));
    }

    // Entrance fee in Wei
    function getEntranceFee() public view returns (uint256) {
        uint256 minimumUSD = 50;
        return ConvertUsdInWei(minimumUSD);
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "You are not allowed to carry this transaction"
        );
        _;
    }

    function Withdraw() public payable onlyOwner {
        msg.sender.transfer(addressToAmountFunded[msg.sender]);
        for (uint256 x = 0; x < funders.length; x++) {
            addressToAmountFunded[funders[x]] = 0;
        }
        funders = new address[](0);
    }
}

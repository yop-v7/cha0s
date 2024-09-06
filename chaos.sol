// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract cha0s {

    struct Candle {
        uint256 open;
        uint256 high;
        uint256 low;
        uint256 close;
        uint256 timestamp;
    }

    mapping(string => Candle) public candles;
    
    // Mapping of asset names to Chainlink price feed addresses
    mapping(string => address) public priceFeeds;
    
    // Event to trigger recalculation
    event CandleUpdated(string asset, uint256 timestamp, uint256 closePrice);

    // Function to set the Chainlink price feed for an asset
    function setPriceFeed(string memory asset, address priceFeed) public {
        priceFeeds[asset] = priceFeed;
    }

    // Function to update the candle data for a given asset
    function updateCandle(string memory asset) public {
        address priceFeed = priceFeeds[asset];
        require(priceFeed != address(0), "Price feed not set");

        (,int256 latestPrice,,uint256 timestamp,) = AggregatorV3Interface(priceFeed).latestRoundData();
        uint256 closePrice = uint256(latestPrice);

        // Update candle data (simplified, assuming close = latest price)
        Candle storage candle = candles[asset];
        candle.close = closePrice;
        candle.timestamp = timestamp;

        // Emit event to trigger recalculation in external systems
        emit CandleUpdated(asset, timestamp, closePrice);
    }

    // Function to calculate entry & exit points using Black-Scholes
    function getEntryExitPoints(
        string memory asset,
        uint256 strikePrice,
        uint256 timeToMaturity, // in seconds
        uint256 riskFreeRate, // in basis points
        uint256 volatility // in basis points
    ) public view returns (bool shouldEnter, bool shouldExit) {
        Candle memory candle = candles[asset];
        
        (int256 d1, int256 d2) = calculateD1D2(
            candle.close,
            strikePrice,
            timeToMaturity,
            riskFreeRate,
            volatility
        );

        shouldEnter = (d1 > 0); // Placeholder logic for entry
        shouldExit = (d2 < 0);  // Placeholder logic for exit
    }

    function calculateD1D2(
        uint256 S0, // Current Price of token/coin
        uint256 X,  // Strike Price
        uint256 T,  // Time to Maturity (in seconds)
        uint256 r,  // Risk-free interest rate (annualized, in basis points)
        uint256 sigma // Volatility (annualized, in basis points)
    ) public pure returns (int256 d1, int256 d2) {
        int256 S0i = int256(S0);
        int256 Xi = int256(X);
        int256 Ti = int256(T);
        int256 ri = int256(r);
        int256 sigmai = int256(sigma); 

        int256 logTerm = ln(S0i * 1e18 / Xi);
        d1 = (logTerm + (ri + (sigmai + sigmai) / 2) * Ti) / (sigmai * sqrt(Ti));
        d2 = d1 - sigmai * sqrt(Ti);
    }
// Copied from GPT
    function ln(int256 x) internal pure returns (int256) {
        return x;
    }
// Also copied from GPT
    function sqrt(int256 x) internal pure returns (int256) {
        return x;
    }
}

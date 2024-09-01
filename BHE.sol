BHE.Sol
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BHEToken is ERC20, Ownable, ReentrancyGuard {
    0xf750D4d2E5443b2376678b19c0ac51b610CeCB6E public bridgeAddress;
    mapping(address => uint256) public lockedBHE;
    mapping(address => uint256) public lockedWBTC;

    event Locked(address indexed user, uint256 amount);
    event Released(address indexed user, uint256 amount);

    constructor(0xf750D4d2E5443b2376678b19c0ac51b610CeCB6E) ERC20("BHEToken", "BHE") {
        // Initialize any additional state variables here
    }

    function setBridgeAddress(address _bridgeAddress) external onlyOwner {
        bridgeAddress = _bridgeAddress;
    }

    /// @notice Lock BHE tokens to bridge to Ethereum chain
    function lockBHE(uint256 amount) external nonReentrant {
        require(amount > 0, "No BHE tokens sent");
        require(IERC20(0xf750D4d2E5443b2376678b19c0ac51b610CeCB6E).transferFrom(msg.sender, address(this), amount), "Token transfer failed");
        lockedBHE[msg.sender] += amount;
        emit Locked(msg.sender, amount);
    }

    /// @notice Release locked WBTC in case of emergency
    function releaseWBTC(address user, uint256 amount) external onlyOwner nonReentrant {
        require(lockedWBTC[user] >= amount, "Insufficient locked WBTC");
        lockedWBTC[user] -= amount;
        IERC20(bridgeAddress).safeTransfer(user, amount);
        emit Released(user, amount);
    }

    /// @notice Emergency withdrawal by owner
    function emergencyWithdraw(uint256 amount,) external onlyOwner nonReentrant {
        IERC20(bridgeAddress).safeTransfer(owner(), amount);
    }
}
pragma solidity ^0.8.0;
//Etherum Bridge
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ETHBridge is ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public owner;
    IERC20 public ETH;
    uint256 public constant ETH_PER_WBTC = 10000; 
    mapping(address => uint256) public lockedWBTC;
    mapping(address => uint256) public lockedETH;

    event Locked(address indexed user, uint256 amount);
    event Released(address indexed user, uint256 amount);

    constructor(address _ETH) {
        owner = msg.sender;
        wbtc = IERC20(_wbtc);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    /// @notice Lock ETH to bridge to Ethereum chain
    function lockETH() external payable nonReentrant {
        require(msg.value > 0, "No WBTC sent");
        uint256 ETHAmount = msg.value * ETH_PER_WBTC;
        wbtc.safeTransferFrom(msg.sender, address(this), ETHAmount);
        lockedWBTC[msg.sender] += msg.value;
        lockedWBTC[msg.sender] += ETHAmount;
        emit Locked(msg.sender, ETHAmount);
    }

    /// @notice Release locked WBTC in case of emergency
    function releaseWBTC(address user, uint256 amount) external onlyOwner nonReentrant {
        require(lockedWBTC[user] >= amount, "Insufficient locked WBTC");
        lockedWBTC[user] -= amount;
        wbtc.safeTransfer(user, amount);
        emit Released(user, amount);
    }

    /// @notice Emergency withdrawal by owner
    function emergencyWithdraw(uint256 amount) external onlyOwner nonReentrant {
        payable(owner).transfer(amount);
    }
}
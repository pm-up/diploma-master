pragma solidity ^0.8.0;
// Importing libraries from OpenZeppelin for security measures
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
contract SecureSmartContract is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address payable; // State variables
    mapping(address => uint256) public balances;
    IERC20 public token;
    bool public paused; // Events
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Paused();
    event Unpaused(); // Modifier to check if the contract is paused
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }
    constructor(IERC20 _token) {
        token = _token;
        paused = false;
    }

    // Deposit function using SafeMath to prevent overflow and underflow
    function deposit(uint256 amount) public whenNotPaused nonReentrant {
        require(amount > 0, "Deposit amount must be greater than zero");
        token.transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] = balances[msg.sender].add(amount);
        emit Deposited(msg.sender, amount);
    }
    // Withdraw function with reentrancy guard and checks-effects-interactions pattern
function withdraw(uint256 amount) public whenNotPaused nonReentrant   {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] = balances[msg.sender].sub(amount);
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        emit Withdrawn(msg.sender, amount);
    }
    // Function to pause the contract (only owner can call this)
    function pause() public onlyOwner {
        paused = true;
        emit Paused();
    }
    // Function to unpause the contract (only owner can call this)
    function unpause() public onlyOwner {
        paused = false;
        emit Unpaused();
    }
    // Function to safely send Ether to an address using call to avoid gas limit issues
    function sendEther(address payable recipient, uint256 amount) public onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        recipient.sendValue(amount);
    }
    // Function to receive Ether
    receive() external payable {}
    // Fallback function
    fallback() external payable {}
}

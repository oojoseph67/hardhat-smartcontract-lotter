// Raffle

// Enter the lottery(paying some amount) ✅
// Pick a random winner (verifibly random)
// Winner to be selected every X minutes -> totaly automated
// Chainlink Oracle -> Randomness, Automated Execution (Chainlink Keeper)

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

// Import
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

// Error
error Raffle__NotEnoughETHEntered();
error Raffle__TransferFailed();
error Raffle__NotOpen();
error Raffle__UpkeepNotNeeded(uint256 currentBalance, uint256 numEntrants, uint256 raffleState);

/** @title A sample Raffle contract 
*   @author mcQu33n
*   @notice This contract is for creating an untamperable decentralized raffle/lottery.
*   @dev This implement Chainlink VRF v2 and Chainlink Keeper v2.
 */


// Contract
contract Raffle is VRFConsumerBaseV2, KeeperCompatibleInterface {
    /** Type declarations */
    enum RaffleState {
        OPEN,
        CALCULATING_WINNER
    } // uint256 0 = OPEN, 1 = CALCULATING_WINNER

    /* State Variables */
    uint256 private immutable i_entranceFee;
    address payable[] private s_entrants;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;

    bytes32 private immutable i_keyHash;
    uint64 private immutable i_subId;
    uint32 private immutable i_callbackGasLimit;

    uint16 private constant minimumRequestConfirmations = 3; // REQUEST_CONFIRMATIONS = minimumRequestConfirmations
    uint32 private constant numWords = 1; // NUM_WORDS = numWords /** We only want one random number the case can be different */

    // Raffle Variables
    address private s_recentWinner;
    RaffleState private s_raffleState;
    uint256 private s_lateTimeStamp;
    uint256 private immutable i_interval;

    /* Events */
    event RaffleEnter(
        address indexed entrants
    );
    event RaffleWinner(
        uint256 indexed requestId
    );
    event WinnerPicked (
        address indexed winner
    );

    /* Functions/Constructor */
    constructor(
        address vrfCoordinatorv2,
        uint256 entranceFee,
        bytes32 keyHash,
        uint64 subId,
        uint32 callbackGasLimit,
        uint256 interval
    ) VRFConsumerBaseV2(vrfCoordinatorv2) {
        i_entranceFee = entranceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorv2);
        i_keyHash = keyHash;
        i_subId = subId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
        s_lateTimeStamp = block.timestamp;
        i_interval = interval;
    }

    // Enter Raffle
    function enterRaffle() public payable {
        if(msg.value < i_entranceFee) {
            revert Raffle__NotEnoughETHEntered();
        }
        if(s_raffleState != RaffleState.OPEN) {
            revert Raffle__NotOpen();
        }
        s_entrants.push(payable(msg.sender));
        // Emit an event when we update a dynamic arrray or mapping
        // Named events with the function name reversed
        emit RaffleEnter(msg.sender);
    }

    function checkUpkeep(
        bytes memory /* ckeckData */
    )
        public view override returns (
            bool upkeepNeeded, bytes memory /** performData */
        ) {
        bool isOpen = RaffleState.OPEN == s_raffleState;
        bool timePassed = ((block.timestamp - s_lateTimeStamp) > i_interval);
        bool hasEntrants = s_entrants.length > 0;
        bool hasBalance = address(this).balance > 0;
        upkeepNeeded = (isOpen && timePassed && hasEntrants && hasBalance);
        return (upkeepNeeded, "0x0");
    }

    // Picking a random winner
    function performUpkeep(bytes calldata /** performData */) external override {
        // request a random number
        // once we get it we do something with it
        // 2 transaction process\
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(
                address(this).balance,
                s_entrants.length,
                uint256(s_raffleState)
            );
        }

        s_raffleState = RaffleState.CALCULATING_WINNER;
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_keyHash, 
            i_subId, 
            minimumRequestConfirmations, 
            i_callbackGasLimit, 
            numWords
        );

        emit RaffleWinner(requestId);
    }

    // requestId is not need3eed but the compile needs us to pass something, so we just comment it out
    function fulfillRandomWords(uint256 /** requestId */ , uint256[] memory randomWords) internal override {
        uint256 indexOfWinner = randomWords[0] % s_entrants.length;
        address payable recentWinner = s_entrants[indexOfWinner];
        s_recentWinner = recentWinner;
        s_raffleState = RaffleState.OPEN;
        s_entrants= new address payable[](0);
        s_lateTimeStamp = block.timestamp;
        (bool success, ) = recentWinner.call{value: address(this).balance}("");

        if(!success) {
            revert Raffle__TransferFailed();
        } 

        emit WinnerPicked(recentWinner);
    }

    /* View / Pure functions */
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getEntrant(uint256 index) public view returns (address) {
       // return s_entrants.length;
       return s_entrants[index];
    }

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }

    function getRaffleState() public view returns (RaffleState) {
        return s_raffleState;
    }

    function getNumWords() public pure returns (uint256) {
        return numWords;
    }

    function getNumberOfEntrants() public view returns (uint256) {
        return s_entrants.length;
    }

    function getLatestTimeStamp() public view returns (uint256) {
        return s_lateTimeStamp;
    }

    function getRequestConfirmations() public pure returns (uint16) {
        return minimumRequestConfirmations;
    }

    function getInterval() public view returns (uint256) {
        return i_interval;
    }
}
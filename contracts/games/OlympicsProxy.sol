// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IGamesHub.sol";
import "../interfaces/IOlympics.sol";

/**
 * @title OlympicsProxy
 * @author PerfectPool
 * @notice The proxy contract for the Olympics game, that stores all information about the games.
 * Please refer to the original contract for more informations about overral functionality.
 */

contract OlympicsProxy {
    /** EVENTS **/
    event GameCreated(uint256 gameIndex);
    event GameActivated(uint256 gameIndex);
    event MatchDecided(uint256 gameIndex, uint8 matchId, uint8 result);
    event GameFinished(uint256 gameIndex);
    event DaysToClaimPrizeChanged(uint8 daysToClaimPrize);
    event Paused(bool paused);
    event UpdatePerformed(uint256 lastTimeStamp);

    /** VARIABLES **/
    IGamesHub public gamesHub;
    mapping(uint256 => address) private gameContract;
    mapping(bytes => address) private projectGameContract;
    uint256 private immutable lastGameId;
    address public executionAddress;

    string public gameName;

    /**
     * @dev Constructor function
     * @param _gamesHubAddress Address of the games hub
     * @param _executorAddress Address of the executor
     */
    constructor(
        address _gamesHubAddress,
        address _executorAddress,
        uint256 _lastGameId,
        string memory _gameName
    ) {
        gamesHub = IGamesHub(_gamesHubAddress);
        executionAddress = _executorAddress;
        lastGameId = _lastGameId;
        gameName = _gameName;
    }

    /** MODIFIERS **/
    modifier onlyAdministrator() {
        require(gamesHub.checkRole(keccak256("ADMIN"), msg.sender), "OLP-01");
        _;
    }

    modifier onlyExecutor() {
        require(msg.sender == executionAddress, "OLP-02");
        _;
    }

    /** MUTATORS **/

    /**
     * @dev Function to set a contract to a specific game id
     * @param _gameId The ID of the game
     * @param _gameAddress The address of the game contract
     */
    function setGameContract(
        uint256 _gameId,
        address _gameAddress
    ) public onlyAdministrator {
        gameContract[_gameId] = _gameAddress;
    }

    /**
     * @dev Function to activate a game
     * @param _gameIndex The index of the game to be activated
     */
    function activateGame(uint256 _gameIndex) public onlyExecutor {
        IOlympics(gamesHub.games(keccak256(bytes(gameName)))).activateGame(
            _gameIndex
        );
        emit GameActivated(_gameIndex);
        emit UpdatePerformed(block.timestamp);
    }

    /**
     * @dev Function to perform the update and create new games
     * @param _dataNewGame The data for a new game
     * Types encoded in order:
     * * uint256 _startTimeStamp, // Start timestamp of the first group
     * * string[16] memory _symbolsG1, // Array of team symbols for group 1
     * * string[16] memory _symbolsG2, // Array of team symbols for group 2
     * * string[16] memory _symbolsG3 // Array of team symbols for group 3
     * @param _lastTimeStamp The last timestamp
     */
    function createGame(
        bytes calldata _dataNewGame,
        uint256 _lastTimeStamp
    ) public onlyExecutor {
        IOlympics _gameContract = IOlympics(
            gamesHub.games(keccak256(bytes(gameName)))
        );
        if (_gameContract.paused()) return;

        if (
            _gameContract.getActiveGames().length <
            _gameContract.minActiveGames() &&
            _gameContract.createNewGames() &&
            _dataNewGame.length != 0
        ) {
            uint256 _gameId = _gameContract.createGame(
                _lastTimeStamp,
                _dataNewGame
            );
            if (_gameId > 0) {
                gameContract[_gameId] = address(_gameContract);
                emit GameCreated(_gameId);
            }
        }
        emit UpdatePerformed(_lastTimeStamp);
    }

    /**
     * @dev Function to set the result for a Match
     * @param _lastTimeStamp The last timestamp
     * @param _gameIndex The index of the game
     * @param _match The match to be decided. This is the index of the match in the group
     * @param _group The group of the match
     * @param _result The result of the match
     */
    function setMatchResult(
        uint256 _lastTimeStamp,
        uint256 _gameIndex,
        uint8 _group,
        uint8 _match,
        uint8 _result
    ) public onlyExecutor {
        IOlympics(gamesHub.games(keccak256(bytes(gameName)))).setMatchResult(
            _lastTimeStamp,
            _gameIndex,
            _group,
            _match,
            _result
        );

        emit MatchDecided(_gameIndex, _match, _result);

        if (
            IOlympics(gamesHub.games(keccak256(bytes(gameName)))).getGameStatus(
                _gameIndex
            ) == 2
        ) {
            emit GameFinished(_gameIndex);
        }
        emit UpdatePerformed(_lastTimeStamp);
    }

    /**
     * @dev Function to change the days to claim the prize
     * @param _daysToClaimPrize The new days to claim the prize
     */
    function changeDaysToClaimPrize(
        uint8 _daysToClaimPrize
    ) public onlyAdministrator {
        IOlympics(gamesHub.games(keccak256(bytes(gameName))))
            .changeDaysToClaimPrize(_daysToClaimPrize);
        emit DaysToClaimPrizeChanged(_daysToClaimPrize);
    }

    /**
     * @dev Function to pause / unpause the contract
     * @param _paused Boolean to pause or unpause the contract
     */
    function setPaused(bool _paused) external onlyAdministrator {
        IOlympics(gamesHub.games(keccak256(bytes(gameName)))).setPaused(
            _paused
        );
        emit Paused(_paused);
    }

    /**
     * @dev Function to set the forwarder address
     * @param _executionAddress Address of the Chainlink forwarder
     */
    function setExecutionAddress(
        address _executionAddress
    ) external onlyAdministrator {
        executionAddress = _executionAddress;
    }

    /**
     * @dev Function to determine if new games should be created
     * @param _active Boolean to activate or deactivate the contract
     */
    function setCreateNewGames(bool _active) public onlyAdministrator {
        IOlympics(gamesHub.games(keccak256(bytes(gameName)))).setCreateNewGames(
                _active
            );
    }

    /**
     * @dev Function to set the minimum number of concurrent games
     * @param _minActiveGames The new minimum number of concurrent games
     */
    function setMinConcurrentGames(
        uint8 _minActiveGames
    ) public onlyAdministrator {
        IOlympics(gamesHub.games(keccak256(bytes(gameName))))
            .setMinConcurrentGames(_minActiveGames);
    }

    /** GETTERS **/

    /**
     * @dev Function to get the game final result
     * @param gameIndex The index of the game
     * @return resultas The array of results
     */
    function getFinalResult(
        uint256 gameIndex
    ) public view returns (uint8[24] memory) {
        return IOlympics(getGameContract(gameIndex)).getFinalResult(gameIndex);
    }

    /**
     * @dev Status of the game. 0 = inactive, 1 = active, 2 = finished
     * @param gameIndex The index of the game
     * @return status The status of the game
     */
    function getGameStatus(
        uint256 gameIndex
    ) public view returns (uint8 status) {
        return IOlympics(getGameContract(gameIndex)).getGameStatus(gameIndex);
    }

    /**
     * @dev Function to get the teams of the groups of a game
     * @param gameIndex The index of the game
     * @return teams The array of team indexes
     */
    function getGroupsTeams(
        uint256 gameIndex
    )
        public
        view
        returns (uint256[16] memory, uint256[16] memory, uint256[16] memory)
    {
        return
            IOlympics(getGameContract(gameIndex)).getGroupsTeams(gameIndex);
    }

    /**
     * @dev Function to get the data for a group of a game
     * If the game has a third place match, the third place match will be the second match of the last group
     * @param gameIndex The index of the game
     * @param group The index of the group
     * @return groupData The ABI encoded data for the group
     * Types encoded in order:
     * * string[16] teams, // Array of team symbols
     * * uint8[8] results, // Array of match results
     * * uint256 start, // Group start timestamp
     * * uint256 end // Group end timestamp
     */
    function getGroupFullData(
        uint256 gameIndex,
        uint8 group
    ) public view returns (bytes memory) {
        return
            IOlympics(getGameContract(gameIndex)).getGroupFullData(
                gameIndex,
                group
            );
    }

    /**
     * @dev Function to get the data for a game
     * @param gameIndex The index of the game
     * @return gameData The ABI encoded data for the game
     * Types encoded in order:
     * * bytes fullGroupData, // Group 1 data (same as returned on getGroupFullData)
     * * bytes fullGroupData, // Group 2 data (same as returned on getGroupFullData)
     * * bytes fullGroupData, // Group 3 data (same as returned on getGroupFullData)
     * * uint256 start, // Game start timestamp
     * * uint256 end, // Game end timestamp
     * * uint8 activated // 0: Inactive / 1: Active / 2: Finished
     */
    function getGameFullData(
        uint256 gameIndex
    ) public view returns (bytes memory) {
        return IOlympics(getGameContract(gameIndex)).getGameFullData(gameIndex);
    }

    /**
     * @dev Function to get the data for a group of a game
     * @param gameIndex The index of the game
     * @param group The index of the group
     * @return teams The array of team IDs
     * @return results The array of results
     */
    function getGroupData(
        uint256 gameIndex,
        uint8 group
    ) public view returns (uint256[16] memory teams, uint8[8] memory results) {
        return
            IOlympics(getGameContract(gameIndex)).getGroupData(
                gameIndex,
                group
            );
    }

    /**
     * @dev Function to get all active games indexes
     * @return activeGames The total number of active games
     */
    function getActiveGames() public view returns (uint256[] memory) {
        return
            IOlympics(gamesHub.games(keccak256(bytes(gameName))))
                .getActiveGames();
    }

    /**
     * @dev Function to get the symbol of a team
     * @param teamIndex The index of the team
     */
    function getTeamSymbol(
        uint256 teamIndex
    ) public view returns (string memory) {
        return
            IOlympics(gamesHub.games(keccak256(bytes(gameName)))).getTeamSymbol(
                teamIndex
            );
    }

    /**
     * @dev Function to get the team index of a symbol
     * @param _symbol The symbol of the team
     */
    function getTeamId(string memory _symbol) public view returns (uint256) {
        return
            IOlympics(gamesHub.games(keccak256(bytes(gameName)))).getTeamId(
                _symbol
            );
    }

    /**
     * @dev Function to get the team index of an array of symbols
     * @param _symbols The array of symbols
     */
    function getTeamsIds(
        bytes memory _symbols
    ) public view returns (uint256[16] memory) {
        return
            IOlympics(gamesHub.games(keccak256(bytes(gameName)))).getTeamsIds(
                _symbols
            );
    }

    /**
     * @dev Function to get the team symbol of an array of indexes
     * @param _teams The array of team indexes
     */
    function getTeamsSymbols(
        bytes memory _teams
    ) public view returns (string[16] memory) {
        return
            IOlympics(gamesHub.games(keccak256(bytes(gameName))))
                .getTeamsSymbols(_teams);
    }

    /**
     * @dev Function to get the game contract address
     * @param _gameId The ID of the game
     * @return The address of the game contract
     */
    function getGameContract(uint256 _gameId) public view returns (address) {
        return
            (_gameId < lastGameId) || gameContract[_gameId] == address(0)
                ? gameContract[lastGameId]
                : gameContract[_gameId];
    }

    /** VARIABLES **/
    /**
     * @dev Function to minimum number of active games on the contract.
     * If this number is not reached and createNewGames is true, new games will be created.
     * @return The minimum number of active games
     */
    function minActiveGames() public view returns (uint256) {
        return
            IOlympics(gamesHub.games(keccak256(bytes(gameName))))
                .minActiveGames();
    }

    /**
     * @dev Function to get the total number of games (also the index of the last game created)
     * @return The total number of games
     */
    function totalGames() public view returns (uint256) {
        return
            IOlympics(gamesHub.games(keccak256(bytes(gameName)))).totalGames();
    }

    /**
     * @dev Function to get the time in days to claim the prize after the game is finished.
     * After this time, the pot of the game will be dismissed (refer to BracketTicket8 to know more about this)
     * @return The time in days to claim the prize
     */
    function daysToClaimPrize() public view returns (uint256) {
        return
            IOlympics(gamesHub.games(keccak256(bytes(gameName))))
                .daysToClaimPrize();
    }

    /**
     * @dev Function to get if the contract is paused
     * @return Boolean to check if the contract is paused
     */
    function paused() public view returns (bool) {
        return IOlympics(gamesHub.games(keccak256(bytes(gameName)))).paused();
    }

    /**
     * @dev Function to get if the creation of new games is enabled
     * @return Boolean to check if the creation of new games is enabled
     */
    function createNewGames() public view returns (bool) {
        return
            IOlympics(gamesHub.games(keccak256(bytes(gameName))))
                .createNewGames();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IGamesHub.sol";
import "../interfaces/IBracketGame8.sol";

/**
 * @title BracketGame8
 * @author PerfectPool
 * @notice The proxy contract for the Bracket8 game, that stores all information about the games.
 * Please refer to the original contract for more informations about overral functionality.
 */

contract Bracket8Proxy {
    /** EVENTS **/
    event GameCreated(uint256 gameIndex);
    event GameActivated(uint256 gameIndex);
    event GameAdvanced(uint256 gameIndex, uint8 round);
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
        require(gamesHub.checkRole(keccak256("ADMIN"), msg.sender), "BKP-01");
        _;
    }

    modifier onlyExecutor() {
        require(msg.sender == executionAddress, "BKP-02");
        _;
    }

    modifier gameOutOfIndex(uint256 gameIndex) {
        IBracketGame8 _gameContract = IBracketGame8(
            gamesHub.games(keccak256(bytes(gameName)))
        );
        require(
            (gameIndex != 0) && (gameIndex <= _gameContract.totalGames()),
            "BKP-03"
        );
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
        IBracketGame8(gamesHub.games(keccak256(bytes(gameName)))).activateGame(
            _gameIndex
        );

        emit GameActivated(_gameIndex);
        emit UpdatePerformed(block.timestamp);
    }

    /**
     * @dev Function to perform the update and create new games
     * @param _dataNewGame The data for a new game
     * Types encoded in order:
     * * uint256 _startTimeStamp, // Start timestamp of the first round
     * * string[8] _symbols // Array of symbols of the teams
     * * bool _thirdPlaceMatch // Boolean to determine if the third place match should be created
     * @param _dataUpdate Data for the update
     * _dataUpdate types encoded in order:
     * * uint256[4] gameIds, // Array of game IDs
     * * bytes[4] _matchData // Array of match data
     * _matchData types encoded in order:
     * * uint8 _match, // Match number
     * * uint256 _scoreTeam1, // Score of team 1
     * * uint256 _scoreTeam2, // Score of team 2
     * * uint8 _result // Result of the match
     * @param _lastTimeStamp The last timestamp
     */
    function performGames(
        bytes calldata _dataNewGame,
        bytes calldata _dataUpdate,
        uint256 _lastTimeStamp
    ) public onlyExecutor {
        IBracketGame8 _gameContract = IBracketGame8(
            gamesHub.games(keccak256(bytes(gameName)))
        );
        if (_gameContract.paused()) return;

        if (_dataUpdate.length != 0) {
            (uint256[4] memory gameIds, bytes[4] memory _matchData) = abi
                .decode(_dataUpdate, (uint256[4], bytes[4]));

            for (uint8 i = 0; i < _gameContract.getActiveGames().length; i++) {
                if (gameIds[i] == 0) continue;
                (
                    uint8 _match,
                    uint256 _scoreTeam1,
                    uint256 _scoreTeam2,
                    uint8 _result
                ) = abi.decode(_matchData[i], (uint8, uint256, uint256, uint8));

                bool _activated = _gameContract.isGameActivated(gameIds[i]);

                if (_match == 8) {
                    _gameContract.setThirdPlaceMatch(
                        _lastTimeStamp,
                        gameIds[i],
                        _scoreTeam1,
                        _scoreTeam2,
                        _result
                    );
                } else {
                    _gameContract.setMatchResult(
                        _lastTimeStamp,
                        gameIds[i],
                        _match,
                        _scoreTeam1,
                        _scoreTeam2,
                        _result
                    );
                }

                uint8 _status = _gameContract.getGameStatus(gameIds[i]);
                if (!_activated && _gameContract.isGameActivated(gameIds[i]))
                    emit GameActivated(gameIds[i]);
                if (_status == 4) emit GameFinished(gameIds[i]);
                emit GameAdvanced(gameIds[i], _status == 0 ? 0 : _status - 1);
            }
        }

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
     * @dev Function to change the days to claim the prize
     * @param _daysToClaimPrize The new days to claim the prize
     */
    function changeDaysToClaimPrize(
        uint8 _daysToClaimPrize
    ) public onlyAdministrator {
        IBracketGame8(gamesHub.games(keccak256(bytes(gameName))))
            .changeDaysToClaimPrize(_daysToClaimPrize);
        emit DaysToClaimPrizeChanged(_daysToClaimPrize);
    }

    /**
     * @dev Function to pause / unpause the contract
     * @param _paused Boolean to pause or unpause the contract
     */
    function setPaused(bool _paused) external onlyAdministrator {
        IBracketGame8(gamesHub.games(keccak256(bytes(gameName)))).setPaused(
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
        IBracketGame8(gamesHub.games(keccak256(bytes(gameName))))
            .setCreateNewGames(_active);
    }

    /**
     * @dev Function to set the round duration
     * @param _roundDuration The new round duration
     */
    function setRoundDuration(uint256 _roundDuration) public onlyAdministrator {
        IBracketGame8(gamesHub.games(keccak256(bytes(gameName))))
            .setRoundDuration(_roundDuration);
    }

    /**
     * @dev Function to set the minimum number of concurrent games
     * @param _minActiveGames The new minimum number of concurrent games
     */
    function setMinConcurrentGames(
        uint8 _minActiveGames
    ) public onlyAdministrator {
        IBracketGame8(gamesHub.games(keccak256(bytes(gameName))))
            .setMinConcurrentGames(_minActiveGames);
    }

    /** GETTERS **/

    /**
     * @dev Function to get the game final result
     * @param gameIndex The index of the game
     * @return brackets The array of team IDs
     */
    function getFinalResult(
        uint256 gameIndex
    ) public view gameOutOfIndex(gameIndex) returns (uint256[8] memory) {
        return
            IBracketGame8(getGameContract(gameIndex)).getFinalResult(gameIndex);
    }

    /**
     * @dev Status of the game. 0 = inactive, 1 ~ 3 = actual round, 4 = finished
     * @param gameIndex The index of the game
     * @return status The status of the game
     */
    function getGameStatus(
        uint256 gameIndex
    ) public view gameOutOfIndex(gameIndex) returns (uint8 status) {
        return
            IBracketGame8(getGameContract(gameIndex)).getGameStatus(gameIndex);
    }

    /**
     * @dev Function to get the data for a round of a game
     * @param gameIndex The index of the game
     * @param round The index of the round
     * @return roundData The data for the round
     * Types encoded in order:
     * * string[8] teams, // Array of team symbols
     * * uint8[4] results, // Array of match results
     * * uint256[8] scores, // Array of teams scores
     * * uint256 start, // Round start timestamp
     * * uint256 end // Round end timestamp
     */
    function getRoundFullData(
        uint256 gameIndex,
        uint8 round
    ) private view gameOutOfIndex(gameIndex) returns (bytes memory) {
        return
            IBracketGame8(getGameContract(gameIndex)).getRoundFullData(
                gameIndex,
                round
            );
    }

    /**
     * @dev Function to get the data for a game
     * @param _gameId The index of the game
     * @return gameData The data for the game
     * Types encoded in order:
     * * bytes fullRoundData, // Round 1 data (same as returned on getRoundFullData)
     * * bytes fullRoundData, // Round 2 data (same as returned on getRoundFullData)
     * * bytes fullRoundData, // Round 3 data (same as returned on getRoundFullData)
     * * string winner, // Winner team symbol
     * * string secondPlace, // Second place team symbol
     * * string thirdPlace, // Third place team symbol
     * * uint8 currentRound, // 0-2: Rounds 1-3 / 3: Finished
     * * uint256 start, // Game start timestamp
     * * uint256 end, // Game end timestamp
     * * uint8 activated // 0: Inactive / 1: Active
     */
    function getGameFullData(
        uint256 _gameId
    ) public view gameOutOfIndex(_gameId) returns (bytes memory) {
        // Return: ABI-encoded bytes, bytes, bytes, string, uint256, uint8, uint256, uint256
        // CurrentRound 0-2: Rounds 1-3 / 3: Finished
        // Activated: 0: Inactive / 1: Active
        return IBracketGame8(getGameContract(_gameId)).getGameFullData(_gameId);
    }

    /**
     * @dev Function to get the data for a round of a game
     * @param gameIndex The index of the game
     * @param round The index of the round
     * @return teams The array of team IDs
     * @return results The array of results
     */
    function getRoundData(
        uint256 gameIndex,
        uint8 round
    )
        public
        view
        gameOutOfIndex(gameIndex)
        returns (uint256[8] memory, uint8[4] memory)
    {
        return
            IBracketGame8(getGameContract(gameIndex)).getRoundData(
                gameIndex,
                round
            );
    }

    /**
     * @dev Function to get all active games indexes
     * @return activeGames The total number of active games
     */
    function getActiveGames() public view returns (uint256[] memory) {
        return
            IBracketGame8(gamesHub.games(keccak256(bytes(gameName))))
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
            IBracketGame8(gamesHub.games(keccak256(bytes(gameName))))
                .getTeamSymbol(teamIndex);
    }

    /**
     * @dev Function to get the team index of a symbol
     * @param _symbol The symbol of the team
     */
    function getTeamId(string memory _symbol) public view returns (uint256) {
        return
            IBracketGame8(gamesHub.games(keccak256(bytes(gameName)))).getTeamId(
                _symbol
            );
    }

    /**
     * @dev Function to get the team index of an array of symbols
     * @param _symbols The array of symbols
     */
    function getTeamsIds(
        bytes memory _symbols
    ) public view returns (uint256[8] memory) {
        return
            IBracketGame8(gamesHub.games(keccak256(bytes(gameName))))
                .getTeamsIds(_symbols);
    }

    /**
     * @dev Function to get the team symbol of an array of indexes
     * @param _teams The array of team indexes
     */
    function getTeamsSymbols(
        bytes memory _teams
    ) public view returns (string[8] memory) {
        return
            IBracketGame8(gamesHub.games(keccak256(bytes(gameName))))
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
            IBracketGame8(gamesHub.games(keccak256(bytes(gameName))))
                .minActiveGames();
    }

    /**
     * @dev Function to get the total number of games (also the index of the last game created)
     * @return The total number of games
     */
    function totalGames() public view returns (uint256) {
        return
            IBracketGame8(gamesHub.games(keccak256(bytes(gameName))))
                .totalGames();
    }

    /**
     * @dev Function to get the time in days to claim the prize after the game is finished.
     * After this time, the pot of the game will be dismissed (refer to BracketTicket8 to know more about this)
     * @return The time in days to claim the prize
     */
    function daysToClaimPrize() public view returns (uint256) {
        return
            IBracketGame8(gamesHub.games(keccak256(bytes(gameName))))
                .daysToClaimPrize();
    }

    /**
     * @dev Function to get if the contract is paused
     * @return Boolean to check if the contract is paused
     */
    function paused() public view returns (bool) {
        return
            IBracketGame8(gamesHub.games(keccak256(bytes(gameName)))).paused();
    }

    /**
     * @dev Function to get if the creation of new games is enabled
     * @return Boolean to check if the creation of new games is enabled
     */
    function createNewGames() public view returns (bool) {
        return
            IBracketGame8(gamesHub.games(keccak256(bytes(gameName))))
                .createNewGames();
    }
}

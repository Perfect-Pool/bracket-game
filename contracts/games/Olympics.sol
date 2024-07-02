// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IGamesHub.sol";
import "../interfaces/IOlympics.sol";

/**
 * @title Onchain Olympics
 * @author PerfectPool
 * @notice The Olympics contract is a game where players can bet on the results of a tournament with 16 teams in 3 groups.
 * The tournament consists of 3 groups, each with 8 matches that can have Player 1 win, Player 2 win, or a draw.
 * While the game is not activated, the players can bet on the results of the matches, using the OlympicsTicket contract.
 * When the game is activated by an administrator, there will be no more bets accepted and the results of the matches can be set.
 *
 * This contrat is modified only by the OlympicsProxy contract, which is the data storage contract for the Olympics game.
 */

interface IOlympicsTicket {
    function setGamePot(uint256 _gameId) external;
}

contract Olympics is IOlympics {
    /** STRUCTS **/
    /**
     * @notice Struct to store the data of a match
     * @param team1 The index of the first team
     * @param team2 The index of the second team
     * @param result The result of the match (0: Not Defined, 1: Team 1, 2: Team 2, 3: Draw)
     */
    struct Match {
        uint256 team1;
        uint256 team2;
        uint8 result;
    }

    /**
     * @notice Struct to store the data of a group
     * @param teams The array of team indexes
     * @param matches The array of matches
     * @param decidedMatches The number of decided matches
     * @param start The start timestamp of the group
     * @param end The end timestamp of the group
     */
    struct Group {
        uint256[16] teams;
        Match[8] matches;
        uint8 decidedMatches;
        uint256 start;
        uint256 end;
    }

    /**
     * @notice Struct to store the data of a game
     * @param teams The array of team indexes
     * @param groups The array of groups
     * @param thirdPlaceMatch The third place match
     * @param start The start timestamp of the game
     * @param end The end timestamp of the game
     * @param currentGroup The current group of the game
     * @param winner The winner of the game
     * @param secondPlace The second place of the game
     * @param thirdPlace The third place of the game
     * @param hasThirdPlace If the game has a third place match
     * @param activated If the game is activated
     */
    struct Game {
        uint256[16] teams;
        Group[3] groups;
        uint256 start;
        uint256 end;
        bool activated;
    }

    /** VARIABLES **/
    IGamesHub public gamesHub;

    mapping(uint256 => bytes) private teams;
    mapping(uint256 => Game) private games;
    mapping(uint256 => uint256) private gameIndexToActiveIndex;
    mapping(bytes => uint256) private symbolToTeamId;
    mapping(uint256 => bytes) private teamIdToSymbol;

    uint256[] private activeGames;
    uint256 public minActiveGames = 1;
    uint256 public daysToClaimPrize;
    uint256 public totalTeams;
    uint256 public totalGames = 1;

    bool public paused = false;
    bool public createNewGames = true;

    address public executionAddress;

    string public proxyName;
    string public ticketName;

    /**
     * @dev Constructor function
     * @param _gamesHubAddress Address of the games hub
     * @param _executorAddress Address of the Chainlink forwarder
     */
    constructor(
        address _gamesHubAddress,
        address _executorAddress,
        string memory _proxyName,
        string memory _ticketName
    ) {
        gamesHub = IGamesHub(_gamesHubAddress);
        executionAddress = _executorAddress;
        proxyName = _proxyName;
        ticketName = _ticketName;
        daysToClaimPrize = 30;
    }

    /** MODIFIERS **/
    modifier onlyGameContract() {
        require(
            gamesHub.games(keccak256(bytes(proxyName))) == msg.sender,
            "OLP-01"
        );
        _;
    }

    modifier gameOutOfIndex(uint256 gameIndex) {
        require((gameIndex != 0) && (gameIndex <= totalGames), "OLP-02");
        _;
    }

    /** MUTATORS **/

    /**
     * @dev Function to pause / unpause the contract
     * @param _paused Boolean to pause or unpause the contract
     */
    function setPaused(bool _paused) external onlyGameContract {
        paused = _paused;
    }

    /**
     * @dev Function to determine if new games should be created
     * @param _active Boolean to activate or deactivate the contract
     */
    function setCreateNewGames(bool _active) external onlyGameContract {
        createNewGames = _active;
    }

    /**
     * @dev Function to set the minimum number of concurrent games
     * @param _minActiveGames The new minimum number of concurrent games
     */
    function setMinConcurrentGames(
        uint8 _minActiveGames
    ) public onlyGameContract {
        minActiveGames = _minActiveGames;
    }

    /**
     * @dev Function to add a new team to the game
     * @param symbol The symbol of the team
     */
    function addTeam(string memory symbol) private returns (uint256) {
        totalTeams++;
        symbolToTeamId[abi.encodePacked(symbol)] = totalTeams;
        teamIdToSymbol[totalTeams] = abi.encodePacked(symbol);
        return totalTeams;
    }

    /**
     * @dev Function to create a new game
     * @param _lastTimeStamp The last timestamp
     * @param _dataNewGame The data for a new game
     * Types encoded in order:
     * * uint256 _startTimeStamp, // Start timestamp of the first group
     * * string[8] _symbols // Array of symbols of the teams
     * * uint8 group // Group of the game
     * @return The index of the new game
     */
    function createGame(
        uint256 _lastTimeStamp,
        bytes calldata _dataNewGame
    ) external onlyGameContract returns (uint256) {
        (
            uint256 _startTimeStamp,
            string[16] memory _symbolsG1,
            string[16] memory _symbolsG2,
            string[16] memory _symbolsG3
        ) = abi.decode(
                _dataNewGame,
                (uint256, string[16], string[16], string[16])
            );
        require(!paused, "OLP-03");

        if (activeGames.length != 0) {
            removeGame(totalGames);
            games[totalGames] = games[totalGames + 1];
        }

        activeGames.push(totalGames);
        gameIndexToActiveIndex[totalGames] = activeGames.length - 1;

        Game storage _game = games[totalGames];
        uint8 _match = 0;
        for (uint8 i = 0; i < 16; i++) {
            require(bytes(_symbolsG1[i]).length != 0, "OLP-03");
            uint256 _teamIndex = symbolToTeamId[
                abi.encodePacked(_symbolsG1[i])
            ];
            if (_teamIndex == 0) {
                _teamIndex = addTeam(_symbolsG1[i]);
            }

            if (i % 2 == 0) {
                _game.groups[0].matches[_match].team1 = _teamIndex;
            } else {
                _game.groups[0].matches[_match].team2 = _teamIndex;
                _match++;
            }

            _game.teams[i] = _teamIndex;
            _game.groups[0].teams[i] = _teamIndex;
        }

        _match = 0;
        for (uint8 i = 0; i < 16; i++) {
            uint256 _teamIndex = symbolToTeamId[
                abi.encodePacked(_symbolsG2[i])
            ];

            if (i % 2 == 0) {
                _game.groups[1].matches[i / 2].team1 = _teamIndex;
            } else {
                _game.groups[1].matches[i / 2].team2 = _teamIndex;
                _match++;
            }

            _game.teams[i] = _teamIndex;
            _game.groups[1].teams[i] = _teamIndex;
        }

        _match = 0;
        for (uint8 i = 0; i < 16; i++) {
            uint256 _teamIndex = symbolToTeamId[
                abi.encodePacked(_symbolsG3[i])
            ];

            if (i % 2 == 0) {
                _game.groups[2].matches[i / 2].team1 = _teamIndex;
            } else {
                _game.groups[2].matches[i / 2].team2 = _teamIndex;
            }

            _game.teams[i] = _teamIndex;
            _game.groups[2].teams[i] = _teamIndex;
        }

        _game.start = _lastTimeStamp;
        _game.groups[0].start = _startTimeStamp;

        return totalGames;
    }

    /**
     * @dev Function to activate a game
     * @param _gameIndex The index of the game to be activated
     */
    function activateGame(uint256 _gameIndex) external onlyGameContract {
        Game storage _game = games[_gameIndex];
        require(!_game.activated, "OLP-04");
        _game.activated = true;
    }

    /**
     * @dev Function to set the result for a Match
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
    ) external onlyGameContract {
        Game storage _game = games[_gameIndex];
        require(_result == 1 || _result == 2 || _result == 3, "OLP-05");
        require(_game.activated, "OLP-06");

        Match storage _matchToSet = _game.groups[_group].matches[_match];
        if (_matchToSet.result != 0) return;

        _matchToSet.result = _result;

        require(_game.groups[_group].decidedMatches < 8, "OLP-07");
        _game.groups[_group].decidedMatches++;

        if (_game.groups[_group].decidedMatches == 8) {
            _game.groups[_group].end = _lastTimeStamp;
        }

        if (
            _game.groups[0].decidedMatches == 8 &&
            _game.groups[1].decidedMatches == 8 &&
            _game.groups[2].decidedMatches == 8
        ) {
            _game.groups[2].end = _lastTimeStamp;
            _game.end = _lastTimeStamp;

            // removeGame(_gameIndex);

            IOlympicsTicket(gamesHub.helpers(keccak256(bytes(ticketName))))
                .setGamePot(_gameIndex);
        }
    }

    /** AUXILIARY FUNCTIONS **/

    /**
     * @dev Function to remove a game from the list of active games
     * @param gameIndex The index of the game to be removed
     */
    function removeGame(uint256 gameIndex) internal gameOutOfIndex(gameIndex) {
        //remover o jogo da lista de jogos ativos
        uint256 activeIndex = gameIndexToActiveIndex[gameIndex];

        activeGames[activeIndex] = activeGames[activeGames.length - 1];

        gameIndexToActiveIndex[
            activeGames[activeGames.length - 1]
        ] = activeIndex;

        activeGames.pop();
    }

    /**
     * @dev Function to change the days to claim the prize
     * @param _daysToClaimPrize The new days to claim the prize
     */
    function changeDaysToClaimPrize(
        uint256 _daysToClaimPrize
    ) external onlyGameContract {
        daysToClaimPrize = _daysToClaimPrize;
    }

    /**
     * @dev Function to get the game final result
     * @param gameIndex The index of the game
     * @return results The array of results
     */
    function getFinalResult(
        uint256 gameIndex
    ) public view gameOutOfIndex(gameIndex) returns (uint8[24] memory results) {
        Game storage _game = games[gameIndex];

        for (uint8 i = 0; i < 8; i++) {
            results[i] = _game.groups[0].matches[i].result;
            results[i + 8] = _game.groups[1].matches[i].result;
            results[i + 16] = _game.groups[2].matches[i].result;
        }
    }

    /**
     * @dev Status of the game. 0 = inactive, 1 = active, 2 = finished
     * @param gameIndex The index of the game
     * @return status The status of the game
     */
    function getGameStatus(
        uint256 gameIndex
    ) public view gameOutOfIndex(gameIndex) returns (uint8 status) {
        if (!games[gameIndex].activated) {
            return 0;
        } else if (games[gameIndex].end == 0) {
            return 1;
        } else {
            return 2;
        }
    }

    /**
     * @dev Function to get the symbol of a team
     * @param teamIndex The index of the team
     */
    function getTeamSymbol(
        uint256 teamIndex
    ) public view returns (string memory) {
        return string(teamIdToSymbol[teamIndex]);
    }

    /**
     * @dev Function to get the team index of a symbol
     * @param _symbol The symbol of the team
     */
    function getTeamId(string memory _symbol) public view returns (uint256) {
        return symbolToTeamId[abi.encodePacked(_symbol)];
    }

    /**
     * @dev Function to get the team index of an array of symbols
     * @param _symbols The array of symbols (ABI-encoded string[16])
     */
    function getTeamsIds(
        bytes memory _symbols
    ) public view returns (uint256[16] memory) {
        uint256[16] memory _teams;
        string[16] memory _symbolsArray = abi.decode(_symbols, (string[16]));
        for (uint8 i = 0; i < 16; i++) {
            _teams[i] = getTeamId(_symbolsArray[i]);
        }
        return _teams;
    }

    /**
     * @dev Function to get the team symbol of an array of indexes
     * @param _teams The array of team indexes (ABI-encoded uint256[16])
     */
    function getTeamsSymbols(
        bytes memory _teams
    ) public view returns (string[16] memory) {
        string[16] memory _symbols;
        uint256[16] memory _teamsArray = abi.decode(_teams, (uint256[16]));
        for (uint8 i = 0; i < 16; i++) {
            _symbols[i] = getTeamSymbol(_teamsArray[i]);
        }
        return _symbols;
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
        gameOutOfIndex(gameIndex)
        returns (uint256[16] memory, uint256[16] memory, uint256[16] memory)
    {
        return (
            games[gameIndex].groups[0].teams,
            games[gameIndex].groups[1].teams,
            games[gameIndex].groups[2].teams
        );
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
    ) public view gameOutOfIndex(gameIndex) returns (bytes memory) {
        if (group > 2) return abi.encodePacked("");
        uint256[16] memory _teamsIds;
        uint8[8] memory _results;

        for (uint8 i = 0; i < 8; i++) {
            _teamsIds[i * 2] = games[gameIndex].groups[group].matches[i].team1;
            _teamsIds[i * 2 + 1] = games[gameIndex]
                .groups[group]
                .matches[i]
                .team2;
        }

        for (uint8 i = 0; i < 8; i++) {
            _results[i] = games[gameIndex].groups[group].matches[i].result;
        }

        return (
            abi.encode(
                getTeamsSymbols(abi.encode(_teamsIds)),
                _results,
                games[gameIndex].groups[group].start,
                games[gameIndex].groups[group].end
            )
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
     * * uint8 activated // 0: Inactive / 1: Active
     */
    function getGameFullData(
        uint256 gameIndex
    ) public view gameOutOfIndex(gameIndex) returns (bytes memory) {
        return (
            abi.encode(
                getGroupFullData(gameIndex, 0),
                getGroupFullData(gameIndex, 1),
                getGroupFullData(gameIndex, 2),
                games[gameIndex].start,
                games[gameIndex].end,
                games[gameIndex].activated
            )
        );
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
    )
        public
        view
        gameOutOfIndex(gameIndex)
        returns (uint256[16] memory, uint8[8] memory)
    {
        require(group <= 2, "OLP-08");
        uint256[16] memory _teams;
        uint8[8] memory _results;

        _teams = games[gameIndex].teams;

        for (uint8 i = 0; i < 8; i++) {
            _results[i] = games[gameIndex].groups[group].matches[i].result;
        }

        return (_teams, _results);
    }

    /**
     * @dev Function to get all active games indexes
     * @return activeGames The total number of active games
     */
    function getActiveGames() public view returns (uint256[] memory) {
        return activeGames;
    }

    /**
     * @dev Function to get if the game is active
     * @param gameIndex The index of the game
     * @return activated If the game is activated
     */
    function isGameActivated(
        uint256 gameIndex
    ) public view gameOutOfIndex(gameIndex) returns (bool) {
        return games[gameIndex].activated;
    }
}

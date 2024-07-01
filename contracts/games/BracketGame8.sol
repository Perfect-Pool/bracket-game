// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/IGamesHub.sol";
import "../interfaces/IBracketGame8.sol";
import "../interfaces/IBracketTicket8.sol";

/**
 * @title BracketGame8
 * @author PerfectPool
 * @notice The BracketGame8 contract manages a bracket-style tournament with 8 teams.
 * The tournament consists of 3 rounds, with the first round having 4 matches between the 8 teams.
 * While the game is not activated, the players can bet on the results of the matches, using the BracketTicket8 contract.
 * When the game is activated by an administrator, there will be no more bets accepted and the results of the matches can be set.
 *
 * The winners of each match advance to the second round, which has 2 matches.
 * The winners of the second round then compete in the final match of the third round to determine the winner and second place.
 * Optionally, the game can include a third-place match between the losers of the second round matches.
 * This allows for the determination of the third place in addition to the winner and second place.
 *
 * This contrat is modified only by the Bracket8Proxy contract, which is the data storage contract for the Bracket8 game.
 */

contract BracketGame8 is IBracketGame8 {
    /** STRUCTS **/
    /**
     * @notice Struct to store the data of a match
     * @param team1 The index of the first team
     * @param team2 The index of the second team
     * @param scoreTeam1 The score of the first team
     * @param scoreTeam2 The score of the second team
     * @param result The result of the match (0: Not Defined, 1: Team 1, 2: Team 2)
     */
    struct Match {
        uint256 team1;
        uint256 team2;
        uint256 scoreTeam1;
        uint256 scoreTeam2;
        uint8 result;
    }

    /**
     * @notice Struct to store the data of a round
     * @param matches The array of matches
     * @param decidedMatches The number of decided matches
     * @param start The start timestamp of the round
     * @param end The end timestamp of the round
     */
    struct Round {
        Match[4] matches;
        uint8 decidedMatches;
        uint256 start;
        uint256 end;
    }

    /**
     * @notice Struct to store the data of a game
     * @param teams The array of team indexes
     * @param rounds The array of rounds
     * @param thirdPlaceMatch The third place match
     * @param start The start timestamp of the game
     * @param end The end timestamp of the game
     * @param currentRound The current round of the game
     * @param winner The winner of the game
     * @param secondPlace The second place of the game
     * @param thirdPlace The third place of the game
     * @param hasThirdPlace If the game has a third place match
     * @param activated If the game is activated
     */
    struct Game {
        uint256[8] teams;
        Round[3] rounds;
        Match thirdPlaceMatch;
        uint256 start;
        uint256 end;
        uint8 currentRound;
        string winner;
        string secondPlace;
        string thirdPlace;
        bool hasThirdPlace;
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
    uint256 public roundDuration;
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

        roundDuration = 0;
        daysToClaimPrize = 30;
    }

    /** MODIFIERS **/
    modifier onlyGameContract() {
        require(
            gamesHub.games(keccak256(bytes(proxyName))) == msg.sender,
            "BRK-01"
        );
        _;
    }

    modifier gameOutOfIndex(uint256 gameIndex) {
        require((gameIndex != 0) && (gameIndex <= totalGames), "BRK-02");
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
     * @dev Function to set the round duration in minutes
     * @param _roundDuration The new round duration
     */
    function setRoundDuration(
        uint256 _roundDuration
    ) external onlyGameContract {
        roundDuration = _roundDuration * 60;
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
     * * uint256 _startTimeStamp, // Start timestamp of the first round
     * * string[8] _symbols // Array of symbols of the teams
     * * bool _hasThirdPlace // If the game has a third place match
     * @return The index of the new game
     */
    function createGame(
        uint256 _lastTimeStamp,
        bytes calldata _dataNewGame
    ) external onlyGameContract returns (uint256) {
        (
            uint256 _startTimeStamp,
            string[8] memory _symbols,
            bool _hasThirdPlace
        ) = abi.decode(_dataNewGame, (uint256, string[8], bool));
        require(!paused, "BRK-03");

        if (activeGames.length != 0) {
            removeGame(totalGames);
            delete games[totalGames];
        }
        
        activeGames.push(totalGames);
        gameIndexToActiveIndex[totalGames] = activeGames.length - 1;

        Game storage _game = games[totalGames];
        _game.hasThirdPlace = _hasThirdPlace;
        uint8 _match = 0;
        for (uint8 i = 0; i < _symbols.length; i++) {
            require(bytes(_symbols[i]).length != 0, "BRK-03");
            uint256 _teamIndex = symbolToTeamId[abi.encodePacked(_symbols[i])];
            if (_teamIndex == 0) {
                _teamIndex = addTeam(_symbols[i]);
            }

            if (i % 2 == 0) {
                _game.rounds[0].matches[_match].team1 = _teamIndex;
            } else {
                _game.rounds[0].matches[_match].team2 = _teamIndex;
                _match++;
            }

            _game.teams[i] = _teamIndex;
        }

        _game.start = _lastTimeStamp;
        _game.rounds[0].start = _startTimeStamp;

        uint256 timer = _startTimeStamp;
        uint256 _roundDuration = roundDuration;

        if (_roundDuration != 0) {
            timer += _roundDuration;
            _game.rounds[0].end = timer;
            _game.rounds[1].start = timer;
            timer += _roundDuration;
            _game.rounds[1].end = timer;
            _game.rounds[2].start = timer;
            timer += _roundDuration;
            _game.rounds[2].end = timer;
            _game.end = timer;
        }

        return totalGames;
    }

    /**
     * @dev Function to activate a game
     * @param _gameIndex The index of the game to be activated
     */
    function activateGame(uint256 _gameIndex) external onlyGameContract {
        Game storage _game = games[_gameIndex];
        require(!_game.activated, "BRK-04");
        _game.activated = true;
    }

    /**
     * @dev Function to set the result for a Match
     * @param _gameIndex The index of the game
     * @param _match The match to be decided. This is the index of the match in the round
     * @param _result The result of the match
     */
    function setMatchResult(
        uint256 _lastTimeStamp,
        uint256 _gameIndex,
        uint8 _match,
        uint256 _scoreTeam1,
        uint256 _scoreTeam2,
        uint8 _result
    ) external onlyGameContract {
        Game storage _game = games[_gameIndex];
        require(_result == 1 || _result == 2, "BRK-05");
        require(_game.activated, "BRK-06");

        if (_game.currentRound == 0) require(_match < 4, "BRK-07");
        else if (_game.currentRound == 1) require(_match < 2, "BRK-07");
        else if (_game.currentRound == 2) require(_match == 0, "BRK-07");

        uint8 _round = _game.currentRound;

        Match storage _matchToSet = _game.rounds[_round].matches[_match];
        if (_matchToSet.result != 0) return;

        _matchToSet.result = _result;
        _matchToSet.scoreTeam1 = _scoreTeam1;
        _matchToSet.scoreTeam2 = _scoreTeam2;

        if (_round == 0) {
            require(_game.rounds[_round].decidedMatches < 4, "BRK-09");
            _game.rounds[_round].decidedMatches++;

            if (_match % 2 == 0) {
                _game.rounds[1].matches[_match / 2].team1 = _result == 1
                    ? _game.rounds[_round].matches[_match].team1
                    : _game.rounds[_round].matches[_match].team2;
            } else {
                _game.rounds[1].matches[_match / 2].team2 = _result == 1
                    ? _game.rounds[_round].matches[_match].team1
                    : _game.rounds[_round].matches[_match].team2;
            }

            if (_game.rounds[_round].decidedMatches == 4) {
                _game.currentRound++;
                _game.rounds[0].end = _lastTimeStamp;
                _game.rounds[1].start = _lastTimeStamp;
            }
        } else if (_round == 1) {
            require(_game.rounds[_round].decidedMatches < 2, "BRK-10");
            _game.rounds[_round].decidedMatches++;

            uint256 winner;
            uint256 loser;

            if (_result == 1) {
                winner = _game.rounds[_round].matches[_match].team1;
                loser = _game.rounds[_round].matches[_match].team2;
            } else {
                winner = _game.rounds[_round].matches[_match].team2;
                loser = _game.rounds[_round].matches[_match].team1;
            }

            if (_match % 2 == 0) {
                _game.rounds[2].matches[_match / 2].team1 = winner;
                if (_game.hasThirdPlace) {
                    _game.thirdPlaceMatch.team1 = loser;
                }
            } else {
                _game.rounds[2].matches[_match / 2].team2 = winner;
                if (_game.hasThirdPlace) {
                    _game.thirdPlaceMatch.team2 = loser;
                }
            }

            if (_game.rounds[_round].decidedMatches == 2) {
                _game.currentRound++;
                _game.rounds[1].end = _lastTimeStamp;
                _game.rounds[2].start = _lastTimeStamp;
            }
        } else if (_round == 2) {
            require(_game.rounds[_round].decidedMatches == 0, "BRK-10");
            _game.rounds[_round].decidedMatches++;

            if (_result == 1) {
                _game.winner = getTeamSymbol(
                    _game.rounds[_round].matches[_match].team1
                );
                _game.secondPlace = getTeamSymbol(
                    _game.rounds[_round].matches[_match].team2
                );
            } else {
                _game.winner = getTeamSymbol(
                    _game.rounds[_round].matches[_match].team2
                );
                _game.secondPlace = getTeamSymbol(
                    _game.rounds[_round].matches[_match].team1
                );
            }

            if (!_game.hasThirdPlace) {
                _game.currentRound++;
                _game.rounds[2].end = _lastTimeStamp;
                _game.end = _lastTimeStamp;

                // removeGame(_gameIndex);

                IBracketTicket8(gamesHub.helpers(keccak256(bytes(ticketName))))
                    .setGamePot(_gameIndex);
            }
        }
    }

    /**
     * @dev Function to set the third place match
     * @param _gameIndex The index of the game
     * @param _result The result of the match
     */
    function setThirdPlaceMatch(
        uint256 _lastTimeStamp,
        uint256 _gameIndex,
        uint256 _scoreTeam1,
        uint256 _scoreTeam2,
        uint8 _result
    ) external onlyGameContract {
        Game storage _game = games[_gameIndex];
        require(_game.activated, "BRK-06");
        require(_game.hasThirdPlace, "BRK-11");
        require(_result == 1 || _result == 2, "BRK-05");

        Match storage _matchToSet = _game.thirdPlaceMatch;
        require(_matchToSet.result == 0, "BRK-12");

        _matchToSet.result = _result;
        _matchToSet.scoreTeam1 = _scoreTeam1;
        _matchToSet.scoreTeam2 = _scoreTeam2;

        _game.thirdPlace = getTeamSymbol(
            _result == 1
                ? _game.thirdPlaceMatch.team1
                : _game.thirdPlaceMatch.team2
        );

        if (_game.rounds[2].decidedMatches == 1) {
            _game.currentRound++;
            _game.rounds[2].end = _lastTimeStamp;
            _game.end = _lastTimeStamp;

            // removeGame(_gameIndex);

            IBracketTicket8(gamesHub.helpers(keccak256(bytes(ticketName))))
                .setGamePot(_gameIndex);
        }
        _game.rounds[2].decidedMatches++;
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
     * @return brackets The array of team IDs
     */
    function getFinalResult(
        uint256 gameIndex
    ) public view gameOutOfIndex(gameIndex) returns (uint256[8] memory) {
        uint256[8] memory brackets;

        brackets[0] = games[gameIndex].rounds[0].matches[0].result == 0
            ? 0
            : games[gameIndex].rounds[0].matches[0].result == 1
            ? games[gameIndex].rounds[0].matches[0].team1
            : games[gameIndex].rounds[0].matches[0].team2;
        brackets[1] = games[gameIndex].rounds[0].matches[1].result == 0
            ? 0
            : games[gameIndex].rounds[0].matches[1].result == 1
            ? games[gameIndex].rounds[0].matches[1].team1
            : games[gameIndex].rounds[0].matches[1].team2;
        brackets[2] = games[gameIndex].rounds[0].matches[2].result == 0
            ? 0
            : games[gameIndex].rounds[0].matches[2].result == 1
            ? games[gameIndex].rounds[0].matches[2].team1
            : games[gameIndex].rounds[0].matches[2].team2;
        brackets[3] = games[gameIndex].rounds[0].matches[3].result == 0
            ? 0
            : games[gameIndex].rounds[0].matches[3].result == 1
            ? games[gameIndex].rounds[0].matches[3].team1
            : games[gameIndex].rounds[0].matches[3].team2;
        brackets[4] = games[gameIndex].rounds[1].matches[0].result == 0
            ? 0
            : games[gameIndex].rounds[1].matches[0].result == 1
            ? games[gameIndex].rounds[1].matches[0].team1
            : games[gameIndex].rounds[1].matches[0].team2;
        brackets[5] = games[gameIndex].rounds[1].matches[1].result == 0
            ? 0
            : games[gameIndex].rounds[1].matches[1].result == 1
            ? games[gameIndex].rounds[1].matches[1].team1
            : games[gameIndex].rounds[1].matches[1].team2;
        brackets[6] = games[gameIndex].rounds[2].matches[0].result == 0
            ? 0
            : games[gameIndex].rounds[2].matches[0].result == 1
            ? games[gameIndex].rounds[2].matches[0].team1
            : games[gameIndex].rounds[2].matches[0].team2;
        brackets[7] = games[gameIndex].thirdPlaceMatch.result == 0
            ? 0
            : games[gameIndex].thirdPlaceMatch.result == 1
            ? games[gameIndex].thirdPlaceMatch.team1
            : games[gameIndex].thirdPlaceMatch.team2;

        return brackets;
    }

    /**
     * @dev Status of the game. 0 = inactive, 1 ~ 3 = actual round, 4 = finished
     * @param gameIndex The index of the game
     * @return status The status of the game
     */
    function getGameStatus(
        uint256 gameIndex
    ) public view gameOutOfIndex(gameIndex) returns (uint8 status) {
        if (!games[gameIndex].activated) {
            return 0;
        } else {
            return games[gameIndex].currentRound + 1;
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
     * @param _symbols The array of symbols (ABI-encoded string[8])
     */
    function getTeamsIds(
        bytes memory _symbols
    ) public view returns (uint256[8] memory) {
        uint256[8] memory _teams;
        string[8] memory _symbolsArray = abi.decode(_symbols, (string[8]));
        for (uint8 i = 0; i < 8; i++) {
            _teams[i] = getTeamId(_symbolsArray[i]);
        }
        return _teams;
    }

    /**
     * @dev Function to get the team symbol of an array of indexes
     * @param _teams The array of team indexes (ABI-encoded uint256[8])
     */
    function getTeamsSymbols(
        bytes memory _teams
    ) public view returns (string[8] memory) {
        string[8] memory _symbols;
        uint256[8] memory _teamsArray = abi.decode(_teams, (uint256[8]));
        for (uint8 i = 0; i < 8; i++) {
            _symbols[i] = getTeamSymbol(_teamsArray[i]);
        }
        return _symbols;
    }

    /**
     * @dev Function to get the data for a round of a game
     * If the game has a third place match, the third place match will be the second match of the last round
     * @param gameIndex The index of the game
     * @param round The index of the round
     * @return roundData The ABI encoded data for the round
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
    ) public view gameOutOfIndex(gameIndex) returns (bytes memory) {
        if (round > 2) return abi.encodePacked("");
        uint256[8] memory _teamsIds;
        uint256[8] memory _scores;
        uint8[4] memory _results;

        if (round == 0) {
            _teamsIds = games[gameIndex].teams;

            _scores = [
                games[gameIndex].rounds[0].matches[0].scoreTeam1,
                games[gameIndex].rounds[0].matches[0].scoreTeam2,
                games[gameIndex].rounds[0].matches[1].scoreTeam1,
                games[gameIndex].rounds[0].matches[1].scoreTeam2,
                games[gameIndex].rounds[0].matches[2].scoreTeam1,
                games[gameIndex].rounds[0].matches[2].scoreTeam2,
                games[gameIndex].rounds[0].matches[3].scoreTeam1,
                games[gameIndex].rounds[0].matches[3].scoreTeam2
            ];

            _results = [
                games[gameIndex].rounds[round].matches[0].result,
                games[gameIndex].rounds[round].matches[1].result,
                games[gameIndex].rounds[round].matches[2].result,
                games[gameIndex].rounds[round].matches[3].result
            ];
        } else if (round == 1) {
            _teamsIds[0] = games[gameIndex].rounds[1].matches[0].team1;
            _teamsIds[1] = games[gameIndex].rounds[1].matches[0].team2;
            _teamsIds[2] = games[gameIndex].rounds[1].matches[1].team1;
            _teamsIds[3] = games[gameIndex].rounds[1].matches[1].team2;

            _scores[0] = games[gameIndex].rounds[1].matches[0].scoreTeam1;
            _scores[1] = games[gameIndex].rounds[1].matches[0].scoreTeam2;
            _scores[2] = games[gameIndex].rounds[1].matches[1].scoreTeam1;
            _scores[3] = games[gameIndex].rounds[1].matches[1].scoreTeam2;

            _results[0] = games[gameIndex].rounds[1].matches[0].result;
            _results[1] = games[gameIndex].rounds[1].matches[1].result;
        } else if (round == 2) {
            _teamsIds[0] = games[gameIndex].rounds[2].matches[0].team1;
            _teamsIds[1] = games[gameIndex].rounds[2].matches[0].team2;

            _scores[0] = games[gameIndex].rounds[2].matches[0].scoreTeam1;
            _scores[1] = games[gameIndex].rounds[2].matches[0].scoreTeam2;

            _results[0] = games[gameIndex].rounds[2].matches[0].result;

            if (games[gameIndex].hasThirdPlace) {
                _teamsIds[2] = games[gameIndex].thirdPlaceMatch.team1;
                _teamsIds[3] = games[gameIndex].thirdPlaceMatch.team2;

                _results[1] = games[gameIndex].thirdPlaceMatch.result;
            }
        }

        return (
            abi.encode(
                getTeamsSymbols(abi.encode(_teamsIds)),
                _results,
                _scores,
                games[gameIndex].rounds[round].start,
                games[gameIndex].rounds[round].end
            )
        );
    }

    /**
     * @dev Function to get the data for a game
     * @param gameIndex The index of the game
     * @return gameData The ABI encoded data for the game
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
        uint256 gameIndex
    ) public view gameOutOfIndex(gameIndex) returns (bytes memory) {
        return (
            abi.encode(
                getRoundFullData(gameIndex, 0),
                getRoundFullData(gameIndex, 1),
                getRoundFullData(gameIndex, 2),
                games[gameIndex].winner,
                games[gameIndex].secondPlace,
                games[gameIndex].thirdPlace,
                games[gameIndex].currentRound,
                games[gameIndex].start,
                games[gameIndex].end,
                games[gameIndex].activated
            )
        );
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
        require(round <= 2, "BRK-13");
        uint256[8] memory _teams;
        uint8[4] memory _results;

        if (round == 0) {
            _teams = games[gameIndex].teams;
            _results = [
                games[gameIndex].rounds[round].matches[0].result,
                games[gameIndex].rounds[round].matches[1].result,
                games[gameIndex].rounds[round].matches[2].result,
                games[gameIndex].rounds[round].matches[3].result
            ];
        } else if (round == 1) {
            _teams[0] = games[gameIndex].rounds[1].matches[0].team1;
            _teams[1] = games[gameIndex].rounds[1].matches[0].team2;
            _teams[2] = games[gameIndex].rounds[1].matches[1].team1;
            _teams[3] = games[gameIndex].rounds[1].matches[1].team2;

            _results[0] = games[gameIndex].rounds[1].matches[0].result;
            _results[1] = games[gameIndex].rounds[1].matches[1].result;
        } else if (round == 2) {
            _teams[0] = games[gameIndex].rounds[2].matches[0].team1;
            _teams[1] = games[gameIndex].rounds[2].matches[0].team2;

            _results[0] = games[gameIndex].rounds[2].matches[0].result;

            if (games[gameIndex].hasThirdPlace) {
                _teams[2] = games[gameIndex].thirdPlaceMatch.team1;
                _teams[3] = games[gameIndex].thirdPlaceMatch.team2;

                _results[1] = games[gameIndex].thirdPlaceMatch.result;
            }
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

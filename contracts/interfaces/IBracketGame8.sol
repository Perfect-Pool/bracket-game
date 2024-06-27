// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IBracketGame8 {
    /** FUNCTIONS **/
    function setPaused(bool _paused) external;

    function setCreateNewGames(bool _active) external;

    function setMinConcurrentGames(uint8 _minActiveGames) external;

    function setRoundDuration(uint256 _roundDuration) external;

    function createGame(
        uint256 _lastTimeStamp,
        bytes calldata _dataNewGame
    ) external returns (uint256);

    function activateGame(uint256 _gameIndex) external;

    function setMatchResult(
        uint256 _lastTimeStamp,
        uint256 _gameIndex,
        uint8 _match,
        uint256 _scoreTeam1,
        uint256 _scoreTeam2,
        uint8 _result
    ) external;

    function setThirdPlaceMatch(
        uint256 _lastTimeStamp,
        uint256 _gameIndex,
        uint256 _scoreTeam1,
        uint256 _scoreTeam2,
        uint8 _result
    ) external;

    function changeDaysToClaimPrize(uint256 _daysToClaimPrize) external;

    function getFinalResult(
        uint256 gameIndex
    ) external view returns (uint256[8] memory);

    function getGameStatus(
        uint256 gameIndex
    ) external view returns (uint8 status);

    function getTeamSymbol(
        uint256 teamIndex
    ) external view returns (string memory);

    function getTeamId(string memory _symbol) external view returns (uint256);

    function getTeamsIds(
        bytes memory _symbols
    ) external view returns (uint256[8] memory);

    function getTeamsSymbols(
        bytes memory _teams
    ) external view returns (string[8] memory);

    function getRoundFullData(
        uint256 gameIndex,
        uint8 round
    ) external view returns (bytes memory);

    function getGameFullData(
        uint256 gameIndex
    ) external view returns (bytes memory);

    function getRoundData(
        uint256 gameIndex,
        uint8 round
    ) external view returns (uint256[8] memory, uint8[4] memory);

    function getActiveGames() external view returns (uint256[] memory);

    function isGameActivated(uint256 gameIndex) external view returns (bool);

    /** STATE VARIABLES **/
    function minActiveGames() external view returns (uint256);

    function roundDuration() external view returns (uint256);

    function daysToClaimPrize() external view returns (uint256);

    function totalTeams() external view returns (uint256);

    function totalGames() external view returns (uint256);

    function paused() external view returns (bool);

    function createNewGames() external view returns (bool);

    function executionAddress() external view returns (address);

    function proxyName() external view returns (string memory);
}

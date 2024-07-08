// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOlympicsTicket {
    function setGamePot(uint256 _gameId) external;

    function getBetData(
        uint256 _tokenId
    ) external view returns (uint8[24] memory);

    function getGameId(uint256 _tokenId) external view returns (uint256);

    function betValidator(
        uint256 _tokenId
    ) external view returns (uint8[24] memory);

    function getTeamSymbols(
        uint256 _tokenId
    ) external view returns (string[24] memory);

    function betWinQty(uint256 _tokenId) external view returns (uint8);

    function amountPrizeClaimed(
        uint256 _tokenId
    ) external view returns (uint256, uint256);

    function getPotStatus(uint256 _gameId) external view returns (bool);
}

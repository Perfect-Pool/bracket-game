// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBracketTicket8 {
    function getBetData(
        uint256 _tokenId
    ) external view returns (uint256[8] memory);

    function betValidator(
        uint256 _tokenId
    ) external view returns (uint8[8] memory);

    function getGameId(
        uint256 tokenIndex
    ) external view returns (uint256 gameId);

    function getTeamSymbols(
        uint256 _tokenId
    ) external view returns (string[8] memory);

    function setGamePot(uint256 _gameId) external;

    function amountPrizeClaimed(
        uint256 _tokenId
    ) external view returns (uint256 amountToClaim, uint256 amountClaimed);
}

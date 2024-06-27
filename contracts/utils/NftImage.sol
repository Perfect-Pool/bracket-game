// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../libraries/Base64.sol";
import "../libraries/BuildImage.sol";
import "../interfaces/IBracketGame8.sol";
import "../interfaces/IGamesHub.sol";
import "../interfaces/IBracketTicket8.sol";

contract NftImage is Ownable {
    using Strings for uint16;
    using Strings for uint256;

    IGamesHub public gamesHub;

    constructor(address _gamesHub) {
        gamesHub = IGamesHub(_gamesHub);
    }

    function changeGamesHub(address _gamesHub) public onlyOwner {
        gamesHub = IGamesHub(_gamesHub);
    }

    function buildImage(
        uint256 _gameId,
        uint256 _tokenId,
        uint256 prize,
        bool claimed
    ) public view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                BuildImage.fullSvgImage(
                                    IBracketGame8(
                                        gamesHub.games(
                                            keccak256("BRACKETS8_PROXY")
                                        )
                                    ).getGameStatus(_gameId),
                                    IBracketTicket8(
                                        gamesHub.helpers(
                                            keccak256("BRACKET_TICKET8")
                                        )
                                    ).betValidator(_tokenId),
                                    IBracketTicket8(
                                        gamesHub.helpers(
                                            keccak256("BRACKET_TICKET8")
                                        )
                                    ).getTeamSymbols(_tokenId),
                                    prize.toString(),
                                    _tokenId.toString(),
                                    claimed
                                )
                            )
                        )
                    )
                )
            );
    }
}

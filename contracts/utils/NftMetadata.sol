// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../libraries/Base64.sol";
import "../interfaces/IBracketGame8.sol";
import "../interfaces/IGamesHub.sol";
import "../interfaces/IBracketTicket8.sol";

interface INftImage {
    function buildImage(
        uint256 _gameId,
        uint256 _tokenId,
        uint256 prize,
        bool claimed
    ) external view returns (string memory);
}

contract NftMetadata is Ownable {
    using Strings for uint8;
    using Strings for uint256;

    IGamesHub public gamesHub;

    constructor(address _gamesHub) {
        gamesHub = IGamesHub(_gamesHub);
    }

    function changeGamesHub(address _gamesHub) public onlyOwner {
        gamesHub = IGamesHub(_gamesHub);
    }

    function gameStatus(
        uint256 _gameId,
        uint256 _tokenId
    ) private view returns (string memory) {
        uint8 status = IBracketGame8(
            gamesHub.games(keccak256("BRACKETS8_PROXY"))
        ).getGameStatus(_gameId);
        if (status == 0) {
            return "Open";
        } else if (status == 4) {
            (uint256 prize, ) = IBracketTicket8(
                gamesHub.helpers(keccak256("BRACKET_TICKET8"))
            ).amountPrizeClaimed(_tokenId);
            if (prize == 0) return "Loser";
            else return "High Score Winner";
        } else {
            return string(abi.encodePacked("Round ", status.toString()));
        }
    }

    function buildMetadata(
        uint256 _gameId,
        uint256 _tokenId
    ) public view returns (string memory) {
        (uint256 prize, uint256 amountClaimed) = IBracketTicket8(
            gamesHub.helpers(keccak256("BRACKET_TICKET8"))
        ).amountPrizeClaimed(_tokenId);

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"Onchain Olympics Phase 2 NFT #',
                                _tokenId.toString(),
                                '","description":"Onchain Olympics Phase 2 Game NFT from PerfectPool.","image":"',
                                INftImage(
                                    gamesHub.helpers(keccak256("NFT_IMAGE8"))
                                ).buildImage(
                                        _gameId,
                                        _tokenId,
                                        prize,
                                        prize == amountClaimed && prize > 0
                                    ),
                                '","attributes":[{"trait_type":"Game Status:","value":"',
                                gameStatus(_gameId, _tokenId),
                                '"}]}'
                            )
                        )
                    )
                )
            );
    }
}

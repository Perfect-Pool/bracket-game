// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../libraries/Base64.sol";
import "../interfaces/IOlympics.sol";
import "../interfaces/IGamesHub.sol";
import "../interfaces/IOlympicsTicket.sol";

interface INftImagePhaseOne {
    function buildImage(
        uint256 _tokenId,
        uint256 prize,
        bool claimed
    ) external view returns (string memory);
}

contract NftMetadataPhaseOne is Ownable {
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
        uint8 _status,
        uint256 _tokenId
    ) private view returns (string memory) {
        IOlympicsTicket ticketContract = IOlympicsTicket(
            gamesHub.helpers(keccak256("OLYMPICS_TICKET"))
        );
        if (_status == 0) {
            return "Open";
        } else if (_status == 2) {
            (uint256 prize, ) = ticketContract.amountPrizeClaimed(_tokenId);
            if (
                ticketContract.getPotStatus(ticketContract.getGameId(_tokenId))
            ) {
                if (prize == 0) return "Loser";
                else return "High Score Winner";
            } else return "Calculating Scores";
        } else {
            return "On Going";
        }
    }

    function buildMetadata(
        uint256 _gameId,
        uint256 _tokenId
    ) public view returns (string memory) {
        (uint256 prize, uint256 amountClaimed) = IOlympicsTicket(
            gamesHub.helpers(keccak256("OLYMPICS_TICKET"))
        ).amountPrizeClaimed(_tokenId);
        uint8 status = IOlympics(gamesHub.games(keccak256("OLYMPICS_PROXY")))
            .getGameStatus(_gameId);

        uint8 points = IOlympicsTicket(
            gamesHub.helpers(keccak256("OLYMPICS_TICKET"))
        ).betWinQty(_tokenId);

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"Onchain Olympics Phase 1 NFT #',
                                _tokenId.toString(),
                                '","description":"Onchain Olympics Phase 1 Game NFT from PerfectPool. Checkout the game on https://perfectpool.io/soccer/olympics-football/","image":"',
                                INftImagePhaseOne(
                                    gamesHub.helpers(
                                        keccak256("OLYMPICS_IMAGE")
                                    )
                                ).buildImage(
                                        _tokenId,
                                        prize,
                                        prize == amountClaimed && prize > 0
                                    ),
                                '","attributes":[{"trait_type":"Game Status:","value":"',
                                gameStatus(status, _tokenId),
                                '"},{"trait_type":"Points:","value":"',
                                points.toString(),
                                '"}]}'
                            )
                        )
                    )
                )
            );
    }
}

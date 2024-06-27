// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../libraries/Base64.sol";
import "../libraries/BuildImagePhaseOne.sol";
import "../interfaces/IOlympics.sol";
import "../interfaces/IGamesHub.sol";
import "../interfaces/IOlympicsTicket.sol";

contract NftImagePhaseOne is Ownable {
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
        uint256 _tokenId,
        uint256 prize,
        bool claimed
    ) public view returns (string memory) {
        IOlympicsTicket ticket = IOlympicsTicket(
            gamesHub.helpers(keccak256("OLYMPICS_TICKET"))
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                BuildImagePhaseOne.fullSvgImage(
                                    ticket.betValidator(_tokenId),
                                    ticket.getTeamSymbols(_tokenId),
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

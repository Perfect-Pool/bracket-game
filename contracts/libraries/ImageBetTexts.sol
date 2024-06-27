// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./Flags.sol";

library ImageBetTexts {
    using Strings for uint256;
    using Strings for uint8;

    function getColor(
        uint8 statusValidator
    ) external pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    statusValidator == 0 ? "5b5b5b" : statusValidator == 1
                        ? "498804"
                        : "F93939"
                )
            );
    }

    function smallRect(
        uint256 x,
        uint256 y,
        string memory color,
        uint8 matchNumber,
        string memory team
    ) external pure returns (string memory) {
        bytes memory part1 = abi.encodePacked(
            '<rect x="',
            x.toString(),
            '" y="',
            y.toString(),
            '" width="280" height="82" rx="10" fill="#',
            color,
            '" />'
        );
        x += 25;
        y += 37;

        bytes memory part2 = abi.encodePacked(
            '<text style="font-size:26px;fill:white;font-family:Arial;font-weight:600" x="',
            x.toString(),
            '" y="',
            y.toString(),
            '">Match ',
            matchNumber.toString(),
            "</text>"
        );
        y += 32;

        bytes memory part3 = abi.encodePacked(
            '<text style="font-size:16px;fill:white;font-family:Arial;font-weight:300" x="',
            x.toString(),
            '" y="',
            y.toString(),
            '">',
            team,
            "</text>"
        );

        x += 160;
        y -= 52;
        return
            string(
                abi.encodePacked(
                    string(part1),
                    string(part2),
                    string(part3),
                    '<image x="',
                    x.toString(),
                    '" y="',
                    y.toString(),
                    '" width="70" height="50" href="',
                    Flags.getFlag(keccak256(abi.encodePacked(team))),
                    '" />'
                )
            );
    }

    function bigRect(
        uint256 x,
        uint256 y,
        string memory color,
        bool gold,
        string memory team
    ) external pure returns (string memory) {
        bytes memory part1 = abi.encodePacked(
            '<rect x="',
            x.toString(),
            '" y="',
            y.toString(),
            '" width="574" height="82" rx="10" fill="#',
            color,
            '" />'
        );

        x += 25;
        y += 37;

        bytes memory part2 = abi.encodePacked(
            '<text style="font-size:26px;fill:white;font-family:Arial;font-weight:600" x="',
            x.toString(),
            '" y="',
            y.toString(),
            '">',
            gold ? "GOLD" : "BRONZE",
            " MEDAL MATCH</text>"
        );
        y += 32;

        bytes memory part3 = abi.encodePacked(
            '<text style="font-size:18px;fill:white;font-family:Arial;font-weight:300" x="',
            x.toString(),
            '" y="',
            y.toString(),
            '">',
            team,
            "</text>"
        );

        x += 454;
        y -= 53;

        return
            string(
                abi.encodePacked(
                    string(part1),
                    string(part2),
                    string(part3),
                    '<image x="',
                    x.toString(),
                    '" y="',
                    y.toString(),
                    '" width="70" height="50" href="',
                    Flags.getFlag(keccak256(abi.encodePacked(team))),
                    '" />'
                )
            );
    }
}

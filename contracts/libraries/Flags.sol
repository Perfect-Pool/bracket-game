// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FlagsImage.sol";
import "./FlagsImage2.sol";

library Flags {
    function getFlag(bytes32 name) public pure returns (bytes memory) {
        string memory prefix = "data:image/jpeg;base64,";
        if (keccak256("Uzbekistan") == name) {
            return abi.encodePacked(prefix, FlagsImage2.UZBEKISTAN());
        } else if (keccak256("Spain") == name) {
            return abi.encodePacked(prefix, FlagsImage2.SPAIN());
        } else if (keccak256("Argentina") == name) {
            return abi.encodePacked(prefix, FlagsImage2.ARGENTINA());
        } else if (keccak256("Morocco") == name) {
            return abi.encodePacked(prefix, FlagsImage2.MOROCCO());
        } else if (keccak256("Guinea") == name) {
            return abi.encodePacked(prefix, FlagsImage2.GUINEA());
        } else if (keccak256("New Zealand") == name) {
            return abi.encodePacked(prefix, FlagsImage2.NEW_ZEALAND());
        } else if (keccak256("Egypt") == name) {
            return abi.encodePacked(prefix, FlagsImage2.EGYPT());
        } else if (keccak256("Dominican Republic") == name) {
            return abi.encodePacked(prefix, FlagsImage2.DOMINICAN_REPUBLIC());
        } else if (keccak256("Iraq") == name) {
            return abi.encodePacked(prefix, FlagsImage.IRAQ());
        } else if (keccak256("Ukraine") == name) {
            return abi.encodePacked(prefix, FlagsImage.UKRAINE());
        } else if (keccak256("Japan") == name) {
            return abi.encodePacked(prefix, FlagsImage.JAPAN());
        } else if (keccak256("Paraguay") == name) {
            return abi.encodePacked(prefix, FlagsImage.PARAGUAY());
        } else if (keccak256("Mali") == name) {
            return abi.encodePacked(prefix, FlagsImage.MALI());
        } else if (keccak256("Israel") == name) {
            return abi.encodePacked(prefix, FlagsImage.ISRAEL());
        } else if (keccak256("France") == name) {
            return abi.encodePacked(prefix, FlagsImage.FRANCE());
        } else if (keccak256("USA") == name) {
            return abi.encodePacked(prefix, FlagsImage.USA());
        }

        return
        abi.encodePacked(prefix, "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");
    }
}

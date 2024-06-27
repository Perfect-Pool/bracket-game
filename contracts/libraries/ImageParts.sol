// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ImageBetTexts.sol";

library ImageParts {
    function buildBetsRound1(
        string[4] memory teams,
        uint8[4] memory betValidator
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    ImageBetTexts.smallRect(
                        62,
                        225,
                        ImageBetTexts.getColor(betValidator[0]),
                        1,
                        teams[0]
                    ),
                    ImageBetTexts.smallRect(
                        62,
                        320,
                        ImageBetTexts.getColor(betValidator[1]),
                        2,
                        teams[1]
                    ),
                    ImageBetTexts.smallRect(
                        356,
                        225,
                        ImageBetTexts.getColor(betValidator[2]),
                        3,
                        teams[2]
                    ),
                    ImageBetTexts.smallRect(
                        356,
                        320,
                        ImageBetTexts.getColor(betValidator[3]),
                        4,
                        teams[3]
                    )
                )
            );
    }

    function buildBetsRound2(
        string[2] memory teams,
        uint8[2] memory betValidator
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    ImageBetTexts.smallRect(
                        62,
                        460,
                        ImageBetTexts.getColor(betValidator[0]),
                        4,
                        teams[0]
                    ),
                    ImageBetTexts.smallRect(
                        356,
                        460,
                        ImageBetTexts.getColor(betValidator[1]),
                        5,
                        teams[1]
                    )
                )
            );
    }

    function buildBetsRound3(
        string[2] memory teams,
        uint8[2] memory betValidator
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    ImageBetTexts.bigRect(
                        62,
                        595,
                        ImageBetTexts.getColor(betValidator[0]),
                        false,
                        teams[0]
                    ),
                    ImageBetTexts.bigRect(
                        62,
                        727,
                        ImageBetTexts.getColor(betValidator[1]),
                        true,
                        teams[1]
                    )
                )
            );
    }

    function buildBets(
        string[8] memory teams,
        uint8[8] memory betValidator
    ) external pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    buildBetsRound1(
                        [teams[0], teams[1], teams[2], teams[3]],
                        [
                            betValidator[0],
                            betValidator[1],
                            betValidator[2],
                            betValidator[3]
                        ]
                    ),
                    buildBetsRound2(
                        [teams[4], teams[5]],
                        [betValidator[4], betValidator[5]]
                    ),
                    buildBetsRound3(
                        [teams[7], teams[6]],
                        [betValidator[7], betValidator[6]]
                    )
                )
            );
    }

    function formatPrize(
        string memory prize
    ) public pure returns (string memory) {
        uint256 len = bytes(prize).length;
        string memory normalizedPrize = len < 6
            ? appendZeros(prize, 6 - len)
            : prize;

        string memory integerPart = len > 6
            ? substring(normalizedPrize, 0, len - 6)
            : "0";
        string memory decimalPart = substring(
            normalizedPrize,
            len > 6 ? len - 6 : 0,
            2
        );

        return string(abi.encodePacked(integerPart, ".", decimalPart));
    }

    function substring(
        string memory str,
        uint startIndex,
        uint length
    ) private pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(length);

        for (uint i = 0; i < length; i++) {
            result[i] = strBytes[startIndex + i];
        }

        return string(result);
    }

    function appendZeros(
        string memory str,
        uint numZeros
    ) private pure returns (string memory) {
        bytes memory zeros = new bytes(numZeros);
        for (uint i = 0; i < numZeros; i++) {
            zeros[i] = "0";
        }
        return string(abi.encodePacked(zeros, str));
    }

    function idAndPrize(
        string memory id,
        string memory prize,
        bool claimed
    ) external pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<text style="font-size:11px;fill:white;font-family:Arial;font-weight:910" x="635" y="215" text-anchor="end" dominant-baseline="end">NFT ID: ',
                    id,
                    '</text><rect x="389" y="51" width="247" height="91" rx="15" fill="#D8A200" /><text style="font-size:23px;fill:white;font-family:Arial;font-weight:600" x="512.4" y="100" text-anchor="middle" dominant-baseline="middle">',
                    (
                        claimed
                            ? "Claimed"
                            : string(abi.encodePacked("Prize: $", prize))
                    ),
                    "</text>"
                )
            );
    }

    function svgPartUp() external pure returns (string memory) {
        return
            '62 69.492zm53.857 15.738h-15.515V53.754h3.878v27.843h11.637v3.631zm8.663 0l8.727-31.475h3.878l-8.484 31.474h-4.121zm-9.309-22.178c0-1.324.113-2.68.339-4.067.226-1.389.614-3.132 1.164-5.23h3.83c-.582 2.163-.986 3.922-1.212 5.278a24.414 24.414 0 00-.34 4.019c0 3.035.825 5.375 2.473 7.021 1.681 1.614 4.04 2.421 7.079 2.421h1.163v3.632h-1.163c-2.812 0-5.22-.517-7.224-1.55-1.972-1.032-3.491-2.517-4.558-4.454-1.034-1.97-1.551-4.326-1.551-7.07zm26.512 22.178V53.754h2.085c2.521 0 4.784.436 6.788 1.307 2.036.872 3.717 2.099 5.042 3.68 1.326 1.55 2.182 3.406 2.57 5.569h-2.521c.42-2.163 1.277-4.019 2.569-5.569 1.326-1.581 2.99-2.808 4.994-3.68 2.037-.871 4.315-1.307 6.837-1.307h2.084v31.474h-3.878v-28.18l1.115.58h-1.261c-1.875 0-3.507.42-4.897 1.26-1.39.807-2.472 1.969-3.248 3.486-.744 1.517-1.115 3.293-1.115 5.327v7.844h-3.879V67.7c0-2.034-.388-3.81-1.164-5.327-.743-1.517-1.81-2.68-3.2-3.486-1.389-.84-3.022-1.26-4.896-1.26h-1.261l1.115-.58v28.181h-3.879zm37.736 0V53.754h9.212c2.263 0 4.235.403 5.915 1.21 1.714.808 3.039 1.937 3.976 3.39.97 1.42 1.455 3.1 1.455 5.036 0 1.84-.307 3.373-.922 4.6-.581 1.227-1.373 2.244-2.375 3.05a17.254 17.254 0 01-3.297 2.083 376.492 376.492 0 01-3.54 1.646 24.263 24.263 0 00-3.248 1.84 7.837 7.837 0 00-2.424 2.615c-.582 1.033-.873 2.34-.873 3.922v2.082h-3.879zm3.879-10.411a12.856 12.856 0 012.521-1.889 29.244 29.244 0 012.812-1.453c.938-.452 1.843-.903 2.716-1.355a13.01 13.01 0 002.375-1.501 6.05 6.05 0 001.649-2.083c.42-.807.63-1.791.63-2.953 0-1.905-.663-3.406-1.988-4.504-1.293-1.13-3.038-1.694-5.236-1.694h-5.479v17.432zm21.154-12.493h3.781v22.903h-3.781V62.326zm1.89-3.826c-.711 0-1.309-.226-1.793-.678-.453-.452-.679-1.033-.679-1.743 0-.71.226-1.291.679-1.743.484-.452 1.082-.678 1.793-.678.744 0 1.342.226 1.794.678.453.452.679 1.033.679 1.743 0 .71-.226 1.291-.679 1.743-.452.452-1.05.678-1.794.678zm35.401 13.558h4.024c-.388 2.583-1.341 4.907-2.861 6.973-1.519 2.034-3.426 3.648-5.721 4.843-2.295 1.194-4.816 1.791-7.563 1.791-2.263 0-4.38-.403-6.351-1.21a16.882 16.882 0 01-5.237-3.487 16.44 16.44 0 01-3.491-5.133c-.84-1.969-1.26-4.083-1.26-6.343s.42-4.358 1.26-6.295a16.287 16.287 0 013.491-5.18 16.198 16.198 0 015.237-3.439c1.971-.84 4.088-1.259 6.351-1.259 2.586 0 4.978.549 7.176 1.647 2.23 1.065 4.104 2.534 5.624 4.406a15.541 15.541 0 013.103 6.392h-4.073a12.129 12.129 0 00-2.521-4.552 11.866 11.866 0 00-4.121-3.099c-1.584-.775-3.313-1.162-5.188-1.162-1.713 0-3.313.323-4.8.968a12.22 12.22 0 00-3.927 2.712 12.444 12.444 0 00-2.667 3.97c-.646 1.518-.97 3.148-.97 4.891 0 1.743.324 3.374.97 4.89a13.028 13.028 0 002.667 4.02 12.607 12.607 0 003.927 2.663c1.487.646 3.087.969 4.8.969 2.004 0 3.846-.436 5.527-1.308a12.67 12.67 0 004.267-3.583 12.385 12.385 0 002.327-5.085zm17.748 13.607c-1.842 0-3.555-.371-5.139-1.114a9.442 9.442 0 01-3.733-3.292c-.938-1.42-1.406-3.164-1.406-5.23h3.879c0 1.162.274 2.195.824 3.1a5.798 5.798 0 002.278 2.13c.97.516 2.069.775 3.297.775 1.746 0 3.168-.469 4.267-1.405 1.099-.968 1.648-2.211 1.648-3.728 0-1.098-.274-2.002-.824-2.712-.549-.71-1.293-1.307-2.23-1.791a18.38 18.38 0 00-3.006-1.356 71.022 71.022 0 01-3.297-1.356 16.636 16.636 0 01-3.054-1.743 7.792 7.792 0 01-2.182-2.518c-.55-1.033-.824-2.325-.824-3.874 0-1.517.404-2.89 1.212-4.116.84-1.259 1.955-2.26 3.345-3.002 1.39-.743 2.925-1.114 4.606-1.114 1.875 0 3.523.388 4.945 1.162a8.266 8.266 0 013.346 3.148c.808 1.323 1.212 2.873 1.212 4.648h-3.879c0-1.581-.533-2.857-1.6-3.825-1.034-1-2.376-1.501-4.024-1.501-.937 0-1.81.21-2.618.63a4.904 4.904 0 00-1.891 1.646c-.453.678-.679 1.452-.679 2.324 0 1.065.275 1.937.824 2.615.55.678 1.277 1.275 2.182 1.791.938.485 1.956.937 3.055 1.356 1.099.388 2.198.823 3.297 1.308a13.963 13.963 0 013.006 1.791 7.907 7.907 0 012.23 2.615c.549 1.033.824 2.324.824 3.874 0 1.678-.436 3.18-1.309 4.503-.84 1.324-2.004 2.373-3.491 3.147-1.487.743-3.184 1.114-5.091 1.114zM63.6 123.633V92.159h16.436v3.631H65.2l2.279-2.179v20.628l-2.812 4.697c0-2.808.533-5.229 1.6-7.263 1.099-2.034 2.65-3.6 4.654-4.697 2.004-1.098 4.38-1.647 7.127-1.647h.727v3.632h-.727c-3.232 0-5.802.904-7.709 2.712-1.907 1.775-2.86 4.196-2.86 7.263v4.697H63.6zm23.919-15.737c0 1.743.323 3.373.97 4.89a13.036 13.036 0 002.666 4.02 12.635 12.635 0 003.927 2.663c1.487.645 3.087.968 4.8.968 1.713 0 3.313-.323 4.8-.968a12.629 12.629 0 003.927-2.663 13.033 13.033 0 002.667-4.02c.646-1.517.97-3.147.97-4.89 0-1.743-.324-3.374-.97-4.891a12.44 12.44 0 00-2.667-3.97 12.22 12.22 0 00-3.927-2.712c-1.487-.646-3.087-.968-4.8-.968-1.713 0-3.313.322-4.8.968a12.225 12.225 0 00-3.927 2.712 12.442 12.442 0 00-2.666 3.97c-.647 1.517-.97 3.148-.97 4.891zm-3.976 0c0-2.26.42-4.358 1.26-6.295a16.279 16.279 0 013.492-5.181 16.2 16.2 0 015.236-3.438c1.971-.84 4.089-1.26 6.351-1.26 2.263 0 4.38.42 6.352 1.26a15.652 15.652 0 015.187 3.438 15.898 15.898 0 013.54 5.181c.84 1.937 1.26 4.035 1.26 6.295s-.42 4.374-1.26 6.343a16.043 16.043 0 01-3.54 5.133 16.29 16.29 0 01-5.187 3.486c-1.972.807-4.089 1.211-6.352 1.211-2.262 0-4.38-.404-6.351-1.211a16.875 16.875 0 01-5.236-3.486 16.432 16.432 0 01-3.491-5.133c-.84-1.969-1.26-4.083-1.26-6.343zm40.718 0c0 1.743.323 3.373.969 4.89a13.051 13.051 0 002.667 4.02 12.629 12.629 0 003.927 2.663c1.487.645 3.087.968 4.8.968 1.713 0 3.313-.323 4.8-.968a12.629 12.629 0 003.927-2.663 13.051 13.051 0 002.667-4.02c.646-1.517.969-3.147.969-4.89 0-1.743-.323-3.374-.969-4.891a12.456 12.456 0 00-2.667-3.97 12.22 12.22 0 00-3.927-2.712c-1.487-.646-3.087-.968-4.8-.968-1.713 0-3.313.322-4.8.968a12.22 12.22 0 00-3.927 2.712 12.456 12.456 0 00-2.667 3.97c-.646 1.517-.969 3.148-.969 4.891zm-3.976 0c0-2.26.42-4.358 1.26-6.295a16.287 16.287 0 013.491-5.181 16.198 16.198 0 015.237-3.438c1.971-.84 4.088-1.26 6.351-1.26s4.38.42 6.351 1.26a15.656 15.656 0 015.188 3.438 15.895 15.895 0 013.539 5.181c.841 1.937 1.261 4.035 1.261 6.295s-.42 4.374-1.261 6.343a16.04 16.04 0 01-3.539 5.133 16.294 16.294 0 01-5.188 3.486c-1.971.807-4.088 1.211-6.351 1.211s-4.38-.404-6.351-1.211a16.874 16.874 0 01-5.237-3.486 16.441 16.441 0 01-3.491-5.133c-.84-1.969-1.26-4.083-1.26-6.343zm41.646 15.737V93.95l1.454 1.404c-1.713 0-3.426.065-5.139.194-1.681.13-3.135.275-4.364.436v-3.632a85.307 85.307 0 014.558-.435 75.771 75.771 0 0110.812 0c1.81.129 3.345.274 4.606.435v3.632c-.808-.097-1.73-.194-2.764-.29a87.434 87.434 0 00-3.297-.243 60.372 60.372 0 00-3.442-.096l1.454-1.405v29.683h-3.878zm20.65-27.843v3.535c0 1.065.194 1.985.581 2.76a4.369 4.369 0 001.794 1.792c.776.419 1.681.629 2.715.629 1.326 0 2.441-.419 3.346-1.259.905-.839 1.357-1.856 1.357-3.05 0-1.324-.468-2.39-1.406-3.196-.937-.807-2.198-1.21-3.781-1.21h-4.606zm-3.879 27.843V92.159h8.485c1.777 0 3.329.322 4.654.968 1.358.614 2.408 1.485 3.151 2.615.776 1.13 1.164 2.437 1.164 3.922 0 1.582-.404 2.986-1.212 4.213-.776 1.194-1.891 2.114-3.345 2.76l-.049-1.114c1.746.323 3.232.888 4.461 1.695 1.26.775 2.23 1.759 2.909 2.954.678 1.162 1.018 2.469 1.018 3.922 0 1.84-.469 3.486-1.406 4.939-.938 1.42-2.23 2.55-3.879 3.389-1.648.807-3.539 1.211-5.673 1.211h-10.278zm3.879-3.632h6.399c1.358-.032 2.554-.29 3.588-.774 1.067-.517 1.891-1.211 2.473-2.083.614-.903.921-1.92.921-3.05 0-1.162-.307-2.147-.921-2.954-.582-.807-1.487-1.453-2.715-1.937-1.196-.516-2.748-.871-4.655-1.065-1.131-.129-2.117-.355-2.957-.678-.84-.323-1.552-.759-2.133-1.307v13.848zm22.483 3.632v-21.596c0-2.034.42-3.826 1.261-5.375a9.361 9.361 0 013.636-3.632c1.552-.871 3.329-1.307 5.333-1.307 2.037 0 3.814.436 5.334 1.307a9.026 9.026 0 013.587 3.632c.873 1.55 1.309 3.341 1.309 5.375v21.596h-3.878v-1.017c0-3.196-.97-5.762-2.909-7.699-1.907-1.937-4.687-2.905-8.34-2.905h-2.909v-3.632h1.94c4.04 0 7.256.759 9.648 2.276 2.424 1.485 3.927 3.519 4.509 6.101h-1.939v-14.72c0-1.291-.275-2.421-.824-3.39a5.942 5.942 0 00-2.279-2.276c-.938-.58-2.02-.871-3.249-.871-1.228 0-2.327.29-3.297.871a5.933 5.933 0 00-2.278 2.276c-.517.969-.776 2.099-.776 3.39v21.596h-3.879zm42.798 0h-15.515V92.159h3.878V120h11.637v3.632zm20.738 0h-15.515V92.159h3.879V120H268.6v3.632zM67.32 NaN" fill="#fff"/>';
    }
}

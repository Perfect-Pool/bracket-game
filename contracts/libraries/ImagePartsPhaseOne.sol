// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ImageBetTexts.sol";

library ImagePartsPhaseOne {
    function buildBetsGroup1A(
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
                        62,
                        415,
                        ImageBetTexts.getColor(betValidator[2]),
                        3,
                        teams[2]
                    ),
                    ImageBetTexts.smallRect(
                        62,
                        510,
                        ImageBetTexts.getColor(betValidator[3]),
                        4,
                        teams[3]
                    )
                )
            );
    }

    function buildBetsGroup1B(
        string[4] memory teams,
        uint8[4] memory betValidator
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    ImageBetTexts.smallRect(
                        356,
                        225,
                        ImageBetTexts.getColor(betValidator[0]),
                        5,
                        teams[0]
                    ),
                    ImageBetTexts.smallRect(
                        356,
                        320,
                        ImageBetTexts.getColor(betValidator[1]),
                        6,
                        teams[1]
                    ),
                    ImageBetTexts.smallRect(
                        356,
                        415,
                        ImageBetTexts.getColor(betValidator[2]),
                        7,
                        teams[2]
                    ),
                    ImageBetTexts.smallRect(
                        356,
                        510,
                        ImageBetTexts.getColor(betValidator[3]),
                        8,
                        teams[3]
                    )
                )
            );
    }

    function buildBetsGroup2A(
        string[4] memory teams,
        uint8[4] memory betValidator
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    ImageBetTexts.smallRect(
                        62,
                        668,
                        ImageBetTexts.getColor(betValidator[0]),
                        1,
                        teams[0]
                    ),
                    ImageBetTexts.smallRect(
                        62,
                        763,
                        ImageBetTexts.getColor(betValidator[1]),
                        2,
                        teams[1]
                    ),
                    ImageBetTexts.smallRect(
                        62,
                        858,
                        ImageBetTexts.getColor(betValidator[2]),
                        3,
                        teams[2]
                    ),
                    ImageBetTexts.smallRect(
                        62,
                        953,
                        ImageBetTexts.getColor(betValidator[3]),
                        4,
                        teams[3]
                    )
                )
            );
    }

    function buildBetsGroup2B(
        string[4] memory teams,
        uint8[4] memory betValidator
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    ImageBetTexts.smallRect(
                        356,
                        668,
                        ImageBetTexts.getColor(betValidator[0]),
                        5,
                        teams[0]
                    ),
                    ImageBetTexts.smallRect(
                        356,
                        763,
                        ImageBetTexts.getColor(betValidator[1]),
                        6,
                        teams[1]
                    ),
                    ImageBetTexts.smallRect(
                        356,
                        858,
                        ImageBetTexts.getColor(betValidator[2]),
                        7,
                        teams[2]
                    ),
                    ImageBetTexts.smallRect(
                        356,
                        953,
                        ImageBetTexts.getColor(betValidator[3]),
                        8,
                        teams[3]
                    )
                )
            );
    }

    function buildBetsGroup3A(
        string[4] memory teams,
        uint8[4] memory betValidator
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    ImageBetTexts.smallRect(
                        62,
                        1111,
                        ImageBetTexts.getColor(betValidator[0]),
                        1,
                        teams[0]
                    ),
                    ImageBetTexts.smallRect(
                        62,
                        1206,
                        ImageBetTexts.getColor(betValidator[1]),
                        2,
                        teams[1]
                    ),
                    ImageBetTexts.smallRect(
                        62,
                        1301,
                        ImageBetTexts.getColor(betValidator[2]),
                        3,
                        teams[2]
                    ),
                    ImageBetTexts.smallRect(
                        62,
                        1396,
                        ImageBetTexts.getColor(betValidator[3]),
                        4,
                        teams[3]
                    )
                )
            );
    }

    function buildBetsGroup3B(
        string[4] memory teams,
        uint8[4] memory betValidator
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    ImageBetTexts.smallRect(
                        356,
                        1111,
                        ImageBetTexts.getColor(betValidator[0]),
                        5,
                        teams[0]
                    ),
                    ImageBetTexts.smallRect(
                        356,
                        1206,
                        ImageBetTexts.getColor(betValidator[1]),
                        6,
                        teams[1]
                    ),
                    ImageBetTexts.smallRect(
                        356,
                        1301,
                        ImageBetTexts.getColor(betValidator[2]),
                        7,
                        teams[2]
                    ),
                    ImageBetTexts.smallRect(
                        356,
                        1396,
                        ImageBetTexts.getColor(betValidator[3]),
                        8,
                        teams[3]
                    )
                )
            );
    }

    function buildBets(
        string[24] memory teams,
        uint8[24] memory betValidator
    ) external pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    buildBetsGroup1A(
                        [teams[0], teams[1], teams[2], teams[3]],
                        [
                            betValidator[0],
                            betValidator[1],
                            betValidator[2],
                            betValidator[3]
                        ]
                    ),
                    buildBetsGroup1B(
                        [teams[4], teams[5], teams[6], teams[7]],
                        [
                            betValidator[4],
                            betValidator[5],
                            betValidator[6],
                            betValidator[7]
                        ]
                    ),
                    buildBetsGroup2A(
                        [teams[8], teams[9], teams[10], teams[11]],
                        [
                            betValidator[8],
                            betValidator[9],
                            betValidator[10],
                            betValidator[11]
                        ]
                    ),
                    buildBetsGroup2B(
                        [teams[12], teams[13], teams[14], teams[15]],
                        [
                            betValidator[12],
                            betValidator[13],
                            betValidator[14],
                            betValidator[15]
                        ]
                    ),
                    buildBetsGroup3A(
                        [teams[16], teams[17], teams[18], teams[19]],
                        [
                            betValidator[16],
                            betValidator[17],
                            betValidator[18],
                            betValidator[19]
                        ]
                    ),
                    buildBetsGroup3B(
                        [teams[20], teams[21], teams[22], teams[23]],
                        [
                            betValidator[20],
                            betValidator[21],
                            betValidator[22],
                            betValidator[23]
                        ]
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
            '<svg width="698" height="1545" fill="none" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><g clip-path="url(#a)"><rect width="698" height="1545" rx="10" fill="url(#b)"/><path fill="url(#c)" fill-opacity=".75" style="mix-blend-mode:overlay" d="M0 0h698v1545H0z" opacity=".5"/>';
    }

    function svgPartDown() external pure returns (string memory) {
        return '1.38-1.06q.84-.4 1.86-.4 1.88 0 2.96 1.06t1.08 2.88zm1.739-5.14q0-1.04.16-2.14a17 17 0 0 1 .5-2.28h2.28q-.36 1.4-.52 2.42t-.16 1.94q0 1.54.78 2.34t2.1.8h.32v2.2h-.32q-1.5 0-2.68-.62a4.6 4.6 0 0 1-1.82-1.82q-.64-1.18-.64-2.84m3.24 8.14 3.46-12.56h2.34l-3.4 12.56zm10.896-3 5.56-7.08q.58-.72.78-1.18.22-.46.22-.98c0-.52-.093-.66-.28-.94a1.8 1.8 0 0 0-.72-.66 2.04 2.04 0 0 0-1.02-.26q-.58 0-1.06.26-.46.24-.74.66t-.28.94c0 .52.067.653.2.92s.333.527.6.78l-1.32 1.72q-1.76-1.34-1.76-3.38 0-1.14.56-2.04a4.1 4.1 0 0 1 1.56-1.42q1-.54 2.24-.54t2.22.52q.98.5 1.54 1.4.58.88.58 2 0 .54-.14 1.06a4.3 4.3 0 0 1-.48 1.06q-.32.54-.88 1.28l-4.32 5.48-.08-1.74h6.3V214zm16.739-9.56h2.28V214h-2.28v-1.42q0-.78-.34-1.24a2.6 2.6 0 0 0-.9-.78q-.54-.3-1.22-.54-.66-.24-1.34-.56a5.3 5.3 0 0 1-1.22-.82q-.54-.52-.88-1.34t-.34-2.1V201h2.34v4.08q0 .9.3 1.42t.78.82q.5.3 1.08.52.6.2 1.18.48t1.06.76q.5.48.78 1.32.3.82.3 2.18l-1.58-2.22zm10.805-2 .88.7h-3.46V201h4.9v8.86q0 1.96-1.16 3.06-1.161 1.08-3.24 1.08h-.5v-2.18h.5q1 0 1.54-.48.54-.5.54-1.44zm4.42 2h2.28v5.78q0 .88.48 1.4t1.3.52q.8 0 1.28-.52t.48-1.4v-5.78h2.28v5.64q0 1.94-1.1 3.04-1.08 1.08-2.94 1.08c-1.86 0-2.227-.36-2.96-1.08q-1.1-1.1-1.1-3.04zm13.738 9.56h-.46q-1.6 0-2.44-.76-.82-.78-.82-2.28V201h2.28v9.8q0 .6.28.9.279.28.84.28h.32zm1.06-5.14q0-1.04.16-2.14a17 17 0 0 1 .5-2.28h2.28q-.36 1.4-.52 2.42t-.16 1.94q0 1.54.78 2.34t2.1.8h.32v2.2h-.32q-1.5 0-2.68-.62a4.6 4.6 0 0 1-1.82-1.82q-.64-1.18-.64-2.84m3.24 8.14 3.46-12.56h2.34l-3.4 12.56zm10.896-3 5.56-7.08q.58-.72.78-1.18.22-.46.22-.98c0-.52-.093-.66-.28-.94a1.8 1.8 0 0 0-.72-.66 2.04 2.04 0 0 0-1.02-.26q-.58 0-1.06.26-.46.24-.74.66t-.28.94c0 .52.067.653.2.92q.201.4.6.78l-1.32 1.72q-1.76-1.34-1.76-3.38 0-1.14.56-2.04a4.1 4.1 0 0 1 1.56-1.42q1-.54 2.24-.54t2.22.52q.98.5 1.54 1.4.58.88.58 2 0 .54-.14 1.06a4.3 4.3 0 0 1-.48 1.06q-.32.54-.88 1.28l-4.32 5.48-.08-1.74h6.3V214zm12.697-6.5q0 .94.34 1.76.36.82.96 1.44t1.4.96 1.74.34q.92 0 1.72-.34t1.4-.96q.62-.62.96-1.44t.34-1.76c0-.94-.114-1.213-.34-1.76a4.4 4.4 0 0 0-.96-1.44 4.2 4.2 0 0 0-1.4-.96 4.35 4.35 0 0 0-1.72-.34q-.94 0-1.74.34t-1.4.96-.96 1.44a4.5 4.5 0 0 0-.34 1.76m-2.4 0q0-1.42.52-2.62a6.62 6.62 0 0 1 3.64-3.56 6.9 6.9 0 0 1 2.68-.52q1.42 0 2.66.52a6.6 6.6 0 0 1 2.18 1.42 6.6 6.6 0 0 1 1.46 2.14q.54 1.2.54 2.62t-.54 2.64a6.6 6.6 0 0 1-1.46 2.12 6.9 6.9 0 0 1-2.18 1.44q-1.24.5-2.66.5-1.44 0-2.68-.5a6.9 6.9 0 0 1-2.18-1.44 6.6 6.6 0 0 1-1.46-2.12 6.7 6.7 0 0 1-.52-2.64m14.879 6.5 5.56-7.08q.58-.72.78-1.18.22-.46.22-.98c0-.52-.093-.66-.28-.94a1.8 1.8 0 0 0-.72-.66 2.04 2.04 0 0 0-1.02-.26q-.58 0-1.06.26-.46.24-.74.66t-.28.94c0 .52.067.653.2.92s.333.527.6.78l-1.32 1.72q-1.76-1.34-1.76-3.38 0-1.14.56-2.04a4.1 4.1 0 0 1 1.56-1.42q1-.54 2.24-.54t2.22.52q.98.5 1.54 1.4.58.88.58 2 0 .54-.14 1.06a4.3 4.3 0 0 1-.48 1.06q-.32.54-.88 1.28l-4.32 5.48-.08-1.74h6.3V214zm16.739-9.56h2.28V214h-2.28v-1.42q0-.78-.34-1.24a2.6 2.6 0 0 0-.9-.78q-.54-.3-1.22-.54-.66-.24-1.34-.56a5.3 5.3 0 0 1-1.22-.82q-.54-.52-.88-1.34t-.34-2.1V201h2.34v4.08q0 .9.3 1.42t.78.82q.5.3 1.08.52.6.2 1.18.48t1.06.76q.5.48.78 1.32.3.82.3 2.18l-1.58-2.22zm47.719-100.775-.723-2.058c8.311-2.933 13.893-10.842 13.893-19.684 0-11.502-9.329-20.86-20.796-20.86a20.7 20.7 0 0 0-6.35.99c-4.164 1.337-7.748 3.917-10.367 7.459a20.73 20.73 0 0 0-4.081 12.412h-2.175c0-4.98 1.559-9.723 4.507-13.712a22.89 22.89 0 0 1 18.465-9.33c12.667 0 22.972 10.336 22.972 23.042 0 9.766-6.168 18.504-15.346 21.742z" fill="#fff"/><path d="M314.591 90.182h-10.868l-3.359-10.368 8.793-6.409 8.793 6.409zM305.303 88h7.708l2.382-7.354-6.236-4.544-6.236 4.544z" fill="#fff"/><path d="m305.324 89.817-29.702 33.399h-2.914l30.577-34.384.417-.468zm11.913 13.544-8.429 9.48-.003.001-4.03 4.531h-2.914l13.583-15.276.002-.002.167-.187.807.721.006.004.001.003zm-29.153-20.729-.085.097-12.377 13.915h-2.914l6.523-7.334.002-.003 1.789-2.009v-.001l5.44-6.117.808.723.02.02zm21.073-15.141-7.341-5.61 1.318-1.735 6.023 4.602 6.022-4.602 1.318 1.735zm21.298 15.312-7.589-5.266 3.048-8.738 2.053.72-2.5 7.168 6.225 4.321z" fill="#fff"/><path d="m287.891 82.803-1.238-1.795 6.226-4.32-2.5-7.168 2.054-.721 3.047 8.738zm29.583 20.121-2.098-.58 2.451-8.904h9.246v2.182h-7.59z" fill="#fff"/><path d="M340 81.923c0 8.155-3.125 15.83-8.813 21.645h-3.182c6.015-5.272 9.82-13.02 9.82-21.645 0-15.847-12.852-28.742-28.651-28.742s-28.417 12.659-28.65 28.305h-2.174c.11-8.098 3.306-15.69 9.025-21.43 5.823-5.84 13.563-9.056 21.799-9.056s15.976 3.215 21.797 9.057C336.794 65.898 340 73.662 340 81.923M65.976 69.492q0 2.615.97 4.89a13 13 0 0 0 2.666 4.02 12.6 12.6 0 0 0 3.927 2.663q2.23.969 4.8.969t4.8-.969a12.6 12.6 0 0 0 3.927-2.663 13 13 0 0 0 2.667-4.02q.97-2.275.97-4.89t-.97-4.89a12.5 12.5 0 0 0-2.667-3.971 12.2 12.2 0 0 0-3.927-2.712q-2.23-.968-4.8-.968t-4.8.968a12.2 12.2 0 0 0-3.927 2.712 12.5 12.5 0 0 0-2.667 3.97q-.97 2.277-.97 4.891zm-3.976 0q0-3.39 1.26-6.295a16.3 16.3 0 0 1 3.491-5.18 16.2 16.2 0 0 1 5.237-3.439q2.957-1.26 6.351-1.259c3.394.001 4.38.42 6.352 1.26q2.957 1.21 5.187 3.437a15.9 15.9 0 0 1 3.54 5.181q1.26 2.905 1.26 6.295c0 3.39-.42 4.374-1.26 6.343a16 16 0 0 1-3.54 5.133 16.3 16.3 0 0 1-5.188 3.487q-2.957 1.21-6.35 1.21-3.395 0-6.352-1.21a16.9 16.9 0 0 1-5.237-3.487 16.4 16.4 0 0 1-3.49-5.133Q62 72.882 62 69.492m53.857 15.738h-15.515V53.754h3.878v27.843h11.637v3.631zm8.663 0 8.727-31.475h3.878l-8.484 31.474h-4.121zm-9.309-22.178q0-1.986.339-4.067.339-2.083 1.164-5.23h3.83q-.873 3.244-1.212 5.278a24.4 24.4 0 0 0-.34 4.019q0 4.552 2.473 7.021 2.521 2.421 7.079 2.421h1.163v3.632h-1.163q-4.218 0-7.224-1.55-2.958-1.548-4.558-4.454-1.551-2.954-1.551-7.07m26.512 22.178V53.754h2.085q3.782 0 6.788 1.307 3.054 1.308 5.042 3.68 1.988 2.325 2.57 5.569h-2.521q.63-3.244 2.569-5.569 1.988-2.372 4.994-3.68 3.055-1.307 6.837-1.307h2.084v31.474h-3.878v-28.18l1.115.58h-1.261q-2.812 0-4.897 1.26-2.084 1.21-3.248 3.486-1.116 2.276-1.115 5.327v7.844h-3.879V67.7q0-3.051-1.164-5.327-1.115-2.276-3.2-3.486-2.084-1.26-4.896-1.26h-1.261l1.115-.58v28.181h-3.879zm37.736 0V53.754h9.212q3.395 0 5.915 1.21 2.57 1.211 3.976 3.39 1.455 2.131 1.455 5.036 0 2.76-.922 4.6-.872 1.84-2.375 3.05a17.3 17.3 0 0 1-3.297 2.083 377 377 0 0 1-3.54 1.646 24 24 0 0 0-3.248 1.84 7.84 7.84 0 0 0-2.424 2.615q-.873 1.55-.873 3.922v2.082h-3.879zm3.879-10.411a13 13 0 0 1 2.521-1.889 29 29 0 0 1 2.812-1.453q1.407-.678 2.716-1.355a13 13 0 0 0 2.375-1.501 6.05 6.05 0 0 0 1.649-2.083q.63-1.21.63-2.953 0-2.857-1.988-4.504-1.94-1.695-5.236-1.694h-5.479zm21.154-12.493h3.781v22.903h-3.781zm1.89-3.826q-1.067 0-1.793-.678-.68-.678-.679-1.743 0-1.065.679-1.743.726-.678 1.793-.678 1.116 0 1.794.678.68.678.679 1.743 0 1.065-.679 1.743-.678.678-1.794.678m35.401 13.558h4.024q-.582 3.874-2.861 6.973-2.279 3.05-5.721 4.843-3.443 1.791-7.563 1.791-3.395 0-6.351-1.21a16.9 16.9 0 0 1-5.237-3.487 16.4 16.4 0 0 1-3.491-5.133q-1.26-2.953-1.26-6.343c0-3.39.42-4.358 1.26-6.295a16.3 16.3 0 0 1 3.491-5.18 16.2 16.2 0 0 1 5.237-3.439q2.956-1.26 6.351-1.259 3.879 0 7.176 1.647 3.345 1.598 5.624 4.406a15.54 15.54 0 0 1 3.103 6.392h-4.073a12.1 12.1 0 0 0-2.521-4.552 11.9 11.9 0 0 0-4.121-3.099q-2.376-1.162-5.188-1.162-2.57 0-4.8.968a12.2 12.2 0 0 0-3.927 2.712 12.4 12.4 0 0 0-2.667 3.97q-.97 2.277-.97 4.891 0 2.615.97 4.89a13 13 0 0 0 2.667 4.02 12.6 12.6 0 0 0 3.927 2.663q2.23.969 4.8.969 3.006 0 5.527-1.308a12.7 12.7 0 0 0 4.267-3.583 12.4 12.4 0 0 0 2.327-5.085m17.748 13.607q-2.763 0-5.139-1.114a9.44 9.44 0 0 1-3.733-3.292q-1.406-2.13-1.406-5.23h3.879q0 1.743.824 3.1a5.8 5.8 0 0 0 2.278 2.13q1.455.775 3.297.775 2.619 0 4.267-1.405 1.648-1.452 1.648-3.728 0-1.647-.824-2.712t-2.23-1.791a18.4 18.4 0 0 0-3.006-1.356 71 71 0 0 1-3.297-1.356 16.6 16.6 0 0 1-3.054-1.743 7.8 7.8 0 0 1-2.182-2.518q-.825-1.55-.824-3.874 0-2.276 1.212-4.116 1.26-1.889 3.345-3.002 2.085-1.114 4.606-1.114 2.812 0 4.945 1.162a8.27 8.27 0 0 1 3.346 3.148q1.212 1.985 1.212 4.648h-3.879q0-2.372-1.6-3.825-1.551-1.5-4.024-1.501-1.406 0-2.618.63a4.9 4.9 0 0 0-1.891 1.646q-.68 1.016-.679 2.324 0 1.598.824 2.615.825 1.017 2.182 1.791 1.407.728 3.055 1.356 1.648.581 3.297 1.308a14 14 0 0 1 3.006 1.791 7.9 7.9 0 0 1 2.23 2.615q.824 1.55.824 3.874 0 2.518-1.309 4.503-1.26 1.986-3.491 3.147-2.23 1.114-5.091 1.114M63.6 123.633V92.159h16.436v3.631H65.2l2.279-2.179v20.628l-2.812 4.697q0-4.212 1.6-7.263 1.648-3.051 4.654-4.697 3.006-1.647 7.127-1.647h.727v3.632h-.727q-4.848 0-7.709 2.712-2.86 2.662-2.86 7.263v4.697zm23.919-15.737q0 2.614.97 4.89a13 13 0 0 0 2.666 4.02 12.6 12.6 0 0 0 3.927 2.663q2.23.968 4.8.968t4.8-.968a12.6 12.6 0 0 0 3.927-2.663 13 13 0 0 0 2.667-4.02q.97-2.276.97-4.89 0-2.615-.97-4.891a12.4 12.4 0 0 0-2.667-3.97 12.2 12.2 0 0 0-3.927-2.712q-2.23-.969-4.8-.968-2.57 0-4.8.968a12.2 12.2 0 0 0-3.927 2.712 12.4 12.4 0 0 0-2.666 3.97q-.97 2.276-.97 4.891m-3.976 0q0-3.39 1.26-6.295a16.3 16.3 0 0 1 3.492-5.181 16.2 16.2 0 0 1 5.236-3.438q2.957-1.26 6.351-1.26t6.352 1.26a15.7 15.7 0 0 1 5.187 3.438 15.9 15.9 0 0 1 3.54 5.181q1.26 2.905 1.26 6.295c0 3.39-.42 4.374-1.26 6.343a16 16 0 0 1-3.54 5.133 16.3 16.3 0 0 1-5.187 3.486q-2.958 1.21-6.352 1.211-3.394 0-6.351-1.211a16.9 16.9 0 0 1-5.236-3.486 16.4 16.4 0 0 1-3.491-5.133q-1.26-2.953-1.26-6.343zm40.718 0q0 2.614.969 4.89a13 13 0 0 0 2.667 4.02 12.6 12.6 0 0 0 3.927 2.663q2.23.968 4.8.968t4.8-.968a12.6 12.6 0 0 0 3.927-2.663 13 13 0 0 0 2.667-4.02q.969-2.276.969-4.89 0-2.615-.969-4.891a12.5 12.5 0 0 0-2.667-3.97 12.2 12.2 0 0 0-3.927-2.712q-2.23-.969-4.8-.968-2.57 0-4.8.968a12.2 12.2 0 0 0-3.927 2.712 12.5 12.5 0 0 0-2.667 3.97q-.969 2.276-.969 4.891m-3.976 0q0-3.39 1.26-6.295a16.3 16.3 0 0 1 3.491-5.181 16.2 16.2 0 0 1 5.237-3.438q2.956-1.26 6.351-1.26c3.395 0 4.38.42 6.351 1.26a15.7 15.7 0 0 1 5.188 3.438 15.9 15.9 0 0 1 3.539 5.181q1.261 2.905 1.261 6.295c0 3.39-.42 4.374-1.261 6.343a16 16 0 0 1-3.539 5.133 16.3 16.3 0 0 1-5.188 3.486q-2.957 1.21-6.351 1.211c-3.394.001-4.38-.404-6.351-1.211a16.9 16.9 0 0 1-5.237-3.486 16.4 16.4 0 0 1-3.491-5.133q-1.26-2.953-1.26-6.343m41.646 15.737V93.95l1.454 1.404q-2.57 0-5.139.194-2.521.195-4.364.436v-3.632a85 85 0 0 1 4.558-.435 76 76 0 0 1 10.812 0q2.715.194 4.606.435v3.632q-1.212-.146-2.764-.29a87 87 0 0 0-3.297-.243 60 60 0 0 0-3.442-.096l1.454-1.405v29.683zm20.65-27.843v3.535q0 1.598.581 2.76a4.37 4.37 0 0 0 1.794 1.792q1.164.629 2.715.629 1.989 0 3.346-1.259t1.357-3.05q0-1.987-1.406-3.196t-3.781-1.21h-4.606zm-3.879 27.843V92.159h8.485q2.666 0 4.654.968 2.037.92 3.151 2.615 1.164 1.695 1.164 3.922 0 2.373-1.212 4.213-1.164 1.791-3.345 2.76l-.049-1.114q2.618.484 4.461 1.695 1.89 1.162 2.909 2.954 1.018 1.743 1.018 3.922 0 2.76-1.406 4.939-1.406 2.13-3.879 3.389-2.472 1.21-5.673 1.211zm3.879-3.632h6.399q2.037-.048 3.588-.774 1.6-.775 2.473-2.083.921-1.355.921-3.05 0-1.743-.921-2.954-.873-1.21-2.715-1.937-1.794-.774-4.655-1.065-1.697-.194-2.957-.678t-2.133-1.307zm22.483 3.632v-21.596q0-3.051 1.261-5.375a9.36 9.36 0 0 1 3.636-3.632q2.328-1.307 5.333-1.307 3.055 0 5.334 1.307a9.03 9.03 0 0 1 3.587 3.632q1.31 2.325 1.309 5.375v21.596h-3.878v-1.017q0-4.794-2.909-7.699-2.86-2.905-8.34-2.905h-2.909v-3.632h1.94q6.06 0 9.648 2.276 3.636 2.228 4.509 6.101h-1.939v-14.72q0-1.936-.824-3.39a5.94 5.94 0 0 0-2.279-2.276q-1.406-.87-3.249-.871-1.842 0-3.297.871a5.93 5.93 0 0 0-2.278 2.276q-.776 1.454-.776 3.39v21.596zm42.798 0h-15.515V92.159h3.878V120h11.637zm20.738 0h-15.515V92.159h3.879V120H268.6z" fill="#fff"/></g><defs><linearGradient id="b" x1="349" y1="0" x2="349" y2="1545" gradientUnits="userSpaceOnUse"><stop stop-color="#202738"/><stop offset="1" stop-color="#070816"/></linearGradient><clipPath id="a"><rect width="698" height="1545" rx="10" fill="#fff"/></clipPath><pattern id="c" patternContentUnits="objectBoundingBox" width=".315" height=".142"><use xlink:href="#prefix__image0_2015_4234" transform="scale(.00143 .00065)"/></pattern></defs></svg>';
    }
}

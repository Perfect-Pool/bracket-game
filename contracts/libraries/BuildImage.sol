// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ImageParts.sol";
import "./ImageBetTexts.sol";

library BuildImage {
    function fullSvgImage(
        uint8 status,
        uint8[8] memory betValidator,
        string[8] memory teams,
        string memory prize,
        string memory nftId,
        bool claimed
    ) public pure returns (string memory) {
        bool victory = true;
        for (uint8 i = 0; i < 7; i++) {
            if (betValidator[i] == 2) {
                status = 4;
                victory = false;
            }
        }

        return
            string(
                abi.encodePacked(
                    svgPartUp(),
                    ImageParts.buildBets(teams, betValidator),
                    ImageParts.idAndPrize(
                        nftId,
                        ImageParts.formatPrize(prize),
                        claimed
                    ),
                    svgPartDown()
                )
            );
    }

    function svgPartUp() private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<svg width="698" height="874" fill="none" xmlns="http://www.w3.org/2000/svg"><g clip-path="url(#prefix__prefix__clip0_2015_4656)"><rect width="698" height="874" rx="10" fill="url(#prefix__prefix__paint0_linear_2015_4656)"/><path fill="url(#prefix__prefix__pattern0_2015_4656)" fill-opacity=".75" style="mix-blend-mode:overlay" d="M0 0h698v874H0z" opacity=".5"/><path d="M74.82 214v-.58c0-.52-.107-.973-.32-1.36a2.26 2.26 0 00-.86-.94c-.36-.24-.78-.36-1.26-.36-.467 0-.887.113-1.26.34-.373.227-.667.54-.88.94-.2.387-.3.847-.3 1.38h-2c0-.867.193-1.633.58-2.3a4.236 4.236 0 011.58-1.6c.667-.4 1.427-.6 2.28-.6.933 0 1.753.2 2.46.6.72.387 1.28.933 1.68 1.64.4.693.6 1.507.6 2.44v.4h-2.3zm-5.3-2c.613 0 1.187-.113 1.72-.34.533-.227 1-.547 1.4-.96.413-.413.733-.893.96-1.44.227-.547.34-1.133.34-1.76s-.113-1.213-.34-1.76a4.392 4.392 0 00-.96-1.44 4.241 4.241 0 00-1.4-.96 4.345 4.345 0 00-1.72-.34c-.627 0-1.207.113-1.74.34-.533.227-1 .547-1.4.96-.4.413-.72.893-.96 1.44a4.548 4.548 0 00-.34 1.76c0 .627.113 1.213.34 1.76.24.547.56 1.027.96 1.44.4.413.867.733 1.4.96.533.227 1.113.34 1.74.34zm0 2.2c-.96 0-1.853-.167-2.68-.5a6.912 6.912 0 01-2.18-1.44 6.623 6.623 0 01-1.46-2.12 6.66 6.66 0 01-.52-2.64c0-.947.173-1.82.52-2.62a6.628 6.628 0 013.64-3.56 6.853 6.853 0 012.68-.52c.947 0 1.833.173 2.66.52a6.628 6.628 0 013.64 3.56c.36.8.54 1.673.54 2.62 0 .76-.127 1.487-.38 2.18a6.791 6.791 0 01-1.04 1.9l-.22.1a6.45 6.45 0 01-2.28 1.88 6.682 6.682 0 01-2.92.64zm13.354-2.28c.427 0 .793-.093 1.1-.28.32-.187.573-.44.76-.76.187-.32.28-.693.28-1.12V201h2.36v8.76c0 .88-.187 1.66-.56 2.34a3.949 3.949 0 01-1.58 1.56c-.667.36-1.453.54-2.36.54-.907 0-1.7-.18-2.38-.54a3.949 3.949 0 01-1.58-1.56c-.373-.68-.56-1.46-.56-2.34V201h2.34v8.76c0 .427.093.8.28 1.12.187.32.44.573.76.76.333.187.713.28 1.14.28zm6.69 2.08v-8.68c0-.893.188-1.68.56-2.36a3.92 3.92 0 011.58-1.58c.68-.387 1.468-.58 2.36-.58.908 0 1.694.193 2.36.58.68.373 1.207.9 1.58 1.58.374.68.56 1.467.56 2.36V214h-2.32v-.36c0-1.133-.34-2.04-1.02-2.72-.68-.693-1.653-1.04-2.92-1.04h-1.32v-2.12h1.04c1.547 0 2.78.34 3.7 1.02.92.667 1.46 1.587 1.62 2.76l-1.1-.12v-6.1c0-.453-.093-.847-.28-1.18a1.998 1.998 0 00-.78-.78c-.32-.2-.692-.3-1.12-.3-.426 0-.806.1-1.14.3a2 2 0 00-.78.78c-.172.333-.26.727-.26 1.18V214h-2.32zm11.352 0v-13h4.04c1 0 1.874.173 2.62.52.747.333 1.327.807 1.74 1.42.427.6.64 1.307.64 2.12 0 .507-.066.96-.2 1.36a3.47 3.47 0 01-.54 1.04c-.226.293-.486.56-.78.8-.28.227-.586.433-.92.62.6.187 1.114.48 1.54.88.44.387.774.853 1 1.4.227.547.34 1.16.34 1.84v1h-2.4v-1.02c0-.493-.1-.927-.3-1.3a1.965 1.965 0 00-.82-.86 2.388 2.388 0 00-1.24-.32c-.48 0-.9.107-1.26.32-.36.2-.64.487-.84.86-.186.373-.28.807-.28 1.3V214h-2.34zm2.34-10.82v6.02c.267-.253.56-.467.88-.64.32-.187.634-.36.94-.52.32-.16.627-.32.92-.48.307-.16.574-.34.8-.54a2.38 2.38 0 00.56-.72c.134-.28.2-.607.2-.98 0-.667-.226-1.187-.68-1.56-.453-.387-1.066-.58-1.84-.58h-1.78zm10.78 10.82v-11.88l.98.82c-.72 0-1.433.033-2.14.1-.707.053-1.347.127-1.92.22v-2.14c.547-.093 1.2-.167 1.96-.22a25.95 25.95 0 014.58 0c.76.053 1.413.127 1.96.22v2.14c-.4-.067-.82-.12-1.26-.16a20.473 20.473 0 00-1.34-.12c-.453-.027-.933-.04-1.44-.04l.96-.82V214h-2.34zm7.154 0v-13h7.22v2.1h-5.6l.66-.68v7.54l-1.3 1.78c0-1.107.22-2.06.66-2.86a4.529 4.529 0 011.84-1.84c.8-.44 1.746-.66 2.84-.66h.32v2.08h-.38c-1.227 0-2.207.333-2.94 1-.72.653-1.08 1.54-1.08 2.66v.88l-.96-1.1h5.94v2.1h-7.22zm9.218 0v-13h4.04c1 0 1.874.173 2.62.52.747.333 1.327.807 1.74 1.42.427.6.64 1.307.64 2.12 0 .507-.066.96-.2 1.36a3.47 3.47 0 01-.54 1.04c-.226.293-.486.56-.78.8-.28.227-.586.433-.92.62.6.187 1.114.48 1.54.88.44.387.774.853 1 1.4.227.547.34 1.16.34 1.84v1h-2.4v-1.02c0-.493-.1-.927-.3-1.3a1.965 1.965 0 00-.82-.86 2.388 2.388 0 00-1.24-.32c-.48 0-.9.107-1.26.32-.36.2-.64.487-.84.86-.186.373-.28.807-.28 1.3V214h-2.34zm2.34-10.82v6.02c.267-.253.56-.467.88-.64.32-.187.634-.36.94-.52.32-.16.627-.32.92-.48.307-.16.574-.34.8-.54a2.38 2.38 0 00.56-.72c.134-.28.2-.607.2-.98 0-.667-.226-1.187-.68-1.56-.453-.387-1.066-.58-1.84-.58h-1.78zM146.033 214v-13h7.1v2.12h-5.62l.86-.84v7.74l-1.32 1.9c0-1.147.214-2.127.64-2.94a4.477 4.477 0 011.82-1.9c.8-.44 1.747-.66 2.84-.66h.26v2.08h-.32c-1.213 0-2.173.34-2.88 1.02-.693.667-1.04 1.587-1.04 2.76V214h-2.34zm11.325 0h-2.34v-13h2.34v13zm2.523 0v-13h2.2c.653 1.653 1.393 3.14 2.22 4.46a22.23 22.23 0 003 3.7l-.62.18V201h2.34v13h-2.36v-3.2l.34 1.02a25.658 25.658 0 01-2.16-2.18 23.604 23.604 0 01-1.82-2.4c-.533-.84-1-1.693-1.4-2.56l.58.06V214h-2.32zm11.481 0v-8.68c0-.893.186-1.68.56-2.36.373-.68.9-1.207 1.58-1.58.68-.387 1.466-.58 2.36-.58.906 0 1.693.193 2.36.58.68.373 1.206.9 1.58 1.58.373.68.56 1.467.56 2.36V214h-2.32v-.36c0-1.133-.34-2.04-1.02-2.72-.68-.693-1.654-1.04-2.92-1.04h-1.32v-2.12h1.04c1.546 0 2.78.34 3.7 1.02.92.667 1.46 1.587 1.62 2.76l-1.1-.12v-6.1c0-.453-.094-.847-.28-1.18a2.003 2.003 0 00-.78-.78c-.32-.2-.694-.3-1.12-.3-.427 0-.807.1-1.14.3a1.99 1.99 0 00-.78.78c-.174.333-.26.727-.26 1.18V214h-2.32zm18.111 0h-6.76v-13h2.34v10.86h4.42V214zM67.1 450.2a5.197 5.197 0 01-2.28-.5 4.04 4.04 0 01-1.62-1.4c-.4-.613-.6-1.347-.6-2.2h2.32c0 .4.087.753.26 1.06.187.307.447.547.78.72.333.173.707.26 1.12.26.6 0 1.087-.16 1.46-.48.373-.32.56-.727.56-1.22 0-.387-.113-.7-.34-.94a2.729 2.729 0 00-.9-.64 11.088 11.088 0 00-1.24-.48c-.44-.147-.887-.32-1.34-.52-.44-.2-.847-.44-1.22-.72a3.154 3.154 0 01-.9-1.06c-.213-.427-.32-.967-.32-1.62 0-.667.173-1.273.52-1.82a3.93 3.93 0 011.46-1.34c.627-.333 1.327-.5 2.1-.5.84 0 1.58.167 2.22.5.64.32 1.14.773 1.5 1.36.36.587.54 1.26.54 2.02h-2.32c0-.547-.18-.987-.54-1.32-.36-.333-.827-.5-1.4-.5-.32 0-.613.067-.88.2s-.48.32-.64.56a1.32 1.32 0 00-.24.78c0 .373.113.68.34.92a3.1 3.1 0 00.9.6c.373.173.78.34 1.22.5.453.147.9.32 1.34.52.453.187.867.427 1.24.72s.673.66.9 1.1c.227.44.34.987.34 1.64a3.48 3.48 0 01-.56 1.94 3.92 3.92 0 01-1.54 1.36c-.64.333-1.387.5-2.24.5zm6.219-.2v-13h7.22v2.1h-5.6l.66-.68v7.54l-1.3 1.78c0-1.107.22-2.06.66-2.86a4.53 4.53 0 011.84-1.84c.8-.44 1.746-.66 2.84-.66h.32v2.08h-.38c-1.227 0-2.207.333-2.94 1-.72.653-1.08 1.54-1.08 2.66v.88l-.96-1.1h5.94v2.1h-7.22zm9.218 0v-13h1.18c1.08 0 2.054.173 2.92.52.88.347 1.6.847 2.16 1.5.574.64.954 1.42 1.14 2.34h-1.58c.2-.92.58-1.7 1.14-2.34.574-.653 1.294-1.153 2.16-1.5.867-.347 1.847-.52 2.94-.52h1.18v13h-2.34v-10.9l.6.32h-.52c-.666 0-1.24.133-1.72.4s-.853.66-1.12 1.18c-.253.507-.38 1.113-.38 1.82v3.36h-2.3v-3.36c0-.693-.133-1.293-.4-1.8a2.627 2.627 0 00-1.1-1.18c-.48-.28-1.053-.42-1.72-.42h-.52l.62-.32V450h-2.34zm18.083 0h-2.34v-13h2.34v13zm6.703 0v-13h7.1v2.12h-5.62l.86-.84v7.74l-1.32 1.9c0-1.147.213-2.127.64-2.94a4.466 4.466 0 011.82-1.9c.8-.44 1.746-.66 2.84-.66h.26v2.08h-.32c-1.214 0-2.174.34-2.88 1.02-.694.667-1.04 1.587-1.04 2.76V450h-2.34zm11.324 0h-2.34v-13h2.34v13zm2.523 0v-13h2.2c.653 1.653 1.393 3.14 2.22 4.46a22.23 22.23 0 003 3.7l-.62.18V437h2.34v13h-2.36v-3.2l.34 1.02a25.658 25.658 0 01-2.16-2.18 23.604 23.604 0 01-1.82-2.4c-.533-.84-1-1.693-1.4-2.56l.58.06V450h-2.32zm11.481 0v-8.68c0-.893.186-1.68.56-2.36.373-.68.9-1.207 1.58-1.58.68-.387 1.466-.58 2.36-.58.906 0 1.693.193 2.36.58.68.373 1.206.9 1.58 1.58.373.68.56 1.467.56 2.36V450h-2.32v-.36c0-1.133-.34-2.04-1.02-2.72-.68-.693-1.654-1.04-2.92-1.04h-1.32v-2.12h1.04c1.546 0 2.78.34 3.7 1.02.92.667 1.46 1.587 1.62 2.76l-1.1-.12v-6.1c0-.453-.094-.847-.28-1.18a2.003 2.003 0 00-.78-.78c-.32-.2-.694-.3-1.12-.3-.427 0-.807.1-1.14.3a1.99 1.99 0 00-.78.78c-.174.333-.26.727-.26 1.18V450h-2.32zm18.111 0h-6.76v-13h2.34v10.86h4.42V450zm166.021-346.335l-.723-2.058c8.311-2.933 13.893-10.842 13.893-19.684 0-11.502-9.329-20.86-20.796-20.86a20.73 20.73 0 00-6.35.99c-4.164 1.337-7.748 3.917-10.367 7.459a20.73 20.73 0 00-4.081 12.412h-2.175c0-4.98 1.559-9.723 4.507-13.712a22.89 22.89 0 0118.465-9.33c12.667 0 22.972 10.336 22.972 23.042 0 9.766-6.168 18.504-15.346 21.742l.001-.001z" fill="#fff"/><path d="M314.591 90.182h-10.868l-3.359-10.368 8.793-6.409 8.793 6.409-3.359 10.368zM305.303 88h7.708l2.382-7.354-6.236-4.544-6.236 4.544L305.303 88z" fill="#fff"/><path d="M305.324 89.817l-29.702 33.399h-2.914l30.577-34.384.417-.468 1.622 1.453zm11.913 13.544l-8.429 9.48-.003.001-4.03 4.531h-2.914l13.583-15.276.002-.002.167-.187.807.721.006.004.001.003.81.725zm-29.153-20.729l-.085.097-12.377 13.915h-2.914l6.523-7.334.002-.003 1.789-2.009v-.001l5.44-6.117.808.723.02.02.794.709zm21.073-15.141l-7.341-5.61 1.318-1.735 6.023 4.602 6.022-4.602 1.318 1.735-7.34 5.61zm21.298 15.312l-7.589-5.266 3.048-8.738 2.053.72-2.5 7.168 6.225 4.321-1.237 1.795z" fill="#fff"/><path d="M287.891 82.803l-1.238-1.795 6.226-4.32-2.5-7.168 2.054-.721 3.047 8.738-7.589 5.266zm29.583 20.121l-2.098-.58 2.451-8.904h9.246v2.182h-7.59l-2.009 7.302z" fill="#fff"/><path d="M340 81.923c0 8.155-3.125 15.83-8.813 21.645h-3.182c6.015-5.272 9.82-13.02 9.82-21.645 0-15.847-12.852-28.742-28.651-28.742-15.798 0-28.417 12.659-28.65 28.305h-2.174c.11-8.098 3.306-15.69 9.025-21.43 5.823-5.84 13.563-9.056 21.799-9.056 8.236 0 15.976 3.215 21.797 9.057C336.794 65.898 340 73.662 340 81.923zM65.976 69.492c0 1.743.323 3.374.97 4.89a13.028 13.028 0 002.666 4.02 12.613 12.613 0 003.927 2.663c1.487.646 3.087.969 4.8.969 1.713 0 3.313-.323 4.8-.969a12.614 12.614 0 003.927-2.663 13.03 13.03 0 002.667-4.02c.646-1.516.97-3.147.97-4.89 0-1.743-.324-3.373-.97-4.89a12.446 12.446 0 00-2.667-3.971 12.225 12.225 0 00-3.927-2.712c-1.487-.645-3.087-.968-4.8-.968-1.713 0-3.313.323-4.8.968a12.224 12.224 0 00-3.927 2.712 12.445 12.445 0 00-2.667 3.97c-.646 1.518-.97 3.148-.97 4.891zm-3.976 0c0-2.26.42-4.358 1.26-6.295a16.28 16.28 0 013.491-5.18 16.2 16.2 0 015.237-3.439c1.971-.84 4.088-1.259 6.351-1.259s4.38.42 6.352 1.26c1.971.806 3.7 1.952 5.187 3.437a15.9 15.9 0 013.54 5.181c.84 1.937 1.26 4.035 1.26 6.295s-.42 4.374-1.26 6.343a16.044 16.044 0 01-3.54 5.133 16.303 16.303 0 01-5.188 3.487c-1.971.807-4.088 1.21-6.35 1.21-2.264 0-4.38-.403-6.352-1.21a16.884 16.884 0 01-5.237-3.487 16.434 16.434 0 01-3.49-5.133C62.42 73.867 62 71.752 ',
                    ImageParts.svgPartUp()
                )
            );
    }

    function svgPartDown() private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<g clip-path="url(#prefix__clip22_2015_4656)"><path d="M514.067 595l-16.279 33.802a1.135 1.135 0 01-1.356.584 43.76 43.76 0 00-4.105-.987c-.139-.028-.278-.052-.413-.076a43.261 43.261 0 00-10.756-.576c-.155.012-.31.02-.465.036a42.133 42.133 0 00-5.082.717c-.478.092-.862-.395-.654-.826L490.648 595h23.419z" fill="#F41943"/><path d="M487.396 613.826l-2.896-6.025 2.157-4.492 2.921 5.974-2.182 4.543zM493.135 625.785l-5.518-11.487v-.004l2.185-4.548 5.572 11.391-2.239 4.648z" fill="#BA0F38"/><path d="M498.45 627.428l-.662 1.374a1.135 1.135 0 01-1.356.584 41.595 41.595 0 00-4.105-.987c-.139-.028-.274-.056-.413-.076a42.651 42.651 0 00-7.414-.681c.09-.004.176-.004.266-.004 2.406 0 4.816.197 7.189.6a40.397 40.397 0 011.434.262c.478.092.862-.395.653-.826l-.682-1.422 2.243-4.652 2.847 5.828z" fill="#BA0F38"/><path d="M489.802 609.746l-2.185 4.548-.221-.464v-.004l2.182-4.543.224.463z" fill="#CE9117"/><path d="M496.886 595l-7.084 14.746-.224-.463L496.436 595h.45z" fill="#F9B906"/><path d="M495.603 621.6l-2.243 4.652-.225-.467 2.239-4.648.229.463z" fill="#CE9117"/><path d="M508.413 595l-12.81 26.6-.229-.463L507.964 595h.449z" fill="#F9B906"/><path d="M500.031 629.249v7.371h-1.622v-7.161a36.408 36.408 0 00-5.49-1.737 37.41 37.41 0 00-8.419-.954 37.1 37.1 0 00-11.291 1.748c-.89.282-1.765.6-2.618.947v7.161h-1.622v-7.371c0-.515.319-.983.805-1.172a72.443 72.443 0 012.733-1.019 37.98 37.98 0 014.452-1.152 38.82 38.82 0 017.545-.733c2.582 0 5.106.254 7.545.733 1.52.298 3.003.689 4.449 1.16.465.153 1.813.661 2.737 1.019.486.189.804.657.804 1.172l-.008-.012z" fill="#976C0D"/><path d="M484.5 695c17.949 0 32.5-14.347 32.5-32.046 0-17.698-14.551-32.045-32.5-32.045-17.949 0-32.5 14.347-32.5 32.045C452 680.653 466.551 695 484.5 695z" fill="#936D02"/><path d="M484.5 692.148c-16.328 0-29.608-13.094-29.608-29.194 0-16.099 13.28-29.194 29.608-29.194 16.328 0 29.608 13.095 29.608 29.194 0 16.1-13.28 29.194-29.608 29.194z" fill="#976C0D"/><path d="M512.298 662.954c0 15.113-12.467 27.41-27.798 27.41a27.925 27.925 0 01-21.895-10.537 27.1 27.1 0 01-3.076-4.833 26.955 26.955 0 01-2.827-12.04c0-3.202.56-6.275 1.589-9.135 3.092-8.607 10.437-15.253 19.526-17.473a28.165 28.165 0 016.687-.801c5.127 0 9.935 1.373 14.061 3.77a27.934 27.934 0 015.085 3.786 27.449 27.449 0 016.708 9.792 26.88 26.88 0 011.94 10.061z" fill="#936D02"/><path d="M498.561 639.315l-39.032 35.679a26.955 26.955 0 01-2.827-12.04c0-3.202.56-6.275 1.589-9.135l19.526-17.473a28.165 28.165 0 016.687-.801c5.127 0 9.935 1.373 14.061 3.77h-.004zM510.354 652.893l-37.986 34.724a27.933 27.933 0 01-9.764-7.786l41.038-36.726a27.474 27.474 0 016.708 9.792l.004-.004z" fill="#927429"/><path d="M493.389 628.5a42.133 42.133 0 00-5.082-.717c-.155-.016-.31-.024-.465-.036a43.261 43.261 0 00-10.756.576c-.135.024-.274.048-.413.076a43.76 43.76 0 00-4.105.987 1.135 1.135 0 01-1.356-.584L454.933 595h23.419l15.691 32.674c.208.431-.176.918-.654.826z" fill="#F41943"/><path d="M488.307 627.783c-.155-.016-.31-.024-.465-.036L472.115 595h.449l15.743 32.783zM477.086 628.323c-.135.024-.274.048-.413.076L460.587 595h.449l16.05 33.323z" fill="#F9B906"/></g><g clip-path="url(#prefix__clip18_2015_4656)"><path d="M514.067 727l-16.279 33.802a1.135 1.135 0 01-1.356.584 43.76 43.76 0 00-4.105-.987c-.139-.028-.278-.052-.413-.076a43.261 43.261 0 00-10.756-.576c-.155.012-.31.02-.465.036a42.133 42.133 0 00-5.082.717c-.478.092-.862-.395-.654-.826L490.648 727h23.419z" fill="#F41943"/><path d="M487.396 745.826l-2.896-6.025 2.157-4.492 2.921 5.974-2.182 4.543zM493.135 757.785l-5.518-11.487v-.004l2.185-4.548 5.572 11.391-2.239 4.648z" fill="#BA0F38"/><path d="M498.45 759.428l-.662 1.374a1.135 1.135 0 01-1.356.584 41.595 41.595 0 00-4.105-.987c-.139-.028-.274-.056-.413-.076a42.651 42.651 0 00-7.414-.681c.09-.004.176-.004.266-.004 2.406 0 4.816.197 7.189.6a40.397 40.397 0 011.434.262c.478.092.862-.395.653-.826l-.682-1.422 2.243-4.652 2.847 5.828z" fill="#BA0F38"/><path d="M489.802 741.746l-2.185 4.548-.221-.464v-.004l2.182-4.543.224.463z" fill="#CE9117"/><path d="M496.886 727l-7.084 14.746-.224-.463L496.436 727h.45z" fill="#F9B906"/><path d="M495.603 753.6l-2.243 4.652-.225-.467 2.239-4.648.229.463z" fill="#CE9117"/><path d="M508.413 727l-12.81 26.6-.229-.463L507.964 727h.449z" fill="#F9B906"/><path d="M500.031 761.249v7.371h-1.622v-7.161a36.408 36.408 0 00-5.49-1.737 37.41 37.41 0 00-8.419-.954 37.1 37.1 0 00-11.291 1.748c-.89.282-1.765.6-2.618.947v7.161h-1.622v-7.371c0-.515.319-.983.805-1.172a72.443 72.443 0 012.733-1.019 37.98 37.98 0 014.452-1.152 38.82 38.82 0 017.545-.733c2.582 0 5.106.254 7.545.733 1.52.298 3.003.689 4.449 1.16.465.153 1.813.661 2.737 1.019.486.189.804.657.804 1.172l-.008-.012z" fill="#E8A615"/><path d="M484.5 827c17.949 0 32.5-14.347 32.5-32.046 0-17.698-14.551-32.045-32.5-32.045-17.949 0-32.5 14.347-32.5 32.045C452 812.653 466.551 827 484.5 827z" fill="#F9B906"/><path d="M484.5 824.148c-16.328 0-29.608-13.094-29.608-29.194 0-16.099 13.28-29.194 29.608-29.194 16.328 0 29.608 13.095 29.608 29.194 0 16.1-13.28 29.194-29.608 29.194z" fill="#E8A615"/><path d="M512.298 794.954c0 15.113-12.467 27.41-27.798 27.41a27.925 27.925 0 01-21.895-10.537 27.1 27.1 0 01-3.076-4.833 26.955 26.955 0 01-2.827-12.04c0-3.202.56-6.275 1.589-9.135 3.092-8.607 10.437-15.253 19.526-17.473a28.165 28.165 0 016.687-.801c5.127 0 9.935 1.373 14.061 3.77a27.934 27.934 0 015.085 3.786 27.449 27.449 0 016.708 9.792 26.88 26.88 0 011.94 10.061z" fill="#F9B906"/><path d="M498.561 771.315l-39.032 35.679a26.955 26.955 0 01-2.827-12.04c0-3.202.56-6.275 1.589-9.135l19.526-17.473a28.165 28.165 0 016.687-.801c5.127 0 9.935 1.373 14.061 3.77h-.004zM510.354 784.893l-37.986 34.724a27.933 27.933 0 01-9.764-7.786l41.038-36.726a27.474 27.474 0 016.708 9.792l.004-.004z" fill="#FFC943"/><path d="M493.389 760.5a42.133 42.133 0 00-5.082-.717c-.155-.016-.31-.024-.465-.036a43.261 43.261 0 00-10.756.576c-.135.024-.274.048-.413.076a43.76 43.76 0 00-4.105.987 1.135 1.135 0 01-1.356-.584L454.933 727h23.419l15.691 32.674c.208.431-.176.918-.654.826z" fill="#F41943"/><path d="M488.307 759.783c-.155-.016-.31-.024-.465-.036L472.115 727h.449l15.743 32.783zM477.086 760.323c-.135.024-.274.048-.413.076L460.587 727h.449l16.05 33.323z" fill="#F9B906"/></g></g><defs><linearGradient id="prefix__paint0_linear_2015_4656" x1="349" y1="0" x2="349" y2="874" gradientUnits="userSpaceOnUse"><stop stop-color="#202738"/><stop offset="1" stop-color="#070816"/></linearGradient></defs></svg>'
                )
            );
    }
}

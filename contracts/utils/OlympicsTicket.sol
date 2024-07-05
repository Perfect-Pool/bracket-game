// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../interfaces/IGamesHub.sol";
import "../interfaces/IOlympics.sol";
import "../interfaces/IERC20.sol";

/**
 * @title OlympicsTicket
 * @author PerfectPool
 * @notice This contract allows users to mint ERC721 tickets and place bets on the results of Olympic games managed by the Olympics contract.
 *
 * Users can mint a new ticket by calling the `safeMint` function and providing the game ID and their bets for the matches in that game.
 * The contract keeps track of the bets and the pot for each game, and allows users to claim their winnings after the game results are finalized.
 *
 * The contract also manages a global jackpot, which is a percentage of the total pot from all games. The jackpot can be increased by the admin,
 * and a portion of it is added to the pot for each new game.
 *
 * The contract has an admin role that can change various parameters such as the token used for minting, the price of tickets, the protocol fee,
 * and the GamesHub contract address.
 *
 * There is also an executor role that can perform certain actions such as iterating through the bets for a game to determine the winners,
 * and dismissing the pot for a game after a certain time period if a person has not claimed their winnings.
 */

interface INftMetadata {
    function buildMetadata(
        uint256 _gameId,
        uint256 _tokenId
    ) external view returns (string memory);
}

contract OlympicsTicket is ERC721, ReentrancyGuard {
    /** EVENTS **/
    event BetPlaced(
        address indexed _player,
        uint256 indexed _gameId,
        uint256 indexed _tokenId
    );
    event GamePotPlaced(uint256 indexed _gameId, uint256 _pot);
    event GamePotDismissed(uint256 indexed _gameId, uint256 _amount);
    event NoWinners(uint256 indexed _gameId);
    event PrizeClaimed(uint256 indexed _tokenId, uint256 _amount);
    event PriceChanged(uint256 _newPrice);
    event ProtocolFeeChanged(uint8 _newFee);
    event IterateGameData(
        uint256 _gameId,
        uint256 _iterateStart,
        uint256 _iterateEnd
    );
    event IterationFinished(uint256 indexed _gameId);
    event GamePotDecided(uint256 indexed _gameId);

    /** STRUCT **/
    struct GameData {
        uint256[] tokenIds;
        uint256 iterateStart;
        uint256 pot;
        uint256 potClaimed;
        mapping(uint8 => uint256[]) winners;
        uint8 potPoints;
        bool potDismissed;
    }

    /** VARIABLES **/
    uint256 private _nextTokenId;
    bytes32 private gameName;

    uint256 public jackpot;
    uint256 public price;
    uint256 public iterationSize = 100;
    uint8 public protocolFee = 100;
    address public executionAddress;

    IGamesHub public gamesHub;
    IERC20 public token;

    mapping(uint256 => uint256) private tokenToGameId;
    mapping(uint256 => uint8[24]) private nftBet;
    mapping(uint256 => uint256) private tokenClaimed;
    mapping(uint256 => GameData) private gameData;

    /** CONSTRUCTOR **/
    /**
     * @dev Constructor function
     * @param _gamesHub The address of the GamesHub contract
     * @param _executionAddress The address of the executioner wallet
     * @param _gameName The name of the game
     */
    constructor(
        address _gamesHub,
        address _executionAddress,
        string memory _gameName
    ) ERC721("OlympicsTicket", "OLPTK") {
        gamesHub = IGamesHub(_gamesHub);
        executionAddress = _executionAddress;

        gameName = keccak256(bytes(_gameName));
        token = IERC20(gamesHub.helpers(keccak256("TOKEN")));

        _nextTokenId = 1;
        jackpot = 0;
        price = 10 * (10 ** token.decimals());
    }

    /** MODIFIERS **/
    modifier onlyAdmin() {
        require(
            gamesHub.checkRole(gamesHub.ADMIN_ROLE(), msg.sender),
            "OLPTK-01"
        );
        _;
    }

    modifier onlyGameContract() {
        require(msg.sender == gamesHub.games(gameName), "OLPTK-02");
        _;
    }

    modifier onlyExecutor() {
        require(msg.sender == executionAddress, "OLPTK-03");
        _;
    }

    /**
     * @dev Function to set the execution address
     * @param _executionAddress Address of the executioner wallet
     */
    function setExecutionAddress(address _executionAddress) external onlyAdmin {
        executionAddress = _executionAddress;
    }

    /**
     * @dev Change the token to be used for minting and the price of the ticket.
     * Only callable by the admin.
     * @param _token The address of the new token contract.
     * @param _newPrice The new price of the ticket.
     */
    function changeToken(address _token, uint256 _newPrice) public onlyAdmin {
        token = IERC20(_token);
        price = _newPrice;
    }

    /**
     * @dev Change the price of the ticket. Only callable by the admin.
     * @param _newPrice The new price of the ticket.
     */
    function changePrice(uint256 _newPrice) public onlyAdmin {
        price = _newPrice;
        emit PriceChanged(_newPrice);
    }

    /**
     * @dev Change the protocol fee. Only callable by the admin.
     * @param _newFee The new protocol fee.
     */
    function changeProtocolFee(uint8 _newFee) public onlyAdmin {
        protocolFee = _newFee;
        emit ProtocolFeeChanged(_newFee);
    }

    /**
     * @dev Change the GamesHub contract address. Only callable by the admin.
     * @param _gamesHub The address of the new GamesHub contract.
     */
    function changeGamesHub(address _gamesHub) public onlyAdmin {
        gamesHub = IGamesHub(_gamesHub);
    }

    /**
     * @dev Mint a new ticket and place a bet.
     * @param _gameId The ID of the game to bet on.
     * @param bets The array of bets for the game. The last ID is for the third place
     */
    function safeMint(uint256 _gameId, uint8[24] memory bets) public {
        IOlympics olympicsContract = IOlympics(gamesHub.games(gameName));
        require(!olympicsContract.paused(), "OLPTK-04");
        require(olympicsContract.getGameStatus(_gameId) == 0, "OLPTK-05");

        uint256 _gamePot = price;
        token.transferFrom(msg.sender, address(this), _gamePot);

        gameData[_gameId].pot += _gamePot;
        tokenToGameId[_nextTokenId] = _gameId;
        nftBet[_nextTokenId] = bets;
        gameData[_gameId].tokenIds.push(_nextTokenId);

        _safeMint(msg.sender, _nextTokenId);
        emit BetPlaced(msg.sender, _gameId, _nextTokenId);
        _nextTokenId++;
    }

    /**
     * @dev Claim the tokens won by a ticket. Only callable by the owner of the ticket.
     * @param _tokenId The ID of the ticket to claim tokens from.
     */
    function claimTokens(uint256 _tokenId) public nonReentrant {
        IOlympics olympicsContract = IOlympics(gamesHub.games(gameName));
        require(!olympicsContract.paused(), "OLPTK-04");
        require(getPotStatus(tokenToGameId[_tokenId]), "OLPTK-07");
        require(ownerOf(_tokenId) == msg.sender, "OLPTK-15");

        uint8 status = olympicsContract.getGameStatus(tokenToGameId[_tokenId]);
        require(status == 2, "OLPTK-08");

        uint256 _gameId = tokenToGameId[_tokenId];

        (uint256 amount, uint256 amountClaimed) = amountPrizeClaimed(_tokenId);
        require(amount > 0 && amountClaimed == 0, "OLPTK-09");

        uint256 availableClaim = token.balanceOf(address(this));
        // avoid overflows
        if (availableClaim < amount) {
            amount = availableClaim;
        }
        require(
            gameData[_gameId].pot > gameData[_gameId].potClaimed,
            "OLPTK-10"
        );

        gameData[_gameId].potClaimed += amount;
        token.transfer(msg.sender, amount);
        tokenClaimed[_tokenId] = amount;

        emit PrizeClaimed(_tokenId, amount);
    }

    /**
     * @dev Claim all tokens on the input array. Iterates through the array, sum the amount to claim and claim it.
     * It skips the tokens where amount to claim is 0.
     * @param _tokenIds The array of token IDs to claim tokens from.
     */
    function claimAll(uint256[] memory _tokenIds) public nonReentrant {
        IOlympics olympicsContract = IOlympics(gamesHub.games(gameName));
        require(!olympicsContract.paused(), "OLPTK-04");

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            if (!getPotStatus(tokenToGameId[_tokenIds[i]])) continue;
            if (ownerOf(_tokenIds[i]) != msg.sender) continue;

            uint8 status = olympicsContract.getGameStatus(
                tokenToGameId[_tokenIds[i]]
            );
            if (status != 2) continue;

            uint256 _gameId = tokenToGameId[_tokenIds[i]];

            (uint256 amount, uint256 amountClaimed) = amountPrizeClaimed(
                _tokenIds[i]
            );
            if (amount == 0 || amountClaimed > 0) continue;

            if (gameData[_gameId].potClaimed >= gameData[_gameId].pot) continue;

            gameData[_gameId].potClaimed += amount;
            totalAmount += amount;
            tokenClaimed[_tokenIds[i]] = amount;

            emit PrizeClaimed(_tokenIds[i], amount);
        }

        require(totalAmount > 0, "OLPTK-11");
        // avoid overflows
        uint256 availableClaim = token.balanceOf(address(this));
        if (availableClaim < totalAmount) {
            totalAmount = availableClaim;
        }
        token.transfer(msg.sender, totalAmount);
    }

    /**
     * @dev Set the game pot for a specific game. Only callable by the game contract.
     * @param _gameId The ID of the game to set the pot for.
     */
    function setGamePot(uint256 _gameId) public onlyGameContract {
        if (gameData[_gameId].tokenIds.length == 0) {
            gameData[_gameId].iterateStart = 0;
        }

        uint256 _fee = (gameData[_gameId].pot * protocolFee) / 1000;
        uint256 _gamepot = gameData[_gameId].pot - _fee;
        
        token.transfer(gamesHub.helpers(keccak256("TREASURY")), _fee);

        _gamepot += jackpot;
        jackpot = 0;

        
        if (gameData[_gameId].tokenIds.length > 0) {
            emit IterateGameData(_gameId, 0, (iterationSize - 1));
        }
    }
    
    /**
     * Iterate the game token ids for a specific game. Only callable by the executor
     * @param _gameId The ID of the game to iterate the token ids for.
     * @param _iterateStart The start iteration position.
     * @param _iterateEnd The end iteration position.
     */
    function iterateGameTokenIds(
        uint256 _gameId,
        uint256 _iterateStart,
        uint256 _iterateEnd
    ) public onlyExecutor {
        GameData storage _gameData = gameData[_gameId];
        require(
            _iterateStart < _gameData.tokenIds.length &&
                _iterateEnd >= _iterateStart,
            "OLPTK-12"
        );
        require(!getPotStatus(_gameId), "OLPTK-13");

        for (uint256 i = _iterateStart; i <= _iterateEnd; i++) {
            uint8 points = betWinQty(_gameData.tokenIds[i]);

            if (_gameData.potPoints < points) {
                _gameData.potPoints = points;
            }

            _gameData.winners[points].push(_gameData.tokenIds[i]);
        }

        _gameData.iterateStart = _iterateEnd;
        emit IterateGameData(
            _gameId,
            _iterateEnd,
            (_iterateEnd + iterationSize)
        );
    }

    /**
     * @dev Change the iteration size. Only callable by the admin.
     * @param _newSize The new iteration size.
     */
    function changeIterationSize(uint256 _newSize) public onlyAdmin {
        iterationSize = _newSize;
    }

    /**
     * @dev Dismiss the game pot for a specific game.
     * It takes the value of daysToClaimPrize on the Olympics contract.
     * If the game end date plus daysToClaimPrize is less than the current block timestamp, raises an error.
     * @param _gameId The ID of the game to dismiss the pot for.
     */
    function dismissGamePot(uint256 _gameId) public onlyExecutor {
        IOlympics olympicsContract = IOlympics(gamesHub.games(gameName));
        uint256 daysToClaimPrize = olympicsContract.daysToClaimPrize();

        (, , , , uint256 gameEnd, ) = abi.decode(
            olympicsContract.getGameFullData(_gameId),
            (bytes, bytes, bytes, uint256, uint256, uint8)
        );

        require(
            gameEnd + (daysToClaimPrize * 1 days) < block.timestamp,
            "OLPTK-06"
        );

        uint256 availableClaim = gameData[_gameId].pot -
            gameData[_gameId].potClaimed;

        if (availableClaim == 0) {
            emit GamePotDismissed(_gameId, 0);
            return;
        }

        uint256 protocolSlice = availableClaim / 2;
        if (protocolSlice > 0) {
            token.transfer(
                gamesHub.helpers(keccak256("TREASURY")),
                protocolSlice
            );
        }

        jackpot += (availableClaim - protocolSlice);
        gameData[_gameId].potClaimed = gameData[_gameId].pot;
        gameData[_gameId].potDismissed = true;

        emit GamePotDismissed(_gameId, availableClaim);
    }

    /**
     * @dev Increase the pot by a certain amount. Only callable by the admin.
     * @param _amount The amount to increase the pot by.
     */
    function increaseJackpot(uint256 _amount) public onlyAdmin {
        token.transferFrom(msg.sender, address(this), _amount);
        jackpot += _amount;
    }

    /**
     * @dev Get the token URI for a specific token.
     * @param _tokenId The ID of the token.
     * @return The token URI.
     */
    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory) {
        require(_exists(_tokenId), "OLPTK-14");

        INftMetadata nftMetadata = INftMetadata(
            gamesHub.helpers(keccak256("OLYMPICS_METADATA"))
        );
        return nftMetadata.buildMetadata(tokenToGameId[_tokenId], _tokenId);
    }

    /**
     * @dev Get the bet data for a specific token.
     * @param _tokenId The ID of the token.
     * @return The array of bets for the token.
     */
    function getBetData(
        uint256 _tokenId
    ) public view returns (uint8[24] memory) {
        return nftBet[_tokenId];
    }

    /**
     * @dev Get the game ID for a specific token.
     * @param _tokenId The ID of the token.
     * @return The ID of the game the token is betting on.
     */
    function getGameId(uint256 _tokenId) public view returns (uint256) {
        return tokenToGameId[_tokenId];
    }

    /**
     * @dev Validate the bets for a specific token.
     * @param _tokenId The ID of the token.
     * @return The array of validation results for the bets.
     */
    function betValidator(
        uint256 _tokenId
    ) public view returns (uint8[24] memory) {
        IOlympics olympicsContract = IOlympics(gamesHub.games(gameName));
        uint8[24] memory bets = nftBet[_tokenId];
        uint8[24] memory results = olympicsContract.getFinalResult(
            tokenToGameId[_tokenId]
        );

        uint8[24] memory validator;
        for (uint8 i = 0; i < 24; i++) {
            validator[i] = results[i] == 0 ? 0 : bets[i] == results[i] ? 1 : 2;
        }

        return validator;
    }

    /**
     * @dev Get the quantity of winning bets for a specific token.
     * @param _tokenId The ID of the token.
     * @return The quantity of winning bets for the token.
     */
    function betWinQty(uint256 _tokenId) public view returns (uint8) {
        uint8[24] memory validator = betValidator(_tokenId);

        uint8 winQty = 0;
        for (uint8 i = 0; i < 24; i++) {
            if (validator[i] == 1) {
                winQty++;
            }
        }

        return winQty;
    }

    /**
     * @dev Get the amount to claim and the amount claimed for a specific token.
     * @param _tokenId The ID of the token.
     * @return amountToClaim The amount of tokens to claim.
     * @return amountClaimed The amount of tokens already claimed.
     */
    function amountPrizeClaimed(
        uint256 _tokenId
    ) public view returns (uint256 amountToClaim, uint256 amountClaimed) {
        uint256 _gameId = tokenToGameId[_tokenId];

        uint8 points = betWinQty(_tokenId);
        if (points != gameData[_gameId].potPoints) {
            return (0, 0);
        }
        return (
            (
                gameData[_gameId].winners[points].length == 0
                    ? 0
                    : gameData[_gameId].pot /
                        gameData[_gameId].winners[points].length
            ),
            tokenClaimed[_tokenId]
        );
    }

    /**
     * #dev Get the potential payout for a specific game.
     * @param _gameId The ID of the game
     */
    function potentialPayout(
        uint256 _gameId
    ) public view returns (uint256 payout) {
        uint256 _fee = (gameData[_gameId].pot * protocolFee) / 1000;
        payout = gameData[_gameId].pot - _fee + jackpot;
    }

    /**
     * @dev Get the quantity of players for a specific game.
     * @param gameId The ID of the game
     */
    function playerQuantity(
        uint256 gameId
    ) public view returns (uint256 players) {
        return gameData[gameId].tokenIds.length;
    }

    /**
     * @dev Get the token IDs for a specific game.
     * @param gameId The ID of the game
     * @return The array of token IDs for the game.
     */
    function getGamePlayers(
        uint256 gameId
    ) public view returns (uint256[] memory) {
        return gameData[gameId].tokenIds;
    }

    /**
     * @dev Get the game prize data for a specific game.
     * @param gameId The ID of the game
     * @return winners The quantity of winners.
     * @return points The points that the winners scored.
     */
    function getGamePrizeData(
        uint256 gameId
    ) public view returns (uint256[] memory, uint8) {
        return (
            gameData[gameId].winners[gameData[gameId].potPoints],
            gameData[gameId].potPoints
        );
    }

    /**
     * @dev Get the pot status for the pot of a specific game.
     * @param _gameId The ID of the game
     * @return The status of the pot.
     */
    function getPotStatus(uint256 _gameId) public view returns (bool) {
        return
            gameData[_gameId].iterateStart ==
            gameData[_gameId].tokenIds.length - 1;
    }

    /**
     * @dev Get if the pot is dismissed for a specific game.
     * @param _gameId The ID of the game
     * @return The status of the pot.
     */
    function getPotDismissed(uint256 _gameId) public view returns (bool) {
        return gameData[_gameId].potDismissed;
    }

    /**
     * @dev Get the team symbols for a specific token.
     * @param _tokenId The ID of the token.
     * @return The array of team symbols for the token.
     */
    function getTeamSymbols(
        uint256 _tokenId
    ) public view returns (string[24] memory) {
        IOlympics olympicsContract = IOlympics(gamesHub.games(gameName));
        uint256 _gameId = tokenToGameId[_tokenId];
        (
            uint256[16] memory _teamsGroup1,
            uint256[16] memory _teamsGroup2,
            uint256[16] memory _teamsGroup3
        ) = olympicsContract.getGroupsTeams(_gameId);

        string[24] memory matchResults;
        uint8[24] memory bets = nftBet[_tokenId];
        uint256[16] memory _teamsGroup;

        for (uint8 i = 0; i < 24; i++) {
            if (i < 8) {
                _teamsGroup = _teamsGroup1;
            } else if (i < 16) {
                _teamsGroup = _teamsGroup2;
            } else {
                _teamsGroup = _teamsGroup3;
            }

            uint8 j = (i % 8) * 2; // Adjusted to ensure correct indexing

            if (bets[i] == 1) {
                matchResults[i] = olympicsContract.getTeamSymbol(
                    _teamsGroup[j]
                );
            } else if (bets[i] == 2) {
                matchResults[i] = olympicsContract.getTeamSymbol(
                    _teamsGroup[j + 1]
                );
            } else {
                matchResults[i] = "Draw";
            }
        }

        return matchResults;
    }
}

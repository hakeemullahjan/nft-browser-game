// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./libraries/Base64.sol";

import "hardhat/console.sol";

contract MyNFTGame is ERC721{

    struct CharacterAttributes{
        uint characterIndex;
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
        uint activePersonnel;
        uint maxActivePersonnel;
        uint tanks;
        uint maxTanks;
        uint helicopters;
        uint maxHelicopters;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    CharacterAttributes[] defaultCharacters;

    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    mapping(address=>uint256) public nftHolders;

    event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
    event AttackComplete(uint newBossHp, uint newPlayerHp);
    event AttackCompleted(uint newBossHp, uint newPlayerHp, uint newBossPersonnel, uint newBossTanks, uint newBossHelicopter, uint newPlayerPersonnel, uint newPlayerTanks, uint newPlayerHelicopter);

    struct BigBoss{
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
        uint activePersonnel;
        uint maxActivePersonnel;
        uint tanks;
        uint maxTanks;
        uint helicopters;
        uint maxHelicopters;
    }

    BigBoss public bigBoss;

    uint256 private seed;


    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterHp,
        uint[] memory characterAttackDmg,
        uint[] memory characterActivePersonnel,
        uint[] memory characterTanks,
        uint[] memory characterHelicopters,

        string memory bossName,
        string memory bossImageURI,
        uint[] memory bossData
    )
    ERC721("WARHEROES","WARHERO")
    {
        bigBoss= BigBoss({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossData[0],
            maxHp: bossData[0],
            attackDamage: bossData[1],
            activePersonnel: bossData[2],
            maxActivePersonnel: bossData[2],
            tanks: bossData[3],
            maxTanks: bossData[3],
            helicopters: bossData[4],
            maxHelicopters: bossData[4]
        });
        console.log("Done initializing boss activePersonnel %s w/ tanks %s, helicopters %s", bigBoss.activePersonnel, bigBoss.tanks, bigBoss.helicopters);

        for(uint i=0; i<characterNames.length; i +=1){  
            defaultCharacters.push(
                CharacterAttributes({
                    characterIndex:i,
                    name:characterNames[i],
                    imageURI:characterImageURIs[i],
                    hp: characterHp[i],
                    maxHp: characterHp[i],
                    attackDamage: characterAttackDmg[i],
                    activePersonnel: characterActivePersonnel[i],
                    maxActivePersonnel: characterActivePersonnel[i],
                    tanks: characterTanks[i],
                    maxTanks: characterTanks[i],
                    helicopters: characterHelicopters[i],
                    maxHelicopters: characterHelicopters[i]
                })               
            );
            CharacterAttributes memory c = defaultCharacters[i];
            console.log("Done initializing activePersonnel %s w/ tanks  %s, helicopters %s", c.activePersonnel, c.tanks, c.helicopters);
        }
        _tokenIds.increment();

        seed = (block.timestamp + block.difficulty) % 100;
    }

      function mintCharacterNFT(uint _characterIndex) external {
        
        uint newItemId= _tokenIds.current();
        _safeMint(msg.sender, newItemId);

        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].maxHp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage,
            activePersonnel: defaultCharacters[_characterIndex].activePersonnel,
            maxActivePersonnel: defaultCharacters[_characterIndex].maxActivePersonnel,
            tanks: defaultCharacters[_characterIndex].tanks,
            maxTanks: defaultCharacters[_characterIndex].maxTanks,
            helicopters: defaultCharacters[_characterIndex].helicopters,
            maxHelicopters: defaultCharacters[_characterIndex].maxHelicopters
        });
        console.log("Minted NFT w/ tokenid %s and character index %s",newItemId, _characterIndex);
        console.log("tanksss %s",nftHolderAttributes[newItemId].tanks);

        nftHolders[msg.sender] = newItemId;

        console.log("nftholder %s",nftHolders[msg.sender]);

        _tokenIds.increment();
        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
    }

    function tokenURI(uint _tokenId) public view override returns (string memory){
        CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);
        string memory strActivePersonnel = Strings.toString(charAttributes.activePersonnel);
        string memory strMaxActivePersonnel = Strings.toString(charAttributes.maxActivePersonnel);
        string memory strTanks = Strings.toString(charAttributes.tanks);
        string memory strMaxTanks = Strings.toString(charAttributes.maxTanks);
        string memory strHelicopters = Strings.toString(charAttributes.helicopters);
        string memory strMaxHelicopters = Strings.toString(charAttributes.maxHelicopters);
        

        string memory json = Base64.encode(
            abi.encodePacked(
    '{"name": "',
    charAttributes.name,
    ' -- NFT #: ',
    Strings.toString(_tokenId),
    '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "ipfs://',
    charAttributes.imageURI,
    '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',strAttackDamage,'}, { "trait_type": "Active Personnel", "value": ',strActivePersonnel,', "max_value":',strMaxActivePersonnel,'}, { "trait_type": "Tanks", "value": ',strTanks,', "max_value":',strMaxTanks,'}, { "trait_type": "Helicopters", "value": ',strHelicopters,', "max_value":',strMaxHelicopters,'} ]}'
            )
        );

        string memory output = string(abi.encodePacked("data:application/json;base64,",json));

        return output;
    }

    function attackBoss() public {
        // Get the state of the player's NFT.
        console.log("attacking boss");
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];

        // Make sure the player has more than 0 Personnel.
        require(player.activePersonnel > 0, "Error: character must have at least 1 Personnel to attack.");

        // Make sure the boss has more than 0 Personnel.
        require(bigBoss.activePersonnel > 0, "Error: boss must have at least 1 Personnel to attack.");

        seed = (block.difficulty + block.timestamp + seed) % 100;
        // Calculate the player damage rate.
        uint playerAttackDmgPersonnel  =  (bigBoss.activePersonnel * ((block.difficulty + block.timestamp + seed + player.activePersonnel) % 25) / 100);
        uint playerAttackDmgTanks  = (bigBoss.tanks * ((block.difficulty + block.timestamp + seed + player.tanks) % 5) / 100) ;
        uint playerAttackDmgHelicopters  = (bigBoss.helicopters * ((block.difficulty + block.timestamp + seed + player.helicopters) % 10) / 100) ;

        // Allow player to attack boss.
        if(bigBoss.activePersonnel < playerAttackDmgPersonnel){
            bigBoss.activePersonnel = 0;
        }else{
            bigBoss.activePersonnel = bigBoss.activePersonnel - playerAttackDmgPersonnel;
        }
        if(bigBoss.tanks < playerAttackDmgTanks){
            bigBoss.tanks = 0;
        }else{
            bigBoss.tanks = bigBoss.tanks - playerAttackDmgTanks;
        }
        if(bigBoss.helicopters < playerAttackDmgHelicopters){
            bigBoss.helicopters = 0;
        }else{
            bigBoss.helicopters = bigBoss.helicopters - playerAttackDmgHelicopters;
        }
        if(bigBoss.hp < player.attackDamage){
            bigBoss.hp = 0;
        }else{
            bigBoss.hp = bigBoss.hp - player.attackDamage;
        }

        seed = (block.difficulty + block.timestamp + seed) % 100;
        // Calculate the boss damage rate.
        uint bossAttackDmgPersonnel  =  (player.activePersonnel * ((block.difficulty + block.timestamp + seed + bigBoss.activePersonnel) % 25) / 100);
        uint bossAttackDmgTanks  = (player.tanks * ((block.difficulty + block.timestamp + seed + bigBoss.tanks) % 5) / 100) ;
        uint bossAttackDmgHelicopters  = (player.helicopters * ((block.difficulty + block.timestamp + seed + bigBoss.helicopters) % 10) / 100) ;

        // Allow boss to attack player.
        if(player.activePersonnel < bossAttackDmgPersonnel){
            player.activePersonnel = 0;
        }else{
            player.activePersonnel = player.activePersonnel - bossAttackDmgPersonnel;
        }
        if(player.tanks < bossAttackDmgTanks){
            player.tanks = 0;
        }else{
            player.tanks = player.tanks - bossAttackDmgTanks;
        }
        if(player.helicopters < bossAttackDmgHelicopters){
            player.helicopters = 0;
        }else{
            player.helicopters = player.helicopters - bossAttackDmgHelicopters;
        }
        if(player.hp < bigBoss.attackDamage){
            player.hp = 0;
        }else{
            player.hp = player.hp - bigBoss.attackDamage;
        }

        emit AttackComplete(bigBoss.hp, player.hp);
        emit AttackCompleted(bigBoss.hp, player.hp,bigBoss.activePersonnel, bigBoss.tanks, bigBoss.helicopters, player.activePersonnel, player.tanks, player.helicopters);
    }

    function checkIfUserHasNFT() public view returns (CharacterAttributes memory){
        uint256 userNftTokenId = nftHolders[msg.sender];

        if(userNftTokenId > 0){
            return nftHolderAttributes[userNftTokenId];
        }else{
            CharacterAttributes memory emptyStruct;
            return emptyStruct;
        }
    }

    function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory){
        return defaultCharacters;
    }
    
    function getBigBoss() public view returns (BigBoss memory){
        return bigBoss;
    }

}
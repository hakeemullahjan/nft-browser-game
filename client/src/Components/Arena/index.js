import React, { useEffect, useState } from "react";
import { ethers } from "ethers";
import { CONTRACT_ADDRESS, transformCharacterData } from "../../constants";
import myEpicGame from "../../utils/MyEpicGame.json";
import myNFTGame from "../../utils/MyNFTGame.json";

import "./Arena.css";
import LoadingIndicator from "../../Components/LoadingIndicator";

/*
 * We pass in our characterNFT metadata so we can show a cool card in our UI
 */
const Arena = ({ characterNFT, setCharacterNFT, currentAccount }) => {
  // State
  const [gameContract, setGameContract] = useState(null);
  const [boss, setBoss] = useState(null);
  const [attackState, setAttackState] = useState("");
  const [showToast, setShowToast] = useState(false);
  const [userNftTokenId, setUserNftTokenId] = useState(0);

  console.log("characterNFT: Holders23232", characterNFT);

  // UseEffects
  useEffect(() => {
    const fetchBoss = async () => {
      const bossTxn = await gameContract.getBigBoss();
      console.log("Boss:", bossTxn, transformCharacterData(bossTxn));
      setBoss(transformCharacterData(bossTxn));

      const nftTokenId = await gameContract.nftHolders(currentAccount);
      console.log("NFT Token ID:", nftTokenId.toNumber());
      setUserNftTokenId(nftTokenId.toNumber());
    };

    /*
     * Setup logic when this event is fired off
     */
    const onAttackComplete = (
      newBossHp,
      newPlayerHp,
      newBossPersonnel,
      newBossTanks,
      newBossHelicopter,
      newPlayerPersonnel,
      newPlayerTanks,
      newPlayerHelicopter
    ) => {
      const bossHp = newBossHp.toNumber();
      const playerHp = newPlayerHp.toNumber();

      const bossPersonnel = newBossPersonnel.toNumber();
      const bossTanks = newBossTanks.toNumber();
      const bossHelicopter = newBossHelicopter.toNumber();
      const playerPersonnel = newPlayerPersonnel.toNumber();
      const playerTanks = newPlayerTanks.toNumber();
      const playerHelicopter = newPlayerHelicopter.toNumber();

      console.log(`AttackComplete: Boss Hp: ${bossHp} Player Hp: ${playerHp}`);

      /*
       * Update both player and boss Hp
       */
      setBoss((prevState) => {
        return {
          ...prevState,
          hp: bossHp,
          activePersonnel: bossPersonnel,
          tanks: bossTanks,
          helicopters: bossHelicopter,
        };
      });

      setCharacterNFT((prevState) => {
        return {
          ...prevState,
          hp: playerHp,
          activePersonnel: playerPersonnel,
          tanks: playerTanks,
          helicopters: playerHelicopter,
        };
      });
    };

    if (gameContract) {
      fetchBoss();
      gameContract.on("AttackCompleted", onAttackComplete);
    }

    /*
     * Make sure to clean up this event when this component is removed
     */
    return () => {
      if (gameContract) {
        gameContract.off("AttackCompleted", onAttackComplete);
      }
    };
  }, [gameContract]);

  // UseEffects
  useEffect(() => {
    const { ethereum } = window;

    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      const gameContract = new ethers.Contract(
        CONTRACT_ADDRESS,
        myNFTGame.abi,
        signer
      );

      setGameContract(gameContract);
    } else {
      console.log("Ethereum object not found");
    }
  }, []);

  // Actions
  const runAttackAction = async () => {
    try {
      if (gameContract) {
        setAttackState("attacking");
        console.log("Attacking boss...");
        const attackTxn = await gameContract.attackBoss();
        await attackTxn.wait();
        console.log("attackTxn:", attackTxn);
        setAttackState("hit");

        setShowToast(true);
        setTimeout(() => {
          setShowToast(false);
        }, 5000);
      }
    } catch (error) {
      console.error("Error attacking boss:", error);
      setAttackState("");
    }
  };

  return (
    <div className="arena-container">
      {/* Add your toast HTML right here */}
      {boss && characterNFT && (
        <div id="toast" className={showToast ? "show" : ""}>
          <div id="desc">{`💥 ${boss.name} was hit for ${characterNFT.attackDamage}!`}</div>
        </div>
      )}

      {/* Boss */}
      {boss && (
        <div className="boss-container">
          <div className={`boss-content ${attackState}`}>
            <h2>🔥 {boss.name} 🔥</h2>
            <div className="image-content">
              <img
                src={`http://cloudflare-ipfs.com/ipfs/${boss.imageURI}`}
                alt={`Boss ${boss.name}`}
              />
              {/* <div className="health-bar">
                <progress value={boss.hp} max={boss.maxHp} />
                <p>{`${boss.hp} / ${boss.maxHp} HP`}</p>
              </div> */}
              <div>
                <h3>{`Active Personnel ${boss.activePersonnel} of ${boss.maxActivePersonnel}`}</h3>
                <h3>{`Tanks ${boss.tanks} of ${boss.maxTanks}`}</h3>
                <h3>{`Helicopters ${boss.helicopters} of ${boss.maxHelicopters}`}</h3>
                <h3>{`HP ${boss.hp} of ${boss.maxHp}`}</h3>
              </div>
            </div>
          </div>
          <div className="attack-container">
            <button className="cta-button" onClick={runAttackAction}>
              {`💥 Attack ${boss.name}`}
            </button>
          </div>
          {/* Add this right under your attack button */}
          {attackState === "attacking" && (
            <div className="loading-indicator">
              <LoadingIndicator />
              <p>Attacking ⚔️</p>
            </div>
          )}
        </div>
      )}

      {/* Replace your Character UI with this */}
      {characterNFT && (
        <div className="players-container">
          <div className="player-container">
            <h2 style={{ color: "blue", backgroundColor: "yellow" }}>
              Your Character
            </h2>
            <div className="player">
              <div className="image-content">
                <h2>{characterNFT.name}</h2>
                <img
                  src={`http://cloudflare-ipfs.com/ipfs/${characterNFT.imageURI}`}
                  alt={`Character ${characterNFT.name}`}
                />
                {/* <div className="health-bar">
                  <progress value={characterNFT.hp} max={characterNFT.maxHp} />
                  <p>{`${characterNFT.hp} / ${characterNFT.maxHp} HP`}</p>
                </div> */}
                <div>
                  <a
                    href={`https://testnets.opensea.io/assets/${CONTRACT_ADDRESS}/${userNftTokenId}`}
                    target="_blank"
                  >
                    View on Opensea
                  </a>
                  <h3>{`Active Personnel ${characterNFT.activePersonnel} of ${characterNFT.maxActivePersonnel}`}</h3>
                  <h3>{`Tanks ${characterNFT.tanks} of ${characterNFT.maxTanks}`}</h3>
                  <h3>{`Helicopters ${characterNFT.helicopters} of ${characterNFT.maxHelicopters}`}</h3>
                  <h3>{`HP ${characterNFT.hp} of ${characterNFT.maxHp}`}</h3>
                </div>
              </div>
              <div className="stats">
                <h4>{`⚔️ Attack Damage: ${characterNFT.attackDamage}`}</h4>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Arena;

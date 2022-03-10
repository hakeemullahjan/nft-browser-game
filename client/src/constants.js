// const CONTRACT_ADDRESS = "0xa11Cbaebe20e93FB307cC6d477abF131CFbCf3b6";
const CONTRACT_ADDRESS = "0x4CAc4AFCc5A9751098877372570013236C68d713";

/*
 * Add this method and make sure to export it on the bottom!
 */
const transformCharacterData = (characterData) => {
  console.log("characterData11", characterData);
  return {
    name: characterData.name,
    imageURI: characterData.imageURI,
    hp: characterData.hp.toNumber(),
    maxHp: characterData.maxHp.toNumber(),
    attackDamage: characterData.attackDamage.toNumber(),
    activePersonnel: characterData.activePersonnel.toNumber(),
    maxActivePersonnel: characterData.maxActivePersonnel.toNumber(),
    tanks: characterData.tanks.toNumber(),
    maxTanks: characterData.maxTanks.toNumber(),
    helicopters: characterData.helicopters.toNumber(),
    maxHelicopters: characterData.maxHelicopters.toNumber(),
  };
};

export { CONTRACT_ADDRESS, transformCharacterData };

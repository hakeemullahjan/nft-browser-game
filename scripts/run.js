const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("MyNFTGame");
  const gameContract = await gameContractFactory.deploy(
    ["Volodymyr Zelenskyy"], // Names
    ["https://i.insider.com/61f9792fef63e10018100a22?width=1136&format=jpeg"],
    [300], // HP values
    [100], // Attack damage values
    [900000], //ActivePersonnel values
    [2596], //Tanks values
    [34], //Helicopters values

    "Vladimir Putin", // Boss name
    "https://www.aljazeera.com/wp-content/uploads/2022/02/000_323T4MF.jpg?resize=770%2C513", // Boss image
    [
      10000, // Boss hp
      50, // Boss attack damage
      2000000, //Boss ActivePersonnel
      12420, //Boss Tanks
      544, //Boss Helicopters
    ]
  );
  await gameContract.deployed();
  console.log("Game deplyed a:", gameContract.address);

  //   console.log("bigBoss", await gameContract.bigBoss.call());

  let txn;
  txn = await gameContract.mintCharacterNFT(0);
  await txn.wait();

  txn = await gameContract.mintCharacterNFT(0);
  await txn.wait();

  txn = await gameContract.attackBoss(0);
  await txn.wait();

  //   txn = await gameContract.attackBoss();
  //   await txn.wait();

  //   let returnTokenUri = await gameContract.tokenURI(1);
  //   console.log(" Token URI: ", returnTokenUri);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();

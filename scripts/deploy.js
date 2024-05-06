// This is a script for deploying your contracts. You can adapt it to deploy
// yours, or create new ones.

const path = require("path");

async function main() {

  const contractName = "Token";
  // This is just a convenience check
  if (network.name === "hardhat") {
    console.warn(
      "You are trying to deploy a contract to the Hardhat Network, which" +
      "gets automatically created and destroyed every time. Use the Hardhat" +
      " option '--network localhost'"
    );
  }

  // ethers is available in the global scope
  const [deployer] = await ethers.getSigners();
  console.log(
    "Deploying the contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Token = await ethers.getContractFactory(contractName);
  const token = await Token.deploy();
  await token.deployed();

  console.log("Token address:", token.address);

  // We also save the contract's artifacts and address in the frontend directory
  saveFrontendFiles(token);
}

function saveFrontendFiles(token) {
  const fs = require("fs");
  const contractsDir = path.join(__dirname, "..", "frontend", "public");

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }
  var smartContract = JSON.parse(
    fs.readFileSync(path.join(contractsDir, "smartcontract.json"), "utf8")
  );

  const TokenArtifact = artifacts.readArtifactSync("Token");
  const abi = TokenArtifact.abi;
  const contractAddress = token.address;
  try {
    smartContract.results.push({
      json_abi: abi,
      contract_address: contractAddress,
      contract_name: "Token",
    });
  } catch (error) {
    smartContract = {
      results: [{
        json_abi: abi,
        contract_address: contractAddress,
        contract_name: "Token",
      }]
    };
  }

  fs.writeFileSync(
    path.join(contractsDir, "smartcontract.json"),
    JSON.stringify(smartContract, null, 2)
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

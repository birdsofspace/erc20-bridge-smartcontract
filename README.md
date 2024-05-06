## Birds of Space DApp Boilerplate (Hardhat, Solidity, Pug)
![screenshot](https://raw.githubusercontent.com/birdsofspace/dapps-smartcontract-boilerplate/main/screenshot-2.png)
This repository serves as a starting point for your Ethereum DApp development using Hardhat, Solidity, and Pug for the frontend. 

**Note:** This boilerplate replaces the original React frontend with Pug.

### Project Overview

This boilerplate aligns with the Hardhat Beginners Tutorial: [https://hardhat.org/tutorial](https://hardhat.org/tutorial) and offers a solid foundation for learning smart contract development. You can explore the code within the `contracts`, `tests`, `scripts`, and `frontend` directories.

### Getting Started

1. **Clone the Repository:**

```bash
git clone https://github.com/birdsofspace/birds-of-space-dapp-boilerplate.git
cd birds-of-space-dapp-boilerplate
```

2. **Install Dependencies:**

```bash
yarn install
```

3. **Run Truffle Dashboard:**

```bash
yarn truffle-dashboard
```

4. **Deploy Contract:** (Open a separate terminal)

```bash
yarn deploy
```

5. **Run Frontend:**

```bash
yarn frontend install
yarn frontend build
yarn frontend start
```

Access your DApp at http://localhost:3000/. Ensure you have a compatible wallet like MetaMask installed and connected to `localhost:8545`.

### Resources

* **Hardhat Documentation:** [https://hardhat.org/hardhat-runner/docs/config](https://hardhat.org/hardhat-runner/docs/config)
    * Writing and compiling contracts: [https://hardhat.org/hardhat-runner/docs/getting-started](https://hardhat.org/hardhat-runner/docs/getting-started)
    * Setting up the environment: [https://hardhat.org/tutorial/creating-a-new-hardhat-project](https://hardhat.org/tutorial/creating-a-new-hardhat-project)
    * Testing contracts: [https://hardhat.org/tutorial/testing-contracts](https://hardhat.org/tutorial/testing-contracts)
    * Full documentation: [https://hardhat.org/docs](https://hardhat.org/docs)
* **Hardhat Getting Started Guide:** [https://hardhat.org/hardhat-runner/docs/getting-started](https://hardhat.org/hardhat-runner/docs/getting-started)

### Included Tools

* **Hardhat Toolbox:** Provides functionalities like:
    * Contract deployment and interaction with ethers.js: [https://docs.ethers.io/v5/](https://docs.ethers.io/v5/) and the `hardhat-ethers` plugin.
    * Contract testing with Mocha, Chai, and Hardhat Chai Matchers.
    * Hardhat Network interaction with Hardhat Network Helpers.
    * Contract source code verification with hardhat-etherscan.
    * Gas usage measurement with hardhat-gas-reporter.
    * Solidity code coverage with solidity-coverage.

**Note:** The original React frontend has been replaced with Pug. 

### Troubleshooting

* **"Invalid nonce" Errors:** Reset your MetaMask account to clear the transaction history and nonce. Navigate to MetaMask, select your account, go to "Settings > Advanced > Clear activity tab data".

### Development Tools

* **Hardhat for Visual Studio Code:** [https://hardhat.org/hardhat-vscode](https://hardhat.org/hardhat-vscode) - Enhances Solidity development within VS Code.

### Getting Help and Updates

* **Hardhat Help:** [https://github.com/NomicFoundation/hardhat/issues](https://github.com/NomicFoundation/hardhat/issues)
* **Follow Hardhat on Twitter:** [https://twitter.com/hardhathq?lang=en](https://twitter.com/hardhathq?lang=en)
* **Star the Hardhat GitHub Repository:** [https://github.com/NomicFoundation/hardhat](https://github.com/NomicFoundation/hardhat)

**Happy DApp development!**

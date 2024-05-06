## Sample Pug DApp

This directory contains a sample DApp built using Pug, designed to interact with your contracts.

**Note:** This DApp replaces the original React frontend with Pug.

## Building and Running the DApp

1. **Install Dependencies:**

   ```bash
   npm install
   ```

2. **Build the DApp:**

   ```bash
   npm run build
   ```

   This command creates an optimized production build of the DApp in the `build` directory.

3. **Start the Development Server:**

   ```bash
   npm start
   ```

   This will start the development server and serve the built DApp from the `build` directory, accessible at http://localhost:3000.

## DApp Structure

The DApp utilizes Pug templates located in the `src/templates` directory. These templates define the structure and presentation of the user interface.

## Functionality

Core functionalities are implemented using JavaScript code within the `src/scripts` directory. This code interacts with the user's wallet, establishes the Ethereum connection, fetches contract data, and transmits transactions.

**Note:** You can leverage the existing code in `src/scripts` as a foundation for your project. Comments within the code explain functionalities and highlight project-specific sections that can be adapted for your use case.

## Getting Help and Updates

* **Hardhat Help:** [https://github.com/NomicFoundation/hardhat/issues](https://github.com/NomicFoundation/hardhat/issues)
* **Follow Hardhat on Twitter:** [https://twitter.com/hardhathq?lang=en](https://twitter.com/hardhathq?lang=en)
* **Star the Hardhat GitHub Repository:** [https://github.com/NomicFoundation/hardhat](https://github.com/NomicFoundation/hardhat)

**Happy DApp development!**

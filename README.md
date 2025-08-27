-----

# Serverless Subscription Example using Marlin Oyster
This project demonstrates how to create subscription-based serverless requests using smart contracts on the Marlin Oyster platform. The application functions as a simple price oracle, fetching the current price of ETH in USD and emitting it as a smart contract event every 30 seconds. This is an example of off-chain computing using TEE coprocessors.

-----

## ⚙️ How It Works

The core of this application is the `EthRate.sol` smart contract.

1.  A serverless JavaScript function (`eth-price.js`) is deployed to the Marlin Oyster network to fetch ETH price data.
2.  The `EthRate.sol` smart contract is deployed, containing the hash of the serverless function.
3.  The contract is funded with ETH and USDC to pay for the serverless job execution.
4.  A subscription job is created, instructing the serverless function to run every 30 seconds for a total duration of 200 seconds.
5.  At each interval, the serverless function executes, fetches the price, and calls back to the smart contract.
6.  The smart contract receives the data and emits an `EthPrice` event containing the latest price of ETH in USD.

-----

## 🚀 Getting Started

Follow these steps to deploy and run the application.

### Step 1: Installation

First, clone the repository and install the necessary dependencies.

```bash
# Clone the project repository
git clone https://github.com/marlinprotocol/Serverless-Subscription-Example.git

# Navigate into the project directory
cd Serverless-Subscription-Example

# Install npm dependencies
npm install 

# Verify your Hardhat installation
npx hardhat 
```

### Step 2: Compile the Smart Contract

The project comes with a pre-written smart contract located at `contracts/EthRate.sol`. Compile it using Hardhat.

```bash
npx hardhat compile 
```

### Step 3: Deploy the Serverless Function

The JavaScript function that fetches the ETH price is located at `js-function/eth-price.js`. A minified version is already provided at `js-function/eth-price.min.js`.

1.  Navigate to the [Marlin Oyster Serverless Sandbox](https://hub.marlin.org/oyster/serverless-sandbox/).
2.  Copy the content of `js-function/eth-price.min.js` and paste it into the sandbox editor.
3.  Click **Deploy Function**.
4.  **Important:** Save the generated transaction hash. You will need it in the next step.

### Step 4: Deploy Your Smart Contract

Now, you'll configure and deploy the `EthRate.sol` contract.

1.  Open the deployment script at `script/deploy/EthRate.ts`.
2.  Replace the placeholder `codeHash` with the transaction hash you saved from the previous step.
3.  Create a `.env` file in the root of the project and add the following variables:
    ```env
    ARBITRUM_DEPLOYER_KEY=<YOUR_DEPLOYER_ACCOUNT_PRIVATE_KEY>
    ARBISCAN_API_KEY=<YOUR_ARBISCAN_API_KEY>
    ```
4.  Run the deployment script on the Arbitrum network:
    ```bash
    npx hardhat run script/deploy/EthRate.ts --network arbi
    ```
5.  Take note of the deployed contract address that is output to your terminal.

### Step 5: Add Funds to Your Contract

The smart contract needs funds to pay for the serverless requests.

1.  **Send ETH**: Use your wallet to send **0.002 ETH** to your deployed contract address.
2.  **Send USDC**:
      * Navigate to the [USDC Contract on Arbiscan](https://www.google.com/search?q=https://arbiscan.io/address/0xaf88d065e77c8cC2239327C5EDb3A432268e5831%23writeProxy).
      * Connect your wallet and use the `transfer` function to send **10 USDC** to your deployed contract address. For the `value (uint256)` field, enter `10000000`.

### Step 6: Create a Serverless Request

Interact with your deployed contract to start the subscription.

1.  Start a Hardhat console connected to the Arbitrum network:
    ```bash
    npx hardhat console --network arbl
    ```
2.  In the console, create an instance of your contract. Replace `<Deployed_Contract_Address>` with your actual contract address:
    ```javascript
    ethRate = (await ethers.getContractFactory("EthRate")).attach("<Deployed_Contract_Address>");
    ```
3.  Call the `run()` function to begin the serverless job subscription:
    ```javascript
    await ethRate.run({gasLimit: 2000000});
    ```

### Step 7: Verify the Response Callback

After about 30 seconds, the first callback should occur. You can check the event logs to verify this.

1.  In the same Hardhat console, run the following command to query for `EthPrice` events:
    ```javascript
    await ethRate.queryFilter("EthPrice");
    ```
2.  You will see that a new `EthPrice` event is emitted every 30 seconds.
3.  The price data in the log is in Hex format. You can convert the hex code to an ASCII string to view the human-readable ETH price in USD. For example, the hex `343432362e3633` converts to `4426.63`.

### Step 8: Withdraw Remaining Funds

Once the subscription period is over or you wish to stop, you can withdraw any remaining ETH and USDC from the contract.

1.  In the Hardhat console, call the withdraw functions:
    ```javascript
    await ethRate.withdrawEth();
    await ethRate.withdrawUsdc();
    ```

Congratulations\! You have successfully created a smart contract that makes subscription-based serverless requests.

import { ethers } from "hardhat";

async function main() {
    let relaySubAddress = "0x8Fb2C621d6E636063F0E49828f4Da7748135F3cB";
    let usdcToken = "0xaf88d065e77c8cC2239327C5EDb3A432268e5831";
    let codeHash = "0xee2f5946063a0c7fe4cfbce6de6b9849951aae5cdd20f7e589ffe98cd96bba84";
    let owner = await (await ethers.getSigners())[0].getAddress();
    const ethRate = await ethers.deployContract(
        "EthRate",
        [
            relaySubAddress,
            usdcToken,
            owner,
            codeHash
        ]
    );
    await ethRate.waitForDeployment();
    console.log("User Contract is deployed at ", ethRate.target);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
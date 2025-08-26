import { ethers } from "hardhat";

async function main() {

    // Note: Following addresses are dummy values. Replace them with deployed addresses.
    let relayAddress = "0x56EC16763Ec62f4EAF9C7Cfa09E29DC557e97006";
    let usdcToken = "0x186A361FF2361BAbEE9344A2FeC1941d80a7a49C";
    let owner = await (await ethers.getSigners())[0].getAddress();
    const userSample = await ethers.deployContract(
        "UserSample",
        [
            relayAddress,
            usdcToken,
            owner
        ]
    );
    await userSample.waitForDeployment();
    console.log("User Contract is deployed at ", userSample.target);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

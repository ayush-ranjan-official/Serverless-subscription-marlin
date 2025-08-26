import { ethers } from "hardhat";

async function main() {

    // Note: Following addresses are dummy values. Replace them with deployed addresses.
    let relaySubscriptionsAddress = "0x6B59433387341925aE903E36d16D976053D018E1";
    let usdcToken = "0x186A361FF2361BAbEE9344A2FeC1941d80a7a49C";
    let owner = await (await ethers.getSigners())[0].getAddress();
    const subsUser = await ethers.deployContract(
        "SubsUser",
        [
            relaySubscriptionsAddress,
            usdcToken,
            owner
        ]
    );
    await subsUser.waitForDeployment();
    console.log("User Contract is deployed at ", subsUser.target);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

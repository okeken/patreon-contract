const hre = require("hardhat");

// Returns the Ether balance of a given address.
async function getBalance(address) {
  const balanceBigInt = await hre.waffle.provider.getBalance(address);
  return hre.ethers.utils.formatEther(balanceBigInt);
}

// Logs the Ether balances for a list of addresses.
async function printBalances(addresses) {
  let idx = 0;
  for (const address of addresses) {
    console.log(`Address ${idx} balance: `, await getBalance(address));
    idx++;
  }
}

// Logs the subscribers stored on-chain from coffee purchases.

const plans = {
  0: "basic",
  1: "standard",
  2: "premium",
};
async function printSubscribers(subscribers) {
  for (const subscriber of subscribers) {
    const timestamp = subscriber.lastSubTime;
    const user = subscriber.name;
    const userAddress = subscriber.from;
    const plan = subscriber.currentPlan;
    console.log(
      `At ${timestamp}, ${user} (${userAddress}) has a "${plans[plan]} plan"`
    );
  }
}

async function main() {
  // Get the example accounts we'll be working with.
  const [owner, user, user2, user3] = await hre.ethers.getSigners();

  // We get the contract to deploy.
  const Patreon = await hre.ethers.getContractFactory("Patreon");
  const patreon = await Patreon.deploy();

  // Deploy the contract.
  await patreon.deployed();
  console.log("Patreon deployed to:", patreon.address);

  // Check balances before the subscribing
  const addresses = [owner.address, user.address, patreon.address];
  console.log("== start ==");
  await printBalances(addresses);

  const plansPrice = {
    basic: { value: hre.ethers.utils.parseEther("0.01") },
    standard: { value: hre.ethers.utils.parseEther("0.02") },
    premium: { value: hre.ethers.utils.parseEther("0.03") },
  };

  //subscribe to channel.
  await patreon
    .connect(user)
    .subscribe(Object.keys(plans)[0], "Carolina", plansPrice.basic);
  await patreon
    .connect(user2)
    .subscribe(Object.keys(plans)[1], "Ken", plansPrice.standard);
  await patreon
    .connect(user3)
    .subscribe(Object.keys(plans)[2], "Jude", plansPrice.premium);

  // Check balances after the coffee purchase.
  console.log("== subscription ==");
  await printBalances(addresses);

  // Withdraw.
  await patreon.connect(owner).withdrawFunds();

  // Check balances after withdrawal.
  console.log("== withdrawFunds ==");
  await printBalances(addresses);

  // Check out the subscribers.
  console.log("== subscribers ==");
  const subscribers = await patreon.getSubscribers();
  printSubscribers(subscribers);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

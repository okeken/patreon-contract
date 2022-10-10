# Patreon solidity contract

This repo contains a contract that implements subscribe functionality.

Install dependencies with `yarn install`.

Set up by creating a `.env` file, and filling out these variables:

```
MUMBAI_URL="your Alchemy RPC URL"
MUMBAI_API_KEY="your Alchemy API key"
PRIVATE_KEY="your wallet private key"
```

You can get your Private Key from MetaMask [like this](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-Export-an-Account-Private-Key).

Deploy your contract with:

```
npx hardhat run scripts/deploy.js
```

Run an example buy patreon flow locally with:

```
npx hardhat run scripts/subscribe.js
```

Once you have a contract deployed to MUMBAI testnet, grab the contract address and update the `contractAddress` variable in `scripts/withdraw.js`, then:

```
npx hardhat run scripts/withdraw.js
```

will allow you to withdraw any funds stored on the contract.

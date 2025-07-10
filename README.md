# SimpleSwap DApp with Scaffold-ETH

This project is a decentralized application (dApp) built using **Scaffold-ETH**, enabling interaction with three smart contracts deployed on the Sepolia testnet:

- **SimpleSwap**: The main contract facilitating token swaps.
- **TokenA**: A custom ERC-20 token with minting functionality.
- **TokenB**: Another custom ERC-20 token with minting functionality.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Getting Started](#getting-started)
- [Environment Variables](#environment-variables)
- [Deploying Contracts](#deploying-contracts)
- [Running the Frontend](#running-the-frontend)
- [Minting Tokens](#minting-tokens)
- [Interacting with SimpleSwap](#interacting-with-simpleswap)
- [Folder Structure](#folder-structure)
- [Contributing](#contributing)
- [License](#license)

---

## Project Overview

This dApp allows users to mint TokenA and TokenB and swap between them using the SimpleSwap contract. The project is built on top of Scaffold-ETH v1 with a Next.js frontend, leveraging ethers.js for blockchain interactions.

---

## Features

- Mint TokenA and TokenB tokens directly from the frontend.
- Swap tokens using the SimpleSwap contract.
- Connect wallet via MetaMask or WalletConnect.
- Supports Sepolia testnet.

---

## Getting Started

### Prerequisites

- Node.js >= 16.x
- Yarn package manager
- MetaMask or WalletConnect-compatible wallet

### Installation

Clone the repository:

git clone https://github.com/diegoprego/SimpleSwap_Scaffold_Front
cd your-repo/packages/nextjs
yarn install

## Environment Variables

Create a `.env.local` file inside `packages/nextjs/` with the following variables:

NEXT_PUBLIC_ALCHEMY_API_KEY=your-alchemy-api-key
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your-walletconnect-project-id
NEXT_PUBLIC_SIMPLE_SWAP_ADDRESS=deployed-simple-swap-address
NEXT_PUBLIC_TOKEN_A_ADDRESS=deployed-token-a-address
NEXT_PUBLIC_TOKEN_B_ADDRESS=deployed-token-b-address
NEXT_PUBLIC_CHAIN_ID=11155111

> **Note:** Replace the placeholders with your actual API keys and deployed contract addresses.

---

## Deploying Contracts

Contracts are located in the `packages/hardhat/contracts` folder.

To deploy contracts to Sepolia:

cd packages/hardhat
yarn deploy --network sepolia


This will deploy SimpleSwap, TokenA, and TokenB contracts and output their addresses.

---

## Running the Frontend

Start the frontend development server:

cd packages/nextjs
yarn dev

Open http://localhost:3000 in your browser.

## Minting Tokens

- Navigate to the TokenA or TokenB mint section in the UI.
- Connect your wallet.
- Specify the amount to mint and confirm the transaction.
- Tokens will be minted to your connected wallet on Sepolia.

---

## Interacting with SimpleSwap

- Use the swap interface to exchange TokenA for TokenB or vice versa.
- Ensure you have approved SimpleSwap contract to spend your tokens.
- Confirm the swap transaction in your wallet.

---

Or visit https://simple-swap-scaffold-front-nextjs.vercel.app/ ;-p

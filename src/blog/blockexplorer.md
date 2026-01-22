% Building a Minimal Ethereum Block Explorer

## Introduction

I just completed Week 3 of the [Alchemy University Ethereum Developer Bootcamp](https://university.alchemy.com/), and I'm excited to share what I built: a fully functional Ethereum Block Explorer with a twist - it's intentionally minimal, using only black and white with a modular architecture.

**Check out the code:** [GitHub Repository](https://github.com/0-x-joseph/block-explorer)

## What's a Block Explorer?

Before diving in, let me explain what a block explorer is. Think of it as Google for the blockchain. Just like you search the web with Google, you use a block explorer to search and navigate the Ethereum blockchain. You can look up:

- **Blocks** - containers that hold batches of transactions
- **Transactions** - individual transfers of ETH or smart contract interactions
- **Addresses** - both wallet addresses and smart contracts
- **Balances** - how much ETH an address holds

Sites like Etherscan are the go-to block explorers for Ethereum. Now I understand exactly how they work!

## The Challenge

Week 3 of Alchemy University focused on the Ethereum JSON-RPC API and blockchain interaction. The challenge was open-ended: build your own block explorer using the Alchemy SDK.

I decided to take a different approach - I wanted something **minimal, fast, and maintainable**. No fancy colors, no rounded corners, just pure function with clean aesthetics.

## Design Philosophy: Less is More

I deliberately chose a **minimal black and white design**:

- **Pure black (#000000) and white (#ffffff)** - no gray scales, no colors
- **Square edges** - no rounded corners anywhere
- **No gradients or shadows** - flat design only
- **Clean typography** - proper spacing and hierarchy
- **2px solid borders** - consistent throughout

Why? Because I wanted the _data_ to be the star, not the design. When exploring blockchain data, clarity is everything. The minimal aesthetic keeps you focused on what matters - the blocks, transactions, and addresses.

## Architecture: Modular and Maintainable

I structured the project properly:

```
src/
├── App.js                    # Main routing
├── components/
│   └── Header.js            # Search bar component
├── pages/
│   ├── Home.js              # Latest blocks
│   ├── BlockDetails.js      # Individual block
│   ├── TransactionDetails.js # Transaction info
│   └── AddressDetails.js    # Address lookup
└── utils/
    └── alchemy.js           # SDK configuration
```

Each page is a separate component with a single responsibility. Want to modify how blocks display? Edit `BlockDetails.js`. Need to change the search? It's all in `Header.js`. This makes the code **easy to understand, test, and extend**.

## What I Built

### Home Page - Latest Blocks

When you open the app, you see the 10 most recent blocks on Ethereum mainnet. Each block shows:

- Block number (clickable)
- Transaction count
- Gas used
- Timestamp
- Miner address

It's a real-time snapshot of the network. Refresh and you'll see newer blocks.

### Smart Search

The search bar automatically detects what you're looking for:

- Enter a number? It takes you to that block
- Enter a transaction hash (0x + 64 hex)? Shows the transaction
- Enter an address (0x + 40 hex)? Displays the address info

No dropdown menus, no radio buttons - it just works.

### Block Details

Click any block and you get:

- Complete block information (hash, parent hash, gas metrics, base fee)
- List of all transactions in that block
- Links to the miner and parent block

You can literally traverse the blockchain by clicking parent hashes, going back through history block by block.

### Transaction Details

Every transaction shows:

- Status (success or failed)
- Block number
- From and To addresses
- Value transferred in ETH
- Gas limit, gas used, gas price
- Total transaction fee
- Input data for contract calls

### Address Lookup

Enter any Ethereum address to see:

- Current ETH balance
- Recent transaction history (last 20)
- All transfer types (external, internal, ERC20, ERC721, ERC1155)

## The Tech Stack

**Frontend:**

- React 17 with Hooks
- React Router DOM v5 for navigation
- Pure CSS (no frameworks)

**Blockchain:**

- Alchemy SDK v2
- Ethereum Mainnet

**Architecture:**

- Modular components
- Clean separation of concerns

The Alchemy SDK made everything smooth. Instead of wrestling with raw JSON-RPC calls, I could write clean code like:

```javascript
const blockNumber = await alchemy.core.getBlockNumber();
const block = await alchemy.core.getBlockWithTransactions(blockNumber);
```

Simple, readable, and it just works.

## What I Learned

### Blockchain Structure

I now deeply understand how blocks, transactions, and addresses interconnect. Seeing real mainnet data flow through my app - billions of dollars moving on-chain - made everything click. The blockchain isn't abstract anymore.

### Gas Economics

Watching gas prices fluctuate, seeing how different transactions consume gas, understanding base fees vs priority fees - it all became tangible. Theory became practice.

### React Patterns

Building this forced me to:

- Master React Router properly
- Use Hooks effectively (useState, useEffect)
- Manage async data flow
- Handle loading and error states
- Think in components

### Code Organization

I learned that good architecture isn't about clever tricks - it's about making things **obvious**. When someone (including future me) looks at this code, they should immediately understand where everything is and why.

### Design Restraint

Working within constraints (black, white, squares only) forced creative solutions. I couldn't hide bad UX behind fancy animations or gradients. The design had to work on its own merit.

## The "Aha!" Moments

**Blocks are literally chained:** When I clicked through parent hashes, it hit me - the blockchain is an actual chain. Each block points to the previous one. You can traverse backwards through the entire history of Ethereum.

**Transactions have multiple states:** A transaction isn't just "sent" - it's pending, then mined, then confirmed. Watching this happen in real-time was eye-opening.

**The mempool is real:** Seeing pending transactions waiting to be mined made the mempool concept concrete. There's this pool of waiting transactions, and miners pick which ones to include.

**Gas makes sense:** By seeing thousands of transactions with different gas prices, I finally understood gas as a market mechanism. Higher gas = faster inclusion.

## What's Next

I'm not done! Here are features I want to add:

### Technical Enhancements

- **WebSocket integration** - Real-time block updates as they're mined
- **Transaction decoder** - Decode contract interactions into readable format
- **ENS support** - Resolve ENS names like vitalik.eth
- **Contract verification** - Show verified contract source code

### UI Improvements

- **Dark mode** - An inverted black/white theme
- **Export functionality** - Download transaction history as CSV
- **Favorites system** - Save addresses you check frequently
- **Comparison view** - Compare two addresses or blocks side-by-side

### Data Features

- **NFT display** - Show NFTs owned by an address with images
- **Token balances** - Display all ERC-20 tokens
- **Gas tracker** - Live gas price recommendations
- **Statistics dashboard** - Network metrics and charts

## Why This Project Matters

Building a block explorer taught me more about Ethereum than reading documentation ever could. I had to understand:

- How blocks are structured
- What transactions actually contain
- How gas works in practice
- What happens when you send ETH

More importantly, I learned about **building production-quality software**:

- Modular architecture for maintainability
- Clean code for readability
- Minimal design for clarity
- Proper error handling
- Responsive design
- Performance optimization

This isn't just a learning project - it's software I can actually use. When I want to look up a transaction, I use my own explorer.

## Try It Yourself

If you're learning blockchain development, building a block explorer is the perfect project. It forces you to:

- Interact with real blockchain data
- Handle async operations
- Think about user experience
- Structure a non-trivial application

The [Alchemy University course](https://university.alchemy.com/) provides excellent guidance, and the Alchemy SDK makes it surprisingly approachable. You don't need to be an expert - just curious and willing to learn.

---

**Want to see the code?** Check out the [GitHub repository](https://github.com/0-x-joseph/block-explorer)

Happy exploring! 🚀

---

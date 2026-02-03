# Foundry UUPS Upgradeable Contracts

A UUPS upgradeable contract example project using OpenZeppelin 5.x.

## Project Structure

```
├── src/
│   ├── BoxV1.sol          # Initial implementation
│   └── BoxV2.sol          # Upgraded implementation
├── script/
│   ├── DeployBox.s.sol    # Deploy script
│   └── UpgradeBox.s.sol   # Upgrade script
├── test/
│   └── DeployAndUpgradeTest.t.sol
└── Makefile
```

## Installation

```bash
git clone https://github.com/SymmaTe/foundry-upgrades-f23.git
cd foundry-upgrades-f23
forge install
```

## Configuration

Create a `.env` file and add your config:

```
SEPOLIA_RPC_URL=<your-sepolia-rpc-url>
PRIVATE_KEY=<your-private-key>
ETHERSCAN_API_KEY=<your-etherscan-api-key>
```

## Usage

### Build

```bash
make build
```

### Test

```bash
make test
```

### Local Deployment (Anvil)

```bash
# Start local node
make anvil

# In a new terminal, deploy contracts
make deploy ARGS="--network anvil"

# Upgrade contracts
make upgrade ARGS="--network anvil"
```

### Sepolia Testnet Deployment

```bash
# Deploy
make deploy ARGS="--network sepolia"

# Upgrade
make upgrade ARGS="--network sepolia"
```

### Interact with Cast

```bash
# Get version
cast call <PROXY_ADDRESS> "version()" --rpc-url $SEPOLIA_RPC_URL

# Get owner
cast call <PROXY_ADDRESS> "owner()" --rpc-url $SEPOLIA_RPC_URL

# Set number (requires V2)
cast send <PROXY_ADDRESS> "setNumber(uint256)" 123 --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY

# Get number
cast call <PROXY_ADDRESS> "getNumber()" --rpc-url $SEPOLIA_RPC_URL
```

## UUPS Proxy Pattern

```
User → ERC1967Proxy (Proxy) → BoxV1/BoxV2 (Implementation)
            ↓
       State Storage
```

- **Proxy Contract**: Stores all state data, address never changes
- **Implementation Contract**: Contains only logic, can be upgraded
- **Upgrade**: Deploy new implementation and call `upgradeToAndCall`

## Important Notes

1. Always interact with the **proxy address**, not the implementation address
2. New variables can only be added **after** existing variables
3. Cannot delete or reorder existing variables
4. `_authorizeUpgrade` should have `onlyOwner` modifier

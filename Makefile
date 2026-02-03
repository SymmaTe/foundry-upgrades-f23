-include .env

.PHONY: all test clean deploy upgrade help install build snapshot format anvil

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]    部署 BoxV1 + Proxy"
	@echo "  make upgrade [ARGS=...]   升级到 BoxV2"
	@echo "  make test                 运行测试"
	@echo "  make build                编译合约"
	@echo "  make anvil                启动本地节点"
	@echo ""
	@echo "Examples:"
	@echo "  make deploy ARGS=\"--network sepolia\""
	@echo "  make deploy ARGS=\"--network anvil\""
	@echo "  make upgrade ARGS=\"--network sepolia\""

all: clean install build test

install:
	forge install

build:
	forge build

test:
	forge test -vvv

snapshot:
	forge snapshot

format:
	forge fmt

anvil:
	anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

ifeq ($(findstring --network mainnet,$(ARGS)),--network mainnet)
	NETWORK_ARGS := --rpc-url $(MAINNET_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

ifeq ($(findstring --network anvil,$(ARGS)),--network anvil)
	NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast
endif

deploy:
	@forge script script/DeployBox.s.sol:DeployBox $(NETWORK_ARGS)

upgrade:
	@forge script script/UpgradeBox.s.sol:UpgradeBox $(NETWORK_ARGS)

clean:
	forge clean

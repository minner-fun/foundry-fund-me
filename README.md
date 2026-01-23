## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

github项目地址为https://github.com/smartcontractkit/chainlink-brownie-contracts
安装命令为：forge install smartcontractkit/chainlink-brownie-contracts@0.6.1


-v的个数的含义
```
Verbosity levels:
- 2: Print logs for all tests
- 3: Print execution traces for failing tests
- 4: Print execution traces for all tests, and setup traces for failing tests
- 5: Print execution and setup traces for all tests
```

forge test --mt testPriceFeedVersionIsAccurate

测试覆盖率
forge coverage --fork-url $SEPOLIA_RPC_URL 

部署合约时，如果直接在测试合约中new xx(),那么msg.sender就为测试合约。如果是用了vm.startBroadcast();其实msg.sender就是我们的默认外部账号的地址。这个地址和anvil链上没有关系。这是测试内置的账号。

vm.deal(alice, BALANCE)
vm.prank(alice) 下一行是alice执行

vm.startPrank(alice)
...中间多行都有alice执行
vm.stopPrank()

uint160 是可以直接转为 address类型， uint256不行

hoax = deal + prank 直接加eth + 换msg.sender

chisel 是一个交互环境

gas消耗
forge snapshot --mt testOwnerIsMsgSender

gasleft() solidity的方法，返回剩余的gas
tx.gasprice; solidity中的属性，当前的交易的gas价格

vm.txGasPrice(GAS_PRICE); foundry的作弊码，用来改变tx.gasprice

vm.load();  加载存储数据
forge inspect FundMe storageLayout 查看存储超结构
cast storage 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 2  通过合约地址查看存储情况


部署
$ forge script DeployFundMe --rpc-url $ANVIL_RPC_URL --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast

 forge install Cyfrin/foundry-devops 安装包
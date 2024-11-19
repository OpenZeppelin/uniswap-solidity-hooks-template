# Uniswap Solidity Hooks Template

> [!WARNING]
> This project is still in a very early and experimental phase. It has never
> been audited nor thoroughly reviewed for security vulnerabilities. Do not use
> in production.

### **A template for writing Uniswap v4 Hooks with custom swap curve implemantion in Stylus**

This template is built on top of [Uniswap V4 Template](https://github.com/uniswapfoundation/v4-template).

[`Use this Template`](https://github.com/OpenZeppelin/uniswap-solidity-hooks-template/generate)

1. The example hook [Counter.sol](src/Counter.sol) demonstrates:
    - `beforeSwap()` hook calling external custom curve implementation written in [Stylus](https://github.com/OpenZeppelin/uniswap-stylus-curve-template),
    - `afterSwap()` hook,
    - `beforeAddLiquidity()` hook,
    - `beforeRemoveLiquidity()` hook,
    - `getHookPermissions()` function.
2. The test template [Counter.t.sol](test/Counter.t.sol) preconfigures the v4 pool manager, test tokens, and test liquidity.

---

### Check Forge Installation
*Ensure that you have correctly installed Foundry (Forge) Stable. You can update Foundry by running:*

```
foundryup
```

> *v4-template* appears to be _incompatible_ with Foundry Nightly. See [foundry announcements](https://book.getfoundry.sh/announcements) to revert back to the stable build



## Set up

*requires [foundry](https://book.getfoundry.sh)*

```
forge install
forge test
```

### Local Development (Nitro Testnode)

Other than writing unit tests, you can deploy & test hooks on [Nitro Testnode](https://github.com/OffchainLabs/nitro-testnode).

You can follow this [instruction](https://github.com/OpenZeppelin/uniswap-stylus-curve-template?tab=readme-ov-file#how-to-run-a-local-dev-node) to run Nitro Testnode.

---

<details>
<summary><h2>Troubleshooting</h2></summary>



### *Permission Denied*

When installing dependencies with `forge install`, Github may throw a `Permission Denied` error

Typically caused by missing Github SSH keys, and can be resolved by following the steps [here](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh)

Or [adding the keys to your ssh-agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent), if you have already uploaded SSH keys

### Hook deployment failures

Hook deployment failures are caused by incorrect flags or incorrect salt mining

1. Verify the flags are in agreement:
    * `getHookCalls()` returns the correct flags
    * `flags` provided to `HookMiner.find(...)`
2. Verify salt mining is correct:
    * In **forge test**: the *deployer* for: `new Hook{salt: salt}(...)` and `HookMiner.find(deployer, ...)` are the same. This will be `address(this)`. If using `vm.prank`, the deployer will be the pranking address
    * In **forge script**: the deployer must be the CREATE2 Proxy: `0x4e59b44847b379578588920cA78FbF26c0B4956C`
        * If anvil does not have the CREATE2 deployer, your foundry may be out of date. You can update it with `foundryup`

</details>

---

Additional resources:

[Uniswap v4 docs](https://docs.uniswap.org/contracts/v4/overview)

[v4-periphery](https://github.com/uniswap/v4-periphery) contains advanced hook implementations that serve as a great reference

[v4-core](https://github.com/uniswap/v4-core)

[v4-by-example](https://v4-by-example.org)

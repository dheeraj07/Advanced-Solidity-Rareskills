# `Why does the SafeERC20 program exist and when should it be used?`
The SafeERC20 is a library which is used to address potential issues with the ERC20 token standard.
ERC20 issues which can be avoided using SafeERC20:
1. Usually transfer and transferFrom should return a boolean. Several tokens do not return a boolean on these functions. As a result, their calls in the contract might fail.

2. ERC20 approve race condition can also be counteracted
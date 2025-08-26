// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract SubsUser is Ownable {
    using SafeERC20 for IERC20;

    address public relaySubscriptionsAddress;

    /// @notice refers to USDC token
    IERC20 public token;

    event OwnerEthWithdrawal();

    error EthWithdrawalFailed();

    constructor(
        address _relaySubscriptionsAddress,
        address _token,
        address _owner
    ) Ownable(_owner) {
        relaySubscriptionsAddress = _relaySubscriptionsAddress;
        token = IERC20(_token);
    }

    struct JobSubscriptionParams {
        uint8 env;
        uint256 startTime;
        uint256 maxGasPrice;
        uint256 usdcDeposit;
        uint256 callbackGasLimit;
        address callbackContract;
        bytes32 codehash;
        bytes codeInputs;
        uint256 periodicGap;
        uint256 terminationTimestamp;
        uint256 userTimeout;
        address refundAccount;
    }

    event CalledBack(
        uint256 indexed jobId,
        address jobOwner,
        bytes32 codehash,
        bytes codeInputs,
        bytes outputs,
        uint8 errorCode
    );

    // bytes32 txhash = 0xc7d9122f583971d4801747ab24cf3e83984274b8d565349ed53a73e0a547d113;

    function oysterResultCall(
        uint256 _jobId,
        address _jobOwner,
        bytes32 _codehash,
        bytes calldata _codeInputs,
        bytes calldata _output,
        uint8 _errorCode
    ) public {
        emit CalledBack(_jobId, _jobOwner, _codehash, _codeInputs, _output, _errorCode);
    }

    function startJobSubscription(
        uint256 _usdcDeposit,
        bytes32 _codehash,
        bytes memory _codeInputs,
        uint256 _periodicGap,
        uint256 _terminationTimestamp,
        uint256 _userTimeout,
        uint256 _callbackDeposit
    ) external returns (bool) {
        // usdcDeposit = _userTimeout * EXECUTION_FEE_PER_MS + GATEWAY_FEE_PER_JOB;
        token.safeIncreaseAllowance(relaySubscriptionsAddress, _usdcDeposit);
        JobSubscriptionParams memory _jobSubsParams = JobSubscriptionParams(
            {
                env: 1,
                startTime: block.timestamp + 10,
                maxGasPrice: 2 * tx.gasprice,
                usdcDeposit: _usdcDeposit,
                callbackGasLimit: 5000,
                callbackContract: address(this),
                codehash: _codehash,
                codeInputs: _codeInputs,
                periodicGap: _periodicGap,
                terminationTimestamp: _terminationTimestamp,
                userTimeout: _userTimeout,
                refundAccount: _msgSender()
            }
        );
        (bool success, ) = relaySubscriptionsAddress.call{value: _callbackDeposit}(
            abi.encodeWithSignature(
                "startJobSubscription((uint8,uint256,uint256,uint256,uint256,address,bytes32,bytes,uint256,uint256,uint256,address))",
                _jobSubsParams
            )
        );
        return success;
    }

    function withdrawEth() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        if (!success) revert EthWithdrawalFailed();

        emit OwnerEthWithdrawal();
    }

    receive() external payable {}
}

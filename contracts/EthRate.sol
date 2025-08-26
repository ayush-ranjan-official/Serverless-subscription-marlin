// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract EthRate is Ownable {
    using SafeERC20 for IERC20;

    address public relaySubscriptionsAddress;

    /// @notice refers to USDC token
    IERC20 public token;

    bytes32 public immutable CODE_HASH;

    uint256 public subscriptionId;

    event EthPrice(
        bytes price,
        uint256 time
    );

    event Refunded(
        uint256 subscriptionId
    );

    event OwnerEthWithdrawal();
    event OwnerUsdcWithdrawal();

    error EthRateInvalidCallback();
    error EthRateAlreadyRunning();
    error EthRateNotRunning();
    error EthRateRefundFailed();
    error EthWithdrawalFailed();

    constructor(
        address _relaySubscriptionsAddress,
        address _token,
        address _owner,
        bytes32 _codeHash
    ) Ownable(_owner) {
        relaySubscriptionsAddress = _relaySubscriptionsAddress;
        token = IERC20(_token);
        CODE_HASH = _codeHash;
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

    function run() external onlyOwner returns (bool) {
        if (subscriptionId != 0) {
            revert EthRateAlreadyRunning();
        } 
        uint256 _usdcDeposit = 11 * 4100;
        uint256 _maxGasPrice = 2 * tx.gasprice;
        uint256 _callbackDeposit = 11 * _maxGasPrice * (35000 + 150000 + 4530);
        token.safeIncreaseAllowance(relaySubscriptionsAddress, _usdcDeposit);
        JobSubscriptionParams memory _jobSubsParams = JobSubscriptionParams(
            {
                env: 1,
                startTime: block.timestamp,
                maxGasPrice: _maxGasPrice,
                usdcDeposit: _usdcDeposit,
                callbackGasLimit: 35000,
                callbackContract: address(this),
                codehash: CODE_HASH,
                codeInputs: '',
                periodicGap: 30,
                terminationTimestamp: block.timestamp + 200,
                userTimeout: 2000,
                refundAccount: _msgSender()
            }
        );
        (bool success, bytes memory data ) = relaySubscriptionsAddress.call{value: _callbackDeposit}(
            abi.encodeWithSignature(
                "startJobSubscription((uint8,uint256,uint256,uint256,uint256,address,bytes32,bytes,uint256,uint256,uint256,address))",
                _jobSubsParams
            )
        );
        subscriptionId = abi.decode(data, (uint256));
        return success;
    }

    function oysterResultCall(
        uint256 _jobId,
        address _jobOwner,
        bytes32 _codehash,
        bytes calldata _codeInputs,
        bytes calldata _output,
        uint8 _errorCode
    ) public {
        if (relaySubscriptionsAddress != _msgSender() || _jobId != subscriptionId) {
            revert EthRateInvalidCallback();
        }
        emit EthPrice(_output, block.timestamp);
    }

    function getSubscriptionRefund() external onlyOwner {
        if (subscriptionId == 0) {
            revert EthRateNotRunning();
        }
        (bool success,) = relaySubscriptionsAddress.call(
            abi.encodeWithSignature(
                "refundJobSubsDeposits(uint256)",
                subscriptionId
            )
        );
        if (!success) {
            revert EthRateRefundFailed();
        }
        emit Refunded(subscriptionId);
        subscriptionId = 0;
         
    }

    function withdrawEth() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        if (!success) revert EthWithdrawalFailed();

        emit OwnerEthWithdrawal();
    }

    function withdrawUsdc() external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(owner(), balance);

        emit OwnerUsdcWithdrawal();
    }

    receive() external payable {}
}
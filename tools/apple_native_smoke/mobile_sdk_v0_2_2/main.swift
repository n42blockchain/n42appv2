import Foundation

func check(_ condition: @autoclosure () -> Bool, _ message: String) {
    if !condition() {
        fputs("FAIL: \(message)\n", stderr)
        exit(1)
    }
}

func checkError(_ value: Result<String, MobileSdkError>) {
    switch value {
    case .failure(.rustError(let message)):
        check(message == "synthetic error", "wrong error text")
    default:
        check(false, "result and error must resolve as failure")
    }
}

let stringCalls: [() -> Result<String, MobileSdkError>] = [
    { MobileSdk.generateBls12381Keypair() },
    { MobileSdk.createDepositUnsignedTx(depositContractAddress: "synthetic", validatorPrivateKey: "synthetic", withdrawalAddress: "synthetic", depositValueInWei: "1") },
    { MobileSdk.createGetExitFeeUnsignedTx() },
    { MobileSdk.createExitUnsignedTx(validatorPublicKey: "synthetic", feeInWeiOrEmpty: "1") },
]

for operation in stringCalls {
    fake_set_mode(1)
    checkError(operation())
    check(fake_free_count() == 2, "both C pointers must be freed")

    fake_set_mode(2)
    switch operation() {
    case .success(let value): check(value == "{}", "wrong success value")
    default: check(false, "success pointer must return success")
    }
    check(fake_free_count() == 1, "success pointer must be freed")

    fake_set_mode(3)
    checkError(operation())
    check(fake_free_count() == 1, "error pointer must be freed")
}

// This call links only the C shim. No Rust SDK or network client runs.
fake_set_mode(1)
var runClientResult: Result<Void, MobileSdkError>?
MobileSdk.runClient(wsUrl: "synthetic", validatorPrivateKey: "synthetic") {
    runClientResult = $0
}
let deadline = Date().addingTimeInterval(5)
while runClientResult == nil && Date() < deadline {
    RunLoop.current.run(until: Date().addingTimeInterval(0.01))
}
switch runClientResult {
case .failure(.rustError(let message)):
    check(message == "synthetic error", "runClient error precedence")
default:
    check(false, "runClient code zero plus error must fail")
}
check(fake_free_count() == 1, "runClient error pointer must be freed")

print("Swift bridge pointer contract: 13 cases passed")

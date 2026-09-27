import Foundation

public enum MobileSdkError: Error {
    case rustError(String)
    case simulatorNotSupported(String)
}

public class MobileSdk {

#if targetEnvironment(simulator)
    // MARK: - Simulator Mock Implementations
    // These mock implementations allow the app to build and run on simulator
    // Mining features will show appropriate error messages

    private static let simulatorErrorMessage = "Mining features are not available on iOS Simulator. Please use a physical device for mining operations."

    public static func runClient(wsUrl: String, validatorPrivateKey: String,
                                 completion: @escaping (Result<Void, MobileSdkError>) -> Void) {
        DispatchQueue.main.async {
            completion(.failure(.simulatorNotSupported(simulatorErrorMessage)))
        }
    }

    public static func generateBlockVerifyResult(
        block: String,
        validatorPrivateKey: String,
        completion: @escaping (Result<String, MobileSdkError>) -> Void
    ) {
        DispatchQueue.main.async {
            completion(.failure(.simulatorNotSupported(simulatorErrorMessage)))
        }
    }

    public static func generateBls12381Keypair() -> Result<String, MobileSdkError> {
        // Return a mock keypair for UI testing (not for actual use)
        let mockKeypair = """
        {
            "publicKey": "0x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
            "privateKey": "0x0000000000000000000000000000000000000000000000000000000000000000",
            "isMock": true,
            "warning": "This is a mock keypair for simulator testing only"
        }
        """
        return .success(mockKeypair)
    }

    public static func createDepositUnsignedTx(
        depositContractAddress: String,
        validatorPrivateKey: String,
        withdrawalAddress: String,
        depositValueInWei: String
    ) -> Result<String, MobileSdkError> {
        return .failure(.simulatorNotSupported(simulatorErrorMessage))
    }

    public static func createGetExitFeeUnsignedTx() -> Result<String, MobileSdkError> {
        // Return a mock response for UI testing
        let mockResponse = """
        {
            "fee": "0",
            "isMock": true,
            "warning": "This is a mock response for simulator testing only"
        }
        """
        return .success(mockResponse)
    }

    public static func createExitUnsignedTx(
        validatorPublicKey: String,
        feeInWeiOrEmpty: String?
    ) -> Result<String, MobileSdkError> {
        return .failure(.simulatorNotSupported(simulatorErrorMessage))
    }

#else
    // MARK: - Real Device Implementations

    private static func consumeStringResult(
        _ resultPtr: UnsafeMutablePointer<CChar>?,
        _ errorPtr: UnsafeMutablePointer<CChar>?
    ) -> Result<String, MobileSdkError> {
        defer {
            if let resultPtr { rust_free_string(resultPtr) }
            if let errorPtr { rust_free_string(errorPtr) }
        }
        if let errorPtr {
            return .failure(.rustError(String(cString: errorPtr)))
        }
        guard let resultPtr else {
            return .failure(.rustError("Null response from Rust engine"))
        }
        return .success(String(cString: resultPtr))
    }

    public static func runClient(wsUrl: String, validatorPrivateKey: String,
completion: @escaping (Result<Void, MobileSdkError>) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            var errorPtr: UnsafeMutablePointer<CChar>? = nil
            let code = run_client_c(wsUrl, validatorPrivateKey, &errorPtr)
            defer { if let err = errorPtr { rust_free_string(err) } }

            if let errorPtr {
                let msg = String(cString: errorPtr)
                DispatchQueue.main.async {
completion(.failure(.rustError(msg))) }
            } else if code == 0 {
                DispatchQueue.main.async { completion(.success(())) }
            } else {
                DispatchQueue.main.async {
completion(.failure(.rustError("Unknown Rust error"))) }
            }
        }
    }

    public static func generateBlockVerifyResult(
    block: String,
    validatorPrivateKey: String,
    completion: @escaping (Result<String, MobileSdkError>) -> Void
    ) {
        DispatchQueue.global(qos: .utility).async {
            var errorPtr: UnsafeMutablePointer<CChar>? = nil

            // 1. Call the Rust C-bridge function
            // Note: The return type is *mut c_char (the result string)
            let resultPtr = gen_block_verify_result_c(block, validatorPrivateKey, &errorPtr)

            // 2. Setup cleanup for both the result and the error pointers
            defer {
                if let res = resultPtr { rust_free_string(res) }
                if let err = errorPtr { rust_free_string(err) }
            }

            // 3. Handle the Logic
            if let error = errorPtr {
                // If an error was populated, fail with the error message
                let msg = String(cString: error)
                DispatchQueue.main.async {
                    completion(.failure(.rustError(msg)))
                }
            } else if let result = resultPtr {
                // If no error, convert the result pointer to a Swift String
                let resultString = String(cString: result)
                DispatchQueue.main.async {
                    completion(.success(resultString))
                }
            } else {
                // Fallback for null pointers from both sides
                DispatchQueue.main.async {
                    completion(.failure(.rustError("Null response from Rust engine")))
                }
            }
        }
    }

    public static func generateBls12381Keypair(
    ) -> Result<String, MobileSdkError> {
        var errorPtr: UnsafeMutablePointer<CChar>? = nil
        let resultPtr = generate_bls12_381_keypair_c(&errorPtr)
        return consumeStringResult(resultPtr, errorPtr)
    }

    public static func createDepositUnsignedTx(
        depositContractAddress: String,
        validatorPrivateKey: String,
        withdrawalAddress: String,
        depositValueInWei: String
    ) -> Result<String, MobileSdkError> {
        var errorPtr: UnsafeMutablePointer<CChar>? = nil
        let resultPtr = create_deposit_unsigned_tx_c(
            depositContractAddress,
            validatorPrivateKey,
            withdrawalAddress,
            depositValueInWei,
            &errorPtr
        )
        return consumeStringResult(resultPtr, errorPtr)
    }

    public static func createGetExitFeeUnsignedTx(
    ) -> Result<String, MobileSdkError> {
        var errorPtr: UnsafeMutablePointer<CChar>? = nil
        let resultPtr = create_get_exit_fee_unsigned_tx_c(&errorPtr)
        return consumeStringResult(resultPtr, errorPtr)
    }

    public static func createExitUnsignedTx(
        validatorPublicKey: String,
        feeInWeiOrEmpty: String?
    ) -> Result<String, MobileSdkError> {
        var errorPtr: UnsafeMutablePointer<CChar>? = nil
        let resultPtr = create_exit_unsigned_tx_c(
            validatorPublicKey,
            feeInWeiOrEmpty ?? "",
            &errorPtr
        )
        return consumeStringResult(resultPtr, errorPtr)
    }
#endif
}

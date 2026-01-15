import Foundation

final class WebSocketManager {

    static let shared = WebSocketManager()

    private var session: URLSession?
    private var task: URLSessionWebSocketTask?

    private var wsUrl: String?
    private var validatorPubkey: String?
    private var validatorPrivateKey: String?

    private let reconnectDelay: TimeInterval = 5
    private var isReconnecting = false

    // ⭐ 对齐 Android
    private var manualClose = false
    private var connectionId: Int = 0
    private var tCount = 1

    private init() {}

    // MARK: - Connect

    func connect(
        wsUrl: String,
        validatorPubkey: String,
        validatorPrivateKey: String
    ) {
        let walletChanged =
            self.wsUrl != wsUrl ||
            self.validatorPubkey != validatorPubkey ||
            self.validatorPrivateKey != validatorPrivateKey

        if walletChanged {
            // ⭐ 切钱包：主动关闭旧连接
            stopWebSocket(manual: true)
        }

        self.wsUrl = wsUrl
        self.validatorPubkey = validatorPubkey
        self.validatorPrivateKey = validatorPrivateKey

        // 已有连接且钱包没变 → 什么都不做
        if task != nil {
            return
        }

        manualClose = false
        connectionId += 1
        let currentId = connectionId

        guard let url = URL(string: wsUrl) else { return }

        session = URLSession(configuration: .default)
        task = session?.webSocketTask(with: url)
        task?.resume()

        sendToFlutter("onOpen")

        sendSubscribe()
        receiveLoop(connectionId: currentId)
    }


    // MARK: - Subscribe

    private func sendSubscribe() {
        guard let pubkey = validatorPubkey else { return }

        let json: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "consensusBeaconExt_subscribeToVerificationRequest",
            "id": incrementTCount(),
            "params": [pubkey]
        ]

        send(json)
    }

    // MARK: - Receive Loop

    private func receiveLoop(connectionId: Int) {
        task?.receive { [weak self] result in
            guard let self = self else { return }

            // 忽略旧连接回调
            if connectionId != self.connectionId {
                return
            }

            switch result {
            case .success(let message):
                if case .string(let text) = message {
                    self.handleMessage(text)
                }
                self.receiveLoop(connectionId: connectionId)

            case .failure(let error):
                print("WebSocket receive error:", error)
                self.task = nil

                if self.manualClose {
                    self.sendToFlutter("onClosed")
                    return
                }

                self.sendToFlutter("onFailure")
                self.scheduleReconnect()
            }
        }
    }


    // MARK: - Handle Message

    private func handleMessage(_ text: String) {
        sendToFlutter(text)

        guard
            let data = text.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let method = json["method"] as? String,
            method == "subscribeToVerificationRequest",
            let params = json["params"] as? [String: Any],
            let result = params["result"] as? [String: Any],
            let privateKey = validatorPrivateKey
        else { return }

        // result → JSON string
        guard
            let resultData = try? JSONSerialization.data(withJSONObject: result),
            let resultJsonStr = String(data: resultData, encoding: .utf8)
        else { return }

        // ⚠️ 替换为你的真实 SDK
        MobileSdk.generateBlockVerifyResult(
            block: resultJsonStr,
            validatorPrivateKey: privateKey
        ) { [weak self] sdkResult in
            guard let self = self else { return }

            switch sdkResult {
            case .success(let verifyResultJson):
                self.sendSubmitVerification(verifyResultJson)

            case .failure(let error):
                print("SDK error:", error)
                self.sendToFlutter("sdk_error")
            }
        }
    }

    // MARK: - Submit Verification

    private func sendSubmitVerification(_ rawJson: String) {
        guard
            let data = rawJson.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let pubkey = json["pubkey"],
            let signature = json["signature"],
            let attestationData = json["attestation_data"],
            let blockHash = json["block_hash"]
        else { return }

        let submit: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "consensusBeaconExt_submitVerification",
            "id": incrementTCount(),
            "params": [
                pubkey,
                signature,
                attestationData,
                blockHash
            ]
        ]

        send(submit) { ok in
            self.sendToFlutter(ok ? "submit_ok" : "submit_failed")
        }
    }

    // MARK: - Send Helper

    private func send(_ json: [String: Any], completion: ((Bool) -> Void)? = nil) {
        guard
            let data = try? JSONSerialization.data(withJSONObject: json),
            let text = String(data: data, encoding: .utf8)
        else {
            completion?(false)
            return
        }

        task?.send(.string(text)) { error in
            completion?(error == nil)
        }
    }

    // MARK: - Reconnect

    private func scheduleReconnect() {
        guard
            !manualClose,
            !isReconnecting,
            let url = wsUrl,
            let pubkey = validatorPubkey,
            let privateKey = validatorPrivateKey
        else { return }

        isReconnecting = true

        DispatchQueue.global().asyncAfter(deadline: .now() + reconnectDelay) {
            self.isReconnecting = false
            self.sendToFlutter("reconnecting")
            self.connect(
                wsUrl: url,
                validatorPubkey: pubkey,
                validatorPrivateKey: privateKey
            )
        }
    }


    // MARK: - Disconnect

    private func stopWebSocket(manual: Bool) {
        manualClose = manual
        isReconnecting = false

        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        session = nil
    }

    func disconnect() {
        stopWebSocket(manual: true)
        sendToFlutter("onClosed")
    }


    // MARK: - Flutter Event

    private func sendToFlutter(_ message: String) {
        DispatchQueue.main.async {
            TrustdartPlugin.eventSink?(message)
        }
    }
    // 辅助函数
    private func incrementTCount() -> Int {
        tCount += 1
        return tCount
    }
}

//
//  TrustdartPlugin.swift
//  Runner
//
//  Created by JiangYiwei on 2026/1/13.
//


import Flutter
import UIKit

public class TrustdartPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    static var eventSink: FlutterEventSink?

    private var channel: FlutterMethodChannel?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = TrustdartPlugin()

        // MethodChannel
        let methodChannel = FlutterMethodChannel(
            name: "trustdart_mining",
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        instance.channel = methodChannel

        // EventChannel
        let eventChannel = FlutterEventChannel(
            name: "trustdart_ws_events",
            binaryMessenger: registrar.messenger()
        )
        eventChannel.setStreamHandler(instance)
    }

    // MARK: - MethodChannel

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {

        case "connectWebSocket":
            guard
                let args = call.arguments as? [String: Any],
                let wsUrl = args["wsUrl"] as? String,
                let pubkey = args["validatorPubkey"] as? String,
                let privateKey = args["validatorPrivateKey"] as? String
            else {
                result(FlutterError(
                    code: "bad_args",
                    message: "Missing arguments",
                    details: nil
                ))
                return
            }

            WebSocketManager.shared.connect(
                wsUrl: wsUrl,
                validatorPubkey: pubkey,
                validatorPrivateKey: privateKey
            )
            result("connecting")

        case "disconnectWebSocket":
            WebSocketManager.shared.disconnect()
            result("disconnected")

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - EventChannel

    public func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        TrustdartPlugin.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        TrustdartPlugin.eventSink = nil
        return nil
    }
}


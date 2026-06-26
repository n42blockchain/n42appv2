import '../../domain/protocols/messaging_protocol.dart';
import 'matrix_protocol.dart';

/// Registry for managing multiple messaging protocol implementations.
///
/// Allows dynamic registration, retrieval, and switching of
/// protocol implementations at runtime. This enables the application
/// to support multiple protocols simultaneously and switch between
/// them without restarting.
///
/// Usage:
/// ```dart
/// final registry = ProtocolRegistry();
/// registry.register(matrixProtocol);
/// registry.register(xmtpProtocol);
///
/// // Use the active protocol
/// final protocol = registry.activeProtocol;
/// await protocol?.sendMessage(roomId, content);
///
/// // Switch to a different protocol
/// registry.switchProtocol('xmtp');
/// ```
class ProtocolRegistry {
  final Map<String, IMessagingProtocol> _protocols = {};
  String? _activeProtocolId;

  /// Register a protocol implementation.
  ///
  /// If this is the first protocol registered, it automatically
  /// becomes the active protocol.
  void register(IMessagingProtocol protocol) {
    _protocols[protocol.protocolId] = protocol;
    // Set as active if it's the first one registered
    _activeProtocolId ??= protocol.protocolId;
  }

  /// Unregister a protocol by ID.
  ///
  /// If the protocol implements [MatrixProtocol] (or any protocol with
  /// a `dispose()` method), it will be disposed to release resources.
  /// If the unregistered protocol was active, the first remaining
  /// protocol becomes active. If no protocols remain, active is null.
  void unregister(String protocolId) {
    final protocol = _protocols.remove(protocolId);
    if (protocol is MatrixProtocol) {
      protocol.dispose();
    }
    if (_activeProtocolId == protocolId) {
      _activeProtocolId =
          _protocols.keys.isNotEmpty ? _protocols.keys.first : null;
    }
  }

  /// Get the currently active protocol
  IMessagingProtocol? get activeProtocol {
    if (_activeProtocolId == null) return null;
    return _protocols[_activeProtocolId];
  }

  /// Get a protocol by ID
  IMessagingProtocol? getProtocol(String protocolId) =>
      _protocols[protocolId];

  /// Switch the active protocol.
  ///
  /// Returns true if the switch was successful (protocol exists),
  /// false if the protocol ID is not registered.
  bool switchProtocol(String protocolId) {
    if (!_protocols.containsKey(protocolId)) return false;
    _activeProtocolId = protocolId;
    return true;
  }

  /// Get all registered protocol IDs
  List<String> get registeredProtocols => _protocols.keys.toList();

  /// Get the active protocol ID
  String? get activeProtocolId => _activeProtocolId;

  /// Check if a protocol is registered
  bool isRegistered(String protocolId) => _protocols.containsKey(protocolId);
}

// The verification nodes a phone can mine against. Any node works for any
// device; the UI shows only node names, never addresses.

/// One verification node of the fleet.
class MiningV3Node {
  const MiningV3Node(this.id, this.name, this.url);

  /// Stable key stored in preferences.
  final String id;

  /// Name shown to users.
  final String name;

  /// The node's mobileverify base URL. Never shown in the UI.
  final String url;
}

const miningV3Nodes = <MiningV3Node>[
  MiningV3Node('us-1', 'US 1', 'http://5.161.199.154:21012'),
  MiningV3Node('fsn-1', 'Falkenstein 1', 'http://138.199.148.145:21013'),
  MiningV3Node('fsn-2', 'Falkenstein 2', 'http://138.199.148.145:21014'),
  MiningV3Node('fsn-3', 'Falkenstein 3', 'http://138.199.148.145:21015'),
  MiningV3Node('nbg-1', 'Nuremberg 1', 'http://188.245.191.239:21016'),
  MiningV3Node('nbg-2', 'Nuremberg 2', 'http://188.245.191.239:21017'),
  MiningV3Node('nbg-3', 'Nuremberg 3', 'http://188.245.191.239:21018'),
];

/// Stored selection meaning "use this device's assigned node".
const miningV3AutoNodeId = 'auto';

MiningV3Node? miningV3NodeById(String? id) {
  for (final node in miningV3Nodes) {
    if (node.id == id) return node;
  }
  return null;
}

MiningV3Node? miningV3NodeByUrl(String? url) {
  for (final node in miningV3Nodes) {
    if (node.url == url) return node;
  }
  return null;
}

/// Replaces node addresses in [text] (e.g. a native error) with node names.
String miningV3HideNodeAddresses(String text) {
  var result = text;
  for (final node in miningV3Nodes) {
    final uri = Uri.parse(node.url);
    result = result
        .replaceAll(node.url, node.name)
        .replaceAll('${uri.host}:${uri.port}', node.name);
  }
  return result;
}

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/message_entity.dart';

void main() {
  test('specialized metadata copies preserve encrypted media material', () {
    const metadata = MessageMetadata(
      mediaUrl: 'mxc://server/id',
      encryptKey: 'key',
      encryptIv: 'iv',
      encryptSha256: 'hash',
    );

    final copies = [
      metadata.copyWithPoll(pollEnded: true),
      metadata.copyWithTranscription(transcription: 'hello'),
      metadata.copyWithTransfer(transferStatus: 'confirmed'),
    ];

    for (final copy in copies) {
      expect(copy.mediaUrl, metadata.mediaUrl);
      expect(copy.encryptKey, 'key');
      expect(copy.encryptIv, 'iv');
      expect(copy.encryptSha256, 'hash');
    }
  });
}

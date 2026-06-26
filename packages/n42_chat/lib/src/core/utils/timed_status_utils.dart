class TimedStatusMetadata {
  final String? message;
  final DateTime? expiresAt;

  const TimedStatusMetadata({this.message, this.expiresAt});

  bool get hasMessage => message != null && message!.trim().isNotEmpty;

  bool get isExpired {
    final expiry = expiresAt;
    if (expiry == null) {
      return false;
    }
    return !expiry.isAfter(DateTime.now().toUtc());
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (hasMessage) {
      json['message'] = message;
    }
    if (expiresAt != null) {
      json['expiresAt'] = expiresAt!.toUtc().toIso8601String();
    }
    return json;
  }

  factory TimedStatusMetadata.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TimedStatusMetadata();
    }

    final rawMessage = json['message'];
    final rawExpiry = json['expiresAt'];

    DateTime? expiresAt;
    if (rawExpiry is String && rawExpiry.isNotEmpty) {
      expiresAt = DateTime.tryParse(rawExpiry)?.toUtc();
    }

    return TimedStatusMetadata(
      message: rawMessage is String && rawMessage.trim().isNotEmpty
          ? rawMessage
          : null,
      expiresAt: expiresAt,
    );
  }
}

//
//  Generated code. Do not modify.
//  source: connect.ext.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class PackageType extends $pb.ProtobufEnum {
  static const PackageType PT_UNKNOWN = PackageType._(0, _omitEnumNames ? '' : 'PT_UNKNOWN');
  static const PackageType PT_SIGN_IN = PackageType._(1, _omitEnumNames ? '' : 'PT_SIGN_IN');
  static const PackageType PT_SYNC = PackageType._(2, _omitEnumNames ? '' : 'PT_SYNC');
  static const PackageType PT_HEARTBEAT = PackageType._(3, _omitEnumNames ? '' : 'PT_HEARTBEAT');
  static const PackageType PT_MESSAGE = PackageType._(4, _omitEnumNames ? '' : 'PT_MESSAGE');
  static const PackageType PT_SUBSCRIBE_ROOM = PackageType._(5, _omitEnumNames ? '' : 'PT_SUBSCRIBE_ROOM');

  static const $core.List<PackageType> values = <PackageType> [
    PT_UNKNOWN,
    PT_SIGN_IN,
    PT_SYNC,
    PT_HEARTBEAT,
    PT_MESSAGE,
    PT_SUBSCRIBE_ROOM,
  ];

  static final $core.Map<$core.int, PackageType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static PackageType? valueOf($core.int value) => _byValue[value];

  const PackageType._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');

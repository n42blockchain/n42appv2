//
//  Generated code. Do not modify.
//  source: logic.ext.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class MemberType extends $pb.ProtobufEnum {
  static const MemberType GMT_UNKNOWN = MemberType._(0, _omitEnumNames ? '' : 'GMT_UNKNOWN');
  static const MemberType GMT_ADMIN = MemberType._(1, _omitEnumNames ? '' : 'GMT_ADMIN');
  static const MemberType GMT_MEMBER = MemberType._(2, _omitEnumNames ? '' : 'GMT_MEMBER');

  static const $core.List<MemberType> values = <MemberType> [
    GMT_UNKNOWN,
    GMT_ADMIN,
    GMT_MEMBER,
  ];

  static final $core.Map<$core.int, MemberType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MemberType? valueOf($core.int value) => _byValue[value];

  const MemberType._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');

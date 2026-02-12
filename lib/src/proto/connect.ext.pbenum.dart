// This is a generated file - do not edit.
//
// Generated from connect.ext.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class PackageType extends $pb.ProtobufEnum {
  static const PackageType PT_UNKNOWN =
      PackageType._(0, _omitEnumNames ? '' : 'PT_UNKNOWN');
  static const PackageType PT_SIGN_IN =
      PackageType._(1, _omitEnumNames ? '' : 'PT_SIGN_IN');
  static const PackageType PT_SYNC =
      PackageType._(2, _omitEnumNames ? '' : 'PT_SYNC');
  static const PackageType PT_HEARTBEAT =
      PackageType._(3, _omitEnumNames ? '' : 'PT_HEARTBEAT');
  static const PackageType PT_MESSAGE =
      PackageType._(4, _omitEnumNames ? '' : 'PT_MESSAGE');
  static const PackageType PT_SUBSCRIBE_ROOM =
      PackageType._(5, _omitEnumNames ? '' : 'PT_SUBSCRIBE_ROOM');

  static const $core.List<PackageType> values = <PackageType>[
    PT_UNKNOWN,
    PT_SIGN_IN,
    PT_SYNC,
    PT_HEARTBEAT,
    PT_MESSAGE,
    PT_SUBSCRIBE_ROOM,
  ];

  static final $core.List<PackageType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static PackageType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PackageType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');

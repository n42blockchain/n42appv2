// This is a generated file - do not edit.
//
// Generated from push.ext.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class PushCode extends $pb.ProtobufEnum {
  static const PushCode PC_ADD_DEFAULT =
      PushCode._(0, _omitEnumNames ? '' : 'PC_ADD_DEFAULT');
  static const PushCode PC_USER_MESSAGE =
      PushCode._(100, _omitEnumNames ? '' : 'PC_USER_MESSAGE');
  static const PushCode PC_GROUP_MESSAGE =
      PushCode._(101, _omitEnumNames ? '' : 'PC_GROUP_MESSAGE');
  static const PushCode PC_ADD_FRIEND =
      PushCode._(110, _omitEnumNames ? '' : 'PC_ADD_FRIEND');
  static const PushCode PC_AGREE_ADD_FRIEND =
      PushCode._(111, _omitEnumNames ? '' : 'PC_AGREE_ADD_FRIEND');
  static const PushCode PC_UPDATE_GROUP =
      PushCode._(120, _omitEnumNames ? '' : 'PC_UPDATE_GROUP');
  static const PushCode PC_ADD_GROUP_MEMBERS =
      PushCode._(121, _omitEnumNames ? '' : 'PC_ADD_GROUP_MEMBERS');
  static const PushCode PC_REMOVE_GROUP_MEMBER =
      PushCode._(122, _omitEnumNames ? '' : 'PC_REMOVE_GROUP_MEMBER');

  static const $core.List<PushCode> values = <PushCode>[
    PC_ADD_DEFAULT,
    PC_USER_MESSAGE,
    PC_GROUP_MESSAGE,
    PC_ADD_FRIEND,
    PC_AGREE_ADD_FRIEND,
    PC_UPDATE_GROUP,
    PC_ADD_GROUP_MEMBERS,
    PC_REMOVE_GROUP_MEMBER,
  ];

  static final $core.Map<$core.int, PushCode> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static PushCode? valueOf($core.int value) => _byValue[value];

  const PushCode._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');

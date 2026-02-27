// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

class AddressBookModel {
  int? id;
  String? coinName;
  String? coinIcon;
  String? address;
  String? name;
  String? desc;

  AddressBookModel();

  AddressBookModel.fromJson(Map<String, dynamic> map) {
    id = map['id'] as int?;
    coinName = map['coinName'] as String?;
    coinIcon = map['coinIcon'] as String?;
    address = map['address'] as String?;
    name = map['name'] as String?;
    desc = map['desc'] as String?;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coinName': coinName,
      'coinIcon': coinIcon,
      'address': address,
      'name': name,
      'desc': desc,
    };
  }
}

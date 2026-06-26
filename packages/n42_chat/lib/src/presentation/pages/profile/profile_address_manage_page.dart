import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../core/utils/debug_log.dart';

class AddressManagePage extends StatefulWidget {
  const AddressManagePage({super.key});

  @override
  State<AddressManagePage> createState() => AddressManagePageState();
}

class AddressManagePageState extends State<AddressManagePage> {
  List<AddressItem> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final clientManager = getIt<MatrixClientManager>();
      final client = clientManager.client;

      if (client != null && client.isLogged()) {
        try {
          final data = await client.getAccountData(
            client.userID!,
            'n42.user.addresses',
          );
          if (!mounted) return;

          if (data['addresses'] != null) {
            final addressList = data['addresses'] as List;
            setState(() {
              _addresses = addressList.map((item) {
                final map = item as Map<String, dynamic>;
                return AddressItem(
                  name: (map['name'] as String?) ?? '',
                  phone: (map['phone'] as String?) ?? '',
                  region: (map['region'] as String?) ?? '',
                  detail: (map['detail'] as String?) ?? '',
                  isDefault: (map['isDefault'] as bool?) ?? false,
                );
              }).toList();
              _isLoading = false;
            });
            return;
          }
        } catch (e) {
          debugLog('No saved addresses: $e');
        }
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugLog('Load addresses error: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAddresses() async {
    try {
      final clientManager = getIt<MatrixClientManager>();
      final client = clientManager.client;

      if (client != null && client.isLogged()) {
        final addressList = _addresses
            .map(
              (item) => {
                'name': item.name,
                'phone': item.phone,
                'region': item.region,
                'detail': item.detail,
                'isDefault': item.isDefault,
              },
            )
            .toList();

        await client.setAccountData(client.userID!, 'n42.user.addresses', {
          'addresses': addressList,
        });
        debugLog('Addresses saved successfully');
      }
    } catch (e) {
      debugLog('Save addresses error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${S.of(context)?.profileSaveAddressFailed ?? 'Save address failed'}: $e',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        title: Text(S.of(context)?.profileMyAddresses ?? 'My Addresses'),
        backgroundColor: context.surfaceColor,
        actions: [
          TextButton(
            onPressed: _addAddress,
            child: Text(S.of(context)?.profileAddNew ?? 'Add New'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_off_outlined,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    S.of(context)?.profileNoShippingAddress ??
                        'No shipping address',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.3,
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _addAddress,
                    icon: const Icon(Icons.add),
                    label: Text(
                      S.of(context)?.profileAddAddress ?? 'Add Address',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                address.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.3,
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                address.phone,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  height: 1.3,
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (address.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  S.of(context)?.profileDefaultLabel ??
                                      'Default',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.3,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          address.fullAddress,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            height: 1.4,
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _editAddress(index),
                              child: Text(S.of(context)?.commonEdit ?? 'Edit'),
                            ),
                            TextButton(
                              onPressed: () => _deleteAddress(index),
                              child: Text(
                                S.of(context)?.commonDelete ?? 'Delete',
                                style: const TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _addAddress() async {
    final result = await _showAddressEditor();
    if (result != null) {
      // 如果新地址设为默认，清除其他默认地址
      if (result.isDefault) {
        for (int i = 0; i < _addresses.length; i++) {
          if (_addresses[i].isDefault) {
            _addresses[i] = AddressItem(
              name: _addresses[i].name,
              phone: _addresses[i].phone,
              region: _addresses[i].region,
              detail: _addresses[i].detail,
              isDefault: false,
            );
          }
        }
      }
      setState(() {
        _addresses.add(result);
      });
      await _saveAddresses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.profileAddressAdded ?? 'Address added',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Future<void> _editAddress(int index) async {
    final result = await _showAddressEditor(address: _addresses[index]);
    if (result != null) {
      // 如果修改后的地址设为默认，清除其他默认地址
      if (result.isDefault) {
        for (int i = 0; i < _addresses.length; i++) {
          if (i != index && _addresses[i].isDefault) {
            _addresses[i] = AddressItem(
              name: _addresses[i].name,
              phone: _addresses[i].phone,
              region: _addresses[i].region,
              detail: _addresses[i].detail,
              isDefault: false,
            );
          }
        }
      }
      setState(() {
        _addresses[index] = result;
      });
      await _saveAddresses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.profileAddressUpdated ?? 'Address updated',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _deleteAddress(int index) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context)?.profileDeleteAddress ?? 'Delete Address'),
        content: Text(
          S.of(context)?.profileConfirmDeleteAddress ??
              'Are you sure you want to delete this address?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() {
                _addresses.removeAt(index);
              });
              await _saveAddresses();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      S.of(context)?.profileAddressDeleted ?? 'Address deleted',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
            child: Text(
              S.of(context)?.commonDelete ?? 'Delete',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<AddressItem?> _showAddressEditor({AddressItem? address}) async {
    final nameController = TextEditingController(text: address?.name);
    final phoneController = TextEditingController(text: address?.phone);
    final regionController = TextEditingController(text: address?.region);
    final detailController = TextEditingController(text: address?.detail);
    bool isDefault = address?.isDefault ?? false;

    final s = S.of(context);
    try {
      return await showDialog<AddressItem>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: Text(
              address == null
                  ? (s?.profileAddAddress ?? 'Add Address')
                  : (s?.profileEditAddress ?? 'Edit Address'),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: s?.profileRecipient ?? 'Recipient',
                      hintText:
                          s?.profileEnterRecipientName ??
                          'Enter recipient name',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: s?.profilePhoneNumber ?? 'Phone Number',
                      hintText:
                          s?.profileEnterPhoneNumber ?? 'Enter phone number',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: regionController,
                    decoration: InputDecoration(
                      labelText: s?.profileRegion ?? 'Region',
                      hintText:
                          s?.profileRegionHint ?? 'Province/City/District',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: detailController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText:
                          s?.profileDetailedAddress ?? 'Detailed Address',
                      hintText:
                          s?.profileDetailedAddressHint ??
                          'Street, building number, etc.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: isDefault,
                    onChanged: (value) {
                      setDialogState(() {
                        isDefault = value ?? false;
                      });
                    },
                    title: Text(
                      s?.profileSetAsDefaultAddress ?? 'Set as default address',
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(s?.commonCancel ?? 'Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      phoneController.text.isEmpty ||
                      regionController.text.isEmpty ||
                      detailController.text.isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          s?.profilePleaseCompleteInfo ??
                              'Please complete all fields',
                        ),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(
                    dialogContext,
                    AddressItem(
                      name: nameController.text,
                      phone: phoneController.text,
                      region: regionController.text,
                      detail: detailController.text,
                      isDefault: isDefault,
                    ),
                  );
                },
                child: Text(s?.commonSave ?? 'Save'),
              ),
            ],
          ),
        ),
      );
    } finally {
      nameController.dispose();
      phoneController.dispose();
      regionController.dispose();
      detailController.dispose();
    }
  }
}

/// 地址数据模型
class AddressItem {
  final String name;
  final String phone;
  final String region;
  final String detail;
  final bool isDefault;

  AddressItem({
    required this.name,
    required this.phone,
    required this.region,
    required this.detail,
    this.isDefault = false,
  });

  String get fullAddress => '$region $detail';
}

/// 发票抬头管理页面

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../core/utils/debug_log.dart';

class InvoiceManagePage extends StatefulWidget {
  const InvoiceManagePage({super.key});

  @override
  State<InvoiceManagePage> createState() => InvoiceManagePageState();
}

class InvoiceManagePageState extends State<InvoiceManagePage> {
  List<InvoiceItem> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    try {
      final clientManager = getIt<MatrixClientManager>();
      final client = clientManager.client;

      if (client != null && client.isLogged()) {
        try {
          final data = await client.getAccountData(
            client.userID!,
            'n42.user.invoices',
          );

          if (data['invoices'] != null) {
            final invoiceList = data['invoices'] as List;
            setState(() {
              _invoices = invoiceList.map((item) {
                final map = item as Map<String, dynamic>;
                return InvoiceItem(
                  type: (map['type'] as String?) ?? 'personal',
                  title: (map['title'] as String?) ?? '',
                  taxNumber: map['taxNumber'] as String?,
                  bankName: map['bankName'] as String?,
                  bankAccount: map['bankAccount'] as String?,
                  companyAddress: map['companyAddress'] as String?,
                  companyPhone: map['companyPhone'] as String?,
                  isDefault: (map['isDefault'] as bool?) ?? false,
                );
              }).toList();
              _isLoading = false;
            });
            return;
          }
        } catch (e) {
          debugLog('No saved invoices: $e');
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugLog('Load invoices error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveInvoices() async {
    try {
      final clientManager = getIt<MatrixClientManager>();
      final client = clientManager.client;

      if (client != null && client.isLogged()) {
        final invoiceList = _invoices
            .map(
              (item) => {
                'type': item.type,
                'title': item.title,
                'taxNumber': item.taxNumber,
                'bankName': item.bankName,
                'bankAccount': item.bankAccount,
                'companyAddress': item.companyAddress,
                'companyPhone': item.companyPhone,
                'isDefault': item.isDefault,
              },
            )
            .toList();

        await client.setAccountData(client.userID!, 'n42.user.invoices', {
          'invoices': invoiceList,
        });
        debugLog('Invoices saved successfully');
      }
    } catch (e) {
      debugLog('Save invoices error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${S.of(context)?.profileSaveInvoiceFailed ?? 'Save invoice failed'}: $e',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(S.of(context)?.profileMyInvoices ?? 'My Invoices'),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        actions: [
          TextButton(
            onPressed: _addInvoice,
            child: Text(S.of(context)?.profileAddNew ?? 'Add New'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invoices.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    S.of(context)?.profileNoInvoice ?? 'No invoice',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _addInvoice,
                    icon: const Icon(Icons.add),
                    label: Text(
                      S.of(context)?.profileAddInvoice ?? 'Add Invoice',
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
              itemCount: _invoices.length,
              itemBuilder: (context, index) {
                final invoice = _invoices[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: invoice.type == 'company'
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                invoice.type == 'company'
                                    ? (S.of(context)?.profileCompany ??
                                          'Company')
                                    : (S.of(context)?.profilePersonal ??
                                          'Personal'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: invoice.type == 'company'
                                      ? AppColors.primary
                                      : Colors.orange,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                invoice.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (invoice.isDefault)
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
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (invoice.taxNumber != null &&
                            invoice.taxNumber!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${S.of(context)?.profileTaxNumber ?? 'Tax Number'}: ${invoice.taxNumber}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _editInvoice(index),
                              child: Text(S.of(context)?.commonEdit ?? 'Edit'),
                            ),
                            TextButton(
                              onPressed: () => _deleteInvoice(index),
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

  Future<void> _addInvoice() async {
    final result = await _showInvoiceEditor();
    if (result != null) {
      if (result.isDefault) {
        for (int i = 0; i < _invoices.length; i++) {
          if (_invoices[i].isDefault) {
            _invoices[i] = InvoiceItem(
              type: _invoices[i].type,
              title: _invoices[i].title,
              taxNumber: _invoices[i].taxNumber,
              bankName: _invoices[i].bankName,
              bankAccount: _invoices[i].bankAccount,
              companyAddress: _invoices[i].companyAddress,
              companyPhone: _invoices[i].companyPhone,
              isDefault: false,
            );
          }
        }
      }
      setState(() {
        _invoices.add(result);
      });
      await _saveInvoices();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.profileInvoiceAdded ?? 'Invoice added',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Future<void> _editInvoice(int index) async {
    final result = await _showInvoiceEditor(invoice: _invoices[index]);
    if (result != null) {
      if (result.isDefault) {
        for (int i = 0; i < _invoices.length; i++) {
          if (i != index && _invoices[i].isDefault) {
            _invoices[i] = InvoiceItem(
              type: _invoices[i].type,
              title: _invoices[i].title,
              taxNumber: _invoices[i].taxNumber,
              bankName: _invoices[i].bankName,
              bankAccount: _invoices[i].bankAccount,
              companyAddress: _invoices[i].companyAddress,
              companyPhone: _invoices[i].companyPhone,
              isDefault: false,
            );
          }
        }
      }
      setState(() {
        _invoices[index] = result;
      });
      await _saveInvoices();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.profileInvoiceUpdated ?? 'Invoice updated',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _deleteInvoice(int index) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context)?.profileDeleteInvoice ?? 'Delete Invoice'),
        content: Text(
          S.of(context)?.profileConfirmDeleteInvoice ??
              'Are you sure you want to delete this invoice?',
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
                _invoices.removeAt(index);
              });
              await _saveInvoices();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      S.of(context)?.profileInvoiceDeleted ?? 'Invoice deleted',
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

  Future<InvoiceItem?> _showInvoiceEditor({InvoiceItem? invoice}) async {
    String type = invoice?.type ?? 'personal';
    final titleController = TextEditingController(text: invoice?.title);
    final taxNumberController = TextEditingController(text: invoice?.taxNumber);
    final bankNameController = TextEditingController(text: invoice?.bankName);
    final bankAccountController = TextEditingController(
      text: invoice?.bankAccount,
    );
    final companyAddressController = TextEditingController(
      text: invoice?.companyAddress,
    );
    final companyPhoneController = TextEditingController(
      text: invoice?.companyPhone,
    );
    bool isDefault = invoice?.isDefault ?? false;

    final s = S.of(context);
    try {
      return await showDialog<InvoiceItem>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: Text(
              invoice == null
                  ? (s?.profileAddInvoice ?? 'Add Invoice')
                  : (s?.profileEditInvoice ?? 'Edit Invoice'),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text('${s?.profileInvoiceType ?? 'Invoice Type'}: '),
                      ChoiceChip(
                        label: Text(s?.profilePersonal ?? 'Personal'),
                        selected: type == 'personal',
                        onSelected: (selected) {
                          if (selected) {
                            setDialogState(() => type = 'personal');
                          }
                        },
                      ),
                      ChoiceChip(
                        label: Text(s?.profileCompany ?? 'Company'),
                        selected: type == 'company',
                        onSelected: (selected) {
                          if (selected) {
                            setDialogState(() => type = 'company');
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: type == 'company'
                          ? (s?.profileCompanyName ?? 'Company Name')
                          : (s?.profilePersonalName ?? 'Personal Name'),
                      hintText: type == 'company'
                          ? (s?.profileEnterCompanyName ?? 'Enter company name')
                          : (s?.profileEnterName ?? 'Enter name'),
                    ),
                  ),
                  if (type == 'company') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: taxNumberController,
                      decoration: InputDecoration(
                        labelText: s?.profileTaxIdNumber ?? 'Tax ID Number',
                        hintText:
                            s?.profileEnterTaxIdNumber ?? 'Enter tax ID number',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bankNameController,
                      decoration: InputDecoration(
                        labelText:
                            s?.profileBankNameOptional ??
                            'Bank Name (Optional)',
                        hintText: s?.profileEnterBankName ?? 'Enter bank name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bankAccountController,
                      decoration: InputDecoration(
                        labelText:
                            s?.profileBankAccountOptional ??
                            'Bank Account (Optional)',
                        hintText:
                            s?.profileEnterBankAccount ?? 'Enter bank account',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: companyAddressController,
                      decoration: InputDecoration(
                        labelText:
                            s?.profileCompanyAddressOptional ??
                            'Company Address (Optional)',
                        hintText:
                            s?.profileEnterCompanyAddress ??
                            'Enter company address',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: companyPhoneController,
                      decoration: InputDecoration(
                        labelText:
                            s?.profileCompanyPhoneOptional ??
                            'Company Phone (Optional)',
                        hintText:
                            s?.profileEnterCompanyPhone ??
                            'Enter company phone',
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: isDefault,
                    onChanged: (value) {
                      setDialogState(() {
                        isDefault = value ?? false;
                      });
                    },
                    title: Text(
                      s?.profileSetAsDefaultInvoice ?? 'Set as default invoice',
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
                  if (titleController.text.isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          type == 'company'
                              ? (s?.profileEnterCompanyName ??
                                    'Enter company name')
                              : (s?.profileEnterName ?? 'Enter name'),
                        ),
                      ),
                    );
                    return;
                  }
                  if (type == 'company' && taxNumberController.text.isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          s?.profileEnterTaxIdNumber ?? 'Enter tax ID number',
                        ),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(
                    dialogContext,
                    InvoiceItem(
                      type: type,
                      title: titleController.text,
                      taxNumber: type == 'company'
                          ? taxNumberController.text
                          : null,
                      bankName: type == 'company'
                          ? bankNameController.text
                          : null,
                      bankAccount: type == 'company'
                          ? bankAccountController.text
                          : null,
                      companyAddress: type == 'company'
                          ? companyAddressController.text
                          : null,
                      companyPhone: type == 'company'
                          ? companyPhoneController.text
                          : null,
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
      titleController.dispose();
      taxNumberController.dispose();
      bankNameController.dispose();
      bankAccountController.dispose();
      companyAddressController.dispose();
      companyPhoneController.dispose();
    }
  }
}

/// 发票抬头数据模型
class InvoiceItem {
  final String type; // 'personal' or 'company'
  final String title;
  final String? taxNumber;
  final String? bankName;
  final String? bankAccount;
  final String? companyAddress;
  final String? companyPhone;
  final bool isDefault;

  InvoiceItem({
    required this.type,
    required this.title,
    this.taxNumber,
    this.bankName,
    this.bankAccount,
    this.companyAddress,
    this.companyPhone,
    this.isDefault = false,
  });
}

/// 铃声选择页面
///
/// 使用设备系统铃声列表，确保所有铃声都可以正常播放

// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:n42_wallet/core/security/tx_risk_formatters.dart';
import 'package:n42_wallet/core/security/tx_risk_models.dart';

// ERC-20 selectors (used for function name resolution)
const String selIncAllowance = '0xb0431182';

TxRiskAnalysis decodeErc20Transfer(String params) {
  final fields = <TxRiskField>[];
  if (params.length >= 128) {
    final to = txRiskDecodeAddress(params.substring(0, 64));
    final amount = params.substring(64, 128);
    fields.add(TxRiskField('To', txRiskFormatAddress(to)));
    fields.add(TxRiskField('Amount', txRiskFormatAmount(amount)));
  }
  return TxRiskAnalysis(
    level: TxRiskLevel.safe,
    functionName: 'ERC-20 Transfer',
    fields: fields,
  );
}

TxRiskAnalysis decodeApprove(String params, String selector) {
  final fields = <TxRiskField>[];
  final warnings = <String>[];
  var level = TxRiskLevel.caution;

  if (params.length >= 128) {
    final spender = txRiskDecodeAddress(params.substring(0, 64));
    final amountHex = params.substring(64, 128);
    final isUnlimited = txRiskIsMaxUint256(amountHex);

    if (isUnlimited) {
      level = TxRiskLevel.danger;
      warnings.add(
        'Unlimited approval — spender can transfer ALL tokens in this '
        'contract from your wallet at any time.',
      );
    }

    fields.add(TxRiskField('Spender', txRiskFormatAddress(spender)));
    fields.add(TxRiskField(
      'Amount',
      isUnlimited ? 'Unlimited ∞' : txRiskFormatAmount(amountHex),
      isHighlighted: isUnlimited,
    ));
  }

  return TxRiskAnalysis(
    level: level,
    functionName:
        selector == selIncAllowance ? 'Increase Allowance' : 'ERC-20 Approve',
    fields: fields,
    warnings: warnings,
  );
}

TxRiskAnalysis decodeTransferFrom(String params) {
  final fields = <TxRiskField>[];
  if (params.length >= 192) {
    final from = txRiskDecodeAddress(params.substring(0, 64));
    final to = txRiskDecodeAddress(params.substring(64, 128));
    final amount = params.substring(128, 192);
    fields.add(TxRiskField('From', txRiskFormatAddress(from)));
    fields.add(TxRiskField('To', txRiskFormatAddress(to)));
    fields.add(TxRiskField('Amount', txRiskFormatAmount(amount)));
  }
  return TxRiskAnalysis(
    level: TxRiskLevel.caution,
    functionName: 'ERC-20 TransferFrom',
    fields: fields,
    warnings: ['Tokens will be transferred FROM another address on their behalf.'],
  );
}

TxRiskAnalysis decodePermit(String params) {
  final fields = <TxRiskField>[];
  final warnings = <String>[];

  if (params.length >= 320) {
    // owner(32) + spender(32) + value(32) + deadline(32) + v(32) + r(32) + s(32)
    final spender = txRiskDecodeAddress(params.substring(64, 128));
    final amountHex = params.substring(128, 192);
    final isUnlimited = txRiskIsMaxUint256(amountHex);

    fields.add(TxRiskField('Spender', txRiskFormatAddress(spender)));
    fields.add(TxRiskField(
      'Amount',
      isUnlimited ? 'Unlimited ∞' : txRiskFormatAmount(amountHex),
      isHighlighted: isUnlimited,
    ));

    warnings.add(
      'Gasless approval (EIP-2612): spender gains transfer rights '
      'without any further transaction from you.',
    );
    if (isUnlimited) {
      warnings.add('Amount is UNLIMITED — spender can drain all tokens.');
    }
  }

  return TxRiskAnalysis(
    level: TxRiskLevel.danger,
    functionName: 'Gasless Approve (Permit)',
    fields: fields,
    warnings: warnings,
  );
}

TxRiskAnalysis decodeSetApprovalForAll(String params) {
  final fields = <TxRiskField>[];
  if (params.length >= 64) {
    final operator = txRiskDecodeAddress(params.substring(0, 64));
    fields.add(TxRiskField('Operator', txRiskFormatAddress(operator)));
    if (params.length >= 128) {
      final approved = params.substring(64, 128).endsWith('1');
      fields.add(TxRiskField(
        'Action',
        approved ? 'Grant Access' : 'Revoke Access',
      ));
    }
  }
  return TxRiskAnalysis(
    level: TxRiskLevel.danger,
    functionName: 'NFT Approve All (setApprovalForAll)',
    fields: fields,
    warnings: [
      'Grants the operator full access to your entire NFT collection in '
      'this contract. Revoke after use.',
    ],
  );
}

TxRiskAnalysis decodeTransferOwnership(String params) {
  final fields = <TxRiskField>[];
  if (params.length >= 64) {
    final newOwner = txRiskDecodeAddress(params.substring(0, 64));
    fields.add(TxRiskField('New Owner', txRiskFormatAddress(newOwner)));
  }
  return TxRiskAnalysis(
    level: TxRiskLevel.danger,
    functionName: 'Transfer Ownership',
    fields: fields,
    warnings: [
      'Contract ownership will be permanently transferred to a new address.',
    ],
  );
}

TxRiskAnalysis decodeNftTransfer(String params) {
  final fields = <TxRiskField>[];
  if (params.length >= 192) {
    final from = txRiskDecodeAddress(params.substring(0, 64));
    final to = txRiskDecodeAddress(params.substring(64, 128));
    fields.add(TxRiskField('From', txRiskFormatAddress(from)));
    fields.add(TxRiskField('To', txRiskFormatAddress(to)));
  }
  return TxRiskAnalysis(
    level: TxRiskLevel.safe,
    functionName: 'NFT Transfer',
    fields: fields,
  );
}

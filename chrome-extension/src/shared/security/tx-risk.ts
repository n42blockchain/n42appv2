/**
 * Transaction Risk Analyzer — ported from lib/core/security/tx_risk_analyzer.dart
 *
 * Decodes EVM calldata to identify risky function calls:
 * - Unlimited token approvals (ERC-20/721/1155)
 * - EIP-2612 permit signatures
 * - Suspicious selectors
 */

/** Known EVM function selectors and their risk levels */
const SELECTORS: Record<string, { name: string; risk: 'high' | 'medium' | 'low' | 'info' }> = {
  // ERC-20
  '095ea7b3': { name: 'approve', risk: 'medium' },
  'a9059cbb': { name: 'transfer', risk: 'low' },
  '23b872dd': { name: 'transferFrom', risk: 'medium' },
  // ERC-721
  '42842e0e': { name: 'safeTransferFrom', risk: 'medium' },
  'b88d4fde': { name: 'safeTransferFrom(data)', risk: 'medium' },
  'a22cb465': { name: 'setApprovalForAll', risk: 'high' },
  // ERC-1155
  'f242432a': { name: 'safeTransferFrom(1155)', risk: 'medium' },
  '2eb2c2d6': { name: 'safeBatchTransferFrom', risk: 'medium' },
  // EIP-2612 Permit
  'd505accf': { name: 'permit', risk: 'high' },
  // Swap routers
  '7ff36ab5': { name: 'swapExactETHForTokens', risk: 'low' },
  '38ed1739': { name: 'swapExactTokensForTokens', risk: 'low' },
  '18cbafe5': { name: 'swapExactTokensForETH', risk: 'low' },
  // Multicall
  'ac9650d8': { name: 'multicall', risk: 'info' },
  '5ae401dc': { name: 'multicall(deadline)', risk: 'info' },
  // Proxy
  '3659cfe6': { name: 'upgradeTo', risk: 'high' },
  '4f1ef286': { name: 'upgradeToAndCall', risk: 'high' },
  // Self-destruct trigger
  '00000000': { name: 'unknown(0x00)', risk: 'high' },
};

const MAX_UINT256 = BigInt('0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff');
const HIGH_APPROVAL_THRESHOLD = MAX_UINT256 / 2n;

export interface TxRiskResult {
  level: 'high' | 'medium' | 'low' | 'info';
  function?: string;
  warnings: string[];
}

/** Analyze a transaction for risks */
export function analyzeTxRisk(tx: { to?: string; data?: string; value?: string }): TxRiskResult {
  const warnings: string[] = [];
  let level: TxRiskResult['level'] = 'info';
  let funcName: string | undefined;

  const data = tx.data || '0x';

  // No data = simple ETH transfer
  if (data === '0x' || data.length < 10) {
    if (tx.value && BigInt(tx.value) > 0n) {
      return { level: 'low', function: 'ETH Transfer', warnings: [] };
    }
    return { level: 'info', warnings: [] };
  }

  // Extract selector (first 4 bytes)
  const selector = data.slice(2, 10).toLowerCase();
  const known = SELECTORS[selector];

  if (known) {
    funcName = known.name;
    level = known.risk;

    // Check for unlimited approval
    if (selector === '095ea7b3' && data.length >= 74) {
      try {
        const amount = BigInt('0x' + data.slice(74, 138));
        if (amount >= HIGH_APPROVAL_THRESHOLD) {
          warnings.push('Unlimited token approval — consider setting a specific amount');
          level = 'high';
        }
      } catch { /* ignore parse errors */ }
    }

    // setApprovalForAll with true
    if (selector === 'a22cb465') {
      warnings.push('Grants operator access to ALL tokens in this collection');
    }

    // Permit
    if (selector === 'd505accf') {
      warnings.push('EIP-2612 Permit — grants off-chain token approval');
    }
  } else {
    funcName = `Unknown (0x${selector})`;
    level = 'medium';
    warnings.push('Unknown contract function — review carefully');
  }

  // ETH value with contract call
  if (tx.value && BigInt(tx.value) > 0n && data.length > 2) {
    warnings.push('Sending ETH along with contract call');
  }

  return { level, function: funcName, warnings };
}

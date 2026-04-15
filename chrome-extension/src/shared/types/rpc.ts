/** JSON-RPC 2.0 request from DApp */
export interface RpcRequest {
  id: number;
  method: string;
  params: unknown[];
}

/** JSON-RPC 2.0 response */
export interface RpcResponse {
  id: number;
  jsonrpc: '2.0';
  result?: unknown;
  error?: RpcError;
}

/** JSON-RPC error */
export interface RpcError {
  code: number;
  message: string;
  data?: unknown;
}

/** Internal message between content script and service worker */
export interface ExtensionMessage {
  type: 'N42_RPC_REQUEST' | 'N42_RPC_RESPONSE' | 'N42_EVENT';
  payload: RpcRequest | RpcResponse | EventPayload;
  origin?: string;
}

/** Event from service worker to content script */
export interface EventPayload {
  event: 'chainChanged' | 'accountsChanged' | 'connect' | 'disconnect';
  data: unknown;
}

/** Pending approval request shown in popup */
export interface ApprovalRequest {
  id: string;
  type: 'sign_message' | 'sign_transaction' | 'sign_typed_data' | 'connect';
  origin: string;
  method: string;
  params: unknown;
  timestamp: number;
}

/** Network/chain configuration */
export interface NetworkConfig {
  chainId: number;
  chainIdHex: string;
  name: string;
  rpcUrl: string;
  symbol: string;
  decimals: number;
  explorerUrl?: string;
}

/** Account info */
export interface AccountInfo {
  address: string;
  name: string;
  index: number;
}

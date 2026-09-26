// Package evmsdk limits the Android binding to the app's stable Emit API.
// The engine package also exports Go-only functions with result tuples that
// gobind cannot represent.
package evmsdk

import engine "github.com/n42blockchain/N42/cmd/evmsdk"

// Emit forwards the JSON request/response protocol used by FlutterMiningPlugin.
func Emit(request string) string { return engine.Emit(request) }

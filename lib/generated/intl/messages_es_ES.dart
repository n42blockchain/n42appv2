// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es_ES locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'es_ES';

  static String m0(deviceName, os) =>
      "Su cuenta acaba de iniciar sesión en ${deviceName} (${os}). Si no fue usted, le recomendamos cambiar su contraseña.";

  static String m1(price) => "Precio actual: \$${price}";

  static String m2(symbol) => "Alerta de precio · ${symbol}";

  static String m3(s) => "Reenviar en ${s}s";

  static String m4(message) => "Compra fallida: ${message}";

  static String m5(productId) => "Compra exitosa: ${productId}";

  static String m6(productId) => "Restaurado: ${productId}";

  static String m7(value) => "Cantidad mayor a ${value}.";

  static String m8(value) =>
      "La billetera ya existe, el nombre de la billetera es \"${value}\"";

  static String m9(value) => "Ingrese una cantidad mayor que ${value}";

  static String m10(value) => "Dirección duplicada en fila ${value}";

  static String m11(value) =>
      "Saldo insuficiente: el monto total excedería el disponible ${value}";

  static String m12(value) => "Dirección inválida en fila ${value}";

  static String m13(value) => "Monto inválido en fila ${value}";

  static String m14(value) => "Máximo ${value} destinatarios";

  static String m15(token) => "Aprobar ${token} para continuar";

  static String m16(impact) =>
      "¡Alto impacto en el precio (${impact})! Proceda con precaución.";

  static String m17(secs) => "La cotización vence en ${secs}s";

  static String m18(value) => "Gana hasta ${value}% APY";

  static String m19(value) => "Actualización automática cada ${value} segundos";

  static String m20(address) => "Cuenta ${address} añadida";

  static String m21(address, network) =>
      "¿Desea rastrear esta cuenta de hardware wallet?\n\nDirección: ${address}\nRed: ${network}";

  static String m22(app) => "Aplicación actual: ${app}";

  static String m23(days) => "${days} hace días";

  static String m24(value) => "No se pudo importar la cuenta: ${value}";

  static String m25(date) => "Última conexión: ${date}";

  static String m26(app) =>
      "Asegúrese de que la aplicación ${app} esté abierta en su Ledger";

  static String m27(name) =>
      "¿Está seguro de que desea eliminar \"${name}\" de los dispositivos guardados?";

  static String m28(value) => "Est. gas: ~${value} unidades";

  static String m29(reason) => "Razón: ${reason}";

  static String m30(value) => "${value}d no unido";

  static String m31(value) => "${value} días restantes";

  static String m32(value) =>
      "Quitar el stake tarda ${value} días. Tus tokens estarán bloqueados durante este período.";

  static String m33(value) => "No tienes suficiente \"${value}\"";

  static String m34(value) => "Error al obtener la cuenta\"${value}\" account";

  static String m35(value) =>
      "Mínimo ${value} XRP para la primera transferencia";

  static String m36(count) => "Agregar (${count})";

  static String m37(count) =>
      "${Intl.plural(count, one: '1 token nuevo detectado', other: '${count} nuevos tokens detectados')} — toque para revisar";

  static String m38(value) => "No se agregó ninguna cadena de ${value}";

  static String m39(value) =>
      "${value} tiene transacciones sin finalizar, inténtelo nuevamente más tarde.";

  static String m40(value) => "No se encontró ninguna dirección para ${value}.";

  static String m41(value) => "Saldo insuficiente de ${value}.";

  static String m42(value, value1) =>
      "Cada cuenta XRP debe reservar ${value} XRP (${value1} drops) como mínimo base, el cual no se puede gastar.";

  static String m43(value, value1) =>
      "Por cada objeto que posee la cuenta, se agregan ${value} XRP (${value1} drops) a la reserva.";

  static String m44(value, value1) =>
      "Esta cuenta posee ${value} objetos, lo que significa que se reservan ${value1} XRP adicionales.";

  static String m45(message) => "Error al entrar a la sala\n${message}";

  static String m46(value) => "Patrón incorrecto, quedan ${value} intentos";

  static String m47(value) => "Patrón incorrecto, queda ${value} intento";

  static String m48(value) =>
      "Has configurado correctamente un ${value} y comenzarás a verificar con N42Wallet.";

  static String m49(value) =>
      "¡Únase a mi grupo ${value} en @N42Wallet para ser uno de los primeros mineros de una cadena de Capa 1 y obtenga criptomonedas en su teléfono!";

  static String m50(value, value1) =>
      "¿Está seguro de que desea bloquear ${value} N hasta ${value1} para ejecutar un nodo?";

  static String m51(value) => "Error en la importación::${value}";

  static String m52(value) =>
      "Se requiere un saldo de staking de al menos ${value} para obtener recompensas.";

  static String m53(value, value1) =>
      "${value} N por cada ${value1} bloques minados";

  static String m54(value) => "Debe tener ${value} caracteres";

  static String m55(symbol) => "Importe (${symbol})";

  static String m56(amount, symbol) => "Saldo: ${amount} ${symbol}";

  static String m57(label) =>
      "¿Declarar “${label}” ganador y liquidar? No se puede deshacer.";

  static String m58(n) => "${n} min";

  static String m59(n) => "Resultado ${n}";

  static String m60(label, pct) => "${label} gana (${pct}%)";

  static String m61(shares, avg, after) =>
      "Est. ${shares} part. · prom ${avg}% · después ${after}%";

  static String m62(reason) => "Error al canjear: ${reason}";

  static String m63(label) => "Resultado: ${label}";

  static String m64(n) => "Vender ${n}";

  static String m65(value) => "${value} Saldo insuficiente.";

  static String m66(value) => "${value} entrante...";

  static String m67(value) =>
      "El ${value} intercambiado en la aplicación se distribuirá en breve a tu Wallet y no se puede vender a través de este proceso. Se puede usar para ejecutar un nodo.";

  static String m68(value) => "Máximo ${value} caracteres";

  static String m69(value) => "¡La aplicación ${value} chain ya es compatible!";

  static String m70(value) =>
      "La aplicación ${value} chain ya es compatible, ¿quieres agregarla?";

  static String m71(value) =>
      "¡El enlace de prueba de dirección ${value} falló!";

  static String m72(value) => "0~${value} caracteres";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Edit": MessageLookupByLibrary.simpleMessage("Editar"),
    "Verification": MessageLookupByLibrary.simpleMessage("Verificación"),
    "address_Information": MessageLookupByLibrary.simpleMessage(
      "Información de dirección",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copiado exitosamente"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("Copiar dirección"),
    "descO": MessageLookupByLibrary.simpleMessage("Descripción (Opcional)"),
    "device_login_change_password": MessageLookupByLibrary.simpleMessage(
      "Cambiar contraseña",
    ),
    "device_login_dismiss": MessageLookupByLibrary.simpleMessage("Entendido"),
    "device_login_message": m0,
    "device_login_title": MessageLookupByLibrary.simpleMessage(
      "Nuevo inicio de sesión",
    ),
    "file": MessageLookupByLibrary.simpleMessage("Archivo"),
    "g_alert_above": MessageLookupByLibrary.simpleMessage("Va arriba ↑"),
    "g_alert_below": MessageLookupByLibrary.simpleMessage("Cae por debajo ↓"),
    "g_alert_current_price": m1,
    "g_alert_direction": MessageLookupByLibrary.simpleMessage(
      "Avisarme cuando el precio",
    ),
    "g_alert_enable": MessageLookupByLibrary.simpleMessage(
      "Habilitar esta alerta",
    ),
    "g_alert_invalid_price": MessageLookupByLibrary.simpleMessage(
      "Por favor introduce un precio válido mayor que 0",
    ),
    "g_alert_remove": MessageLookupByLibrary.simpleMessage("Quitar"),
    "g_alert_set": MessageLookupByLibrary.simpleMessage("Establecer alerta"),
    "g_alert_target_price": MessageLookupByLibrary.simpleMessage(
      "Precio objetivo (USD)",
    ),
    "g_alert_title": m2,
    "g_alert_update": MessageLookupByLibrary.simpleMessage(
      "Alerta de actualización",
    ),
    "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
      "Los tokens solo se pueden enviar dentro de la misma red. El envío desde otras redes puede provocar pérdidas.",
    ),
    "g_app_share_key_2": MessageLookupByLibrary.simpleMessage(
      "Escanear para recibir",
    ),
    "g_browser_key1": MessageLookupByLibrary.simpleMessage(
      "Por favor ingresa la URL",
    ),
    "g_browser_key10": MessageLookupByLibrary.simpleMessage(
      "Ingresa una descripción",
    ),
    "g_browser_key11": MessageLookupByLibrary.simpleMessage("Navegador"),
    "g_browser_key12": MessageLookupByLibrary.simpleMessage(
      "Borrar caché del navegador",
    ),
    "g_browser_key13": MessageLookupByLibrary.simpleMessage(
      "Conectar DApp automáticamente",
    ),
    "g_browser_key16": MessageLookupByLibrary.simpleMessage("Cerrar todo"),
    "g_browser_key17": MessageLookupByLibrary.simpleMessage("Hecho"),
    "g_browser_key18": MessageLookupByLibrary.simpleMessage("Historial"),
    "g_browser_key19": MessageLookupByLibrary.simpleMessage(
      "Borrar todo el historial",
    ),
    "g_browser_key20": MessageLookupByLibrary.simpleMessage(
      "¿Borrar todo el historial de navegación?",
    ),
    "g_browser_key21": MessageLookupByLibrary.simpleMessage(
      "Historial borrado",
    ),
    "g_browser_key22": MessageLookupByLibrary.simpleMessage("Hoy"),
    "g_browser_key23": MessageLookupByLibrary.simpleMessage("Ayer"),
    "g_browser_key24": MessageLookupByLibrary.simpleMessage("Descubrir DApps"),
    "g_browser_key25": MessageLookupByLibrary.simpleMessage("populares"),
    "g_browser_key26": MessageLookupByLibrary.simpleMessage("DEX"),
    "g_browser_key27": MessageLookupByLibrary.simpleMessage("DeFi"),
    "g_browser_key28": MessageLookupByLibrary.simpleMessage("NFT"),
    "g_browser_key29": MessageLookupByLibrary.simpleMessage("puente"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("Marcadores"),
    "g_browser_key30": MessageLookupByLibrary.simpleMessage("Herramientas"),
    "g_browser_key4": MessageLookupByLibrary.simpleMessage(
      "Aún no se han agregado marcadores",
    ),
    "g_browser_key5": MessageLookupByLibrary.simpleMessage("xMarcador"),
    "g_browser_key6": MessageLookupByLibrary.simpleMessage("Nombre"),
    "g_browser_key7": MessageLookupByLibrary.simpleMessage(
      "Por favor ingresa el nombre",
    ),
    "g_browser_key8": MessageLookupByLibrary.simpleMessage("URL"),
    "g_browser_key9": MessageLookupByLibrary.simpleMessage("Descripción"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("De acuerdo "),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage(
      "El mensaje ha sido eliminado",
    ),
    "g_coin_key_1": MessageLookupByLibrary.simpleMessage("Transacciones"),
    "g_connect_key1": MessageLookupByLibrary.simpleMessage("Conectar"),
    "g_connect_key11": MessageLookupByLibrary.simpleMessage(
      "Redes disponibles",
    ),
    "g_connect_key12": MessageLookupByLibrary.simpleMessage("Signo de mensaje"),
    "g_connect_key13": MessageLookupByLibrary.simpleMessage("Conectando"),
    "g_connect_key14": MessageLookupByLibrary.simpleMessage(
      "Se está emparejando, por favor espere.",
    ),
    "g_connect_key2": MessageLookupByLibrary.simpleMessage("Desconectar"),
    "g_connect_key3": MessageLookupByLibrary.simpleMessage("Rechazar"),
    "g_dapp_security_blocked": MessageLookupByLibrary.simpleMessage(
      "Bloqueado",
    ),
    "g_dapp_security_caution": MessageLookupByLibrary.simpleMessage(
      "Precaución",
    ),
    "g_dapp_security_safe": MessageLookupByLibrary.simpleMessage("Seguro"),
    "g_dapp_security_verified": MessageLookupByLibrary.simpleMessage(
      "Verificado",
    ),
    "g_email_resend": MessageLookupByLibrary.simpleMessage("Reenviar código"),
    "g_email_resend_countdown": m3,
    "g_face_1": MessageLookupByLibrary.simpleMessage(
      "Consejos para el escaneo biométrico",
    ),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "Escanea tu huella digital o tu rostro para autenticación.",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("Consejos"),
    "g_face_5": MessageLookupByLibrary.simpleMessage("Para configurar"),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "Escanea tu rostro o huella digital para continuar.",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("Regresar"),
    "g_google_auth_key1": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator",
    ),
    "g_google_auth_key2": MessageLookupByLibrary.simpleMessage(
      "Escanea el código QR con la aplicación Google Authenticator",
    ),
    "g_google_auth_key3": MessageLookupByLibrary.simpleMessage(
      "O introduce la clave manualmente:",
    ),
    "g_google_auth_key4": MessageLookupByLibrary.simpleMessage(
      "Introduce el código de verificación de 6 dígitos",
    ),
    "g_google_auth_key5": MessageLookupByLibrary.simpleMessage(
      "Se requiere Google Authenticator para confirmar cada transferencia.",
    ),
    "g_google_auth_key6": MessageLookupByLibrary.simpleMessage(
      "Código incorrecto, inténtalo de nuevo",
    ),
    "g_google_auth_key7": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator no configurado",
    ),
    "g_google_auth_key8": MessageLookupByLibrary.simpleMessage(
      "Vinculación exitosa",
    ),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("Perfil"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("Noticias"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("Verificación"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("Invitar a un amigo"),
    "g_iap_cancelled": MessageLookupByLibrary.simpleMessage("Cancelado"),
    "g_iap_check_network": MessageLookupByLibrary.simpleMessage(
      "Comprueba tu conexión de red e inténtalo de nuevo",
    ),
    "g_iap_failed": m4,
    "g_iap_no_products": MessageLookupByLibrary.simpleMessage(
      "No hay productos disponibles",
    ),
    "g_iap_purchased": m5,
    "g_iap_restore": MessageLookupByLibrary.simpleMessage("Restaurar compras"),
    "g_iap_restored": m6,
    "g_iap_restoring": MessageLookupByLibrary.simpleMessage(
      "Restaurando compras…",
    ),
    "g_iap_retry": MessageLookupByLibrary.simpleMessage("Reintentar"),
    "g_iap_store_unavailable": MessageLookupByLibrary.simpleMessage(
      "Tienda no disponible",
    ),
    "g_iap_title": MessageLookupByLibrary.simpleMessage("Comprar"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("¡Error al eliminar!"),
    "g_key_101": MessageLookupByLibrary.simpleMessage("Límite de gas"),
    "g_key_105": MessageLookupByLibrary.simpleMessage("No más"),
    "g_key_106": MessageLookupByLibrary.simpleMessage("Cargando "),
    "g_key_108": MessageLookupByLibrary.simpleMessage("Libreta de Direcciones"),
    "g_key_11": MessageLookupByLibrary.simpleMessage("Importar wallet"),
    "g_key_110": MessageLookupByLibrary.simpleMessage("Administrar"),
    "g_key_112": MessageLookupByLibrary.simpleMessage("Nueva Dirección"),
    "g_key_113": MessageLookupByLibrary.simpleMessage("Eliminar"),
    "g_key_115": MessageLookupByLibrary.simpleMessage("Guardar"),
    "g_key_119": MessageLookupByLibrary.simpleMessage("Copiar"),
    "g_key_12": MessageLookupByLibrary.simpleMessage("Crear/Importar wallet"),
    "g_key_126": MessageLookupByLibrary.simpleMessage("Tema"),
    "g_key_127": MessageLookupByLibrary.simpleMessage("Sistema"),
    "g_key_128": MessageLookupByLibrary.simpleMessage("Luz"),
    "g_key_129": MessageLookupByLibrary.simpleMessage("Oscuridad"),
    "g_key_13": MessageLookupByLibrary.simpleMessage("Lista de billeteras"),
    "g_key_132": MessageLookupByLibrary.simpleMessage("Sin datos"),
    "g_key_134": MessageLookupByLibrary.simpleMessage("Cantidad no válida"),
    "g_key_135": m7,
    "g_key_14": MessageLookupByLibrary.simpleMessage("Monedero principal"),
    "g_key_140": MessageLookupByLibrary.simpleMessage(
      "Transacción realizada con éxito",
    ),
    "g_key_146": MessageLookupByLibrary.simpleMessage("Contraseña Incorrecta"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("Red de prueba"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("Red principal"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("Idioma del sistema"),
    "g_key_15": MessageLookupByLibrary.simpleMessage(
      "Establecer como billetera principal",
    ),
    "g_key_155": MessageLookupByLibrary.simpleMessage("Dirección de la Wallet"),
    "g_key_156": MessageLookupByLibrary.simpleMessage(
      "Escanear para copiar la dirección",
    ),
    "g_key_159": MessageLookupByLibrary.simpleMessage("Agregar"),
    "g_key_16": MessageLookupByLibrary.simpleMessage(
      "Seleccionar billetera de verificación",
    ),
    "g_key_163": MessageLookupByLibrary.simpleMessage("Símbolo"),
    "g_key_166": MessageLookupByLibrary.simpleMessage("Pegar"),
    "g_key_17": MessageLookupByLibrary.simpleMessage("Elija Cadena"),
    "g_key_175": MessageLookupByLibrary.simpleMessage("La transacción falló"),
    "g_key_179": MessageLookupByLibrary.simpleMessage(
      "Esta es la dirección de la Wallet",
    ),
    "g_key_181": MessageLookupByLibrary.simpleMessage("Otro"),
    "g_key_185": MessageLookupByLibrary.simpleMessage("Guardado exitosamente"),
    "g_key_191": MessageLookupByLibrary.simpleMessage("Éxito"),
    "g_key_192": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que deseas eliminar la Wallet?",
    ),
    "g_key_193": MessageLookupByLibrary.simpleMessage("Activo"),
    "g_key_195": MessageLookupByLibrary.simpleMessage(
      "Sin permiso para acceder a la cámara.",
    ),
    "g_key_196": MessageLookupByLibrary.simpleMessage("Explorador"),
    "g_key_197": MessageLookupByLibrary.simpleMessage("Máximo"),
    "g_key_198": MessageLookupByLibrary.simpleMessage("Activos"),
    "g_key_2": MessageLookupByLibrary.simpleMessage(
      "¡El libro mayor está vacío!",
    ),
    "g_key_202": MessageLookupByLibrary.simpleMessage(
      "Resumen de la transacción",
    ),
    "g_key_203": MessageLookupByLibrary.simpleMessage(
      "Error de enlace, escanee el código QR de nuevo, por favor. ",
    ),
    "g_key_206": MessageLookupByLibrary.simpleMessage("Editar contraseña"),
    "g_key_207": MessageLookupByLibrary.simpleMessage("Contraseña anterior"),
    "g_key_208": MessageLookupByLibrary.simpleMessage(
      "Sincronizando saldos...",
    ),
    "g_key_209": MessageLookupByLibrary.simpleMessage("Clave privada"),
    "g_key_21": MessageLookupByLibrary.simpleMessage(
      "Ingrese la contraseña de la Wallet.",
    ),
    "g_key_210": MessageLookupByLibrary.simpleMessage("Error de clave privada"),
    "g_key_213": MessageLookupByLibrary.simpleMessage(
      "Información del mercado",
    ),
    "g_key_214": m8,
    "g_key_25": MessageLookupByLibrary.simpleMessage(
      "La contraseña no coincide.",
    ),
    "g_key_29": MessageLookupByLibrary.simpleMessage("Saldo"),
    "g_key_3": MessageLookupByLibrary.simpleMessage("¡Error al agregar!"),
    "g_key_33": MessageLookupByLibrary.simpleMessage("Recibir"),
    "g_key_37": MessageLookupByLibrary.simpleMessage("Transferir"),
    "g_key_38": MessageLookupByLibrary.simpleMessage("Para"),
    "g_key_4": MessageLookupByLibrary.simpleMessage("Escanear código QR"),
    "g_key_41": MessageLookupByLibrary.simpleMessage(
      "Ingrese la dirección de la Wallet",
    ),
    "g_key_43": MessageLookupByLibrary.simpleMessage("Saldo disponible"),
    "g_key_44": MessageLookupByLibrary.simpleMessage("Cantidad"),
    "g_key_46": m9,
    "g_key_47": MessageLookupByLibrary.simpleMessage("Fondos insuficientes"),
    "g_key_48": MessageLookupByLibrary.simpleMessage("Enviar"),
    "g_key_5": MessageLookupByLibrary.simpleMessage("¡Error al cargar!"),
    "g_key_6": MessageLookupByLibrary.simpleMessage("Cartera"),
    "g_key_7": MessageLookupByLibrary.simpleMessage("Privado y Seguro"),
    "g_key_75": MessageLookupByLibrary.simpleMessage("De"),
    "g_key_78": MessageLookupByLibrary.simpleMessage("Confirmar"),
    "g_key_79": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("Todos los tokens"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("Configuración"),
    "g_key_aa_account_created": MessageLookupByLibrary.simpleMessage(
      "Cuenta creada exitosamente",
    ),
    "g_key_aa_account_details": MessageLookupByLibrary.simpleMessage(
      "Detalles de la cuenta",
    ),
    "g_key_aa_account_name": MessageLookupByLibrary.simpleMessage(
      "Nombre de cuenta",
    ),
    "g_key_aa_account_name_hint": MessageLookupByLibrary.simpleMessage(
      "Introduzca el nombre de la cuenta",
    ),
    "g_key_aa_account_type": MessageLookupByLibrary.simpleMessage(
      "Tipo de cuenta",
    ),
    "g_key_aa_active": MessageLookupByLibrary.simpleMessage("Activo"),
    "g_key_aa_add_first_operation": MessageLookupByLibrary.simpleMessage(
      "Añade tu primera operación",
    ),
    "g_key_aa_add_operation": MessageLookupByLibrary.simpleMessage(
      "Agregar operación",
    ),
    "g_key_aa_address_calculating": MessageLookupByLibrary.simpleMessage(
      "Calculando dirección...",
    ),
    "g_key_aa_address_error": MessageLookupByLibrary.simpleMessage(
      "Error al calcular la dirección. Por favor, inténtelo de nuevo.",
    ),
    "g_key_aa_approve": MessageLookupByLibrary.simpleMessage("Aprobar"),
    "g_key_aa_batch": MessageLookupByLibrary.simpleMessage("lote"),
    "g_key_aa_batch_atomic": MessageLookupByLibrary.simpleMessage(
      "Ejecución atómica",
    ),
    "g_key_aa_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Ejecutar múltiples operaciones a la vez",
    ),
    "g_key_aa_batch_description": MessageLookupByLibrary.simpleMessage(
      "Envía múltiples transacciones en una sola operación",
    ),
    "g_key_aa_batch_failed": MessageLookupByLibrary.simpleMessage(
      "La ejecución por lotes falló",
    ),
    "g_key_aa_batch_no_templates": MessageLookupByLibrary.simpleMessage(
      "No hay plantillas guardadas",
    ),
    "g_key_aa_batch_operations": MessageLookupByLibrary.simpleMessage(
      "Operaciones por lotes",
    ),
    "g_key_aa_batch_save_gas": MessageLookupByLibrary.simpleMessage(
      "Ahorre gasolina",
    ),
    "g_key_aa_batch_save_template": MessageLookupByLibrary.simpleMessage(
      "Guardar como plantilla",
    ),
    "g_key_aa_batch_submitting": MessageLookupByLibrary.simpleMessage(
      "Enviando...",
    ),
    "g_key_aa_batch_success": MessageLookupByLibrary.simpleMessage(
      "Lote enviado exitosamente",
    ),
    "g_key_aa_batch_template_load": MessageLookupByLibrary.simpleMessage(
      "Cargar plantilla",
    ),
    "g_key_aa_batch_template_name": MessageLookupByLibrary.simpleMessage(
      "Nombre de la plantilla",
    ),
    "g_key_aa_batch_template_name_hint": MessageLookupByLibrary.simpleMessage(
      "Introduzca el nombre de la plantilla",
    ),
    "g_key_aa_batch_template_saved": MessageLookupByLibrary.simpleMessage(
      "Plantilla guardada",
    ),
    "g_key_aa_batch_templates": MessageLookupByLibrary.simpleMessage(
      "Plantillas",
    ),
    "g_key_aa_batch_transaction": MessageLookupByLibrary.simpleMessage(
      "Transacción por lotes",
    ),
    "g_key_aa_benefit_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Apruebe e intercambie en una sola transacción: no más confirmaciones de dos pasos",
    ),
    "g_key_aa_benefit_batch_title": MessageLookupByLibrary.simpleMessage(
      "Acciones por lotes con un clic",
    ),
    "g_key_aa_benefit_gas_desc": MessageLookupByLibrary.simpleMessage(
      "Patrocine transacciones o pague tarifas con tokens ERC-20 en lugar de ETH",
    ),
    "g_key_aa_benefit_gas_title": MessageLookupByLibrary.simpleMessage(
      "Pague gasolina con cualquier token",
    ),
    "g_key_aa_benefit_recovery_desc": MessageLookupByLibrary.simpleMessage(
      "Recupere el acceso a través de contactos de confianza si pierde su clave privada",
    ),
    "g_key_aa_benefit_recovery_title": MessageLookupByLibrary.simpleMessage(
      "Recuperación Social",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "Cuenta inteligente ERC-7579 modular con soporte para transacciones sin gas",
    ),
    "g_key_aa_by": MessageLookupByLibrary.simpleMessage("por"),
    "g_key_aa_chain": MessageLookupByLibrary.simpleMessage("cadena"),
    "g_key_aa_chain_id": MessageLookupByLibrary.simpleMessage("ID de cadena"),
    "g_key_aa_change": MessageLookupByLibrary.simpleMessage("Cambiar"),
    "g_key_aa_check_status": MessageLookupByLibrary.simpleMessage(
      "Verificar estado",
    ),
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage(
      "Próximamente",
    ),
    "g_key_aa_counterfactual_note": MessageLookupByLibrary.simpleMessage(
      "Esta es una dirección contrafactual. Se implementará en su primera transacción.",
    ),
    "g_key_aa_create_account": MessageLookupByLibrary.simpleMessage(
      "Crear cuenta inteligente",
    ),
    "g_key_aa_create_first": MessageLookupByLibrary.simpleMessage(
      "Crea tu primera cuenta inteligente",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage(
      "Crear clave de sesión",
    ),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("Creado"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage("personalizado"),
    "g_key_aa_deploy_auto_note": MessageLookupByLibrary.simpleMessage(
      "La cuenta se implementará automáticamente en su primera transacción",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("Implementado"),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage(
      "Implementando...",
    ),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "La implementación se producirá automáticamente con su primera transacción.",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "Experimente la próxima generación de cuentas Ethereum con funciones mejoradas",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("Detalles"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "EOA híbrido/Cuenta inteligente: no se necesita implementación",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("error"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage(
      "Gasolina estimada",
    ),
    "g_key_aa_execute_batch": MessageLookupByLibrary.simpleMessage(
      "Ejecutar lote",
    ),
    "g_key_aa_expired": MessageLookupByLibrary.simpleMessage("Caducado"),
    "g_key_aa_expires": MessageLookupByLibrary.simpleMessage("Vence"),
    "g_key_aa_factory": MessageLookupByLibrary.simpleMessage("Fábrica"),
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("GRATIS"),
    "g_key_aa_gas_estimate_failed": MessageLookupByLibrary.simpleMessage(
      "La estimación de gas falló, utilizando el valor predeterminado",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage(
      "Pago de gasolina",
    ),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "Opciones de pago de gasolina",
    ),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage(
      "Patrocinado por gasolina",
    ),
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("Sin gas"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "Transacciones sin gas y operaciones por lotes",
    ),
    "g_key_aa_kernel_desc": MessageLookupByLibrary.simpleMessage(
      "Cuenta modular con soporte para complementos de ZeroDev",
    ),
    "g_key_aa_label": MessageLookupByLibrary.simpleMessage("Etiqueta"),
    "g_key_aa_last_activity": MessageLookupByLibrary.simpleMessage(
      "Última actividad",
    ),
    "g_key_aa_my_accounts": MessageLookupByLibrary.simpleMessage(
      "Mis cuentas inteligentes",
    ),
    "g_key_aa_no_accounts": MessageLookupByLibrary.simpleMessage(
      "Aún no hay cuentas inteligentes",
    ),
    "g_key_aa_no_accounts_filter": MessageLookupByLibrary.simpleMessage(
      "Ninguna cuenta coincide con tu filtro",
    ),
    "g_key_aa_no_operations": MessageLookupByLibrary.simpleMessage(
      "No se agregaron operaciones",
    ),
    "g_key_aa_no_session_keys": MessageLookupByLibrary.simpleMessage(
      "Sin claves de sesión",
    ),
    "g_key_aa_not_deployed": MessageLookupByLibrary.simpleMessage(
      "No implementado",
    ),
    "g_key_aa_onboard_step1": MessageLookupByLibrary.simpleMessage(
      "Cree una cuenta inteligente (gratis, no se necesita ETH)",
    ),
    "g_key_aa_onboard_step2": MessageLookupByLibrary.simpleMessage(
      "Financiarlo: reciba cualquier token EVM",
    ),
    "g_key_aa_onboard_step3": MessageLookupByLibrary.simpleMessage(
      "Realice transacciones sin gas con Paymaster",
    ),
    "g_key_aa_operations": MessageLookupByLibrary.simpleMessage("Operaciones"),
    "g_key_aa_owner": MessageLookupByLibrary.simpleMessage("propietario"),
    "g_key_aa_pay_gas_with_token": MessageLookupByLibrary.simpleMessage(
      "Pagar gasolina con token",
    ),
    "g_key_aa_pay_gas_yourself": MessageLookupByLibrary.simpleMessage(
      "Paga gasolina con tu ETH",
    ),
    "g_key_aa_pay_with": MessageLookupByLibrary.simpleMessage("Paga con"),
    "g_key_aa_pay_with_eth": MessageLookupByLibrary.simpleMessage(
      "Paga con ETH",
    ),
    "g_key_aa_paymaster_chains_supported": MessageLookupByLibrary.simpleMessage(
      "cadenas compatibles",
    ),
    "g_key_aa_paymaster_checking": MessageLookupByLibrary.simpleMessage(
      "Verificando disponibilidad...",
    ),
    "g_key_aa_paymaster_coverage": MessageLookupByLibrary.simpleMessage(
      "Cobertura de cadena",
    ),
    "g_key_aa_paymaster_description": MessageLookupByLibrary.simpleMessage(
      "Elija cómo desea pagar las tarifas de transacción de gas",
    ),
    "g_key_aa_paymaster_est_cost": MessageLookupByLibrary.simpleMessage(
      "Costo est.",
    ),
    "g_key_aa_paymaster_load_failed": MessageLookupByLibrary.simpleMessage(
      "Error al cargar opciones de gas",
    ),
    "g_key_aa_paymaster_retry": MessageLookupByLibrary.simpleMessage(
      "Reintentar",
    ),
    "g_key_aa_pending": MessageLookupByLibrary.simpleMessage("Pendiente"),
    "g_key_aa_permission": MessageLookupByLibrary.simpleMessage("Permiso"),
    "g_key_aa_preview_address": MessageLookupByLibrary.simpleMessage(
      "Vista previa de dirección",
    ),
    "g_key_aa_ready": MessageLookupByLibrary.simpleMessage("Listo"),
    "g_key_aa_receive_address": MessageLookupByLibrary.simpleMessage(
      "Recibir dirección",
    ),
    "g_key_aa_retry": MessageLookupByLibrary.simpleMessage("Reintentar"),
    "g_key_aa_revoke": MessageLookupByLibrary.simpleMessage("Revocar"),
    "g_key_aa_revoke_confirm": MessageLookupByLibrary.simpleMessage(
      "¿Está seguro de que desea revocar esta clave de sesión? La DApp autorizada ya no podrá ejecutar transacciones.",
    ),
    "g_key_aa_revoke_session": MessageLookupByLibrary.simpleMessage(
      "Revocar clave de sesión",
    ),
    "g_key_aa_revoked": MessageLookupByLibrary.simpleMessage(
      "Clave de sesión revocada",
    ),
    "g_key_aa_revoked_status": MessageLookupByLibrary.simpleMessage("Revocado"),
    "g_key_aa_revoking": MessageLookupByLibrary.simpleMessage(
      "Revocando clave de sesión...",
    ),
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "Cuenta multifirma con funciones de seguridad avanzadas",
    ),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("salvado"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage(
      "Seleccionar cadena",
    ),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "Seleccione Pagador",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("Seleccionado"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage(
      "Envía tokens usando tu cuenta inteligente",
    ),
    "g_key_aa_session_1d": MessageLookupByLibrary.simpleMessage("1 día"),
    "g_key_aa_session_1h": MessageLookupByLibrary.simpleMessage("1 hora"),
    "g_key_aa_session_30d": MessageLookupByLibrary.simpleMessage("30 días"),
    "g_key_aa_session_7d": MessageLookupByLibrary.simpleMessage("7 días"),
    "g_key_aa_session_amount_hint": MessageLookupByLibrary.simpleMessage(
      "ej. 100.00",
    ),
    "g_key_aa_session_amount_limit": MessageLookupByLibrary.simpleMessage(
      "Monto máximo",
    ),
    "g_key_aa_session_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "Entiendo los permisos de esta clave",
    ),
    "g_key_aa_session_contract_can": MessageLookupByLibrary.simpleMessage(
      "Interactuar con contratos DApp aprobados",
    ),
    "g_key_aa_session_create_failed": MessageLookupByLibrary.simpleMessage(
      "Error al crear la clave de sesión",
    ),
    "g_key_aa_session_create_success": MessageLookupByLibrary.simpleMessage(
      "Clave de sesión creada",
    ),
    "g_key_aa_session_dapp_hint": MessageLookupByLibrary.simpleMessage(
      "ej. Uniswap, Aave...",
    ),
    "g_key_aa_session_dapp_label": MessageLookupByLibrary.simpleMessage(
      "Etiqueta / Nombre DApp",
    ),
    "g_key_aa_session_details": MessageLookupByLibrary.simpleMessage(
      "Detalles clave de la sesión",
    ),
    "g_key_aa_session_expiry": MessageLookupByLibrary.simpleMessage(
      "Válido por",
    ),
    "g_key_aa_session_full_warning": MessageLookupByLibrary.simpleMessage(
      "Alto riesgo — solo DApps verificadas",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage(
      "Claves de sesión",
    ),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "Autorice DApps con acceso temporal a su cuenta inteligente",
    ),
    "g_key_aa_session_preset_contract": MessageLookupByLibrary.simpleMessage(
      "Acceso DApp",
    ),
    "g_key_aa_session_preset_full": MessageLookupByLibrary.simpleMessage(
      "Control total",
    ),
    "g_key_aa_session_preset_transfer": MessageLookupByLibrary.simpleMessage(
      "Solo enviar",
    ),
    "g_key_aa_session_risk_high": MessageLookupByLibrary.simpleMessage(
      "Riesgo alto",
    ),
    "g_key_aa_session_risk_low": MessageLookupByLibrary.simpleMessage(
      "Riesgo bajo",
    ),
    "g_key_aa_session_risk_medium": MessageLookupByLibrary.simpleMessage(
      "Riesgo medio",
    ),
    "g_key_aa_session_risk_warning": MessageLookupByLibrary.simpleMessage(
      "Revisa los permisos antes de confirmar",
    ),
    "g_key_aa_session_select_preset": MessageLookupByLibrary.simpleMessage(
      "Elegir nivel de permiso",
    ),
    "g_key_aa_session_transfer_can": MessageLookupByLibrary.simpleMessage(
      "Transferir tokens dentro del límite",
    ),
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "Cuenta inteligente básica con un único propietario: recomendada para la mayoría de los usuarios",
    ),
    "g_key_aa_smart_accounts": MessageLookupByLibrary.simpleMessage(
      "Cuentas inteligentes",
    ),
    "g_key_aa_smart_wallet": MessageLookupByLibrary.simpleMessage(
      "Cartera inteligente",
    ),
    "g_key_aa_spending_limit": MessageLookupByLibrary.simpleMessage(
      "Límite de gasto",
    ),
    "g_key_aa_sponsored": MessageLookupByLibrary.simpleMessage(
      "Patrocinado (Gratis)",
    ),
    "g_key_aa_title": MessageLookupByLibrary.simpleMessage(
      "Cuenta inteligente",
    ),
    "g_key_aa_total_gas": MessageLookupByLibrary.simpleMessage(
      "Gasolina Total",
    ),
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage(
      "Transacciones",
    ),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage("Ver todo"),
    "g_key_address": MessageLookupByLibrary.simpleMessage("Dirección"),
    "g_key_address_1": MessageLookupByLibrary.simpleMessage(
      "Por favor ingresa un nombre",
    ),
    "g_key_address_2": MessageLookupByLibrary.simpleMessage(
      "Por favor ingresa la dirección",
    ),
    "g_key_address_3": MessageLookupByLibrary.simpleMessage(
      "Por favor seleccione un tipo de moneda",
    ),
    "g_key_address_4": MessageLookupByLibrary.simpleMessage("Editar dirección"),
    "g_key_address_5": MessageLookupByLibrary.simpleMessage(
      "Eliminado exitosamente",
    ),
    "g_key_address_6": MessageLookupByLibrary.simpleMessage("Elegir monedas"),
    "g_key_address_7": MessageLookupByLibrary.simpleMessage("Buscar monedas"),
    "g_key_advanced_features": MessageLookupByLibrary.simpleMessage(
      "Funciones avanzadas",
    ),
    "g_key_batch_add_recipient": MessageLookupByLibrary.simpleMessage(
      "Agregar Destinatario",
    ),
    "g_key_batch_broadcasting": MessageLookupByLibrary.simpleMessage(
      "Transmitiendo...",
    ),
    "g_key_batch_clear_all": MessageLookupByLibrary.simpleMessage(
      "Limpiar Todo",
    ),
    "g_key_batch_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Confirmar transferencia por lotes",
    ),
    "g_key_batch_continue": MessageLookupByLibrary.simpleMessage("Continuar"),
    "g_key_batch_csv_format": MessageLookupByLibrary.simpleMessage(
      "Formato CSV: dirección,monto,etiqueta",
    ),
    "g_key_batch_done": MessageLookupByLibrary.simpleMessage("hecho"),
    "g_key_batch_duplicate_address": m10,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "Estimando Gas...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "La transferencia por lotes solo admite cadenas EVM",
    ),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage(
      "Exportar CSV",
    ),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage(
      "Ayuda para transferencia por lotes",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage(
      "Importar CSV",
    ),
    "g_key_batch_insufficient_balance": m11,
    "g_key_batch_invalid_address": m12,
    "g_key_batch_invalid_amount": m13,
    "g_key_batch_max_recipients": m14,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "La nota es opcional",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "Utilice Multicall3 para obtener tarifas de gas más bajas",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "No hay tokens compatibles",
    ),
    "g_key_batch_recipients": MessageLookupByLibrary.simpleMessage(
      "Destinatarios",
    ),
    "g_key_batch_select_token": MessageLookupByLibrary.simpleMessage(
      "Seleccionar Token",
    ),
    "g_key_batch_send_multiple": MessageLookupByLibrary.simpleMessage(
      "Envía tokens a múltiples direcciones en una transacción",
    ),
    "g_key_batch_signing": MessageLookupByLibrary.simpleMessage("Firmando..."),
    "g_key_batch_swipe_remove": MessageLookupByLibrary.simpleMessage(
      "Desliza hacia la izquierda para eliminar un destinatario",
    ),
    "g_key_batch_title": MessageLookupByLibrary.simpleMessage(
      "Transferencia por Lotes",
    ),
    "g_key_batch_total_amount": MessageLookupByLibrary.simpleMessage(
      "Monto Total",
    ),
    "g_key_bridge_chain_not_supported": MessageLookupByLibrary.simpleMessage(
      "Cadena no compatible",
    ),
    "g_key_bridge_cheapest": MessageLookupByLibrary.simpleMessage("Más Barato"),
    "g_key_bridge_estimated_receive": MessageLookupByLibrary.simpleMessage(
      "Recibirás (estimado)",
    ),
    "g_key_bridge_fastest": MessageLookupByLibrary.simpleMessage("Más Rápido"),
    "g_key_bridge_get_quote": MessageLookupByLibrary.simpleMessage(
      "Obtener Cotización",
    ),
    "g_key_bridge_history": MessageLookupByLibrary.simpleMessage(
      "Historial de Puente",
    ),
    "g_key_bridge_no_routes": MessageLookupByLibrary.simpleMessage(
      "No hay rutas disponibles",
    ),
    "g_key_bridge_recommended": MessageLookupByLibrary.simpleMessage(
      "Recomendado",
    ),
    "g_key_bridge_refresh": MessageLookupByLibrary.simpleMessage("Actualizar"),
    "g_key_bridge_route": MessageLookupByLibrary.simpleMessage("Ruta"),
    "g_key_bridge_search_chain": MessageLookupByLibrary.simpleMessage(
      "Buscar cadena...",
    ),
    "g_key_bridge_select": MessageLookupByLibrary.simpleMessage("Seleccionar"),
    "g_key_bridge_select_token": MessageLookupByLibrary.simpleMessage(
      "Seleccionar Token",
    ),
    "g_key_bridge_slippage": MessageLookupByLibrary.simpleMessage(
      "Deslizamiento",
    ),
    "g_key_bridge_status_completed": MessageLookupByLibrary.simpleMessage(
      "Completado",
    ),
    "g_key_bridge_status_failed": MessageLookupByLibrary.simpleMessage(
      "Fallido",
    ),
    "g_key_bridge_status_in_progress": MessageLookupByLibrary.simpleMessage(
      "En progreso",
    ),
    "g_key_bridge_status_pending": MessageLookupByLibrary.simpleMessage(
      "Pendiente",
    ),
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("Puente"),
    "g_key_bridge_tx_failed": MessageLookupByLibrary.simpleMessage(
      "Puente Fallido",
    ),
    "g_key_bridge_tx_pending": MessageLookupByLibrary.simpleMessage(
      "Transacción Pendiente",
    ),
    "g_key_bridge_tx_success": MessageLookupByLibrary.simpleMessage(
      "Puente Exitoso",
    ),
    "g_key_btc_redeem_locked_until": MessageLookupByLibrary.simpleMessage(
      "Bloqueado hasta",
    ),
    "g_key_btc_redeem_reminder": MessageLookupByLibrary.simpleMessage(
      "Verifica que el período de bloqueo haya expirado antes de enviar el canje.",
    ),
    "g_key_btc_redeem_still_locked": MessageLookupByLibrary.simpleMessage(
      "BTC aún bloqueado",
    ),
    "g_key_btc_redeem_title": MessageLookupByLibrary.simpleMessage(
      "Canjear vBTC",
    ),
    "g_key_btc_redeem_unlocked": MessageLookupByLibrary.simpleMessage(
      "Desbloqueado — listo para canjear",
    ),
    "g_key_btc_stake_acknowledge": MessageLookupByLibrary.simpleMessage(
      "Entiendo los riesgos y deseo continuar",
    ),
    "g_key_btc_stake_continue": MessageLookupByLibrary.simpleMessage(
      "Continuar al Staking",
    ),
    "g_key_btc_stake_how_it_works": MessageLookupByLibrary.simpleMessage(
      "Cómo Funciona",
    ),
    "g_key_btc_stake_reminder": MessageLookupByLibrary.simpleMessage(
      "El BTC quedará bloqueado hasta que expire el bloqueo temporal. Completa el proceso en la interfaz.",
    ),
    "g_key_btc_stake_risk1": MessageLookupByLibrary.simpleMessage(
      "El BTC queda bloqueado durante todo el período de staking. No es posible retirar antes.",
    ),
    "g_key_btc_stake_risk2": MessageLookupByLibrary.simpleMessage(
      "El bloqueo es aplicado por Bitcoin OP_CHECKLOCKTIMEVERIFY (CLTV) y no puede evitarse.",
    ),
    "g_key_btc_stake_risk3": MessageLookupByLibrary.simpleMessage(
      "Riesgo de contrato inteligente: aunque auditado, ningún protocolo es completamente seguro.",
    ),
    "g_key_btc_stake_risk4": MessageLookupByLibrary.simpleMessage(
      "Mínimo staking: 0.001 BTC. Período mínimo de bloqueo: 0.125 días (~3 horas).",
    ),
    "g_key_btc_stake_risk_warning": MessageLookupByLibrary.simpleMessage(
      "Advertencia de Riesgo",
    ),
    "g_key_btc_stake_step1_desc": MessageLookupByLibrary.simpleMessage(
      "Tu BTC queda bloqueado en un multifirma 2-de-2 con bloqueo temporal (CLTV), asegurado por tu clave y la clave del canister N42.",
    ),
    "g_key_btc_stake_step1_title": MessageLookupByLibrary.simpleMessage(
      "Bloquea tu BTC",
    ),
    "g_key_btc_stake_step2_desc": MessageLookupByLibrary.simpleMessage(
      "Tras la confirmación en cadena, se acuña vBTC en tu cartera en proporción 1:1.",
    ),
    "g_key_btc_stake_step2_title": MessageLookupByLibrary.simpleMessage(
      "Acuña vBTC",
    ),
    "g_key_btc_stake_step3_desc": MessageLookupByLibrary.simpleMessage(
      "Mantén vBTC para ganar recompensas. vBTC también es usable en protocolos DeFi.",
    ),
    "g_key_btc_stake_step3_title": MessageLookupByLibrary.simpleMessage(
      "Gana Recompensas",
    ),
    "g_key_btc_stake_step4_desc": MessageLookupByLibrary.simpleMessage(
      "Cuando expire el período de bloqueo, quema tu vBTC para recibir el BTC original.",
    ),
    "g_key_btc_stake_step4_title": MessageLookupByLibrary.simpleMessage(
      "Canjea al Desbloquear",
    ),
    "g_key_btc_stake_title": MessageLookupByLibrary.simpleMessage(
      "Staking BTC Autocustodio",
    ),
    "g_key_burn_got_it": MessageLookupByLibrary.simpleMessage("Entendido"),
    "g_key_burn_nft_step1": MessageLookupByLibrary.simpleMessage(
      "1. Selecciona un token con soporte NFT",
    ),
    "g_key_burn_nft_step2": MessageLookupByLibrary.simpleMessage(
      "2. Ve a la pestaña NFT",
    ),
    "g_key_burn_nft_step3": MessageLookupByLibrary.simpleMessage(
      "3. Selecciona el NFT que quieres quemar",
    ),
    "g_key_burn_nft_step4": MessageLookupByLibrary.simpleMessage(
      "4. Toca el botón \"Quemar\"",
    ),
    "g_key_burn_nft_steps": MessageLookupByLibrary.simpleMessage("Pasos:"),
    "g_key_burn_nft_tip": MessageLookupByLibrary.simpleMessage(
      "Para quemar un NFT, ve a la página de detalles del NFT y toca el botón \"Quemar\".",
    ),
    "g_key_chain_transfer_not_supported": MessageLookupByLibrary.simpleMessage(
      "Esta cadena aún no admite transferencias, estad atentos",
    ),
    "g_key_coin_list_all_hidden": MessageLookupByLibrary.simpleMessage(
      "Todos los activos están por debajo de \$1",
    ),
    "g_key_coin_list_separator": MessageLookupByLibrary.simpleMessage(
      "Otros activos",
    ),
    "g_key_coin_list_show_all": MessageLookupByLibrary.simpleMessage(
      "Toca para mostrar todo",
    ),
    "g_key_coin_search_recent": MessageLookupByLibrary.simpleMessage(
      "Reciente",
    ),
    "g_key_dex_approval_success": MessageLookupByLibrary.simpleMessage(
      "¡Aprobado! Toca Intercambiar para continuar.",
    ),
    "g_key_dex_approve_exact": MessageLookupByLibrary.simpleMessage(
      "Monto Exacto",
    ),
    "g_key_dex_approve_required": m15,
    "g_key_dex_approve_unlimited": MessageLookupByLibrary.simpleMessage(
      "Ilimitado",
    ),
    "g_key_dex_approve_unlimited_info": MessageLookupByLibrary.simpleMessage(
      "Aprobación ilimitada: el enrutador puede gastar este token en cualquier momento. Es estándar, pero conlleva riesgos si el contrato es comprometido.",
    ),
    "g_key_dex_approving": MessageLookupByLibrary.simpleMessage("Aprobando…"),
    "g_key_dex_best_route": MessageLookupByLibrary.simpleMessage("Mejor Ruta"),
    "g_key_dex_best_source": MessageLookupByLibrary.simpleMessage(
      "Mejor Fuente",
    ),
    "g_key_dex_chain": MessageLookupByLibrary.simpleMessage("Cadena"),
    "g_key_dex_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Confirmar Swap",
    ),
    "g_key_dex_gas_estimate": MessageLookupByLibrary.simpleMessage(
      "Estimación de Gas",
    ),
    "g_key_dex_history_title": MessageLookupByLibrary.simpleMessage(
      "Historial DEX",
    ),
    "g_key_dex_min_received": MessageLookupByLibrary.simpleMessage(
      "Mín. Recibido",
    ),
    "g_key_dex_no_tokens": MessageLookupByLibrary.simpleMessage("Sin tokens"),
    "g_key_dex_no_tokens_found": MessageLookupByLibrary.simpleMessage(
      "No se encontraron tokens",
    ),
    "g_key_dex_price_chart": MessageLookupByLibrary.simpleMessage(
      "Gráfico de precio",
    ),
    "g_key_dex_price_impact": MessageLookupByLibrary.simpleMessage(
      "Impacto del Precio",
    ),
    "g_key_dex_price_impact_high": m16,
    "g_key_dex_quote_expires": m17,
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage(
      "Cotización fallida",
    ),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage(
      "Buscar símbolo / nombre / dirección",
    ),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage(
      "Seleccionar",
    ),
    "g_key_dex_slippage_label": MessageLookupByLibrary.simpleMessage(
      "Deslizamiento máximo",
    ),
    "g_key_dex_status_confirmed": MessageLookupByLibrary.simpleMessage(
      "Confirmado",
    ),
    "g_key_dex_status_failed": MessageLookupByLibrary.simpleMessage("Fallido"),
    "g_key_dex_status_pending": MessageLookupByLibrary.simpleMessage(
      "Pendiente",
    ),
    "g_key_dex_status_quoted": MessageLookupByLibrary.simpleMessage("Cotizado"),
    "g_key_dex_swap_btn": MessageLookupByLibrary.simpleMessage("Intercambiar"),
    "g_key_dex_swap_success": MessageLookupByLibrary.simpleMessage(
      "Swap enviado con éxito",
    ),
    "g_key_dex_you_pay": MessageLookupByLibrary.simpleMessage("Pagas"),
    "g_key_dex_you_receive": MessageLookupByLibrary.simpleMessage("Recibes"),
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage(
      "Productos Activos",
    ),
    "g_key_earn_batch": MessageLookupByLibrary.simpleMessage("Transferencia"),
    "g_key_earn_burn": MessageLookupByLibrary.simpleMessage("Quemar"),
    "g_key_earn_buy_n": MessageLookupByLibrary.simpleMessage("Comprar N"),
    "g_key_earn_buy_n_desc": MessageLookupByLibrary.simpleMessage(
      "Compra N con el protocolo AST",
    ),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage(
      "Transferencia entre cadenas",
    ),
    "g_key_earn_dex_swap": MessageLookupByLibrary.simpleMessage(
      "Intercambio DEX",
    ),
    "g_key_earn_gas": MessageLookupByLibrary.simpleMessage("gasolina"),
    "g_key_earn_go_staking": MessageLookupByLibrary.simpleMessage(
      "Comenzar Staking",
    ),
    "g_key_earn_ledger": MessageLookupByLibrary.simpleMessage("Libro mayor"),
    "g_key_earn_loading_apy": MessageLookupByLibrary.simpleMessage(
      "Cargando APY...",
    ),
    "g_key_earn_mining": MessageLookupByLibrary.simpleMessage("Minería"),
    "g_key_earn_more": MessageLookupByLibrary.simpleMessage("Ganar Más"),
    "g_key_earn_native_sol": MessageLookupByLibrary.simpleMessage(
      "Staking nativo de Solana",
    ),
    "g_key_earn_no_positions": MessageLookupByLibrary.simpleMessage(
      "Sin posiciones activas",
    ),
    "g_key_earn_node_mining_desc": MessageLookupByLibrary.simpleMessage(
      "Gana recompensas participando en la minería de nodos",
    ),
    "g_key_earn_quick_tools": MessageLookupByLibrary.simpleMessage(
      "Herramientas Rápidas",
    ),
    "g_key_earn_recommended": MessageLookupByLibrary.simpleMessage(
      "Recomendado",
    ),
    "g_key_earn_select_swap": MessageLookupByLibrary.simpleMessage(
      "Seleccionar Tipo de Intercambio",
    ),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "Stake ETH con Lido",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("Intercambiar"),
    "g_key_earn_title": MessageLookupByLibrary.simpleMessage("Ganar"),
    "g_key_earn_total_earnings": MessageLookupByLibrary.simpleMessage(
      "Ganancias Totales",
    ),
    "g_key_earn_up_to_apy": m18,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage("Ver Todo"),
    "g_key_ens_address_updated": MessageLookupByLibrary.simpleMessage(
      "Dirección resuelta actualizada",
    ),
    "g_key_ens_advanced": MessageLookupByLibrary.simpleMessage("Avanzado"),
    "g_key_ens_annual_fee": MessageLookupByLibrary.simpleMessage("Cuota Anual"),
    "g_key_ens_available": MessageLookupByLibrary.simpleMessage("Disponible"),
    "g_key_ens_base_price": MessageLookupByLibrary.simpleMessage("Precio base"),
    "g_key_ens_checking": MessageLookupByLibrary.simpleMessage(
      "Comprobando disponibilidad...",
    ),
    "g_key_ens_commit": MessageLookupByLibrary.simpleMessage("comprometerse"),
    "g_key_ens_commit_failed": MessageLookupByLibrary.simpleMessage(
      "La confirmación falló",
    ),
    "g_key_ens_commitment_expired_msg": MessageLookupByLibrary.simpleMessage(
      "El compromiso de registro ha expirado. Por favor, reinicie el proceso de registro.",
    ),
    "g_key_ens_committing": MessageLookupByLibrary.simpleMessage(
      "Comprometiéndose...",
    ),
    "g_key_ens_confirm_renew": MessageLookupByLibrary.simpleMessage(
      "Confirmar renovación",
    ),
    "g_key_ens_confirm_send": MessageLookupByLibrary.simpleMessage(
      "Confirmar y Enviar",
    ),
    "g_key_ens_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Confirmar Resolución ENS",
    ),
    "g_key_ens_copy_address": MessageLookupByLibrary.simpleMessage(
      "Dirección copiada",
    ),
    "g_key_ens_current_expiry": MessageLookupByLibrary.simpleMessage(
      "Vencimiento actual",
    ),
    "g_key_ens_days_left": MessageLookupByLibrary.simpleMessage("quedan días"),
    "g_key_ens_description": MessageLookupByLibrary.simpleMessage(
      "Registre y administre sus nombres de dominio .eth",
    ),
    "g_key_ens_detected": MessageLookupByLibrary.simpleMessage(
      "Nombre ENS Detectado",
    ),
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage("Caducado"),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage("Vence"),
    "g_key_ens_extend_period": MessageLookupByLibrary.simpleMessage(
      "Ampliar el período de registro",
    ),
    "g_key_ens_failed": MessageLookupByLibrary.simpleMessage("Fallido"),
    "g_key_ens_finalizing": MessageLookupByLibrary.simpleMessage(
      "Finalizando registro",
    ),
    "g_key_ens_get_started": MessageLookupByLibrary.simpleMessage(
      "Comience con ENS",
    ),
    "g_key_ens_get_your_name": MessageLookupByLibrary.simpleMessage(
      "Obtenga su nombre .eth",
    ),
    "g_key_ens_invalid_address": MessageLookupByLibrary.simpleMessage(
      "Dirección no válida (debe ser 0x + 40 caracteres hexadecimales)",
    ),
    "g_key_ens_invalid_name": MessageLookupByLibrary.simpleMessage(
      "Nombre ENS inválido",
    ),
    "g_key_ens_is_yours": MessageLookupByLibrary.simpleMessage(
      "¡Ahora es tuyo!",
    ),
    "g_key_ens_keep_app_open": MessageLookupByLibrary.simpleMessage(
      "Mantenga la aplicación abierta durante el registro.",
    ),
    "g_key_ens_manage_your_identity": MessageLookupByLibrary.simpleMessage(
      "Administre su identidad Web3",
    ),
    "g_key_ens_min_length": MessageLookupByLibrary.simpleMessage(
      "Mínimo 3 caracteres",
    ),
    "g_key_ens_my_domains": MessageLookupByLibrary.simpleMessage(
      "Mis Dominios",
    ),
    "g_key_ens_name": MessageLookupByLibrary.simpleMessage("Nombre ENS"),
    "g_key_ens_new_expiry": MessageLookupByLibrary.simpleMessage(
      "Nuevo vencimiento",
    ),
    "g_key_ens_new_owner": MessageLookupByLibrary.simpleMessage(
      "Dirección del nuevo propietario",
    ),
    "g_key_ens_no_domains": MessageLookupByLibrary.simpleMessage(
      "Aún no hay dominios",
    ),
    "g_key_ens_owner": MessageLookupByLibrary.simpleMessage("propietario"),
    "g_key_ens_please_wait": MessageLookupByLibrary.simpleMessage(
      "Por favor espera",
    ),
    "g_key_ens_premium_name": MessageLookupByLibrary.simpleMessage(
      "Nombre premium",
    ),
    "g_key_ens_price_breakdown": MessageLookupByLibrary.simpleMessage(
      "Desglose de precios",
    ),
    "g_key_ens_primary": MessageLookupByLibrary.simpleMessage("Primaria"),
    "g_key_ens_primary_set": MessageLookupByLibrary.simpleMessage(
      "Nombre principal configurado correctamente",
    ),
    "g_key_ens_processing": MessageLookupByLibrary.simpleMessage(
      "Procesando...",
    ),
    "g_key_ens_purchase_title": MessageLookupByLibrary.simpleMessage(
      "Registrarse ENS",
    ),
    "g_key_ens_register": MessageLookupByLibrary.simpleMessage("Registrarse"),
    "g_key_ens_register_description": MessageLookupByLibrary.simpleMessage(
      "Tu identidad descentralizada en Ethereum",
    ),
    "g_key_ens_register_failed": MessageLookupByLibrary.simpleMessage(
      "Registro fallido",
    ),
    "g_key_ens_register_now": MessageLookupByLibrary.simpleMessage(
      "Regístrese ahora",
    ),
    "g_key_ens_registering": MessageLookupByLibrary.simpleMessage(
      "Registrando...",
    ),
    "g_key_ens_registration_info": MessageLookupByLibrary.simpleMessage(
      "Información de registro",
    ),
    "g_key_ens_registration_period": MessageLookupByLibrary.simpleMessage(
      "Período de registro",
    ),
    "g_key_ens_reminder_enable": MessageLookupByLibrary.simpleMessage(
      "Activar recordatorio de vencimiento",
    ),
    "g_key_ens_reminder_hint": MessageLookupByLibrary.simpleMessage(
      "Notificar 30, 7 y 1 día antes del vencimiento",
    ),
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("Renovar"),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage(
      "Amplíe el registro de su dominio",
    ),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage(
      "Renovación exitosa",
    ),
    "g_key_ens_resolved_address": MessageLookupByLibrary.simpleMessage(
      "Dirección Resuelta",
    ),
    "g_key_ens_resolving": MessageLookupByLibrary.simpleMessage(
      "Resolviendo ENS...",
    ),
    "g_key_ens_search": MessageLookupByLibrary.simpleMessage("Buscar"),
    "g_key_ens_search_desc": MessageLookupByLibrary.simpleMessage(
      "Encuentra nombres .eth disponibles",
    ),
    "g_key_ens_search_hint": MessageLookupByLibrary.simpleMessage(
      "Buscar un nombre .eth",
    ),
    "g_key_ens_search_prompt": MessageLookupByLibrary.simpleMessage(
      "Introduzca un nombre de ENS para buscar",
    ),
    "g_key_ens_search_register": MessageLookupByLibrary.simpleMessage(
      "Buscar y registrarse",
    ),
    "g_key_ens_search_title": MessageLookupByLibrary.simpleMessage(
      "Buscar ENS",
    ),
    "g_key_ens_self_transfer": MessageLookupByLibrary.simpleMessage(
      "No puedes enviarte a ti mismo",
    ),
    "g_key_ens_service": MessageLookupByLibrary.simpleMessage(
      "Servicio de nombres de Ethereum",
    ),
    "g_key_ens_set_primary": MessageLookupByLibrary.simpleMessage(
      "Establecer como principal",
    ),
    "g_key_ens_standard_name": MessageLookupByLibrary.simpleMessage(
      "Nombre estándar",
    ),
    "g_key_ens_start_registration": MessageLookupByLibrary.simpleMessage(
      "Iniciar registro",
    ),
    "g_key_ens_step_1": MessageLookupByLibrary.simpleMessage("Paso 1"),
    "g_key_ens_step_2": MessageLookupByLibrary.simpleMessage("Paso 2"),
    "g_key_ens_step_3": MessageLookupByLibrary.simpleMessage("Paso 3"),
    "g_key_ens_subdomain_create": MessageLookupByLibrary.simpleMessage(
      "Crear subdominio",
    ),
    "g_key_ens_subdomain_created": MessageLookupByLibrary.simpleMessage(
      "Subdominio creado",
    ),
    "g_key_ens_subdomain_delete": MessageLookupByLibrary.simpleMessage(
      "Eliminar subdominio",
    ),
    "g_key_ens_subdomain_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "Este subdominio se eliminará permanentemente.",
    ),
    "g_key_ens_subdomain_deleted": MessageLookupByLibrary.simpleMessage(
      "Subdominio eliminado",
    ),
    "g_key_ens_subdomain_empty": MessageLookupByLibrary.simpleMessage(
      "Aún no hay subdominios",
    ),
    "g_key_ens_subdomain_invalid_label": MessageLookupByLibrary.simpleMessage(
      "Utilice únicamente letras, números y guiones.",
    ),
    "g_key_ens_subdomain_label": MessageLookupByLibrary.simpleMessage(
      "Etiqueta de subdominio",
    ),
    "g_key_ens_subdomain_label_hint": MessageLookupByLibrary.simpleMessage(
      "por ej. blog, correo, aplicación",
    ),
    "g_key_ens_subdomain_owner": MessageLookupByLibrary.simpleMessage(
      "Dirección del propietario",
    ),
    "g_key_ens_subdomain_owner_hint": MessageLookupByLibrary.simpleMessage(
      "Déjelo vacío para usar la billetera actual",
    ),
    "g_key_ens_subdomains": MessageLookupByLibrary.simpleMessage("Subdominios"),
    "g_key_ens_success": MessageLookupByLibrary.simpleMessage("¡Éxito!"),
    "g_key_ens_suggestions": MessageLookupByLibrary.simpleMessage(
      "Sugerencias",
    ),
    "g_key_ens_text_records": MessageLookupByLibrary.simpleMessage(
      "Registros de texto",
    ),
    "g_key_ens_title": MessageLookupByLibrary.simpleMessage("Gerente ENS"),
    "g_key_ens_total": MessageLookupByLibrary.simpleMessage("totales"),
    "g_key_ens_transfer": MessageLookupByLibrary.simpleMessage("Transferir"),
    "g_key_ens_transfer_desc": MessageLookupByLibrary.simpleMessage(
      "Transferir la propiedad a otra dirección",
    ),
    "g_key_ens_transfer_success": MessageLookupByLibrary.simpleMessage(
      "Transferencia exitosa",
    ),
    "g_key_ens_transfer_warning": MessageLookupByLibrary.simpleMessage(
      "La transferencia es irreversible. Asegúrese de que la dirección del nuevo propietario sea correcta.",
    ),
    "g_key_ens_try_another": MessageLookupByLibrary.simpleMessage(
      "Prueba con otro nombre",
    ),
    "g_key_ens_two_step_process": MessageLookupByLibrary.simpleMessage(
      "El registro en ENS es un proceso de dos pasos",
    ),
    "g_key_ens_unavailable": MessageLookupByLibrary.simpleMessage(
      "No disponible",
    ),
    "g_key_ens_wait": MessageLookupByLibrary.simpleMessage("espera"),
    "g_key_ens_wait_explanation": MessageLookupByLibrary.simpleMessage(
      "El período de espera previene ataques adelantados",
    ),
    "g_key_ens_wait_time_info": MessageLookupByLibrary.simpleMessage(
      "Un período de espera impide el avance",
    ),
    "g_key_ens_waiting": MessageLookupByLibrary.simpleMessage("Esperando..."),
    "g_key_ens_warning": MessageLookupByLibrary.simpleMessage(
      "Por favor verifica la dirección resuelta antes de continuar. Los nombres ENS pueden ser transferidos o cambiados por su propietario.",
    ),
    "g_key_ens_year": MessageLookupByLibrary.simpleMessage("año"),
    "g_key_ens_years": MessageLookupByLibrary.simpleMessage("años"),
    "g_key_ens_your_identity": MessageLookupByLibrary.simpleMessage(
      "Tu identidad",
    ),
    "g_key_error_1": MessageLookupByLibrary.simpleMessage(
      "¡Error al analizar los datos de respuesta!",
    ),
    "g_key_error_10": MessageLookupByLibrary.simpleMessage("Error dado"),
    "g_key_error_11": MessageLookupByLibrary.simpleMessage(
      "Error de sintaxis de la solicitud",
    ),
    "g_key_error_12": MessageLookupByLibrary.simpleMessage(
      "No autorizado, inicia sesión",
    ),
    "g_key_error_13": MessageLookupByLibrary.simpleMessage("Acceso denegado"),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage("Acceso denegado"),
    "g_key_error_15": MessageLookupByLibrary.simpleMessage(
      "Se agotó el tiempo de espera de la solicitud",
    ),
    "g_key_error_16": MessageLookupByLibrary.simpleMessage("Servidor anormal"),
    "g_key_error_17": MessageLookupByLibrary.simpleMessage(
      "Servicio no implementado",
    ),
    "g_key_error_18": MessageLookupByLibrary.simpleMessage(
      "Error de puerta de enlace",
    ),
    "g_key_error_19": MessageLookupByLibrary.simpleMessage(
      "El servicio no está disponible",
    ),
    "g_key_error_20": MessageLookupByLibrary.simpleMessage(
      "Tiempo de espera de la puerta de enlace",
    ),
    "g_key_error_21": MessageLookupByLibrary.simpleMessage(
      "La versión HTTP no es compatible",
    ),
    "g_key_error_22": MessageLookupByLibrary.simpleMessage(
      "La solicitud falló, código de error:",
    ),
    "g_key_error_23": MessageLookupByLibrary.simpleMessage(
      "El sistema está ocupado, inténtelo de nuevo más tarde",
    ),
    "g_key_error_24": MessageLookupByLibrary.simpleMessage(
      "La frecuencia de solicitud es demasiado rápida",
    ),
    "g_key_error_25": MessageLookupByLibrary.simpleMessage(
      "Error de decodificación",
    ),
    "g_key_error_26": MessageLookupByLibrary.simpleMessage(
      "La transacción ya está en la cadena",
    ),
    "g_key_error_27": MessageLookupByLibrary.simpleMessage(
      "¡Error de configuración del certificado!",
    ),
    "g_key_error_28": MessageLookupByLibrary.simpleMessage(
      "¡Error de configuración del código de estado!",
    ),
    "g_key_error_3": MessageLookupByLibrary.simpleMessage(
      "¡Error desconocido!",
    ),
    "g_key_error_4": MessageLookupByLibrary.simpleMessage(
      "¡Se agotó el tiempo de conexión de red, verifique la configuración de red!",
    ),
    "g_key_error_5": MessageLookupByLibrary.simpleMessage(
      "El servidor es anormal. ¡Vuelve a intentarlo más tarde!",
    ),
    "g_key_error_8": MessageLookupByLibrary.simpleMessage(
      "¡Se canceló la solicitud, vuelva a solicitarla!",
    ),
    "g_key_ex_keystore": MessageLookupByLibrary.simpleMessage(
      "Exportar almacén de claves",
    ),
    "g_key_ex_keystore_1": MessageLookupByLibrary.simpleMessage(
      "Consejos para realizar copias de seguridad",
    ),
    "g_key_ex_keystore_10": MessageLookupByLibrary.simpleMessage(
      "Usa una herramienta de administración de contraseñas para almacenar.",
    ),
    "g_key_ex_keystore_11": MessageLookupByLibrary.simpleMessage("Copiado"),
    "g_key_ex_keystore_12": MessageLookupByLibrary.simpleMessage(
      " Copia cancelada ",
    ),
    "g_key_ex_keystore_13": MessageLookupByLibrary.simpleMessage(
      " Identidad de la Wallet",
    ),
    "g_key_ex_keystore_15": MessageLookupByLibrary.simpleMessage(
      "Archivo de clave privada cifrado.",
    ),
    "g_key_ex_keystore_16": MessageLookupByLibrary.simpleMessage(
      " Método de importación",
    ),
    "g_key_ex_keystore_17": MessageLookupByLibrary.simpleMessage(
      "Archivo de almacén de claves",
    ),
    "g_key_ex_keystore_18": MessageLookupByLibrary.simpleMessage(
      "Por favor ingrese la información del almacén de claves.",
    ),
    "g_key_ex_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Exportar clave privada",
    ),
    "g_key_ex_keystore_2": MessageLookupByLibrary.simpleMessage(
      "Obtener el almacén de claves y la contraseña le dará al titular control total sobre los activos de la Wallet.",
    ),
    "g_key_ex_keystore_3": MessageLookupByLibrary.simpleMessage(
      "Grábalo cuidadosamente y guárdalo en un lugar seguro. Mantener varias copias físicas es el método de almacenamiento más seguro.",
    ),
    "g_key_ex_keystore_4": MessageLookupByLibrary.simpleMessage(
      "Si pierde su clave privada, no podrá recuperarla. Haga una copia de seguridad física y guárdela de forma segura.",
    ),
    "g_key_ex_keystore_5": MessageLookupByLibrary.simpleMessage(
      "Guardar sin conexión",
    ),
    "g_key_ex_keystore_6": MessageLookupByLibrary.simpleMessage(
      "No guarde en ningún buzón, bloc de notas, unidad de red o software de chat que no sea seguro.",
    ),
    "g_key_ex_keystore_7": MessageLookupByLibrary.simpleMessage(
      "Usar transmisión de red",
    ),
    "g_key_ex_keystore_8": MessageLookupByLibrary.simpleMessage(
      "Asegúrate de transmitirlo a través de herramientas de red. Una vez que los piratas informáticos lo obtengan, causará una pérdida económica irreparable",
    ),
    "g_key_ex_keystore_9": MessageLookupByLibrary.simpleMessage(
      "Usar herramientas de guardado",
    ),
    "g_key_ex_keystore_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "Entiendo que cualquiera que obtenga este archivo y la contraseña tiene control total sobre mis fondos: la pérdida es permanente e irrecuperable",
    ),
    "g_key_ex_keystore_pwd_title": MessageLookupByLibrary.simpleMessage(
      "Ingresa la contraseña de la billetera para confirmar la exportación",
    ),
    "g_key_ex_pk_pwd_title": MessageLookupByLibrary.simpleMessage(
      "Ingresa la contraseña de la billetera para ver la clave privada",
    ),
    "g_key_filter": MessageLookupByLibrary.simpleMessage("Filtrar"),
    "g_key_gas_alert": MessageLookupByLibrary.simpleMessage("Alerta de Gas"),
    "g_key_gas_alert_above": MessageLookupByLibrary.simpleMessage(
      "Alertar si sube de",
    ),
    "g_key_gas_alert_below": MessageLookupByLibrary.simpleMessage(
      "Alertar si baja de",
    ),
    "g_key_gas_alert_save": MessageLookupByLibrary.simpleMessage("Guardar"),
    "g_key_gas_alert_threshold": MessageLookupByLibrary.simpleMessage(
      "Umbral (Gwei)",
    ),
    "g_key_gas_auto_refresh": m19,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("Tarifa Base"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage("Personalizado"),
    "g_key_gas_fast": MessageLookupByLibrary.simpleMessage("Rápido"),
    "g_key_gas_footer": MessageLookupByLibrary.simpleMessage(
      "Los precios del gas fluctúan según la demanda de la red. Menos gas = confirmación más lenta, más gas = confirmación más rápida.",
    ),
    "g_key_gas_max_fee": MessageLookupByLibrary.simpleMessage("Tarifa Máxima"),
    "g_key_gas_network_busy": MessageLookupByLibrary.simpleMessage(
      "Red congestionada",
    ),
    "g_key_gas_network_idle": MessageLookupByLibrary.simpleMessage("Red libre"),
    "g_key_gas_network_normal": MessageLookupByLibrary.simpleMessage(
      "Red normal",
    ),
    "g_key_gas_price_trend": MessageLookupByLibrary.simpleMessage(
      "Tendencia de Precio",
    ),
    "g_key_gas_priority_fee": MessageLookupByLibrary.simpleMessage(
      "Tarifa Prioritaria",
    ),
    "g_key_gas_realtime_prices": MessageLookupByLibrary.simpleMessage(
      "Precios de Gas en Tiempo Real",
    ),
    "g_key_gas_settings": MessageLookupByLibrary.simpleMessage(
      "Configuración de Gas",
    ),
    "g_key_gas_slow": MessageLookupByLibrary.simpleMessage("Lento"),
    "g_key_gas_standard": MessageLookupByLibrary.simpleMessage("Estándar"),
    "g_key_gas_tracker": MessageLookupByLibrary.simpleMessage(
      "Rastreador de Gas",
    ),
    "g_key_hw_account_added": m20,
    "g_key_hw_account_already_imported": MessageLookupByLibrary.simpleMessage(
      "Cuenta ya importada",
    ),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("Añadir"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage(
      "Agregar Cuenta",
    ),
    "g_key_hw_add_account_content": m21,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "Dirección copiada",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "Asegúrese de que su dispositivo esté desbloqueado y que Bluetooth esté habilitado antes de conectarse.",
    ),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage(
      "Verificar aplicación",
    ),
    "g_key_hw_connect_new_device": MessageLookupByLibrary.simpleMessage(
      "Conectar nuevo dispositivo",
    ),
    "g_key_hw_connect_new_keystone": MessageLookupByLibrary.simpleMessage(
      "Entrehierro con Keystone (QR)",
    ),
    "g_key_hw_connect_new_ledger": MessageLookupByLibrary.simpleMessage(
      "Conectar el libro mayor (Bluetooth)",
    ),
    "g_key_hw_connect_new_trezor": MessageLookupByLibrary.simpleMessage(
      "Conectar Trezor (USB)",
    ),
    "g_key_hw_connected": MessageLookupByLibrary.simpleMessage("Conectado"),
    "g_key_hw_connecting": MessageLookupByLibrary.simpleMessage(
      "Conectando...",
    ),
    "g_key_hw_current_app_label": m22,
    "g_key_hw_days_ago": m23,
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("Desconectar"),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage("Volver"),
    "g_key_hw_import_failed": m24,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "Conectar piedra angular",
    ),
    "g_key_hw_keystone_scan_request_hint": MessageLookupByLibrary.simpleMessage(
      "Escanea este código QR con tu dispositivo Keystone para firmar la transacción",
    ),
    "g_key_hw_keystone_scan_response_hint": MessageLookupByLibrary.simpleMessage(
      "Apunte su cámara al código QR que se muestra en su dispositivo Keystone",
    ),
    "g_key_hw_keystone_scan_response_title":
        MessageLookupByLibrary.simpleMessage("Escanear firma Keystone"),
    "g_key_hw_keystone_scan_xpub_hint": MessageLookupByLibrary.simpleMessage(
      "Escanee el código QR desde su dispositivo Keystone para importar cuentas",
    ),
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "Toque para escanear la respuesta Keystone",
    ),
    "g_key_hw_last_connected": m25,
    "g_key_hw_load_more": MessageLookupByLibrary.simpleMessage("Cargar más"),
    "g_key_hw_loading_accounts": MessageLookupByLibrary.simpleMessage(
      "Cargando cuentas...",
    ),
    "g_key_hw_loading_hint": MessageLookupByLibrary.simpleMessage(
      "Por favor, confirme en su dispositivo si se le solicita",
    ),
    "g_key_hw_no_accounts_found": MessageLookupByLibrary.simpleMessage(
      "No se encontraron cuentas",
    ),
    "g_key_hw_no_app_open": MessageLookupByLibrary.simpleMessage(
      "No hay ninguna aplicación abierta actualmente",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "Dispositivo no conectado",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "No conectado",
    ),
    "g_key_hw_open_ledger_app_hint": m26,
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("Quitar"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage(
      "Quitar dispositivo",
    ),
    "g_key_hw_remove_device_confirm": m27,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage(
      "Dispositivos guardados",
    ),
    "g_key_hw_supported_devices": MessageLookupByLibrary.simpleMessage(
      "Dispositivos compatibles",
    ),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("hoy"),
    "g_key_hw_trezor_connect_failed": MessageLookupByLibrary.simpleMessage(
      "No se pudo conectar con Trezor. Asegúrese de que el USB esté conectado.",
    ),
    "g_key_hw_trezor_connect_title": MessageLookupByLibrary.simpleMessage(
      "Conecta Trezor",
    ),
    "g_key_hw_trezor_connected": MessageLookupByLibrary.simpleMessage(
      "Trezor se conectó exitosamente",
    ),
    "g_key_hw_trezor_connecting": MessageLookupByLibrary.simpleMessage(
      "Conectándose a Trezor...",
    ),
    "g_key_hw_trezor_usb_hint": MessageLookupByLibrary.simpleMessage(
      "Conecte su dispositivo Trezor mediante un cable USB y desbloquéelo",
    ),
    "g_key_hw_view_accounts": MessageLookupByLibrary.simpleMessage(
      "Ver cuentas",
    ),
    "g_key_hw_wallet_accounts": MessageLookupByLibrary.simpleMessage(
      "Cuentas de Cartera",
    ),
    "g_key_hw_yesterday": MessageLookupByLibrary.simpleMessage("ayer"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Ya existe una wallet de moneda actual.",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "No se pudo leer el almacén de claves",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage(
      "Almacén de claves",
    ),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Iniciar Sesión"),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Cerrar sesión"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que quieres salir de la aplicación?",
    ),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("facebook"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("Gorjeo"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("Reddit"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("Navegador"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("telegrama"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("discordia"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("youtube"),
    "g_key_m_19": MessageLookupByLibrary.simpleMessage("Instagram"),
    "g_key_m_2": MessageLookupByLibrary.simpleMessage("Capacidad de mercado"),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("Volumen de operaciones"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("Suministro total"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("En circulación"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("Acerca de"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("Más"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("Enlaces"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("Sitio Web"),
    "g_key_manage_chains": MessageLookupByLibrary.simpleMessage(
      "Administrar cadenas",
    ),
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage(
      "Disponible",
    ),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "Requiere apostar",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage(
      "Por favor, introduzca la frase semilla",
    ),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("totales"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Nombre"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Volver"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage("Transacción enviada"),
    "g_key_nft_address_invalid": MessageLookupByLibrary.simpleMessage(
      "Dirección de billetera no válida",
    ),
    "g_key_nft_balance": MessageLookupByLibrary.simpleMessage("Saldo"),
    "g_key_nft_burn_confirm": MessageLookupByLibrary.simpleMessage(
      "Esta acción es irreversible. El NFT se enviará a la dirección de grabación.",
    ),
    "g_key_nft_burn_title": MessageLookupByLibrary.simpleMessage("Quemar NFT"),
    "g_key_nft_collection": MessageLookupByLibrary.simpleMessage("Colección"),
    "g_key_nft_contract": MessageLookupByLibrary.simpleMessage("Contrato"),
    "g_key_nft_description": MessageLookupByLibrary.simpleMessage(
      "Descripción",
    ),
    "g_key_nft_error_retry": MessageLookupByLibrary.simpleMessage(
      "No se pudieron cargar los NFT. Toca para volver a intentarlo.",
    ),
    "g_key_nft_filter_all": MessageLookupByLibrary.simpleMessage("Todos"),
    "g_key_nft_filter_video": MessageLookupByLibrary.simpleMessage("Vídeo"),
    "g_key_nft_floor_price": MessageLookupByLibrary.simpleMessage("piso"),
    "g_key_nft_gallery": MessageLookupByLibrary.simpleMessage("Galería NFT"),
    "g_key_nft_inscription": MessageLookupByLibrary.simpleMessage(
      "Inscripción #",
    ),
    "g_key_nft_no_items": MessageLookupByLibrary.simpleMessage(
      "No se encontraron NFT",
    ),
    "g_key_nft_no_url": MessageLookupByLibrary.simpleMessage(
      "No hay ningún enlace del explorador disponible",
    ),
    "g_key_nft_no_video_support": MessageLookupByLibrary.simpleMessage(
      "No se admite la reproducción de vídeo",
    ),
    "g_key_nft_ordinals": MessageLookupByLibrary.simpleMessage("Ordinales"),
    "g_key_nft_ordinals_unsupported": MessageLookupByLibrary.simpleMessage(
      "Las transferencias de ordinales aún no son compatibles",
    ),
    "g_key_nft_quantity": MessageLookupByLibrary.simpleMessage("Cantidad"),
    "g_key_nft_search_hint": MessageLookupByLibrary.simpleMessage(
      "Buscar por nombre o colección",
    ),
    "g_key_nft_send": MessageLookupByLibrary.simpleMessage("Enviar NFT"),
    "g_key_nft_send_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Las transferencias de Solana NFT llegarán pronto",
    ),
    "g_key_nft_token_id": MessageLookupByLibrary.simpleMessage("ID de token"),
    "g_key_nft_type": MessageLookupByLibrary.simpleMessage("Tipo"),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "Las contraseñas no coinciden",
    ),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
      "Seleccionar de la galería del teléfono",
    ),
    "g_key_reset": MessageLookupByLibrary.simpleMessage("Reiniciar"),
    "g_key_security_goplus_caution": MessageLookupByLibrary.simpleMessage(
      "Tenga precaución",
    ),
    "g_key_security_goplus_checking": MessageLookupByLibrary.simpleMessage(
      "Comprobando la seguridad del contrato...",
    ),
    "g_key_security_goplus_danger": MessageLookupByLibrary.simpleMessage(
      "Alto riesgo detectado",
    ),
    "g_key_security_goplus_powered_by": MessageLookupByLibrary.simpleMessage(
      "GoPlus",
    ),
    "g_key_security_goplus_safe": MessageLookupByLibrary.simpleMessage(
      "Contrato verificado seguro",
    ),
    "g_key_send_memo_hint": MessageLookupByLibrary.simpleMessage(
      "Memorándum/Nota",
    ),
    "g_key_send_memo_label": MessageLookupByLibrary.simpleMessage(
      "Memo/Nota (opcional)",
    ),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage(
      "Compartir código QR",
    ),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage(
      "Compartir enlace",
    ),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage(
      "Método compartir",
    ),
    "g_key_sim_gas_estimate": m28,
    "g_key_sim_reverted": MessageLookupByLibrary.simpleMessage(
      "Es probable que la transacción falle",
    ),
    "g_key_sim_reverted_reason": m29,
    "g_key_sim_simulating": MessageLookupByLibrary.simpleMessage(
      "Simulando transacción…",
    ),
    "g_key_sim_success": MessageLookupByLibrary.simpleMessage(
      "Simulación de transacción aprobada",
    ),
    "g_key_sim_unavailable": MessageLookupByLibrary.simpleMessage(
      "Simulación no disponible para esta red",
    ),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Charla"),
    "g_key_stake_active": MessageLookupByLibrary.simpleMessage("Activo"),
    "g_key_stake_active_positions": MessageLookupByLibrary.simpleMessage(
      "Posiciones activas",
    ),
    "g_key_stake_amount": MessageLookupByLibrary.simpleMessage("Cantidad"),
    "g_key_stake_amount_unstake": MessageLookupByLibrary.simpleMessage(
      "Monto a descontar",
    ),
    "g_key_stake_apy": MessageLookupByLibrary.simpleMessage("APY"),
    "g_key_stake_avg_apy": MessageLookupByLibrary.simpleMessage("APY promedio"),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage("Comisión"),
    "g_key_stake_d_unbond": m30,
    "g_key_stake_days_remaining": m31,
    "g_key_stake_estimated_daily": MessageLookupByLibrary.simpleMessage(
      "Est. Recompensa diaria",
    ),
    "g_key_stake_estimated_yearly": MessageLookupByLibrary.simpleMessage(
      "Est. Recompensa anual",
    ),
    "g_key_stake_go_to_swap": MessageLookupByLibrary.simpleMessage(
      "Ir a intercambiar",
    ),
    "g_key_stake_liquid_staking_label": MessageLookupByLibrary.simpleMessage(
      "Estaca líquida",
    ),
    "g_key_stake_liquid_tag": MessageLookupByLibrary.simpleMessage("Líquido"),
    "g_key_stake_liquid_unstake_desc": MessageLookupByLibrary.simpleMessage(
      "Su token líquido se puede negociar directamente en DEX. Utilice Swap para cambiarlo por el activo nativo.",
    ),
    "g_key_stake_min_stake": MessageLookupByLibrary.simpleMessage(
      "Apuesta Mínima",
    ),
    "g_key_stake_no_active_positions": MessageLookupByLibrary.simpleMessage(
      "No hay posiciones activas para quitar la apuesta",
    ),
    "g_key_stake_no_lock": MessageLookupByLibrary.simpleMessage(
      "sin cerradura",
    ),
    "g_key_stake_no_positions_yet": MessageLookupByLibrary.simpleMessage(
      "Aún no hay posiciones de apuesta",
    ),
    "g_key_stake_no_validators": MessageLookupByLibrary.simpleMessage(
      "No se encontraron validadores",
    ),
    "g_key_stake_no_wallet": MessageLookupByLibrary.simpleMessage(
      "Dirección de billetera no disponible",
    ),
    "g_key_stake_overview": MessageLookupByLibrary.simpleMessage(
      "Descripción general de la apuesta total",
    ),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage(
      "Mis Posiciones",
    ),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("Protocolos"),
    "g_key_stake_rewards": MessageLookupByLibrary.simpleMessage("Recompensas"),
    "g_key_stake_search_validator": MessageLookupByLibrary.simpleMessage(
      "Buscar validadores...",
    ),
    "g_key_stake_select_a_validator": MessageLookupByLibrary.simpleMessage(
      "Seleccione un validador",
    ),
    "g_key_stake_select_position": MessageLookupByLibrary.simpleMessage(
      "Seleccione una posición para quitar la apuesta",
    ),
    "g_key_stake_select_validator": MessageLookupByLibrary.simpleMessage(
      "Seleccionar Validador",
    ),
    "g_key_stake_sort_by": MessageLookupByLibrary.simpleMessage("Ordenar por"),
    "g_key_stake_stake": MessageLookupByLibrary.simpleMessage("Apostar"),
    "g_key_stake_staked": MessageLookupByLibrary.simpleMessage("apostado"),
    "g_key_stake_start_staking": MessageLookupByLibrary.simpleMessage(
      "Empezar a apostar",
    ),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("Replantear"),
    "g_key_stake_tx_prepared": MessageLookupByLibrary.simpleMessage(
      "Transacción preparada exitosamente",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage(
      "Desvinculando",
    ),
    "g_key_stake_unbonding_warning": m32,
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage(
      "Retirar Apuesta",
    ),
    "g_key_stake_updating": MessageLookupByLibrary.simpleMessage(
      "Actualizando...",
    ),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("Validador"),
    "g_key_stake_you_receive": MessageLookupByLibrary.simpleMessage(
      "Recibirás",
    ),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Completado"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Precio del gas"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("Tarifa máxima de gas"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage("Tarifa máxima por gas"),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("Pendiente"),
    "g_key_t_29": m33,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("Error"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("Continuar"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage(
      "Contraseña de la Wallet",
    ),
    "g_key_t_34": MessageLookupByLibrary.simpleMessage(
      "Contraseña de Wallet incorrecta",
    ),
    "g_key_t_35": MessageLookupByLibrary.simpleMessage(
      "Por favor ingresa la contraseña de la Wallet",
    ),
    "g_key_t_36": MessageLookupByLibrary.simpleMessage(
      "Precio de la tarifa de gas",
    ),
    "g_key_t_37": MessageLookupByLibrary.simpleMessage(
      "El promedio de la tarifa de gas del último bloque",
    ),
    "g_key_t_4": MessageLookupByLibrary.simpleMessage("Trasferencia"),
    "g_key_t_43": MessageLookupByLibrary.simpleMessage(
      "Ingrese un número entero mayor que 0.",
    ),
    "g_key_t_44": MessageLookupByLibrary.simpleMessage(
      "Error al obtener datos",
    ),
    "g_key_t_45": m34,
    "g_key_t_46": MessageLookupByLibrary.simpleMessage(
      "Verificar la dirección de recepción de la cuenta",
    ),
    "g_key_t_47": MessageLookupByLibrary.simpleMessage("Buscar"),
    "g_key_t_49": MessageLookupByLibrary.simpleMessage("Sin cuenta"),
    "g_key_t_5": MessageLookupByLibrary.simpleMessage("Transferencia"),
    "g_key_t_50": MessageLookupByLibrary.simpleMessage("Dirección no válida"),
    "g_key_t_51": MessageLookupByLibrary.simpleMessage(
      "Verificación de cuenta exitosa",
    ),
    "g_key_t_52": m35,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "La dirección de recepción no tiene una cuenta y la primera transferencia es de al menos 10XRP",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Gas usado"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("gasolina"),
    "g_key_token_discovery_add": MessageLookupByLibrary.simpleMessage("Añadir"),
    "g_key_token_discovery_add_selected": m36,
    "g_key_token_discovery_added": MessageLookupByLibrary.simpleMessage(
      "Ficha agregada",
    ),
    "g_key_token_discovery_banner": m37,
    "g_key_token_discovery_deselect_all": MessageLookupByLibrary.simpleMessage(
      "Deseleccionar todo",
    ),
    "g_key_token_discovery_empty": MessageLookupByLibrary.simpleMessage(
      "No se encontraron nuevos tokens",
    ),
    "g_key_token_discovery_ignore": MessageLookupByLibrary.simpleMessage(
      "ignorar",
    ),
    "g_key_token_discovery_select_all": MessageLookupByLibrary.simpleMessage(
      "Seleccionar todo",
    ),
    "g_key_token_discovery_title": MessageLookupByLibrary.simpleMessage(
      "Fichas descubiertas",
    ),
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage(
      "Historial de transacciones",
    ),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage(
      "Detalle de transacción",
    ),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage(
      "Por favor, vea los recibos de transacciones en el historial",
    ),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage("Monto gastado"),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage("Obtener monto"),
    "g_key_tx_filter_date_from": MessageLookupByLibrary.simpleMessage(
      "Fecha de inicio",
    ),
    "g_key_tx_filter_date_range": MessageLookupByLibrary.simpleMessage(
      "Rango de fechas",
    ),
    "g_key_tx_filter_date_to": MessageLookupByLibrary.simpleMessage(
      "Fecha de finalización",
    ),
    "g_key_tx_filter_direction": MessageLookupByLibrary.simpleMessage(
      "Dirección",
    ),
    "g_key_tx_no_results": MessageLookupByLibrary.simpleMessage(
      "Ninguna transacción coincide con su filtro",
    ),
    "g_key_uuid": MessageLookupByLibrary.simpleMessage("UUID"),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage(
      "Encontrar la última versión",
    ),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage(
      "Actualizar inmediatamente",
    ),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage(
      "Nueva versión encontrada",
    ),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage("Ya la última versión"),
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage(
      "Ver frase inicial",
    ),
    "g_key_wallet_c12": MessageLookupByLibrary.simpleMessage(
      "Ahora intenta poner tu frase inicial nuevamente.",
    ),
    "g_key_wallet_c13": MessageLookupByLibrary.simpleMessage("Importar cuenta"),
    "g_key_wallet_c14": MessageLookupByLibrary.simpleMessage("Crear cuenta"),
    "g_key_wallet_c15": MessageLookupByLibrary.simpleMessage("¡Ya terminaste!"),
    "g_key_wallet_c16": MessageLookupByLibrary.simpleMessage(
      "Ahora puedes disfrutar plenamente de tu billetera.",
    ),
    "g_key_wallet_c17": MessageLookupByLibrary.simpleMessage("Comenzar"),
    "g_key_wallet_c18": MessageLookupByLibrary.simpleMessage(
      "Saltar por ahora",
    ),
    "g_key_wallet_c19": MessageLookupByLibrary.simpleMessage(
      "Puede omitir la copia de seguridad de la frase inicial por ahora y volver a hacerlo en Configuración en cualquier momento si lo necesita.",
    ),
    "g_key_wallet_c21": MessageLookupByLibrary.simpleMessage(
      "Crear directamente",
    ),
    "g_key_wallet_c22": MessageLookupByLibrary.simpleMessage(
      "Creación exitosa",
    ),
    "g_key_wallet_c23": MessageLookupByLibrary.simpleMessage(
      "Si deseas verificar los detalles de tu billetera o exportar el almacén de claves, puedes ir a la barra lateral > Administrar billetera",
    ),
    "g_key_wallet_c24": MessageLookupByLibrary.simpleMessage(
      "Exportar mi almacén de claves",
    ),
    "g_key_wallet_c25": MessageLookupByLibrary.simpleMessage(
      "Asegura tu billetera haciendo una copia de seguridad",
    ),
    "g_key_wallet_c26": MessageLookupByLibrary.simpleMessage(
      "Un almacén de claves es un depósito de certificados de seguridad y claves privadas asociadas.",
    ),
    "g_key_wallet_c27": MessageLookupByLibrary.simpleMessage(
      "Paso 1: Ve a Administrar Monedero.",
    ),
    "g_key_wallet_c28": MessageLookupByLibrary.simpleMessage(
      "Paso 2: Seleccione la dirección de la billetera.",
    ),
    "g_key_wallet_c29": MessageLookupByLibrary.simpleMessage(
      "Paso 3: Presione Exportar almacén de claves.",
    ),
    "g_key_wallet_c30": MessageLookupByLibrary.simpleMessage(
      "Ir a Administrar Cartera",
    ),
    "g_key_wallet_c31": MessageLookupByLibrary.simpleMessage(
      "Volver a la página de inicio",
    ),
    "g_key_wallet_c32": MessageLookupByLibrary.simpleMessage(
      "Agregar billetera",
    ),
    "g_key_wallet_c33": MessageLookupByLibrary.simpleMessage(
      "Crear una billetera usando una frase inicial.",
    ),
    "g_key_wallet_c34": MessageLookupByLibrary.simpleMessage(
      "Ingrese un nombre de billetera",
    ),
    "g_key_wallet_c35": MessageLookupByLibrary.simpleMessage(
      "¡No ha realizado una copia de seguridad de la frase inicial de su billetera!",
    ),
    "g_key_wallet_c36": MessageLookupByLibrary.simpleMessage(
      "Realizar copia de seguridad ahora",
    ),
    "g_key_wallet_c37": MessageLookupByLibrary.simpleMessage(
      "Establecer contraseña de billetera",
    ),
    "g_key_wallet_c38": MessageLookupByLibrary.simpleMessage(
      "Realizar copia de seguridad de billetera",
    ),
    "g_key_wallet_c39": MessageLookupByLibrary.simpleMessage(
      "Registre la siguiente frase inicial",
    ),
    "g_key_wallet_c4": MessageLookupByLibrary.simpleMessage("Iniciar"),
    "g_key_wallet_c40": MessageLookupByLibrary.simpleMessage(
      "Los dispositivos conectados a Internet pueden exponer su información. Le recomendamos que anote la frase inicial y la guarde de forma segura.",
    ),
    "g_key_wallet_c41": MessageLookupByLibrary.simpleMessage(
      "Advertencia: No revele su frase inicial a nadie. N42Wallet nunca le solicitará esta información. Tenga cuidado. Tenga mucho cuidado y guárdela de forma segura sin conexión. Si su frase inicial queda expuesta, puede perder todos sus activos y no poder recuperarlos.",
    ),
    "g_key_wallet_c42": MessageLookupByLibrary.simpleMessage(
      "Advertencia: la frase inicial es la única forma de recuperar los activos de su billetera.",
    ),
    "g_key_wallet_c43": MessageLookupByLibrary.simpleMessage("Siguiente paso"),
    "g_key_wallet_c44": MessageLookupByLibrary.simpleMessage(
      "Haga clic para ver la frase inicial",
    ),
    "g_key_wallet_c45": MessageLookupByLibrary.simpleMessage(
      "Asegúrese de que no haya otras personas ni cámaras cerca",
    ),
    "g_key_wallet_c46": MessageLookupByLibrary.simpleMessage(
      "Confirmar frase inicial",
    ),
    "g_key_wallet_c47": MessageLookupByLibrary.simpleMessage(
      "Información de la billetera",
    ),
    "g_key_wallet_c48": MessageLookupByLibrary.simpleMessage(
      "Nombre de la billetera",
    ),
    "g_key_wallet_c49": MessageLookupByLibrary.simpleMessage(
      "¡Primero haga una copia de seguridad de la frase inicial de su billetera!",
    ),
    "g_key_wallet_c6": MessageLookupByLibrary.simpleMessage(
      "Comprobar frase inicial",
    ),
    "g_key_wallet_c7": MessageLookupByLibrary.simpleMessage(
      "Ahora ingresa tu frase inicial.",
    ),
    "g_key_wallet_c8": MessageLookupByLibrary.simpleMessage("Establecer frase"),
    "g_key_wallet_c9": MessageLookupByLibrary.simpleMessage(
      "Asegúrese de registrar su frase inicial y almacenarla de forma segura. La necesitará para importar o recuperar su billetera de criptomonedas.",
    ),
    "g_key_wallet_edit": MessageLookupByLibrary.simpleMessage("Editar Wallet"),
    "g_key_wallet_k25": MessageLookupByLibrary.simpleMessage("Hora"),
    "g_key_wallet_k33": MessageLookupByLibrary.simpleMessage("Resultado"),
    "g_key_wallet_k37": MessageLookupByLibrary.simpleMessage(
      "Hash de transacción",
    ),
    "g_key_wallet_k47": MessageLookupByLibrary.simpleMessage("Agregar"),
    "g_key_wallet_k53": MessageLookupByLibrary.simpleMessage("Ruta"),
    "g_key_wallet_k54": MessageLookupByLibrary.simpleMessage("Bloquear"),
    "g_key_wallet_k55": MessageLookupByLibrary.simpleMessage("Valor"),
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage("Mientras tanto"),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("Acelerar"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("Nota"),
    "g_key_wallet_m1": m38,
    "g_key_wallet_m19": m39,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "El token actual no ha sido agregado.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Ingresa tu frase semilla con palabras separadas por espacios",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage("Importar Wallet"),
    "g_key_wallet_m3": m40,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "El saldo actual de tokens es insuficiente.",
    ),
    "g_key_wallet_m5": m41,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage("Error de firma"),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage(
      "Administrar Wallet",
    ),
    "g_key_watch_address_hint": MessageLookupByLibrary.simpleMessage(
      "Ingrese la dirección de Ethereum (0x...)",
    ),
    "g_key_watch_only_cant_send": MessageLookupByLibrary.simpleMessage(
      "La billetera de solo reloj no puede enviar ni firmar transacciones",
    ),
    "g_key_watch_wallet": MessageLookupByLibrary.simpleMessage(
      "Cartera de reloj",
    ),
    "g_key_watch_wallet_desc": MessageLookupByLibrary.simpleMessage(
      "Realice un seguimiento de cualquier dirección EVM sin clave privada",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("Reservado"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("Reserva base"),
    "g_key_xml_11": m42,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("Reserva incremental"),
    "g_key_xml_22": m43,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "Cantidad de objetos poseídos",
    ),
    "g_key_xml_33": m44,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage(
      "Cómo calcular el monto total reservado",
    ),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "Reserva total = Reserva base + (Cantidad de objetos poseídos × Reserva incremental)",
    ),
    "g_live_enter_room_failed": m45,
    "g_live_follow": MessageLookupByLibrary.simpleMessage("Seguir"),
    "g_live_follow_wip": MessageLookupByLibrary.simpleMessage(
      "Función de seguir próximamente",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch ID y Face ID"),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("Contraseña gestual"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage(
      "Establecer contraseña gestual",
    ),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "Dibuja tu patrón gestual",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage(
      "Confirma tu patrón gestual",
    ),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage(
      "Dibuja el patrón gestual actual",
    ),
    "g_lock_key21": m46,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Restablecer contraseña gestual",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Demasiados intentos fallidos, inténtalo de nuevo",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "¿Agregar contraseña de billetera?",
    ),
    "g_lock_key25": m47,
    "g_lock_key26": MessageLookupByLibrary.simpleMessage(
      "Transfer Verification",
    ),
    "g_lock_key27": MessageLookupByLibrary.simpleMessage(
      "Require biometric authentication (Face ID / fingerprint) to confirm each wallet transfer.",
    ),
    "g_lock_key28": MessageLookupByLibrary.simpleMessage(
      "Contraseña gestual no establecida",
    ),
    "g_lock_key29": MessageLookupByLibrary.simpleMessage(
      "Se requiere autenticación gestual para confirmar cada transferencia.",
    ),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("Exitoso"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("Error"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage(
      "El reconocimiento biométrico no está habilitado",
    ),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage(
      "¿Agregar verificación biométrica?",
    ),
    "g_market_30d_change": MessageLookupByLibrary.simpleMessage("Cambio 30D"),
    "g_market_7d_change": MessageLookupByLibrary.simpleMessage("Cambio 7D"),
    "g_market_ath": MessageLookupByLibrary.simpleMessage("ATH"),
    "g_market_atl": MessageLookupByLibrary.simpleMessage("ATL"),
    "g_market_depth": MessageLookupByLibrary.simpleMessage(
      "Profundidad del mercado",
    ),
    "g_market_empty_watchlist": MessageLookupByLibrary.simpleMessage(
      "Aún no hay lista de seguimiento",
    ),
    "g_market_fdv": MessageLookupByLibrary.simpleMessage("FDV"),
    "g_market_high_24h": MessageLookupByLibrary.simpleMessage("Alta 24H"),
    "g_market_liquidity_score": MessageLookupByLibrary.simpleMessage(
      "Puntuación de liquidez",
    ),
    "g_market_low_24h": MessageLookupByLibrary.simpleMessage("Bajo 24H"),
    "g_market_news": MessageLookupByLibrary.simpleMessage("Noticias"),
    "g_market_no_chart": MessageLookupByLibrary.simpleMessage(
      "Sin datos del gráfico",
    ),
    "g_market_no_results": MessageLookupByLibrary.simpleMessage(
      "Sin resultados",
    ),
    "g_market_rank": MessageLookupByLibrary.simpleMessage("Rango"),
    "g_market_search": MessageLookupByLibrary.simpleMessage("Buscar"),
    "g_market_search_hint": MessageLookupByLibrary.simpleMessage(
      "Buscar monedas...",
    ),
    "g_market_trending": MessageLookupByLibrary.simpleMessage("Tendencia"),
    "g_market_watchlist": MessageLookupByLibrary.simpleMessage(
      "Lista de seguimiento",
    ),
    "g_mining_inactivity_warning": MessageLookupByLibrary.simpleMessage(
      "La puntuación de inactividad del validador es alta. Verifique el estado de su nodo para evitar penalizaciones.",
    ),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("¿Desbloquear N?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage(
      "Registro de actividad de verificación en la nube",
    ),
    "g_mining_key33": MessageLookupByLibrary.simpleMessage(
      "Configuración de verificación",
    ),
    "g_mining_key34": MessageLookupByLibrary.simpleMessage(
      "Música de verificación de fondo",
    ),
    "g_mining_key35": MessageLookupByLibrary.simpleMessage("Predeterminado"),
    "g_mining_key36": MessageLookupByLibrary.simpleMessage("Silenciar"),
    "g_mining_key37": MessageLookupByLibrary.simpleMessage(
      "Cuando la verificación en segundo plano está habilitada, la música se reproducirá en segundo plano. Si la música se detiene, la verificación también se detendrá.",
    ),
    "g_mining_key38": MessageLookupByLibrary.simpleMessage("Tu nivel"),
    "g_mining_key46": MessageLookupByLibrary.simpleMessage(
      "La configuración requiere una pequeña cantidad de gas.",
    ),
    "g_mining_key60": MessageLookupByLibrary.simpleMessage(
      "Te has unido exitosamente a un Nodo de Grupo en N42Wallet. Comparte el enlace para invitar a tus amigos, activar el nodo y comenzar a verificar.",
    ),
    "g_mining_key61": MessageLookupByLibrary.simpleMessage(
      "Compartir con amigos",
    ),
    "g_mining_key62": MessageLookupByLibrary.simpleMessage("Continuar"),
    "g_mining_key63": m48,
    "g_mining_key73": m49,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "Acabo de configurar un nodo en @N42aWallet y comencé a verificar en dispositivos móviles. ¡Únete a mí! ¡El futuro descentralizado es móvil!",
    ),
    "g_mining_key76": m50,
    "g_mining_key82": MessageLookupByLibrary.simpleMessage("minerales"),
    "g_mining_key83": MessageLookupByLibrary.simpleMessage("Nodo"),
    "g_mining_key84": MessageLookupByLibrary.simpleMessage("Red"),
    "g_mining_key85": MessageLookupByLibrary.simpleMessage(
      "Cambie entre testnet y mainnet para minería en la nube.",
    ),
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "Canje disponible después de los 768.",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "Las solicitudes anteriores no se procesarán.",
    ),
    "g_mining_key_1": MessageLookupByLibrary.simpleMessage("Inicio"),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage(
      "La recompensa de hoy",
    ),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "Trate los datos a continuación como una llave importante. Le recomendamos copiarlos y guardarlos de inmediato en un lugar de confianza.",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage("Copiar datos"),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("Inactivo"),
    "g_mining_key_104": MessageLookupByLibrary.simpleMessage(
      "Importación exitosa",
    ),
    "g_mining_key_105": MessageLookupByLibrary.simpleMessage(
      "¡Los datos cifrados no pueden estar vacíos!",
    ),
    "g_mining_key_106": MessageLookupByLibrary.simpleMessage(
      "¡La contraseña no puede estar vacía!",
    ),
    "g_mining_key_107": MessageLookupByLibrary.simpleMessage(
      "Error de descifrado. ¡Comprueba si la contraseña es correcta!",
    ),
    "g_mining_key_108": MessageLookupByLibrary.simpleMessage(
      "¡Formato de datos cifrados no compatible!",
    ),
    "g_mining_key_109": m51,
    "g_mining_key_11": MessageLookupByLibrary.simpleMessage(
      "Recompensas de ayer",
    ),
    "g_mining_key_110": MessageLookupByLibrary.simpleMessage("Datos cifrados"),
    "g_mining_key_111": MessageLookupByLibrary.simpleMessage(
      "Importar archivos",
    ),
    "g_mining_key_112": MessageLookupByLibrary.simpleMessage(
      "Por favor, introduzca datos cifrados.",
    ),
    "g_mining_key_113": MessageLookupByLibrary.simpleMessage("Importador..."),
    "g_mining_key_114": MessageLookupByLibrary.simpleMessage("Confirmación"),
    "g_mining_key_115": MessageLookupByLibrary.simpleMessage(
      "El canje tarda un poco, ¡por favor espera un momento!",
    ),
    "g_mining_key_116": m52,
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "La recompensa se acumula diariamente y solo se envía a tu Wallet N cuando alcanza ~0.5 N.",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage(
      "Recompensas totales",
    ),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("Valor extraído"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage(
      "Detalle de la tarea",
    ),
    "g_mining_key_19": MessageLookupByLibrary.simpleMessage("Resumen"),
    "g_mining_key_2": MessageLookupByLibrary.simpleMessage("Actividades"),
    "g_mining_key_20": MessageLookupByLibrary.simpleMessage(
      "Valor total extraído",
    ),
    "g_mining_key_21": MessageLookupByLibrary.simpleMessage(
      "Verificación desde",
    ),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage(
      "Número de beneficios",
    ),
    "g_mining_key_24": MessageLookupByLibrary.simpleMessage("Valor verificado"),
    "g_mining_key_31": MessageLookupByLibrary.simpleMessage(
      "Seleccionar planes",
    ),
    "g_mining_key_32": MessageLookupByLibrary.simpleMessage(
      "Período de desbloqueo: Desbloqueable en cualquier momento",
    ),
    "g_mining_key_33": MessageLookupByLibrary.simpleMessage(
      "Recompensa máxima anual",
    ),
    "g_mining_key_34": MessageLookupByLibrary.simpleMessage(
      "Distribución de recompensas",
    ),
    "g_mining_key_35": MessageLookupByLibrary.simpleMessage("Límite diario"),
    "g_mining_key_36": MessageLookupByLibrary.simpleMessage("Velocidad"),
    "g_mining_key_37": MessageLookupByLibrary.simpleMessage(
      "Planes de verificación",
    ),
    "g_mining_key_38": MessageLookupByLibrary.simpleMessage(
      "Seleccione el método de pago",
    ),
    "g_mining_key_39": MessageLookupByLibrary.simpleMessage("Métodos de pago"),
    "g_mining_key_40": MessageLookupByLibrary.simpleMessage("Pagar usando N"),
    "g_mining_key_42": MessageLookupByLibrary.simpleMessage(
      "Saldo de la Wallet",
    ),
    "g_mining_key_43": MessageLookupByLibrary.simpleMessage(
      "No tienes suficiente N para esta transacción",
    ),
    "g_mining_key_45": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que quieres saltarte?",
    ),
    "g_mining_key_46": MessageLookupByLibrary.simpleMessage(
      "No recibirás ninguna recompensa de verificación hasta que elijas 1 de los planes.",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Desactivado"),
    "g_mining_key_48": MessageLookupByLibrary.simpleMessage("recompensa"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("Ver más"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage(
      "Estado de verificación",
    ),
    "g_mining_key_50": MessageLookupByLibrary.simpleMessage("para desbloquear"),
    "g_mining_key_52": MessageLookupByLibrary.simpleMessage("Saltar"),
    "g_mining_key_58": MessageLookupByLibrary.simpleMessage("Últimos 7 días"),
    "g_mining_key_59": MessageLookupByLibrary.simpleMessage(
      "Recompensas acumuladas",
    ),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Bloquea los N para comenzar a extraer recompensas.",
    ),
    "g_mining_key_60": MessageLookupByLibrary.simpleMessage(
      "Recompensas recibidas",
    ),
    "g_mining_key_61": MessageLookupByLibrary.simpleMessage("Avanzado"),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Entrada"),
    "g_mining_key_63": MessageLookupByLibrary.simpleMessage("profesional"),
    "g_mining_key_64": MessageLookupByLibrary.simpleMessage("NODO COMPLETO"),
    "g_mining_key_65": MessageLookupByLibrary.simpleMessage("MINUTOS/DÍA"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("Nodo Avanzado"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("Nodo De Entrada"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Nodo Pro"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 bloques/día ~ 70 minutos",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage(
      "Fecha de desbloqueo",
    ),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 bloques/día ~ 15 minutos",
    ),
    "g_mining_key_71": m53,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage(
      "128 segundos por verificación",
    ),
    "g_mining_key_74": MessageLookupByLibrary.simpleMessage(
      "La cadena de pruebas se está actualizando y los bloques no se pueden verificar temporalmente.",
    ),
    "g_mining_key_75": MessageLookupByLibrary.simpleMessage(
      "Si no se completan las tareas durante cuatro días consecutivos, no se obtendrán ganancias y existe el riesgo de recibir una penalización.",
    ),
    "g_mining_key_76": MessageLookupByLibrary.simpleMessage(
      "Puntuación de riesgo",
    ),
    "g_mining_key_77": MessageLookupByLibrary.simpleMessage("canjear"),
    "g_mining_key_78": MessageLookupByLibrary.simpleMessage(
      "Guarde primero el par de claves pública y privada del verificador.",
    ),
    "g_mining_key_79": MessageLookupByLibrary.simpleMessage("Exportar"),
    "g_mining_key_8": MessageLookupByLibrary.simpleMessage(
      "Hora de verificación de hoy",
    ),
    "g_mining_key_80": MessageLookupByLibrary.simpleMessage(
      "Fondos insuficientes para la transferencia.",
    ),
    "g_mining_key_81": MessageLookupByLibrary.simpleMessage(
      "Lista de validadores",
    ),
    "g_mining_key_82": MessageLookupByLibrary.simpleMessage(
      "Validador de importación",
    ),
    "g_mining_key_83": MessageLookupByLibrary.simpleMessage(
      "El validador ya existe",
    ),
    "g_mining_key_84": MessageLookupByLibrary.simpleMessage("Riesgo bajo"),
    "g_mining_key_85": MessageLookupByLibrary.simpleMessage(
      "Riesgo moderadamente",
    ),
    "g_mining_key_86": MessageLookupByLibrary.simpleMessage(
      "Recompensas de los últimos 7 días",
    ),
    "g_mining_key_87": MessageLookupByLibrary.simpleMessage("Riesgo alto"),
    "g_mining_key_88": MessageLookupByLibrary.simpleMessage(
      "El contrato se está cargando y no se puede verificar en este momento. ¡Espere un momento!",
    ),
    "g_mining_key_89": MessageLookupByLibrary.simpleMessage(
      "Consejos de seguridad",
    ),
    "g_mining_key_9": MessageLookupByLibrary.simpleMessage(
      "Verificación en segundo plano",
    ),
    "g_mining_key_90": MessageLookupByLibrary.simpleMessage(
      "Mantenga su clave privada o frase mnemotécnica segura.",
    ),
    "g_mining_key_91": MessageLookupByLibrary.simpleMessage(
      "Su clave privada o frase mnemotécnica es la única credencial para acceder a los activos de su billetera.",
    ),
    "g_mining_key_92": MessageLookupByLibrary.simpleMessage(
      "Guárdela en un lugar seguro (papel, administrador de contraseñas, etc.).",
    ),
    "g_mining_key_93": MessageLookupByLibrary.simpleMessage(
      "No tome capturas de pantalla, no las suba a internet ni las comparta con nadie.",
    ),
    "g_mining_key_94": MessageLookupByLibrary.simpleMessage(
      "Una vez perdida o comprometida, los activos de su billetera no se pueden recuperar.",
    ),
    "g_mining_key_95": MessageLookupByLibrary.simpleMessage(
      "Confirmar y guardar",
    ),
    "g_mining_key_96": MessageLookupByLibrary.simpleMessage(
      "Establezca una contraseña y encripte",
    ),
    "g_mining_key_97": MessageLookupByLibrary.simpleMessage(
      "Por favor, introduzca la contraseña de cifrado",
    ),
    "g_mining_key_98": m54,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "Vuelve a introducir tu contraseña para asegurarte de que es correcta",
    ),
    "g_mining_node_key1": MessageLookupByLibrary.simpleMessage(
      "Detalle Nodo Completo",
    ),
    "g_mining_node_key2": MessageLookupByLibrary.simpleMessage("ID de Nodo"),
    "g_mining_node_key3": MessageLookupByLibrary.simpleMessage("WS Conectado"),
    "g_mining_node_key4": MessageLookupByLibrary.simpleMessage(
      "WS Desconectado",
    ),
    "g_mining_node_key5": MessageLookupByLibrary.simpleMessage(
      "WS Reconectando",
    ),
    "g_mining_node_key6": MessageLookupByLibrary.simpleMessage("Vencimiento"),
    "g_mining_unlock_period": MessageLookupByLibrary.simpleMessage(
      "Período de desbloqueo:",
    ),
    "g_mining_unlockable_anytime": MessageLookupByLibrary.simpleMessage(
      "Desbloqueable en cualquier momento",
    ),
    "g_news_empty": MessageLookupByLibrary.simpleMessage(
      "No hay noticias disponibles",
    ),
    "g_phishing_go_back": MessageLookupByLibrary.simpleMessage(
      "Volver (Seguro)",
    ),
    "g_phishing_proceed_anyway": MessageLookupByLibrary.simpleMessage(
      "Continuar de todos modos",
    ),
    "g_phishing_warning_body": MessageLookupByLibrary.simpleMessage(
      "Este sitio web ha sido identificado como potencialmente malicioso. Podría intentar robar sus activos cripto o claves privadas.",
    ),
    "g_phishing_warning_title": MessageLookupByLibrary.simpleMessage(
      "Advertencia de Seguridad",
    ),
    "g_phishing_warning_url_label": MessageLookupByLibrary.simpleMessage(
      "URL sospechosa:",
    ),
    "g_pnl_add_trade": MessageLookupByLibrary.simpleMessage("Agregar comercio"),
    "g_pnl_avg_cost": MessageLookupByLibrary.simpleMessage("Costo promedio"),
    "g_pnl_buy_price_usd": MessageLookupByLibrary.simpleMessage(
      "Precio de compra (USD)",
    ),
    "g_pnl_cost_basis": MessageLookupByLibrary.simpleMessage("Base del costo"),
    "g_pnl_quantity": MessageLookupByLibrary.simpleMessage("Cantidad"),
    "g_pnl_save": MessageLookupByLibrary.simpleMessage("Guardar"),
    "g_pnl_unrealized": MessageLookupByLibrary.simpleMessage(
      "PyG no realizadas",
    ),
    "g_portfolio_24h": MessageLookupByLibrary.simpleMessage("Cambio 24h"),
    "g_portfolio_all_holdings": MessageLookupByLibrary.simpleMessage(
      "Todos los activos",
    ),
    "g_portfolio_allocation": MessageLookupByLibrary.simpleMessage(
      "Asignación de activos",
    ),
    "g_portfolio_gainers": MessageLookupByLibrary.simpleMessage(
      "Principales ganadores",
    ),
    "g_portfolio_losers": MessageLookupByLibrary.simpleMessage(
      "Mayores pérdidas",
    ),
    "g_portfolio_movers": MessageLookupByLibrary.simpleMessage("Mudanzas 24h"),
    "g_portfolio_no_assets": MessageLookupByLibrary.simpleMessage(
      "No se encontraron activos",
    ),
    "g_portfolio_others": MessageLookupByLibrary.simpleMessage("Otros"),
    "g_portfolio_pie_total": MessageLookupByLibrary.simpleMessage("totales"),
    "g_portfolio_title": MessageLookupByLibrary.simpleMessage("Portafolio"),
    "g_portfolio_total": MessageLookupByLibrary.simpleMessage("Valor total"),
    "g_pred_add_outcome": MessageLookupByLibrary.simpleMessage(
      "Añadir resultado",
    ),
    "g_pred_amount_input": m55,
    "g_pred_balance": m56,
    "g_pred_buy": MessageLookupByLibrary.simpleMessage("Comprar"),
    "g_pred_cancel_refund": MessageLookupByLibrary.simpleMessage(
      "Cancelar y reembolsar",
    ),
    "g_pred_close_only": MessageLookupByLibrary.simpleMessage("Solo cerrar"),
    "g_pred_closed_waiting": MessageLookupByLibrary.simpleMessage(
      "Cerrado, esperando resolución",
    ),
    "g_pred_confirm_resolve": MessageLookupByLibrary.simpleMessage(
      "Confirmar resolución",
    ),
    "g_pred_confirm_resolve_msg": m57,
    "g_pred_create_title": MessageLookupByLibrary.simpleMessage(
      "Iniciar predicción",
    ),
    "g_pred_creating": MessageLookupByLibrary.simpleMessage("Creando…"),
    "g_pred_deadline": MessageLookupByLibrary.simpleMessage("Plazo"),
    "g_pred_err_amount_low": MessageLookupByLibrary.simpleMessage(
      "El importe debe ser mayor que 0",
    ),
    "g_pred_err_insufficient_balance": MessageLookupByLibrary.simpleMessage(
      "Saldo insuficiente",
    ),
    "g_pred_err_insufficient_shares": MessageLookupByLibrary.simpleMessage(
      "Participaciones insuficientes",
    ),
    "g_pred_err_invalid_outcome": MessageLookupByLibrary.simpleMessage(
      "Resultado no válido",
    ),
    "g_pred_err_market_closed": MessageLookupByLibrary.simpleMessage(
      "Mercado cerrado, sin operaciones",
    ),
    "g_pred_err_market_not_found": MessageLookupByLibrary.simpleMessage(
      "Mercado no encontrado",
    ),
    "g_pred_err_not_resolved": MessageLookupByLibrary.simpleMessage(
      "Mercado sin resolver, no se puede canjear",
    ),
    "g_pred_err_outcomes": MessageLookupByLibrary.simpleMessage(
      "Al menos dos resultados válidos",
    ),
    "g_pred_err_question": MessageLookupByLibrary.simpleMessage(
      "Introduce una pregunta",
    ),
    "g_pred_err_slippage": MessageLookupByLibrary.simpleMessage(
      "Slippage excedido, reinténtalo",
    ),
    "g_pred_minutes": m58,
    "g_pred_no": MessageLookupByLibrary.simpleMessage("No"),
    "g_pred_outcome_n": m59,
    "g_pred_outcome_win": m60,
    "g_pred_outcomes": MessageLookupByLibrary.simpleMessage("Resultados"),
    "g_pred_pick_winner": MessageLookupByLibrary.simpleMessage(
      "Elige el resultado ganador para liquidar (fondos según resultado)",
    ),
    "g_pred_processing": MessageLookupByLibrary.simpleMessage("Procesando…"),
    "g_pred_publish": MessageLookupByLibrary.simpleMessage("Publicar"),
    "g_pred_q_hint": MessageLookupByLibrary.simpleMessage(
      "Pregunta de predicción, p. ej. ¿Quién gana esta ronda?",
    ),
    "g_pred_quote_info": m61,
    "g_pred_redeem_failed": m62,
    "g_pred_resolved": MessageLookupByLibrary.simpleMessage("Resuelto"),
    "g_pred_result_label": m63,
    "g_pred_sell_n": m64,
    "g_pred_unlimited": MessageLookupByLibrary.simpleMessage(
      "Sin límite (cierre manual)",
    ),
    "g_pred_yes": MessageLookupByLibrary.simpleMessage("Sí"),
    "g_referral_downloaded": MessageLookupByLibrary.simpleMessage("Descargado"),
    "g_referral_invite_code": MessageLookupByLibrary.simpleMessage(
      "Código de invitación",
    ),
    "g_referral_invited": MessageLookupByLibrary.simpleMessage("Invitados"),
    "g_referral_mining": MessageLookupByLibrary.simpleMessage(
      "Nodos de minería",
    ),
    "g_referral_reward": MessageLookupByLibrary.simpleMessage("Recompensa (N)"),
    "g_setting_mining_v1_label": MessageLookupByLibrary.simpleMessage(
      "Minería clásica (V1)",
    ),
    "g_setting_mining_v2_label": MessageLookupByLibrary.simpleMessage(
      "Minería (V2)",
    ),
    "g_setting_mining_version": MessageLookupByLibrary.simpleMessage(
      "Interfaz de Minería",
    ),
    "g_share_v2_key_5": MessageLookupByLibrary.simpleMessage("Compartir"),
    "g_share_v3_key_2": MessageLookupByLibrary.simpleMessage("Recomendación"),
    "g_share_v3_key_3": MessageLookupByLibrary.simpleMessage(
      "¡Recomienda amigos y obtén tokens N!",
    ),
    "g_share_v3_key_4": MessageLookupByLibrary.simpleMessage(
      "Consigues hasta ",
    ),
    "g_share_v3_key_5": MessageLookupByLibrary.simpleMessage(
      " N cuando tu referido comience a verificar.",
    ),
    "g_share_v3_key_6": MessageLookupByLibrary.simpleMessage("Referir vía"),
    "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("Enlace"),
    "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("código"),
    "g_swap_key_14": m65,
    "g_swap_key_15": MessageLookupByLibrary.simpleMessage(
      "Obtener error en el precio de la moneda.",
    ),
    "g_swap_key_16": MessageLookupByLibrary.simpleMessage(
      "Al continuar, aceptas lo siguiente",
    ),
    "g_swap_key_17": MessageLookupByLibrary.simpleMessage(
      "Términos y condiciones.",
    ),
    "g_swap_key_18": MessageLookupByLibrary.simpleMessage("Finalizar"),
    "g_swap_key_19": MessageLookupByLibrary.simpleMessage(
      "Su intercambio se distribuirá en breve. Tenga paciencia.",
    ),
    "g_swap_key_20": m66,
    "g_swap_key_21": MessageLookupByLibrary.simpleMessage(
      "Costos para ejecutar un nodo: Verificación en grupo 1-49 N Nodo Básico: 50 N Nodo Premium: 100 N Nodo Pro: 500 N.",
    ),
    "g_swap_key_22": MessageLookupByLibrary.simpleMessage("Caducar"),
    "g_swap_key_23": MessageLookupByLibrary.simpleMessage("No pagado"),
    "g_swap_key_24": MessageLookupByLibrary.simpleMessage("Confirmando pago"),
    "g_swap_key_25": MessageLookupByLibrary.simpleMessage(
      "Para ser distribuido",
    ),
    "g_swap_key_28": MessageLookupByLibrary.simpleMessage(
      "Resumen de intercambio",
    ),
    "g_swap_key_29": MessageLookupByLibrary.simpleMessage("Saldo Nuevo"),
    "g_swap_key_3": MessageLookupByLibrary.simpleMessage("Tú pagas"),
    "g_swap_key_30": MessageLookupByLibrary.simpleMessage("Fecha"),
    "g_swap_key_31": m67,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "Los swaps se pueden ver en los exploradores de cadena relevantes (Etherscan, BscScan, TRONSCAN y el nuestro).",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Cambiar a N"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("Intercambiar"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("Obtienes"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage(
      "Intercambio de vista previa",
    ),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("Inténtalo de nuevo"),
    "g_theme_accent_color": MessageLookupByLibrary.simpleMessage(
      "Color de acento",
    ),
    "g_theme_accent_reset": MessageLookupByLibrary.simpleMessage(
      "Restablecer los valores predeterminados",
    ),
    "g_token_m_key_1": m68,
    "g_token_m_key_10": MessageLookupByLibrary.simpleMessage(
      "Cualquiera puede crear un token, incluso crear versiones falsas de tokens existentes. Siempre investigue un token antes de importarlo.",
    ),
    "g_token_m_key_11": MessageLookupByLibrary.simpleMessage("Fichas"),
    "g_token_m_key_12": MessageLookupByLibrary.simpleMessage("Buscar Tokens"),
    "g_token_m_key_13": MessageLookupByLibrary.simpleMessage(
      "Nombre de la cadena",
    ),
    "g_token_m_key_14": MessageLookupByLibrary.simpleMessage(
      "Símbolo de cadena",
    ),
    "g_token_m_key_15": MessageLookupByLibrary.simpleMessage(
      "Identificación de cadena",
    ),
    "g_token_m_key_16": MessageLookupByLibrary.simpleMessage("decimales"),
    "g_token_m_key_17": MessageLookupByLibrary.simpleMessage("RPC"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage(
      "Añadir cadena personalizada",
    ),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18 unidades"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("Agregar tokens"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage(
      "¡Error de formato!",
    ),
    "g_token_m_key_22": m69,
    "g_token_m_key_23": m70,
    "g_token_m_key_24": m71,
    "g_token_m_key_3": MessageLookupByLibrary.simpleMessage("Importar tokens"),
    "g_token_m_key_4": MessageLookupByLibrary.simpleMessage("Todas las redes"),
    "g_token_m_key_5": MessageLookupByLibrary.simpleMessage(
      "Token personalizado",
    ),
    "g_token_m_key_6": MessageLookupByLibrary.simpleMessage(
      "Dirección del token",
    ),
    "g_token_m_key_7": MessageLookupByLibrary.simpleMessage("Símbolo de ficha"),
    "g_token_m_key_8": MessageLookupByLibrary.simpleMessage(
      "decimal simbólico",
    ),
    "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("Importar"),
    "g_tx_risk_caution": MessageLookupByLibrary.simpleMessage("Precaución"),
    "g_tx_risk_danger": MessageLookupByLibrary.simpleMessage("Alto Riesgo"),
    "g_tx_risk_safe": MessageLookupByLibrary.simpleMessage("Seguro"),
    "g_version_later": MessageLookupByLibrary.simpleMessage("Más tarde"),
    "g_wallet_group_hd": MessageLookupByLibrary.simpleMessage(
      "Cartera HD · Mnemónico",
    ),
    "g_wallet_group_single": MessageLookupByLibrary.simpleMessage(
      "Cadena única · Importado",
    ),
    "g_wc_connection_lost": MessageLookupByLibrary.simpleMessage(
      "Conexión perdida. Por favor, reconecte.",
    ),
    "g_wc_dapp_disconnected": MessageLookupByLibrary.simpleMessage(
      "La DApp se ha desconectado",
    ),
    "g_wc_disconnect_all": MessageLookupByLibrary.simpleMessage(
      "Desconectar todo",
    ),
    "g_wc_disconnect_all_confirm": MessageLookupByLibrary.simpleMessage(
      "¿Desconectar de todas las DApps?",
    ),
    "g_wc_disconnect_confirm": MessageLookupByLibrary.simpleMessage(
      "¿Desconectar de esta DApp?",
    ),
    "g_wc_no_sessions": MessageLookupByLibrary.simpleMessage(
      "Sin conexiones activas",
    ),
    "g_wc_no_sessions_desc": MessageLookupByLibrary.simpleMessage(
      "Escanea un código QR para conectar con una DApp",
    ),
    "g_wc_proposal_timeout": MessageLookupByLibrary.simpleMessage(
      "La solicitud de conexión ha expirado",
    ),
    "g_wc_session_expired": MessageLookupByLibrary.simpleMessage(
      "La sesión ha expirado",
    ),
    "g_wc_sessions": MessageLookupByLibrary.simpleMessage("DApps conectadas"),
    "g_xrp_dest_tag_hint": MessageLookupByLibrary.simpleMessage(
      "Suele ser obligatorio al enviar a un exchange",
    ),
    "g_xrp_optional": MessageLookupByLibrary.simpleMessage("(Opcional)"),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "Enlace",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage("Aviso Importante"),
    "login_email": MessageLookupByLibrary.simpleMessage("Correo electrónico"),
    "login_password": MessageLookupByLibrary.simpleMessage("Contraseña"),
    "next": MessageLookupByLibrary.simpleMessage("Siguiente"),
    "nicknameMessage": m72,
    "personalInformation": MessageLookupByLibrary.simpleMessage(
      "Editar perfil",
    ),
    "photograph": MessageLookupByLibrary.simpleMessage("Fotografía"),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "Por favor ingrese la dirección",
    ),
    "push_bg_delivery_dialog_content": MessageLookupByLibrary.simpleMessage(
      "This device restricts background apps, so you may miss chat messages and transfer alerts when the app is in the background or closed.\n\nTap \"Go to Settings\" to allow background activity, then enable Autostart for this app.",
    ),
    "push_bg_delivery_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Background Delivery May Be Limited",
    ),
    "push_permission_btn_dismiss": MessageLookupByLibrary.simpleMessage(
      "No recordar más",
    ),
    "push_permission_btn_later": MessageLookupByLibrary.simpleMessage(
      "Más tarde",
    ),
    "push_permission_btn_settings": MessageLookupByLibrary.simpleMessage(
      "Ir a Ajustes",
    ),
    "push_permission_dialog_content": MessageLookupByLibrary.simpleMessage(
      "Las notificaciones push están desactivadas. Podría perderse mensajes de chat y alertas de transferencias.\n\nActive las notificaciones para esta aplicación en la configuración del sistema.",
    ),
    "push_permission_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Notificaciones desactivadas",
    ),
    "repeatPassword": MessageLookupByLibrary.simpleMessage(
      "Repita la contraseña",
    ),
    "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
      "Elige una contraseña (8~18 caracteres)",
    ),
    "rest_Confirm_password": MessageLookupByLibrary.simpleMessage(
      "Confirmar contraseña",
    ),
    "s_key_10": MessageLookupByLibrary.simpleMessage("Acerca de la App"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("Seguridad"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("Transacción"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("Idioma"),
    "search": MessageLookupByLibrary.simpleMessage("Buscar"),
    "verification": MessageLookupByLibrary.simpleMessage("verificación"),
    "w_item_1": MessageLookupByLibrary.simpleMessage(
      "Si pierdo mi frase secreta, mis fondos se perderán para siempre.",
    ),
    "w_item_2": MessageLookupByLibrary.simpleMessage(
      "Si revelo o comparto mi frase inicial con alguien, mis fondos pueden ser robados.",
    ),
    "w_item_3": MessageLookupByLibrary.simpleMessage(
      "Es mi responsabilidad mantener segura mi frase inicial.",
    ),
    "w_key_12": MessageLookupByLibrary.simpleMessage(
      "Frase inicial incorrecta.",
    ),
    "w_key_8": MessageLookupByLibrary.simpleMessage(
      "Ingrese la frase inicial para la Wallet que desea importar.",
    ),
  };
}

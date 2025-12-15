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

  static String m0(value) => "Soy ${value}";

  static String m1(value) => "Miembro del chat(${value})";

  static String m2(value) =>
      "¿Estás seguro de que quieres agregar a ${value} como amigo?";

  static String m3(value) =>
      "Usted ha sido vinculado y no puede volver a vincularse en este momento. Dirección de vinculación: ${value}.";

  static String m4(value) => "Enlace exitoso. Dirección de enlace: ${value}";

  static String m5(value) => "¡No hay N42chain en la billetera ${value}!";

  static String m6(value) => "Coincidencia exitosa. Dirección: ${value}.";

  static String m7(value) => "Cantidad mayor a ${value}.";

  static String m8(value) =>
      "La billetera ya existe, el nombre de la billetera es \"${value}\"";

  static String m9(value) => "Ingrese una cantidad mayor que ${value}";

  static String m10(value) =>
      "¿Estás seguro de que deseas eliminar el contacto?";

  static String m11(value) => "No tienes suficiente \"${value}\"";

  static String m12(value) => "Error al obtener la cuenta\"${value}\" account";

  static String m13(value) =>
      "Mínimo ${value} XRP para la primera transferencia";

  static String m14(value) => "No se agregó ninguna cadena de ${value}";

  static String m15(value) =>
      "${value} tiene transacciones sin finalizar, inténtelo nuevamente más tarde.";

  static String m16(value) => "No se encontró ninguna dirección para ${value}.";

  static String m17(value) => "Saldo insuficiente de ${value}.";

  static String m18(value, value1) =>
      "Every XRP account must reserve ${value} XRP (${value1} drops) as a baseline, which cannot be spent.";

  static String m19(value, value1) =>
      "For every object the account owns, ${value} XRP (${value1} drops) is added to the reserve.";

  static String m20(value, value1) =>
      "This account owns ${value} objects, which means an additional ${value1} XRP is reserved.";

  static String m21(value) =>
      "Error al ingresar el patrón de contraseña, tienes ${value} posibilidades";

  static String m22(value) =>
      "Error al ingresar la contraseña del patrón, tiene ${value} posibilidades";

  static String m23(value) =>
      "Has configurado correctamente un ${value} y comenzarás a verificar con N42Wallet.";

  static String m24(value) =>
      "¡Únase a mi grupo ${value} en @N42Wallet para ser uno de los primeros mineros de una cadena de Capa 1 y obtenga criptomonedas en su teléfono!";

  static String m25(value) => "Bloquee ${value} N para ejecutar un validador.";

  static String m26(value) => "Error en la importación::${value}";

  static String m27(value, value1) =>
      "${value} N por cada ${value1} bloques minados";

  static String m28(value) => "Debe tener ${value} caracteres";

  static String m29(value) => "${value} Saldo insuficiente.";

  static String m30(value) => "${value} entrante...";

  static String m31(value) =>
      "El ${value} intercambiado en la aplicación se distribuirá en breve a tu Wallet y no se puede vender a través de este proceso. Se puede usar para ejecutar un nodo.";

  static String m32(value) => "Máximo ${value} caracteres";

  static String m33(value) => "¡La aplicación ${value} chain ya es compatible!";

  static String m34(value) =>
      "La aplicación ${value} chain ya es compatible, ¿quieres agregarla?";

  static String m35(value) =>
      "¡El enlace de prueba de dirección ${value} falló!";

  static String m36(value) =>
      "La aplicación se desbloqueará en ${value} segundos.";

  static String m37(value) =>
      "Error al ingresar la contraseña del patrón, tienes ${value} posibilidades";

  static String m38(value) =>
      "Error al ingresar la contraseña, tienes ${value} posibilidades";

  static String m39(value) =>
      "Error al ingresar la contraseña, tienes ${value} posibilidades";

  static String m40(value) => "Ingrese ${value} contraseña";

  static String m41(value) => "0~${value} caracteres";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Create_account": MessageLookupByLibrary.simpleMessage("Crear cuenta"),
    "Create_your_account": MessageLookupByLibrary.simpleMessage(
      "Cree su cuenta",
    ),
    "Edit": MessageLookupByLibrary.simpleMessage("Editar"),
    "Verification": MessageLookupByLibrary.simpleMessage("Verificación"),
    "address_Information": MessageLookupByLibrary.simpleMessage(
      "Información de dirección",
    ),
    "code_403": MessageLookupByLibrary.simpleMessage(
      "Cuenta bloqueada temporalmente por un día",
    ),
    "code_err_tips": MessageLookupByLibrary.simpleMessage(
      "El código es incorrecto. Inténtelo de nuevo.",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copiado exitosamente"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("Copiar dirección"),
    "descO": MessageLookupByLibrary.simpleMessage("Descripción (Opcional)"),
    "editPhoto": MessageLookupByLibrary.simpleMessage("Editar foto"),
    "email_code_error": MessageLookupByLibrary.simpleMessage(
      "Error al obtener el código de autenticación",
    ),
    "email_code_finish": MessageLookupByLibrary.simpleMessage(
      "Código de autenticación enviado exitosamente, por favor revisa tu correo electrónico",
    ),
    "email_code_input_error": MessageLookupByLibrary.simpleMessage(
      "Error del código de autenticación",
    ),
    "email_error": MessageLookupByLibrary.simpleMessage(
      "Dirección de correo electrónico no válida",
    ),
    "email_verification": MessageLookupByLibrary.simpleMessage(
      "Autenticación de dirección de correo electrónico",
    ),
    "email_verification_message1": MessageLookupByLibrary.simpleMessage(
      "La aplicación Email Address Authenticator protege tus retiros y tu cuenta de N42Wallet.",
    ),
    "email_verification_message2": MessageLookupByLibrary.simpleMessage(
      "¿Agregar verificación de correo electrónico?",
    ),
    "file": MessageLookupByLibrary.simpleMessage("Archivo"),
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
    "g_browser_key14": MessageLookupByLibrary.simpleMessage(
      "Confirma la conexión a la DApp",
    ),
    "g_browser_key16": MessageLookupByLibrary.simpleMessage("Cerrar todo"),
    "g_browser_key17": MessageLookupByLibrary.simpleMessage("Hecho"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("Marcadores"),
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
    "g_chat_key_1": MessageLookupByLibrary.simpleMessage("Iniciar chat grupal"),
    "g_chat_key_10": m0,
    "g_chat_key_11": MessageLookupByLibrary.simpleMessage("Invitar amigos"),
    "g_chat_key_12": MessageLookupByLibrary.simpleMessage(
      "Seleccionar contacto",
    ),
    "g_chat_key_13": MessageLookupByLibrary.simpleMessage("Finalizar"),
    "g_chat_key_14": MessageLookupByLibrary.simpleMessage(
      "Seleccione al menos 2 contactos",
    ),
    "g_chat_key_16": MessageLookupByLibrary.simpleMessage("Detalles del amigo"),
    "g_chat_key_17": MessageLookupByLibrary.simpleMessage(
      " Detalles del grupo",
    ),
    "g_chat_key_18": MessageLookupByLibrary.simpleMessage(
      "Ver más miembros del grupo",
    ),
    "g_chat_key_19": MessageLookupByLibrary.simpleMessage("Nombre del grupo"),
    "g_chat_key_2": MessageLookupByLibrary.simpleMessage("Nuevo amigo"),
    "g_chat_key_20": MessageLookupByLibrary.simpleMessage(
      "¿Estamos seguros de que nos vamos a disolver?",
    ),
    "g_chat_key_21": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que estás fuera del grupo?",
    ),
    "g_chat_key_22": MessageLookupByLibrary.simpleMessage("Desagrupar"),
    "g_chat_key_23": MessageLookupByLibrary.simpleMessage("Salir del grupo"),
    "g_chat_key_24": MessageLookupByLibrary.simpleMessage(
      "Cambiar el nombre del chat grupal",
    ),
    "g_chat_key_25": MessageLookupByLibrary.simpleMessage(
      "Cuando se cambia el nombre del chat grupal, se notificará a otros miembros dentro del grupo.",
    ),
    "g_chat_key_26": MessageLookupByLibrary.simpleMessage("Finalizar"),
    "g_chat_key_27": MessageLookupByLibrary.simpleMessage(
      "Solicitud de adición de amigo",
    ),
    "g_chat_key_28": MessageLookupByLibrary.simpleMessage(
      "Solicitud para agregarte como amigo",
    ),
    "g_chat_key_29": MessageLookupByLibrary.simpleMessage(
      "La solicitud de amistad fue exitosa",
    ),
    "g_chat_key_3": MessageLookupByLibrary.simpleMessage("Agregado"),
    "g_chat_key_30": MessageLookupByLibrary.simpleMessage(
      "Has sido agregado como amigo",
    ),
    "g_chat_key_31": MessageLookupByLibrary.simpleMessage("de acuerdo"),
    "g_chat_key_32": m1,
    "g_chat_key_33": MessageLookupByLibrary.simpleMessage(
      "La contraseña no se puede analizar correctamente y el mensaje no se puede enviar temporalmente. Importe la Wallet cuando ingrese al grupo",
    ),
    "g_chat_key_34": MessageLookupByLibrary.simpleMessage(
      "¿Eliminar el historial de chat?",
    ),
    "g_chat_key_35": MessageLookupByLibrary.simpleMessage("Eliminar miembro"),
    "g_chat_key_36": MessageLookupByLibrary.simpleMessage(
      "Tu enlace de mensajería",
    ),
    "g_chat_key_4": MessageLookupByLibrary.simpleMessage("Han caducado"),
    "g_chat_key_40": MessageLookupByLibrary.simpleMessage("Reportar"),
    "g_chat_key_41": MessageLookupByLibrary.simpleMessage("Nuevo chat"),
    "g_chat_key_42": MessageLookupByLibrary.simpleMessage("Nuevo grupo"),
    "g_chat_key_43": MessageLookupByLibrary.simpleMessage("Código QR"),
    "g_chat_key_44": MessageLookupByLibrary.simpleMessage(
      "Reportar y bloquear",
    ),
    "g_chat_key_45": MessageLookupByLibrary.simpleMessage(
      "Este mensaje será reenviado a N42Wallet. Este contacto no será notificado.",
    ),
    "g_chat_key_46": MessageLookupByLibrary.simpleMessage("Vídeo"),
    "g_chat_key_47": MessageLookupByLibrary.simpleMessage("Foto"),
    "g_chat_key_48": MessageLookupByLibrary.simpleMessage("Eliminar mensaje"),
    "g_chat_key_49": MessageLookupByLibrary.simpleMessage(
      " Eliminar en mi dispositivo ",
    ),
    "g_chat_key_5": MessageLookupByLibrary.simpleMessage("Espere"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("De acuerdo "),
    "g_chat_key_54": MessageLookupByLibrary.simpleMessage(
      " Motivo del informe ",
    ),
    "g_chat_key_55": MessageLookupByLibrary.simpleMessage(
      " Ingrese el motivo de su informe ",
    ),
    "g_chat_key_56": MessageLookupByLibrary.simpleMessage(
      " Verificaremos su informe y responderemos dentro de las 24 horas",
    ),
    "g_chat_key_57": MessageLookupByLibrary.simpleMessage(
      "Usted informó esto - Haga clic para ver",
    ),
    "g_chat_key_58": MessageLookupByLibrary.simpleMessage("Lista negra"),
    "g_chat_key_59": MessageLookupByLibrary.simpleMessage("Eliminar"),
    "g_chat_key_6": m2,
    "g_chat_key_60": MessageLookupByLibrary.simpleMessage(
      "Aún no hay contacto",
    ),
    "g_chat_key_61": MessageLookupByLibrary.simpleMessage("Hoy"),
    "g_chat_key_62": MessageLookupByLibrary.simpleMessage("Hace más de 3 días"),
    "g_chat_key_63": MessageLookupByLibrary.simpleMessage("Bloquear"),
    "g_chat_key_64": MessageLookupByLibrary.simpleMessage(
      "¡Hola!, estoy usando N42Wallet para chatear y enviar dinero. Instala N42Wallet y envíame un mensaje a",
    ),
    "g_chat_key_66": MessageLookupByLibrary.simpleMessage("Responder"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage(
      "El mensaje ha sido eliminado",
    ),
    "g_chat_key_68": MessageLookupByLibrary.simpleMessage("Alguien @ a mí"),
    "g_chat_key_69": MessageLookupByLibrary.simpleMessage("Saluda"),
    "g_chat_key_8": MessageLookupByLibrary.simpleMessage("Agregar amigos"),
    "g_chat_key_9": MessageLookupByLibrary.simpleMessage(
      "Motivo de la solicitud",
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
    "g_face_1": MessageLookupByLibrary.simpleMessage(
      "Consejos para el escaneo biométrico",
    ),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "Escanea tu huella digital o tu rostro para autenticación.",
    ),
    "g_face_2": MessageLookupByLibrary.simpleMessage(
      "El escaneo biométrico no funcionó",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("Consejos"),
    "g_face_4": MessageLookupByLibrary.simpleMessage(
      "Exito del escaneo biométrico",
    ),
    "g_face_5": MessageLookupByLibrary.simpleMessage("Para configurar"),
    "g_face_6": MessageLookupByLibrary.simpleMessage(
      "No has configurado el inicio de sesión biométrico. Ve a Configuración del sistema para configurarlo.",
    ),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "Escanea tu rostro o huella digital para continuar.",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("Regresar"),
    "g_face_9": MessageLookupByLibrary.simpleMessage(
      "Se recomienda volver a habilitar la biometría.",
    ),
    "g_face_match_key1": MessageLookupByLibrary.simpleMessage(
      "Método de coincidencia de caras",
    ),
    "g_face_match_key10": m3,
    "g_face_match_key11": m4,
    "g_face_match_key12": MessageLookupByLibrary.simpleMessage(
      "Volver a vincular",
    ),
    "g_face_match_key13": MessageLookupByLibrary.simpleMessage("Vincular"),
    "g_face_match_key14": MessageLookupByLibrary.simpleMessage("Verificar"),
    "g_face_match_key15": MessageLookupByLibrary.simpleMessage(
      "Puedes vincular tus datos faciales directamente a una dirección de billetera (si ya has vinculado una anteriormente, la dirección de billetera anterior será sobrescrita), o si ya has vinculado una dirección de billetera, también puedes verificar manualmente para recuperar la dirección de billetera vinculada.",
    ),
    "g_face_match_key16": MessageLookupByLibrary.simpleMessage(
      "La dirección de billetera vinculada a tus datos faciales ha sido detectada de la siguiente manera, pero aún no has importado esta billetera a tu lista de billeteras.",
    ),
    "g_face_match_key17": MessageLookupByLibrary.simpleMessage(
      "Has vinculado tus datos faciales con esta cartera.",
    ),
    "g_face_match_key18": MessageLookupByLibrary.simpleMessage(
      "Aviso para el Usuario",
    ),
    "g_face_match_key19": MessageLookupByLibrary.simpleMessage(
      "¿Qué es la Vinculación Facial?",
    ),
    "g_face_match_key20": MessageLookupByLibrary.simpleMessage(
      "La vinculación facial utiliza tecnología de reconocimiento facial para hacer coincidir tus características biométricas faciales con la dirección de tu billetera blockchain.",
    ),
    "g_face_match_key21": MessageLookupByLibrary.simpleMessage(
      "Este proceso no solo mejora la comodidad de las transacciones, sino que también refuerza la seguridad de la cuenta, asegurando que cada acción esté autorizada por ti.",
    ),
    "g_face_match_key22": MessageLookupByLibrary.simpleMessage(
      "¿Por qué es Necesaria la Vinculación Facial?",
    ),
    "g_face_match_key23": MessageLookupByLibrary.simpleMessage(
      "verificación de identidad y mejorando la eficiencia operativa. Esta tecnología garantiza una verificación rápida y segura de la identidad al realizar operaciones sensibles, como transferir activos o interactuar con contratos.",
    ),
    "g_face_match_key24": MessageLookupByLibrary.simpleMessage(
      "¿Cómo se Almacenan Mis Datos Faciales y Son Seguros?",
    ),
    "g_face_match_key25": MessageLookupByLibrary.simpleMessage(
      "Tus datos faciales se almacenan en una forma cifrada en una blockchain pública, no en ninguna base de datos centralizada. Esto significa que el sistema solo puede descifrar y utilizar tus datos para la verificación de identidad cuando está autorizado por ti, garantizando la privacidad y la seguridad de tus datos.",
    ),
    "g_face_match_key26": MessageLookupByLibrary.simpleMessage(
      "¿Cómo Afecta la Vinculación Facial la Seguridad de Mi Cuenta?",
    ),
    "g_face_match_key27": MessageLookupByLibrary.simpleMessage(
      "La vinculación facial mejora la seguridad de tu cuenta al asegurar que todas las acciones sensibles se realicen solo con tu autorización explícita. Utilizamos tecnología de cifrado líder en la industria para proteger tus datos biométricos, evitando accesos no autorizados.",
    ),
    "g_face_match_key28": MessageLookupByLibrary.simpleMessage(
      "¿Están Seguros Mis Datos Faciales?",
    ),
    "g_face_match_key29": MessageLookupByLibrary.simpleMessage(
      "Absolutamente. Todos los datos biométricos se someten a un estricto cifrado, y se siguen los más altos estándares de seguridad para la transmisión y almacenamiento de los datos. El sistema solo descifrará estos datos cuando sea necesario para completar la verificación de identidad.",
    ),
    "g_face_match_key3": MessageLookupByLibrary.simpleMessage(
      "¡La coincidencia falló!",
    ),
    "g_face_match_key30": MessageLookupByLibrary.simpleMessage("Entiendo"),
    "g_face_match_key31": MessageLookupByLibrary.simpleMessage(
      "Seleccionar la dirección de la billetera",
    ),
    "g_face_match_key32": m5,
    "g_face_match_key33": MessageLookupByLibrary.simpleMessage("Unbinding"),
    "g_face_match_key34": MessageLookupByLibrary.simpleMessage(
      "¡La verificación de datos faciales falló!",
    ),
    "g_face_match_key35": MessageLookupByLibrary.simpleMessage(
      "Fallo de desvinculación de datos de cara!",
    ),
    "g_face_match_key4": m6,
    "g_face_match_key5": MessageLookupByLibrary.simpleMessage(
      "¡Dirección incorrecta!",
    ),
    "g_face_match_key6": MessageLookupByLibrary.simpleMessage(
      "Vinculación de Datos Faciales",
    ),
    "g_face_match_key7": MessageLookupByLibrary.simpleMessage(
      "Coincidencia de caras",
    ),
    "g_face_match_key8": MessageLookupByLibrary.simpleMessage(
      "Volver a seleccionar",
    ),
    "g_face_match_key9": MessageLookupByLibrary.simpleMessage("coincidencia"),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("Perfil"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("Noticias"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("Verificación"),
    "g_home_key5": MessageLookupByLibrary.simpleMessage("Mensajes"),
    "g_home_key6": MessageLookupByLibrary.simpleMessage("Aprender"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("Invitar a un amigo"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("¡Error al eliminar!"),
    "g_key_100": MessageLookupByLibrary.simpleMessage("Enviar"),
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
    "g_key_154": MessageLookupByLibrary.simpleMessage("Enviar"),
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
    "g_key_205": MessageLookupByLibrary.simpleMessage(
      "No hay permiso para acceder al álbum de fotos.",
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
    "g_key_211": MessageLookupByLibrary.simpleMessage("Comprar"),
    "g_key_212": MessageLookupByLibrary.simpleMessage("Vender"),
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
    "g_key_8": MessageLookupByLibrary.simpleMessage("Observación"),
    "g_key_85": MessageLookupByLibrary.simpleMessage("Frase Semilla"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("Todos los tokens"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("Configuración"),
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
    "g_key_error_13": MessageLookupByLibrary.simpleMessage("Access denied"),
    "g_key_error_1301": MessageLookupByLibrary.simpleMessage(
      "Cuenta o contraseña incorrecta",
    ),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage("Acceso denegado"),
    "g_key_error_1403": MessageLookupByLibrary.simpleMessage(
      "Ya has iniciado sesión en otro teléfono y estás obligado a cerrar la sesión.",
    ),
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
    "g_key_feedback": MessageLookupByLibrary.simpleMessage("Comentarios"),
    "g_key_feedback_1": MessageLookupByLibrary.simpleMessage(
      "Por favor complete la información de comentarios",
    ),
    "g_key_feedback_2": MessageLookupByLibrary.simpleMessage(
      "Hay archivos adjuntos no cargados",
    ),
    "g_key_feedback_3": MessageLookupByLibrary.simpleMessage("Envío fallido"),
    "g_key_feedback_4": MessageLookupByLibrary.simpleMessage(
      "Enviado exitosamente",
    ),
    "g_key_feedback_5": MessageLookupByLibrary.simpleMessage("Apéndices"),
    "g_key_feedback_6": MessageLookupByLibrary.simpleMessage(
      "Sube hasta 5 archivos adjuntos, cada uno de los cuales no puede tener más de 100 MB",
    ),
    "g_key_feedback_7": MessageLookupByLibrary.simpleMessage("Error"),
    "g_key_feedback_8": MessageLookupByLibrary.simpleMessage(
      "Haz clic en intentar",
    ),
    "g_key_feedback_9": MessageLookupByLibrary.simpleMessage(
      "Por favor inicia sesión",
    ),
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
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("Facebook"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("Twitter"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("Reddit"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("Navegador"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("Telegram"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("Discord"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("Youtube"),
    "g_key_m_19": MessageLookupByLibrary.simpleMessage("Instagram"),
    "g_key_m_2": MessageLookupByLibrary.simpleMessage("Capacidad de mercado"),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("Volumen de operaciones"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("Suministro total"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("En circulación"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("Acerca de"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("Más"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("Enlaces"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("Sitio Web"),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage(
      "Por favor, introduzca la frase semilla",
    ),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("Total"),
    "g_key_nft_16": MessageLookupByLibrary.simpleMessage("Cámara"),
    "g_key_nft_17": MessageLookupByLibrary.simpleMessage("Seleccionar foto"),
    "g_key_nft_18": MessageLookupByLibrary.simpleMessage("Contenido"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Nombre"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Volver"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage("Transacción enviada"),
    "g_key_nft_47": MessageLookupByLibrary.simpleMessage("Seleccionar vídeo"),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
      "Seleccionar de la galería del teléfono",
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
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Chat"),
    "g_key_squad_k11": MessageLookupByLibrary.simpleMessage(
      "El archivo es demasiado grande para cargarlo",
    ),
    "g_key_squad_k15": m10,
    "g_key_squad_k18": MessageLookupByLibrary.simpleMessage("Agregar contacto"),
    "g_key_squad_k24": MessageLookupByLibrary.simpleMessage("Contacto"),
    "g_key_squad_k25": MessageLookupByLibrary.simpleMessage(
      "Buscar por correo electrónico",
    ),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Completado"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Precio del gas"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("Tarifa máxima de gas"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage("Tarifa máxima por gas"),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("Pendiente"),
    "g_key_t_29": m11,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("Error"),
    "g_key_t_30": MessageLookupByLibrary.simpleMessage("arifa de minero"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("Continuar"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage(
      "Contraseña de la Wallet",
    ),
    "g_key_t_33": MessageLookupByLibrary.simpleMessage(
      "La contraseña de la Wallet no puede estar vacía",
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
    "g_key_t_45": m12,
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
    "g_key_t_52": m13,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "La dirección de recepción no tiene una cuenta y la primera transferencia es de al menos 10XRP",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Gas usado"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Gas"),
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage("Transaction history"),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage("Transaction Detail"),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage(
      "Por favor, vea los recibos de transacciones en el historial",
    ),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage("Monto gastado"),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage("Obtener monto"),
    "g_key_u_10": MessageLookupByLibrary.simpleMessage("Tipos de NFT"),
    "g_key_u_11": MessageLookupByLibrary.simpleMessage("Seguidores"),
    "g_key_u_12": MessageLookupByLibrary.simpleMessage("Tipos de usuario"),
    "g_key_u_13": MessageLookupByLibrary.simpleMessage("Sitio Web"),
    "g_key_u_14": MessageLookupByLibrary.simpleMessage("Enlace de productos"),
    "g_key_u_15": MessageLookupByLibrary.simpleMessage("Plataformas de medios"),
    "g_key_u_16": MessageLookupByLibrary.simpleMessage("Dirección de Wallet"),
    "g_key_u_2": MessageLookupByLibrary.simpleMessage("Apodo"),
    "g_key_u_23": MessageLookupByLibrary.simpleMessage(
      "Falló la carga del avatar",
    ),
    "g_key_u_3": MessageLookupByLibrary.simpleMessage("Descripción"),
    "g_key_u_5": MessageLookupByLibrary.simpleMessage(
      "Información del artista",
    ),
    "g_key_u_6": MessageLookupByLibrary.simpleMessage("No eres un artista aún"),
    "g_key_u_7": MessageLookupByLibrary.simpleMessage(
      "Haz clic aquí para postularte y convertirte en artista",
    ),
    "g_key_u_8": MessageLookupByLibrary.simpleMessage("Nombre"),
    "g_key_u_9": MessageLookupByLibrary.simpleMessage("Ingresos"),
    "g_key_user_p1": MessageLookupByLibrary.simpleMessage("He leído y acepto "),
    "g_key_user_p2": MessageLookupByLibrary.simpleMessage(
      "Términos de servicio",
    ),
    "g_key_user_p3": MessageLookupByLibrary.simpleMessage(
      "Política de privacidad",
    ),
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
    "g_key_wallet_c11": MessageLookupByLibrary.simpleMessage(
      "Asegúrese de registrar su frase inicial y almacenarla de forma segura.",
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
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage("Nonce"),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("Acelerar"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("Nota"),
    "g_key_wallet_m1": m14,
    "g_key_wallet_m11": MessageLookupByLibrary.simpleMessage(
      "¿Estás seguro de que deseas cancelar tu cuenta?",
    ),
    "g_key_wallet_m13": MessageLookupByLibrary.simpleMessage(
      "Confirmar cierre de sesión",
    ),
    "g_key_wallet_m17": MessageLookupByLibrary.simpleMessage(
      "Ingrese el código de verificación de Google.",
    ),
    "g_key_wallet_m19": m15,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "El token actual no ha sido agregado.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Ingresa tu frase semilla con palabras separadas por espacios",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage("Importar Wallet"),
    "g_key_wallet_m3": m16,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "El saldo actual de tokens es insuficiente.",
    ),
    "g_key_wallet_m5": m17,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage("Error de firma"),
    "g_key_wallet_m8": MessageLookupByLibrary.simpleMessage(
      "Cancelación de cuenta",
    ),
    "g_key_wallet_m9": MessageLookupByLibrary.simpleMessage(
      "Ingrese el código de verificación de correo electrónico.",
    ),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage(
      "Administrar Wallet",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("Reserved"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("Base Reserve"),
    "g_key_xml_11": m18,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("Incremental Reserve"),
    "g_key_xml_22": m19,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage("Owned Objects Count"),
    "g_key_xml_33": m20,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage(
      "How to calculate total reserved amount",
    ),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "Total Reserve = Base Reserve + (Owned Objects Count × Incremental Reserve)",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch ID y Face ID"),
    "g_lock_key10": MessageLookupByLibrary.simpleMessage("Contraseña actual"),
    "g_lock_key11": MessageLookupByLibrary.simpleMessage("Nueva contraseña"),
    "g_lock_key12": MessageLookupByLibrary.simpleMessage(
      "Confirmar nueva contraseña",
    ),
    "g_lock_key13": MessageLookupByLibrary.simpleMessage("Número de 6 dígitos"),
    "g_lock_key15": MessageLookupByLibrary.simpleMessage(
      "Contraseñas y datos biométricos",
    ),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage(
      "Patrón de contraseña",
    ),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage(
      "Establecer contraseña de patrón",
    ),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "Para la seguridad de tu cuenta, establece una contraseña de grupo",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage(
      "Contraseña del patrón de dibujo secundario",
    ),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage(
      "Contraseña del patrón de dibujo",
    ),
    "g_lock_key21": m21,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Restablecer la contraseña del patrón",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Demasiadas entradas incorrectas, restablezca la contraseña",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "¿Agregar contraseña de billetera?",
    ),
    "g_lock_key25": m22,
    "g_lock_key3": MessageLookupByLibrary.simpleMessage(
      "Página de pantalla de bloqueo",
    ),
    "g_lock_key4": MessageLookupByLibrary.simpleMessage("Bloqueo automático"),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("Exitoso"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("Error"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage(
      "El reconocimiento biométrico no está habilitado",
    ),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage(
      "¿Agregar verificación biométrica?",
    ),
    "g_lock_key9": MessageLookupByLibrary.simpleMessage(
      "Restablecer contraseña",
    ),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("¿Desbloquear N?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage(
      "Registro de actividad de verificación en la nube",
    ),
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
    "g_mining_key63": m23,
    "g_mining_key73": m24,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "Acabo de configurar un nodo en @N42aWallet y comencé a verificar en dispositivos móviles. ¡Únete a mí! ¡El futuro descentralizado es móvil!",
    ),
    "g_mining_key76": m25,
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "Canje disponible después de los 768.",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "Las solicitudes anteriores no se procesarán.",
    ),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage(
      "La recompensa de hoy",
    ),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "Trate los datos a continuación como una llave importante. Le recomendamos copiarlos y guardarlos de inmediato en un lugar de confianza.",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage("Copiar datos"),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("Inactivo"),
    "g_mining_key_103": MessageLookupByLibrary.simpleMessage(
      "Lista de validadores",
    ),
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
    "g_mining_key_109": m26,
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
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "La recompensa se acumula diariamente y solo se envía a tu Wallet N cuando alcanza ~0.5 N.",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage(
      "Recompensas totales",
    ),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("Valor extraído"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage(
      "Calculado en base al precio de mercado de N * las recompensas totales de N.",
    ),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage(
      "Recuento de validación",
    ),
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
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Desactivado"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("Ver más"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage(
      "Estado de verificación",
    ),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Bloquea los N para comenzar a extraer recompensas.",
    ),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Entrada"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("Nodo Avanzado"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("Nodo De Entrada"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Nodo Pro"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 bloques/día ~ 70 minutos",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage(
      "Seleccione un plan",
    ),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 bloques/día ~ 15 minutos",
    ),
    "g_mining_key_71": m27,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage(
      "128 segundos por verificación",
    ),
    "g_mining_key_73": MessageLookupByLibrary.simpleMessage(
      "Verificación en la nube iniciada",
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
      "Riesgo moderadamente bajo",
    ),
    "g_mining_key_86": MessageLookupByLibrary.simpleMessage(
      "Riesgo moderadamente alto",
    ),
    "g_mining_key_87": MessageLookupByLibrary.simpleMessage("High Risk"),
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
    "g_mining_key_98": m28,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "Vuelve a introducir tu contraseña para asegurarte de que es correcta",
    ),
    "g_notification_key_1": MessageLookupByLibrary.simpleMessage(
      "Notificaciones",
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
    "g_swap_key_14": m29,
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
    "g_swap_key_20": m30,
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
    "g_swap_key_31": m31,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "Los swaps se pueden ver en los exploradores de cadena relevantes (Etherscan, BscScan, TRONSCAN y el nuestro).",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Cambiar a N"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("Swap"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("Obtienes"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage(
      "Intercambio de vista previa",
    ),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("Inténtalo de nuevo"),
    "g_token_m_key_1": m32,
    "g_token_m_key_10": MessageLookupByLibrary.simpleMessage(
      "Cualquiera puede crear un token, incluso crear versiones falsas de tokens existentes. Siempre investigue un token antes de importarlo.",
    ),
    "g_token_m_key_11": MessageLookupByLibrary.simpleMessage("Tokens"),
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
    "g_token_m_key_16": MessageLookupByLibrary.simpleMessage("Decimal"),
    "g_token_m_key_17": MessageLookupByLibrary.simpleMessage("RPC"),
    "g_token_m_key_18": MessageLookupByLibrary.simpleMessage("API"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage(
      "Añadir cadena personalizada",
    ),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18 unidades"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("Agregar tokens"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage(
      "¡Error de formato!",
    ),
    "g_token_m_key_22": m33,
    "g_token_m_key_23": m34,
    "g_token_m_key_24": m35,
    "g_token_m_key_3": MessageLookupByLibrary.simpleMessage("Importar tokens"),
    "g_token_m_key_4": MessageLookupByLibrary.simpleMessage("Todas las redes"),
    "g_token_m_key_5": MessageLookupByLibrary.simpleMessage(
      "Token personalizado",
    ),
    "g_token_m_key_6": MessageLookupByLibrary.simpleMessage(
      "Dirección del token",
    ),
    "g_token_m_key_7": MessageLookupByLibrary.simpleMessage("Símbolo de ficha"),
    "g_token_m_key_8": MessageLookupByLibrary.simpleMessage("Token decimal"),
    "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("Importar"),
    "g_unlock_key10": m36,
    "g_unlock_key2": MessageLookupByLibrary.simpleMessage(
      "El reconocimiento de huellas dactilares o facial no está habilitado. Inicie sesión.",
    ),
    "g_unlock_key3": MessageLookupByLibrary.simpleMessage(
      "Contraseña del patrón de dibujo",
    ),
    "g_unlock_key4": m37,
    "g_unlock_key5": MessageLookupByLibrary.simpleMessage(
      "Ingrese la contraseña",
    ),
    "g_unlock_key6": m38,
    "g_unlock_key7": MessageLookupByLibrary.simpleMessage(
      "Error de autenticación",
    ),
    "g_unlock_key8": m39,
    "g_unlock_key9": MessageLookupByLibrary.simpleMessage("También puedes "),
    "google_verification": MessageLookupByLibrary.simpleMessage(
      "Autenticación de Google",
    ),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "Enlace",
    ),
    "google_verification_message11": MessageLookupByLibrary.simpleMessage(
      "Descargar autenticación de Google",
    ),
    "google_verification_message12": MessageLookupByLibrary.simpleMessage(
      "Instrucciones",
    ),
    "google_verification_message13": MessageLookupByLibrary.simpleMessage(
      "Abre Google Authenticator.",
    ),
    "google_verification_message14": MessageLookupByLibrary.simpleMessage(
      "Verás un código de verificación de 6 dígitos en la pantalla.",
    ),
    "google_verification_message15": MessageLookupByLibrary.simpleMessage(
      "Copia el código de 6 dígitos y pégalo en N42Wallet.",
    ),
    "google_verification_message16": MessageLookupByLibrary.simpleMessage(
      "Entonces, su Autenticador se vinculará exitosamente.",
    ),
    "google_verification_message17": MessageLookupByLibrary.simpleMessage(
      "Clave de respaldo",
    ),
    "google_verification_message18": MessageLookupByLibrary.simpleMessage(
      "Copia la clave de autenticación de Google",
    ),
    "google_verification_message19": MessageLookupByLibrary.simpleMessage(
      "Ingresa el código de verificación de Google",
    ),
    "google_verification_message20": MessageLookupByLibrary.simpleMessage(
      "Ingrese el código de verificación de correo electrónico",
    ),
    "google_verification_message21": m40,
    "google_verification_message3": MessageLookupByLibrary.simpleMessage(
      "Error al obtener la clave de Google",
    ),
    "google_verification_message5": MessageLookupByLibrary.simpleMessage(
      "Autenticación de dos factores (2FA)",
    ),
    "google_verification_message6": MessageLookupByLibrary.simpleMessage(
      "Para proteger su cuenta, se recomienda activar al menos una 2FA.",
    ),
    "google_verification_message7": MessageLookupByLibrary.simpleMessage(
      "La aplicación Google Authenticator protege tus retiros y tu cuenta de N42Wallet.",
    ),
    "google_verification_message8": MessageLookupByLibrary.simpleMessage(
      "Descargar e instalar",
    ),
    "google_verification_message9": MessageLookupByLibrary.simpleMessage(
      "Descargue e instale Google Authenticator. Luego presione \'Vincular\' para vincular su cuenta N42Wallet.",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage("Aviso Importante"),
    "login_button_text": MessageLookupByLibrary.simpleMessage("Iniciar sesión"),
    "login_email": MessageLookupByLibrary.simpleMessage("Correo electrónico"),
    "login_forgot_password": MessageLookupByLibrary.simpleMessage(
      "¿Olvidaste tu contraseña?",
    ),
    "login_invite_code": MessageLookupByLibrary.simpleMessage(
      "Código de referencia",
    ),
    "login_invite_code_title": MessageLookupByLibrary.simpleMessage(
      "Código de referencia",
    ),
    "login_message_1": MessageLookupByLibrary.simpleMessage(
      "¿No tienes una cuenta?",
    ),
    "login_message_10": MessageLookupByLibrary.simpleMessage(
      "Creado correctamente",
    ),
    "login_message_11": MessageLookupByLibrary.simpleMessage(
      "Restablecer correctamente",
    ),
    "login_message_2": MessageLookupByLibrary.simpleMessage(
      "¿Ya tienes una cuenta?",
    ),
    "login_message_6": MessageLookupByLibrary.simpleMessage(
      "Reenviar código en ",
    ),
    "login_message_7": MessageLookupByLibrary.simpleMessage(
      "Código enviado con éxito",
    ),
    "login_message_8": MessageLookupByLibrary.simpleMessage(
      "Correo electrónico no registrado",
    ),
    "login_message_9": MessageLookupByLibrary.simpleMessage(
      "Error al enviar el código",
    ),
    "login_need_login": MessageLookupByLibrary.simpleMessage(
      "Inicie sesión primero",
    ),
    "login_password": MessageLookupByLibrary.simpleMessage("Contraseña"),
    "next": MessageLookupByLibrary.simpleMessage("Siguiente"),
    "nicknameMessage": m41,
    "password_diff": MessageLookupByLibrary.simpleMessage(
      "Las contraseñas no coinciden",
    ),
    "personalInformation": MessageLookupByLibrary.simpleMessage(
      "Editar perfil",
    ),
    "photograph": MessageLookupByLibrary.simpleMessage("Fotografía"),
    "please_enter_code": MessageLookupByLibrary.simpleMessage(
      "Ingrese el código de verificación",
    ),
    "please_enter_email": MessageLookupByLibrary.simpleMessage(
      "Por favor ingresa el correo electrónico",
    ),
    "please_enter_password": MessageLookupByLibrary.simpleMessage(
      "Por favor ingresa la contraseña",
    ),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "Por favor ingrese la dirección",
    ),
    "repeatPassword": MessageLookupByLibrary.simpleMessage(
      "Repita la contraseña",
    ),
    "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
      "Choose password(8~18 characters)",
    ),
    "rest_Confirm_password": MessageLookupByLibrary.simpleMessage(
      "Confirmar contraseña",
    ),
    "rest_Enter_the_password_again": MessageLookupByLibrary.simpleMessage(
      "Ingrese la contraseña nuevamente",
    ),
    "rest_Please_enter": MessageLookupByLibrary.simpleMessage(
      "Ingres el código",
    ),
    "rest_Verification_code": MessageLookupByLibrary.simpleMessage(
      "Código OTP",
    ),
    "rest_your_password": MessageLookupByLibrary.simpleMessage(
      "Restablecer su contraseña",
    ),
    "s_key_1": MessageLookupByLibrary.simpleMessage("Gestionar Cartera"),
    "s_key_10": MessageLookupByLibrary.simpleMessage("Acerca de la App"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("Seguridad"),
    "s_key_2": MessageLookupByLibrary.simpleMessage("Direcciones de Cartera"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("Transaction"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("Idioma"),
    "s_key_5": MessageLookupByLibrary.simpleMessage("Tema"),
    "search": MessageLookupByLibrary.simpleMessage("Buscar"),
    "selected_user_protocol": MessageLookupByLibrary.simpleMessage(
      "Por favor lea el acuerdo y confirme",
    ),
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

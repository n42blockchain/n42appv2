// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SEs extends S {
  SEs([String locale = 'es']) : super(locale);

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonUnknownUser => 'Usuario desconocido';

  @override
  String get transferWalletNotConnected => 'Billetera no conectada';

  @override
  String get chatCallServiceNotInitialized =>
      'Servicio de llamadas no inicializado';

  @override
  String authLoginFailed(String error) {
    return 'Error de inicio de sesion: $error';
  }

  @override
  String get chatCallBack => 'Devolver llamada';

  @override
  String get chatMissedVideoCall => 'Videollamada perdida';

  @override
  String get chatMissedVoiceCall => 'Llamada de voz perdida';

  @override
  String get chatCallNotAnswered => 'No contestada';

  @override
  String get chatCallDurationLabel => 'Duración de la llamada';

  @override
  String get chatVoiceCallCancelled => 'Llamada de voz cancelada';

  @override
  String get chatVideoCallCancelled => 'Videollamada cancelada';

  @override
  String get commonImage => '[Imagen]';

  @override
  String get chatVideo => '[Vídeo]';

  @override
  String get chatVoice => '[Voz]';

  @override
  String get commonFile => '[Archivo]';

  @override
  String get chatLocation => '[Ubicacion]';

  @override
  String get chatUnknownMessage => '[Mensaje desconocido]';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get chatDeleteThisMessage => '¿Eliminar este mensaje?';

  @override
  String get chatMessageDeleted => 'Mensaje eliminado';

  @override
  String get profileNotLoggedIn => 'No has iniciado sesion';

  @override
  String get chatMyLocation => 'Mi ubicacion';

  @override
  String get commonGroupChat => 'Chat grupal';

  @override
  String get commonSearch => 'Buscar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonLoadFailed => 'Error al cargar';

  @override
  String get commonMessages => 'Mensajes';

  @override
  String get commonContacts => 'Contactos';

  @override
  String get commonMe => 'Yo';

  @override
  String get commonVoiceLoading => 'Cargando audio, intenta de nuevo mas tarde';

  @override
  String get commonVoiceToTextFailed => 'Error al convertir voz a texto';

  @override
  String get commonConvertToText => 'A texto';

  @override
  String get chatCopy => 'Copiar';

  @override
  String get commonForward => 'Reenviar';

  @override
  String get commonUnfavorite => 'Quitar de favoritos';

  @override
  String get commonFavorite => 'Favorito';

  @override
  String get settingsResend => 'Reenviar';

  @override
  String get chatRecall => 'Retirar';

  @override
  String get commonQuote => 'Citar';

  @override
  String get commonRemind => 'Recordar';

  @override
  String get chatCopied => 'Copiado';

  @override
  String get storySendMessageHint => 'Enviar un mensaje';

  @override
  String get commonMicrophonePermissionRequired =>
      'Por favor permite el acceso al microfono';

  @override
  String get chatMicrophonePermissionDeniedPermanent =>
      'Se ha denegado el permiso del micrófono. Habilítelo en la configuración del sistema para usar mensajes de voz.';

  @override
  String commonStartRecordingFailed(String error) {
    return 'Error al iniciar grabacion: $error';
  }

  @override
  String get commonRecordingTooShort => 'Grabacion muy corta';

  @override
  String commonStopRecordingFailed(String error) {
    return 'Error al detener grabacion: $error';
  }

  @override
  String get chatReleaseToCancel => 'Suelta para cancelar';

  @override
  String get chatReleaseToSend =>
      'Suelta para enviar, desliza hacia arriba para cancelar';

  @override
  String get commonHoldToTalk => 'Manten presionado para hablar';

  @override
  String get commonSend => 'Enviar';

  @override
  String get commonAddFriend => 'Agregar amigo';

  @override
  String get commonChatServiceNotConnected => 'Servicio de chat no conectado';

  @override
  String contactUserNotFoundHint(String query) {
    return 'Usuario \"$query\" no encontrado\n\nSugerencias:\n- Intenta ingresar el ID completo, ej. @usuario:servidor.com\n- Verifica la ortografia del nombre de usuario';
  }

  @override
  String contactCreateChatFailed(String error) {
    return 'Error al crear chat: $error';
  }

  @override
  String contactSearchFailed(String error) {
    return 'Error en la busqueda: $error';
  }

  @override
  String get contactEnterUserIdOrUsername =>
      'Ingresa ID de usuario o nombre para buscar';

  @override
  String get contactSearching => 'Buscando...';

  @override
  String get contactSearchUserToChat => 'Busca un usuario para iniciar un chat';

  @override
  String get contactMatrixIdExample =>
      'Puedes ingresar un ID de Matrix completo\nej. @usuario:matrix.n42.network';

  @override
  String contactUserNotFound(String username) {
    return 'Usuario \"$username\" no encontrado';
  }

  @override
  String get commonChat => 'Charla';

  @override
  String get commonSettings => 'Configuracion';

  @override
  String get profileEditProfile => 'Editar perfil';

  @override
  String get authLogin => 'Iniciar sesion';

  @override
  String get commonCreateGroup => 'Crear grupo';

  @override
  String get chatError => 'error';

  @override
  String get commonTransfer => 'Transferir';

  @override
  String get commonReceived => 'Recibido';

  @override
  String get commonRefunded => 'Reembolsado';

  @override
  String get commonExpired => 'Expirado';

  @override
  String get chatRedPacketGreeting => 'Mejores deseos';

  @override
  String get commonN42RedPacket => 'Sobre rojo N42';

  @override
  String get commonClaimed => 'Reclamado';

  @override
  String get commonAllClaimed => 'Todo reclamado';

  @override
  String get chatReadAloud => 'Leer en voz alta';

  @override
  String get chatReply => 'Responder';

  @override
  String get commonEdit => 'Editar';

  @override
  String get chatSelectForwardTarget => 'Seleccionar destinatario';

  @override
  String commonSendCount(int count) {
    return 'Enviar ($count)';
  }

  @override
  String contactN42Id(String id) {
    return 'ID N42: $id';
  }

  @override
  String get profileN42IdTitle => 'ID N42';

  @override
  String get profileN42Bean => 'Frijol N42';

  @override
  String get contactFriendInfo => 'Info del amigo';

  @override
  String get contactFriendInfoDesc =>
      'Agrega notas, telefono, etiquetas, anotaciones, fotos y configura permisos.';

  @override
  String get commonMoments => 'Momentos';

  @override
  String get commonSendMessage => 'Mensaje';

  @override
  String get contactAudioVideoCall => 'Llamada de audio/video';

  @override
  String get contactVideoChannel => 'Canal de video';

  @override
  String get contactRemark => 'Nota';

  @override
  String get contactRemarkName => 'Nombre de nota';

  @override
  String get contactPhone => 'Telefono';

  @override
  String get contactTags => 'Etiquetas';

  @override
  String get contactNotes => 'Notas';

  @override
  String get contactPhotos => 'Fotos';

  @override
  String get contactPermissions => 'Permisos';

  @override
  String get contactChatMomentsEtc => 'Chat, Momentos, Deportes, etc.';

  @override
  String get contactMoreInfo => 'Mas informacion';

  @override
  String get contactCommonGroups => 'Grupos en comun';

  @override
  String get contactSource => 'Origen';

  @override
  String get settingsNotificationSettings => 'Notificaciones';

  @override
  String get settingsPrivacy => 'Privacidad';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get commonLogout => 'Cerrar sesion';

  @override
  String get commonLogoutConfirm =>
      'Estas seguro de que quieres cerrar sesion?';

  @override
  String get commonSave => 'Guardar';

  @override
  String get profileNickname => 'Apodo';

  @override
  String get profileEnterNickname => 'Ingresa apodo';

  @override
  String get profileSignature => 'Firma';

  @override
  String get profileAddSignature => 'Agregar una firma';

  @override
  String get commonTakePhoto => 'Tomar foto';

  @override
  String get profileChooseFromGallery => 'Elegir de la galeria';

  @override
  String profileSaveFailed(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String get authSecureDecentralizedChat =>
      'Mensajeria segura y descentralizada';

  @override
  String get commonEndToEndEncryption => 'Cifrado de extremo a extremo';

  @override
  String get authMessagesOnlyYouCanSee =>
      'Mensajes visibles solo para ti y el destinatario';

  @override
  String get authDecentralized => 'Descentralizado';

  @override
  String get authBasedOnMatrix => 'Basado en el protocolo abierto Matrix';

  @override
  String get authWalletIntegration => 'Integracion de billetera';

  @override
  String get authEasyCryptoTransfer =>
      'Transferencias de criptomonedas faciles';

  @override
  String get authRegister => 'Registrarse';

  @override
  String get authAgreeTerms => 'Al iniciar sesion, aceptas';

  @override
  String get authTermsOfService => 'Terminos de servicio';

  @override
  String get authAnd => ' y ';

  @override
  String get authPrivacyPolicy => 'Politica de privacidad';

  @override
  String get authServerAddress => 'Direccion del servidor';

  @override
  String get authEnterServerAddress => 'Ingresa direccion del servidor';

  @override
  String authConnectedTo(String serverName) {
    return 'Conectado a $serverName';
  }

  @override
  String get authUsername => 'Nombre de usuario';

  @override
  String get authEnterUsername => 'Ingresa nombre de usuario';

  @override
  String get authUsernameOrEmail => 'Usuario o Email';

  @override
  String get authEnterUsernameOrEmail => 'Ingresa usuario o email';

  @override
  String get authPassword => 'Contrasena';

  @override
  String get authEnterPassword => 'Ingresa contrasena';

  @override
  String get authRegisterAccount => 'Registrarse';

  @override
  String get authForgotPassword => 'Olvide mi contrasena';

  @override
  String get authOtherLoginMethods => 'Otros metodos de inicio de sesion';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authJoinN42Chat => 'Unete a N42 Chat para comenzar a chatear';

  @override
  String get authUsernameHint => '3-20 caracteres, letras/numeros/_';

  @override
  String get authUsernameMinLength =>
      'El nombre de usuario debe tener al menos 3 caracteres';

  @override
  String get authUsernameMaxLength =>
      'El nombre de usuario debe tener maximo 20 caracteres';

  @override
  String get authUsernameFormat =>
      'El nombre de usuario solo puede contener letras, numeros y guiones bajos';

  @override
  String get authPasswordHint => 'Minimo 8 caracteres';

  @override
  String get commonPasswordMinLength =>
      'La contrasena debe tener al menos 8 caracteres';

  @override
  String get authConfirmPassword => 'Confirmar contrasena';

  @override
  String get authFilled => 'Completado';

  @override
  String get authEnterInviteCode => 'Ingresa codigo de invitacion';

  @override
  String get authAlreadyHaveAccount => 'Ya tienes una cuenta?';

  @override
  String get authLoginNow => 'Iniciar sesion ahora';

  @override
  String get profileAvatar => 'avatar';

  @override
  String get profileStatus => 'Estado';

  @override
  String get commonLoading => 'Cargando...';

  @override
  String get conversationNoConversations => 'Sin conversaciones';

  @override
  String get conversationTapToChat =>
      'Toca arriba a la derecha para iniciar un chat';

  @override
  String get conversationStartGroup => 'Iniciar chat grupal';

  @override
  String get commonScan => 'Escanear';

  @override
  String get commonPayment => 'Pago';

  @override
  String commonFeatureComingSoon(String feature) {
    return '$feature proximamente';
  }

  @override
  String get conversationMarkAsRead => 'Marcar como leido';

  @override
  String get commonUnmute => 'Activar sonido';

  @override
  String get commonMute => 'Silenciar';

  @override
  String get conversationUnpin => 'Desanclar';

  @override
  String get conversationPin => 'Anclar';

  @override
  String get conversationDeleteConversation => 'Eliminar conversacion';

  @override
  String conversationDeleteConversationConfirm(String name) {
    return 'Eliminar conversacion con \"$name\"?';
  }

  @override
  String get commonNoContacts => 'Sin contactos';

  @override
  String get contactAddFriendsToChat => 'Agrega amigos para comenzar a chatear';

  @override
  String get contactNotFound => 'Contacto no encontrado';

  @override
  String get contactTryOtherKeywords =>
      'Intenta con otras palabras clave o busqueda global';

  @override
  String get contactSearchResults => 'Resultados de busqueda';

  @override
  String get contactNewFriends => 'Nuevos amigos';

  @override
  String get contactChatOnlyFriends => 'Amigos solo de chat';

  @override
  String get contactOfficialAccounts => 'Cuentas oficiales';

  @override
  String get contactServiceAccounts => 'Cuentas de servicio';

  @override
  String get contactEnterpriseContacts => 'Contactos empresariales';

  @override
  String get contactRecommendToFriend => 'Compartir contacto';

  @override
  String get commonSetRemark => 'Establecer nota';

  @override
  String get contactSendingCard => 'Enviando tarjeta de contacto...';

  @override
  String get commonFileLabel => 'Archivo';

  @override
  String get commonLocationLabel => 'Ubicacion';

  @override
  String contactRecommendFailed(String error) {
    return 'Error al recomendar: $error';
  }

  @override
  String get profileEnterRemark => 'Ingresa nota';

  @override
  String get contactOpeningChat => 'Abriendo chat...';

  @override
  String contactOpenChatFailed(String error) {
    return 'Error al abrir chat: $error';
  }

  @override
  String get contactAddContact => 'Agregar contacto';

  @override
  String get contactEnterUserId => 'Ingresa ID de usuario';

  @override
  String get contactNoFriendRequests => 'Sin solicitudes de amistad';

  @override
  String get commonAccept => 'Aceptar';

  @override
  String get commonReject => 'Rechazar';

  @override
  String get commonNoGroups => 'Sin grupos';

  @override
  String get contactSelectFriendToRecommend =>
      'Selecciona un amigo para recomendar';

  @override
  String get commonSearchContacts => 'Buscar contactos';

  @override
  String get contactNoContactsFound => 'No se encontraron contactos';

  @override
  String get favoriteYesterday => 'Ayer';

  @override
  String get chatJustNow => 'Ahora';

  @override
  String get profileOnline => 'En linea';

  @override
  String get profileOffline => 'Desconectado';

  @override
  String get searchContactsGroupsMessages =>
      'Buscar contactos, grupos, mensajes';

  @override
  String get searchError => 'Error de busqueda';

  @override
  String get chatSearchHint => 'Buscar contactos, grupos y mensajes';

  @override
  String get searchHistory => 'Historial de busqueda';

  @override
  String get commonClear => 'Limpiar';

  @override
  String get commonAll => 'Todo';

  @override
  String get searchGroups => 'Grupos';

  @override
  String get searchNoResults => 'Sin resultados';

  @override
  String commonGroupMembers(int count) {
    return 'Miembros ($count)';
  }

  @override
  String get groupMembersTitle => 'Miembros del grupo';

  @override
  String get groupViewAll => 'Ver todo';

  @override
  String get groupOwner => 'Propietario';

  @override
  String get groupAdmin => 'administrador';

  @override
  String get groupInvite => 'Invitar';

  @override
  String get commonGroupAnnouncement => 'Anuncio del grupo';

  @override
  String get commonNotSet => 'No establecido';

  @override
  String get groupDescription => 'Descripcion del grupo';

  @override
  String get groupPublicGroup => 'Grupo publico';

  @override
  String get commonClearChatHistory => 'Borrar historial de chat';

  @override
  String get commonDissolveGroup => 'Disolver grupo';

  @override
  String get commonLeaveGroup => 'Salir del grupo';

  @override
  String get groupChangeGroupName => 'Cambiar nombre del grupo';

  @override
  String get commonEnterGroupName => 'Ingresa nombre del grupo';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get groupEnterGroupDescription => 'Ingresa descripcion del grupo';

  @override
  String get groupPublish => 'Publicar';

  @override
  String get chatClearHistoryConfirm =>
      'Borrar todo el historial de chat? Esto no se puede deshacer.';

  @override
  String get chatClearAction => 'Borrar';

  @override
  String get commonChatHistoryCleared => 'Historial de chat borrado';

  @override
  String get commonDissolve => 'Disolver';

  @override
  String get groupQrCode => 'Codigo QR del grupo';

  @override
  String get commonSearchChatHistory => 'Buscar historial de chat';

  @override
  String get groupIdCopied => 'ID del grupo copiado';

  @override
  String get transferEnterOrPasteAddress =>
      'Ingresa o pega direccion de billetera';

  @override
  String get transferSelectToken => 'Seleccionar token';

  @override
  String get commonTransferAmount => 'Monto de transferencia';

  @override
  String get transferAvailable => 'Disponible';

  @override
  String get transferMemoOptional => 'Memo (opcional)';

  @override
  String get transferConfirmTransfer => 'Confirmar transferencia';

  @override
  String get transferAddressVerified => 'Direccion verificada';

  @override
  String transferAvailableBalance(String balance, String symbol) {
    return 'Disponible: $balance $symbol';
  }

  @override
  String get commonEnterAmount => 'Ingresa monto';

  @override
  String get commonRedPacketCountMin => 'Se requiere al menos 1 sobre rojo';

  @override
  String get commonViewRedPacketDetails => 'Ver detalles del sobre rojo';

  @override
  String get commonEnterTransferAmount => 'Ingresa monto de transferencia';

  @override
  String get commonTransferTo => 'Transferir a';

  @override
  String commonFromSender(String name, Object senderName) {
    return 'De $senderName';
  }

  @override
  String get commonConfirmReceive => 'Confirmar recepcion';

  @override
  String get groupProfile => 'Info del grupo';

  @override
  String get groupRemoveMember => 'Eliminar del grupo';

  @override
  String get commonRemove => 'Eliminar';

  @override
  String get profileClearStatus => 'Borrar estado';

  @override
  String get profileClearStatusConfirm => 'Borrar estado actual?';

  @override
  String get profileStatusCleared => 'Estado borrado';

  @override
  String get profileUserNotExist => 'El usuario no existe';

  @override
  String get profileUserIdCopied => 'ID de usuario copiado';

  @override
  String get commonReport => 'Reportar';

  @override
  String get profileQrCode => 'Codigo QR';

  @override
  String get profileAvatarUpdated => 'Avatar actualizado';

  @override
  String commonSelectImageFailed(String error) {
    return 'Error al seleccionar imagen: $error';
  }

  @override
  String get profileChangeName => 'Cambiar nombre';

  @override
  String get profileMale => 'Masculino';

  @override
  String get profileFemale => 'Femenino';

  @override
  String chatFeatureInDev(String feature) {
    return '$feature en desarrollo...';
  }

  @override
  String profileSaveAddressFailed(String error) {
    return 'Error al guardar direccion: $error';
  }

  @override
  String get profileAddNew => 'Agregar';

  @override
  String get profileAddAddress => 'Agregar direccion';

  @override
  String get profileAddressAdded => 'Direccion agregada';

  @override
  String get profileAddressUpdated => 'Direccion actualizada';

  @override
  String get profileDeleteAddress => 'Eliminar direccion';

  @override
  String get profileAddressDeleted => 'Direccion eliminada';

  @override
  String profileSaveInvoiceFailed(String error) {
    return 'Error al guardar factura: $error';
  }

  @override
  String get profileMyInvoices => 'Mis facturas';

  @override
  String get profileAddInvoice => 'Agregar factura';

  @override
  String get profileInvoiceAdded => 'Factura agregada';

  @override
  String get profileInvoiceUpdated => 'Factura actualizada';

  @override
  String get profileDeleteInvoice => 'Eliminar factura';

  @override
  String get profileInvoiceDeleted => 'Factura eliminada';

  @override
  String get profilePersonal => 'personales';

  @override
  String get groupSelectAtLeastOne =>
      'Por favor selecciona al menos un miembro';

  @override
  String get chatFileNotExist => 'El archivo no existe';

  @override
  String chatSendFailed(String error) {
    return 'Error al enviar: $error';
  }

  @override
  String get chatCannotOpenBrowser => 'No se puede abrir el navegador';

  @override
  String chatSelectFileFailed(String error) {
    return 'Error al seleccionar archivo: $error';
  }

  @override
  String settingsSetupFailed(String error) {
    return 'Error de configuracion: $error';
  }

  @override
  String get transferEnterValidAmount => 'Por favor ingresa un monto valido';

  @override
  String get commonAddressCopied => 'Direccion copiada';

  @override
  String favoriteOpenItem(String content) {
    return 'Abrir: $content';
  }

  @override
  String get favoriteDeleted => 'Eliminado';

  @override
  String get profileWallet => 'Billetera';

  @override
  String get chatRecording => 'Grabando';

  @override
  String get chatInvalidVideoUrl => 'URL de video invalida';

  @override
  String get chatDownloadFile => 'Descargar archivo';

  @override
  String get chatClearChatHistoryTitle => 'Borrar historial de chat';

  @override
  String get chatVideoCall => 'Videollamada';

  @override
  String get commonVoiceCall => 'Llamada de voz';

  @override
  String get callLeaveMeeting => 'Salir de la reunion';

  @override
  String get chatDetails => 'Detalles del chat';

  @override
  String get chatViewAllGroupMembers => 'Ver todos los miembros';

  @override
  String get chatGroupName => 'Nombre del grupo';

  @override
  String get chatGroupNameUpdated => 'Nombre del grupo actualizado';

  @override
  String get chatUpdateFailed => 'Error de actualizacion';

  @override
  String get chatNoPermissionToModify => 'No tienes permiso para modificar';

  @override
  String get chatGroupManagement => 'Gestion del grupo';

  @override
  String get chatMyNicknameInGroup => 'Mi apodo en el grupo';

  @override
  String get chatPinChat => 'Anclar chat';

  @override
  String get chatStrongReminder => 'Recordatorio fuerte';

  @override
  String get chatSetChatBackground => 'Establecer fondo del chat';

  @override
  String get chatUnknownFile => 'Archivo desconocido';

  @override
  String get chatDownload => 'Descargar';

  @override
  String get chatInvalidLocation => 'Ubicacion invalida';

  @override
  String get chatTapToCancel => 'Toca para cancelar';

  @override
  String chatCaptureFailed(Object error) {
    return 'Error de captura: $error';
  }

  @override
  String get chatProcessingVideo => 'Procesando video...';

  @override
  String get chatVideoFileNotExist => 'El archivo de video no existe';

  @override
  String get chatVideoDataEmpty => 'Los datos del video estan vacios';

  @override
  String get chatVideoTooLarge => 'El tamano del video no puede exceder 100MB';

  @override
  String get chatSendingVideo => 'Enviando video...';

  @override
  String chatSendVideoFailed(Object error) {
    return 'Error al enviar video: $error';
  }

  @override
  String get chatImageFileNotExist => 'El archivo de imagen no existe';

  @override
  String get commonImageDataEmpty => 'Los datos de la imagen estan vacios';

  @override
  String get chatSendingImage => 'Enviando imagen...';

  @override
  String chatSendImageFailed(Object error) {
    return 'Error al enviar imagen: $error';
  }

  @override
  String get chatSendLocation => 'Enviar ubicacion';

  @override
  String get chatSelectLocationAndSend => 'Selecciona ubicacion y envia';

  @override
  String get chatShareRealTimeLocation => 'Compartir ubicacion en tiempo real';

  @override
  String get chatShareLocationForOneHour =>
      'Comparte tu ubicacion en tiempo real con un amigo por 1 hora';

  @override
  String get chatLocationSent => 'Ubicacion enviada';

  @override
  String get chatSelectMessages => 'Seleccionar mensajes';

  @override
  String chatSelectedCount(int count) {
    return '$count seleccionados';
  }

  @override
  String get chatSelectAll => 'Seleccionar todo';

  @override
  String chatGroupChatCount(int count) {
    return 'Chat grupal ($count)';
  }

  @override
  String get chatPrivateChat => 'Chat privado';

  @override
  String get chatNoMessages => 'Sin mensajes';

  @override
  String get chatSendFirstMessage =>
      'Envia el primer mensaje para iniciar el chat';

  @override
  String get chatEncryptionNotice =>
      'Este chat tiene cifrado de extremo a extremo. Solo tu y el destinatario pueden leer los mensajes.';

  @override
  String get chatMultiForward => 'Reenviar';

  @override
  String get chatCollect => 'Guardar';

  @override
  String get chatNoMembers => 'Sin miembros';

  @override
  String get chatMemberNotFound => 'Miembro no encontrado';

  @override
  String get chatVoiceFileNotExist => 'El archivo de voz no existe';

  @override
  String get chatVoiceFileEmpty => 'El archivo de voz esta vacio';

  @override
  String get chatSendingVoice => 'Enviando voz...';

  @override
  String chatSendVoiceFailed(Object error) {
    return 'Error al enviar voz: $error';
  }

  @override
  String get chatMessageForwarded => 'Mensaje reenviado';

  @override
  String chatForwardFailed(Object error) {
    return 'Error al reenviar: $error';
  }

  @override
  String get chatUnfavorited => 'Eliminado de favoritos';

  @override
  String get chatFavorited => 'Agregado a favoritos';

  @override
  String get chatReactionAdded => 'Reaccion agregada';

  @override
  String get chatReactionRemoved => 'Reaccion eliminada';

  @override
  String get chatFailedMessageDeleted => 'Mensaje fallido eliminado';

  @override
  String get chatDeleteMessages => 'Eliminar mensajes';

  @override
  String chatDeleteMessagesConfirm(Object count) {
    return 'Estas seguro de que quieres eliminar $count mensajes?';
  }

  @override
  String chatNoteOtherMessages(Object count) {
    return 'Nota: $count mensajes son de otros y solo se eliminaran para ti.';
  }

  @override
  String chatMyMessagesWillBeRecalled(Object count) {
    return '$count mensajes tuyos seran retirados para todos.';
  }

  @override
  String chatRecalledCount(Object count, Object localCount) {
    return 'Retirados $count mensajes, $localCount eliminados solo para ti';
  }

  @override
  String chatRecalledMessages(Object count) {
    return 'Retirados $count mensajes';
  }

  @override
  String chatDeletedLocally(Object count) {
    return '$count mensajes eliminados solo para ti';
  }

  @override
  String chatForwardedCount(Object count) {
    return 'Reenviados $count mensajes';
  }

  @override
  String chatForwardComplete(Object failed, Object success) {
    return 'Reenvio completo: $success exitosos, $failed fallidos';
  }

  @override
  String get chatRemindOnlyInGroup =>
      'La funcion de recordatorio solo esta disponible en chat grupal';

  @override
  String get chatOnlyTextSearchable =>
      'Solo los mensajes de texto se pueden buscar';

  @override
  String chatSearchFor(Object text) {
    return 'Buscar \"$text\"';
  }

  @override
  String get chatBaiduSearch => 'Busqueda Baidu';

  @override
  String get chatGoogleSearch => 'Busqueda Google';

  @override
  String get chatBingSearch => 'Busqueda Bing';

  @override
  String get chatCalling => 'Llamando...';

  @override
  String get chatRinging => 'Sonando...';

  @override
  String get chatInCall => 'En llamada';

  @override
  String commonFeatureInDevelopment(String feature) {
    return 'Funcion en desarrollo...';
  }

  @override
  String chatCollectMessages(Object count) {
    return 'Guardados $count mensajes';
  }

  @override
  String commonMemberCount(int count) {
    return '$count miembros';
  }

  @override
  String groupDone(int count) {
    return 'Listo($count)';
  }

  @override
  String get profileServices => 'Servicios';

  @override
  String get commonFavorites => 'Favoritos';

  @override
  String get profileOrdersAndCards => 'Pedidos y tarjetas';

  @override
  String get profileStickers => 'Pegatinas';

  @override
  String profileStatusSetTo(String status) {
    return 'Estado establecido: $status';
  }

  @override
  String get profileAvatarUploadFailed => 'Error al subir avatar';

  @override
  String get profilePersonalProfile => 'Perfil personal';

  @override
  String get profileName => 'Nombre';

  @override
  String get profileGender => 'Genero';

  @override
  String get profileRegion => 'Región';

  @override
  String get commonMyQrCode => 'Mi codigo QR';

  @override
  String get profilePoke => 'Toque';

  @override
  String get profileRingtone => 'Tono';

  @override
  String get profileDefaultRingtone => 'Tono predeterminado';

  @override
  String get profileMyAddresses => 'Mis direcciones';

  @override
  String profileGenderSetTo(String gender) {
    return 'Genero establecido: $gender';
  }

  @override
  String get profileSelectRegion => 'Seleccionar region';

  @override
  String get profileSelectCity => 'Seleccionar ciudad';

  @override
  String profileRegionSetTo(String region) {
    return 'Region establecida: $region';
  }

  @override
  String get profileSetPoke => 'Establecer toque';

  @override
  String get profileFriendPokedMe => 'Un amigo me toco';

  @override
  String get profileExample => 'Ejemplo';

  @override
  String get profileOnTheShoulder => ' en el hombro';

  @override
  String get profilePokeCleared => 'Toque borrado';

  @override
  String profilePokeSetTo(String suffix) {
    return 'Toque establecido: me toco$suffix';
  }

  @override
  String get profileEditSignature => 'Editar firma';

  @override
  String get profileIntroduceYourself => 'Una frase para presentarte';

  @override
  String get profileSignatureCleared => 'Firma borrada';

  @override
  String get profileSignatureUpdated => 'Firma actualizada';

  @override
  String get profileScanToAddFriend =>
      'Escanea el codigo QR de arriba para agregarme como amigo';

  @override
  String profileRingtoneSetTo(String ringtone) {
    return 'Tono establecido: $ringtone';
  }

  @override
  String commonConfirmDissolveGroup(String name) {
    return '¿Estás seguro de que quieres disolver \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String get authEnterValidServerAddress =>
      'Por favor ingresa una direccion de servidor valida';

  @override
  String get authEnterServerAddressFirst =>
      'Por favor ingresa la direccion del servidor primero';

  @override
  String get authPasskeyRequiresServer =>
      'El inicio de sesion con Passkey requiere soporte del servidor';

  @override
  String get authLoginAgreement => 'Al iniciar sesion, aceptas ';

  @override
  String get authPleaseAgreeToTerms =>
      'Por favor lee y acepta los Terminos de servicio y Politica de privacidad';

  @override
  String get authRegisterFailed => 'Error de registro';

  @override
  String get commonReenterPassword => 'Reingresa la contrasena';

  @override
  String get commonPasswordsDoNotMatch => 'Las contrasenas no coinciden';

  @override
  String get authInviteCodeBuiltIn => 'Codigo de invitacion (integrado)';

  @override
  String get authInviteCodeBuiltInNote =>
      'El codigo de invitacion esta integrado, normalmente no es necesario modificarlo';

  @override
  String get authIHaveReadAndAgree => 'He leido y acepto ';

  @override
  String get mainStartGroupChat => 'Iniciar chat grupal';

  @override
  String get mainAddFriends => 'Agregar amigos';

  @override
  String get mainPaymentAndCollection => 'Pago';

  @override
  String contactCount(int count) {
    return '$count contactos';
  }

  @override
  String get contactAddToHomeScreen => 'Agregar a pantalla de inicio';

  @override
  String contactRecommendedCardTo(String contact, String recipient) {
    return 'Tarjeta de $contact recomendada a $recipient';
  }

  @override
  String get contactEnterRemarkName => 'Ingresa nombre de nota';

  @override
  String contactRemarkSetTo(String remark) {
    return 'Nota establecida: $remark';
  }

  @override
  String contactAcceptedFriendRequest(String name) {
    return 'Aceptaste la solicitud de amistad de $name';
  }

  @override
  String contactRejectedFriendRequest(String name) {
    return 'Rechazaste la solicitud de amistad de $name';
  }

  @override
  String get commonGroupInvites => 'Invitaciones a grupos';

  @override
  String commonMyGroups(int count) {
    return 'Mis grupos ($count)';
  }

  @override
  String get commonInvitedToJoinGroup => 'Invitado a unirse al grupo';

  @override
  String commonConfirmLeaveGroup(String name) {
    return '¿Estás seguro de que quieres salir de \"$name\"?';
  }

  @override
  String get commonLeave => 'Salir';

  @override
  String get commonRecallThisMessage => 'Retirar este mensaje?';

  @override
  String get commonSavedToGallery => 'Guardado en galeria';

  @override
  String get commonFailedToSave => 'Error al guardar';

  @override
  String get chatSaving => 'Guardando...';

  @override
  String get commonShare => 'Compartir';

  @override
  String get chatSaveToGallery => 'Guardar en galeria';

  @override
  String chatDownloadFailed(String code) {
    return 'Descarga fallida: $code';
  }

  @override
  String commonShareFailed(String error) {
    return 'Error al compartir: $error';
  }

  @override
  String get chatFailedToLoadImage => 'Error al cargar imagen';

  @override
  String get chatVideoRecordingFailed =>
      'Error de grabacion de video. Por favor intenta de nuevo.';

  @override
  String get profileRedPacket => 'Sobre rojo';

  @override
  String get commonMusic => 'Musica';

  @override
  String get commonCoupon => 'Cupon';

  @override
  String get commonGift => 'Regalo';

  @override
  String get commonPoll => 'Encuesta';

  @override
  String get favoriteText => 'Texto';

  @override
  String get favoriteLinkLabel => 'Enlace';

  @override
  String get favoriteNote => 'Nota';

  @override
  String get favoriteMyNotes => 'Mis notas';

  @override
  String get favoriteToday => 'Hoy';

  @override
  String favoriteDaysAgoText(int count) {
    return 'Hace $count dias';
  }

  @override
  String favoriteDateFormat(int month, int day) {
    return '$day/$month';
  }

  @override
  String get favoriteNoFavorites => 'Sin favoritos aun';

  @override
  String get favoriteLongPressToFavorite =>
      'Manten presionado un mensaje para agregarlo a favoritos';

  @override
  String get favoriteNewNote => 'Nueva nota';

  @override
  String get favoriteLink => 'Enlace favorito';

  @override
  String get favoriteEditTags => 'Editar etiquetas';

  @override
  String get favoriteDeleteFavorite => 'Eliminar favorito';

  @override
  String get favoriteDeleteFavoriteConfirm =>
      'Estas seguro de que quieres eliminar este favorito?';

  @override
  String get favoriteNoSearchResultsFound => 'No se encontraron resultados';

  @override
  String get commonSendRedPacket => 'Enviar sobre rojo';

  @override
  String get transferAmount => 'Monto';

  @override
  String get commonRedPacketCover => 'Portada del sobre rojo';

  @override
  String get commonRedPacketType => 'Tipo de sobre rojo';

  @override
  String get commonNormalRedPacket => 'normales';

  @override
  String get commonLuckyRedPacket => 'De la suerte';

  @override
  String get commonRedPacketCount => 'Cantidad de sobres rojos';

  @override
  String get commonPieces => 'piezas';

  @override
  String get commonPutMoneyInRedPacket => 'Poner dinero en el sobre rojo';

  @override
  String get commonRedPacketRefundNotice =>
      'Los sobres rojos no reclamados seran reembolsados despues de 24 horas';

  @override
  String get commonOpenRedPacket => 'Abrir';

  @override
  String get commonRedPacketAllClaimed => 'Todos los sobres rojos reclamados';

  @override
  String get commonRedPacketExpired => 'Sobre rojo expirado';

  @override
  String get commonAddTransferNote => 'Agregar nota de transferencia';

  @override
  String get commonYuan => 'CNY';

  @override
  String get commonReplyWithEmoji => 'Responder con este emoji';

  @override
  String get contactEditRemark => 'Editar nota';

  @override
  String get contactSetPermissions => 'Establecer permisos';

  @override
  String get profileAddToBlacklist => 'Agregar a lista negra';

  @override
  String get contactDeleteContact => 'Eliminar contacto';

  @override
  String contactDeleteContactConfirm(String name) {
    return 'Estas seguro de que quieres eliminar a $name?';
  }

  @override
  String get transferTitle => 'Transferir';

  @override
  String get transferReceiverAddressLabel => 'Direccion del destinatario';

  @override
  String get transferSelectTokenLabel => 'Seleccionar token';

  @override
  String get transferAmountLabel => 'Monto de transferencia';

  @override
  String get transferMemoLabel => 'Memo (opcional)';

  @override
  String get transferAddMemoHint => 'Agregar un memo';

  @override
  String get transferSendPaymentRequest => 'Enviar solicitud de pago';

  @override
  String get transferQrCodeGenerateFailed => 'Error al generar codigo QR';

  @override
  String get transferScanQrToPayMe => 'Escanea el codigo QR para pagarme';

  @override
  String get transferMyWalletAddress => 'Mi direccion de billetera';

  @override
  String get transferCreatePaymentRequest => 'Crear solicitud de pago';

  @override
  String profileN42IdLabel(String id) {
    return 'ID N42: $id';
  }

  @override
  String get commonRedPacketDefaultGreeting => 'Mejores deseos';

  @override
  String commonSenderRedPacket(String name) {
    return 'Sobre rojo de $name';
  }

  @override
  String get transferEnterValidAddress =>
      'Por favor ingresa una direccion valida';

  @override
  String get transferPleaseSelectToken => 'Por favor selecciona un token';

  @override
  String get commonReceivedTransfer => 'Transferencia recibida';

  @override
  String commonSenderSentRedPacket(String name) {
    return '$name envio un sobre rojo';
  }

  @override
  String get commonSavedToBalance =>
      'Guardado en saldo, puedes transferir directamente';

  @override
  String get commonRedPacketExpiredOrEmpty =>
      'Sobre rojo expirado/todos reclamados';

  @override
  String get transferScanFeatureComingSoon =>
      'Funcion de escaneo proximamente...';

  @override
  String get contactSetAsStarred => 'Marcar como destacado';

  @override
  String get contactAddToBlocklist => 'Agregar a lista de bloqueados';

  @override
  String get commonClaimedYour => ' reclamo tu ';

  @override
  String get commonClaimedText => ' reclamo ';

  @override
  String commonUserTyping(String name) {
    return '$name esta escribiendo...';
  }

  @override
  String get commonTyping => 'Escribiendo...';

  @override
  String get commonWaitingToReceive => 'Esperando recibir';

  @override
  String get commonTapToClaim => 'Toca para reclamar';

  @override
  String get commonHasBeenReceived => 'Ha sido recibido';

  @override
  String get commonGetLucky => 'Buena suerte';

  @override
  String get qrcodeCameraStartFailed => 'Error al iniciar camara';

  @override
  String get qrcodeUnknownError => 'Error desconocido';

  @override
  String get qrcodePlaceQrCodeInFrame =>
      'Coloca el codigo QR dentro del marco para escanear';

  @override
  String get qrcodeCloseManualInput => 'Cerrar entrada manual';

  @override
  String get qrcodeManualInputUserId => 'Ingresar ID de usuario manualmente';

  @override
  String get commonAdd => 'Agregar';

  @override
  String get profileSetStatus => 'Establecer estado';

  @override
  String get profileVisibleToFriends24h => 'Visible para amigos por 24 horas';

  @override
  String get profileWriteStatus => 'Escribir estado';

  @override
  String get profileEnterYourStatus => 'Ingresa tu estado...';

  @override
  String get profileOk => 'bien';

  @override
  String get qrcodeCameraPermissionRequired =>
      'Se requiere permiso de camara para escanear codigo QR';

  @override
  String get qrcodeCameraPermissionDenied =>
      'El permiso de camara fue denegado permanentemente. Por favor habilitalo en configuracion del sistema.';

  @override
  String qrcodePermissionCheckError(String error) {
    return 'Error al verificar permiso: $error';
  }

  @override
  String get qrcodeInvalidQrCode => 'Codigo QR invalido';

  @override
  String qrcodeCannotAddFriend(String error) {
    return 'No se puede agregar amigo: $error';
  }

  @override
  String get qrcodeScanQrCode => 'Escanear codigo QR';

  @override
  String get qrcodeCheckingCameraPermission =>
      'Verificando permiso de camara...';

  @override
  String get qrcodeNeedCameraPermission => 'Se requiere permiso de camara';

  @override
  String get qrcodeRetryPermission => 'Reintentar';

  @override
  String get qrcodeOpenSettings => 'Abrir configuracion';

  @override
  String get groupInviteMembers => 'Invitar miembros';

  @override
  String groupInviteCount(int count) {
    return 'Invitar($count)';
  }

  @override
  String get profileNoShippingAddress => 'Sin direccion de envio';

  @override
  String get profileDefaultLabel => 'Predeterminado';

  @override
  String get profileNoInvoice => 'Sin factura';

  @override
  String get profileCompany => 'Empresa';

  @override
  String get profileTaxNumber => 'Numero fiscal';

  @override
  String get profileConfirmDeleteAddress =>
      'Estas seguro de que quieres eliminar esta direccion?';

  @override
  String get profileConfirmDeleteInvoice =>
      'Estas seguro de que quieres eliminar esta factura?';

  @override
  String get commonGroupOwner => 'Propietario';

  @override
  String get commonGroupAdmin => 'administrador';

  @override
  String get groupSearchMembers => 'Buscar miembros';

  @override
  String groupTotalMembers(int count) {
    return '$count miembros';
  }

  @override
  String get chatRemoveFromGroup => 'Eliminar del grupo';

  @override
  String groupConfirmRemoveMember(String name) {
    return 'Estas seguro de que quieres eliminar a \"$name\" del grupo?';
  }

  @override
  String get chatUnknownSong => 'Cancion desconocida';

  @override
  String get chatUnknownArtist => 'Artista desconocido';

  @override
  String get chatUnknownContact => 'Contacto desconocido';

  @override
  String get chatPersonalCard => 'Tarjeta de contacto';

  @override
  String get chatSingleChoice => 'Unica';

  @override
  String get chatMultiChoice => 'Multiple';

  @override
  String get chatEnded => 'Finalizada';

  @override
  String get chatEndPollButton => 'Finalizar encuesta';

  @override
  String get chatPollHint =>
      'La encuesta se mostrara en el chat. Los miembros del grupo pueden votar.';

  @override
  String get chatSearchSongOrArtist => 'Buscar cancion o artista';

  @override
  String get chatNoSongsFound => 'No se encontraron canciones';

  @override
  String get chatSongNameOptional => 'Nombre de cancion (opcional)';

  @override
  String get chatEnterSongName => 'Ingresa nombre de cancion';

  @override
  String get chatArtistNameOptional => 'Nombre de artista (opcional)';

  @override
  String get chatEnterArtistName => 'Ingresa nombre de artista';

  @override
  String get chatRealTimeLocationSharing =>
      'Compartir ubicacion en tiempo real en desarrollo...';

  @override
  String get profileVoiceCallFeatureInDev =>
      'Funcion de llamada de voz en desarrollo...';

  @override
  String get profileReportFeatureInDev => 'Funcion de reporte en desarrollo...';

  @override
  String get profileShareFeatureInDev =>
      'Funcion de compartir en desarrollo...';

  @override
  String get profileQrCodeFeatureInDev =>
      'Funcion de codigo QR en desarrollo...';

  @override
  String get qrcodeScanQrToAddMe =>
      'Escanea el codigo QR de arriba para agregarme como amigo';

  @override
  String get qrcodeSaveToAlbum => 'Guardar en album';

  @override
  String get qrcodeChangeStyle => 'Cambiar estilo';

  @override
  String get qrcodeCopyId => 'Copiar ID';

  @override
  String get qrcodeIdCopied => 'ID copiado';

  @override
  String get qrcodeMoreStylesFeatureComingSoon => 'Mas estilos proximamente';

  @override
  String get profileBio => 'Biografia';

  @override
  String get profileHomeServer => 'Servidor';

  @override
  String get profileShareContactCard => 'Compartir tarjeta de contacto';

  @override
  String get profileRemoveFromBlacklist => 'Eliminar de lista negra';

  @override
  String get profileConfirmAddBlacklist =>
      'Estas seguro de que quieres agregar a este usuario a la lista negra? No recibiras mensajes de el.';

  @override
  String get profileConfirmRemoveBlacklist =>
      'Estas seguro de que quieres eliminar a este usuario de la lista negra?';

  @override
  String get profileRemarkSaved => 'Nota guardada';

  @override
  String get profileRemarkCleared => 'Nota borrada';

  @override
  String get transferReceive => 'Recibir';

  @override
  String get transferPleaseConnectWallet =>
      'Por favor conecta tu billetera primero';

  @override
  String get transferSendRequest => 'Enviar solicitud';

  @override
  String get transferPleaseEnterValidAmount =>
      'Por favor ingresa un monto valido';

  @override
  String get searchPlaceholder => 'Buscar contactos, grupos, mensajes';

  @override
  String get searchEnterKeywordToSearch => 'Ingresa palabras clave para buscar';

  @override
  String get searchClearHistory => 'Borrar';

  @override
  String searchNoResultsForQuery(String query) {
    return 'No se encontraron resultados para \"$query\"';
  }

  @override
  String get searchAllResults => 'Todo';

  @override
  String get searchInChat => 'Buscar en chat';

  @override
  String get searchContactLabel => 'Contacto';

  @override
  String get searchGroupLabel => 'Grupo';

  @override
  String get searchConversationLabel => 'Conversación';

  @override
  String get searchMessageLabel => 'Mensaje';

  @override
  String get settingsSecurityTitle => 'Seguridad';

  @override
  String get settingsKeyBackup => 'Respaldo de claves';

  @override
  String get settingsBackupEncryptionKeys => 'Respaldar claves de cifrado';

  @override
  String settingsKeysBackedUp(int count) {
    return '$count claves respaldadas';
  }

  @override
  String get settingsBackupNotSet => 'Respaldo no configurado';

  @override
  String get settingsRestoreKeys => 'Restaurar claves';

  @override
  String get settingsRestoreKeysFromBackup =>
      'Restaurar claves de cifrado desde respaldo';

  @override
  String get settingsExportKeys => 'Exportar claves';

  @override
  String get settingsExportKeysToFile => 'Exportar claves a archivo';

  @override
  String get settingsLoggedInDevices => 'Dispositivos conectados';

  @override
  String get settingsNoOtherDevices => 'Sin otros dispositivos';

  @override
  String get settingsVerified => 'Verificado';

  @override
  String get settingsUnverified => 'No verificado';

  @override
  String get settingsAdvanced => 'Avanzado';

  @override
  String get settingsCrossSigning => 'Firma cruzada';

  @override
  String get settingsEnabled => 'Habilitado';

  @override
  String get settingsNotEnabled => 'No habilitado';

  @override
  String get settingsResetEncryption => 'Restablecer cifrado';

  @override
  String get settingsDeleteAllEncryptionKeys =>
      'Eliminar todas las claves de cifrado';

  @override
  String get settingsEncryptionNotSupported => 'Cifrado no soportado';

  @override
  String get settingsNotInitialized => 'No inicializado';

  @override
  String get settingsBackupKeyTitle => 'Respaldar claves';

  @override
  String get settingsBackupKeyMessage =>
      'Crear un nuevo respaldo de claves? Esto te ayudara a restaurar mensajes cifrados en un nuevo dispositivo.';

  @override
  String get settingsBackup => 'Respaldar';

  @override
  String get settingsRestoreKeyTitle => 'Restaurar claves';

  @override
  String get settingsRestoreKeyMessage =>
      'Ingresa tu contrasena de recuperacion o clave de recuperacion para restaurar mensajes cifrados.';

  @override
  String get settingsRestore => 'Restaurar';

  @override
  String get settingsExportKeyTitle => 'Exportar claves';

  @override
  String get settingsExportKeyMessage =>
      'El archivo de claves exportado contiene todas tus claves de cifrado. Por favor guardalo de forma segura.';

  @override
  String get settingsExport => 'Exportar';

  @override
  String settingsDeviceIdLabel(String deviceId) {
    return 'ID de dispositivo: $deviceId';
  }

  @override
  String get settingsDeviceStatusVerified => 'Estado: Verificado';

  @override
  String get settingsDeviceStatusUnverified => 'Estado: No verificado';

  @override
  String settingsLastActiveLabel(String lastSeen) {
    return 'Ultima actividad: $lastSeen';
  }

  @override
  String get settingsVerifyThisDevice => 'Verificar este dispositivo';

  @override
  String get settingsCrossSigningAlreadyEnabled =>
      'La firma cruzada ya esta habilitada';

  @override
  String get settingsCrossSigningSetupSuccess =>
      'Firma cruzada configurada exitosamente';

  @override
  String get settingsResetEncryptionTitle => 'Restablecer cifrado';

  @override
  String get settingsResetEncryptionWarning =>
      'Advertencia: Esto eliminara todas tus claves de cifrado. No podras descifrar mensajes cifrados anteriores. Esta accion no se puede deshacer.';

  @override
  String get settingsReset => 'Restablecer';

  @override
  String get settingsBackupSuccess => 'Claves respaldadas exitosamente';

  @override
  String get settingsBackupFailed => 'Error en la copia de seguridad';

  @override
  String get settingsRecoveryKey => 'Clave de recuperación';

  @override
  String get settingsRecoveryKeySaveWarning =>
      'Guarde esta clave de recuperación en un lugar seguro. Lo necesitará para restaurar sus mensajes cifrados en un nuevo dispositivo.';

  @override
  String get settingsRecoveryKeySaved => 'lo he guardado';

  @override
  String get settingsRestoreSuccess => 'Claves restauradas exitosamente';

  @override
  String get settingsRestoreFailed => 'Restauración fallida';

  @override
  String get settingsPassword => 'Contraseña';

  @override
  String get settingsEnterRecoveryKey => 'Ingrese la clave de recuperación';

  @override
  String get settingsEnterPassword => 'Introduce la contraseña';

  @override
  String get settingsExportSuccess =>
      'Claves exportadas a la copia de seguridad del servidor con éxito';

  @override
  String get settingsExportNeedBackupFirst =>
      'Primero cree una copia de seguridad de la clave';

  @override
  String get settingsExportFailed => 'Exportación fallida';

  @override
  String get settingsResetSuccess => 'Restablecimiento del cifrado exitoso';

  @override
  String get settingsResetFailed => 'Error al restablecer';

  @override
  String get callLeaveMeetingConfirm =>
      'Estas seguro de que quieres salir de la reunion?';

  @override
  String chatPokedSomeone(String name, String suffix) {
    return 'toco a $name$suffix';
  }

  @override
  String get chatNoContactsToAdd => 'No hay contactos disponibles para agregar';

  @override
  String get chatAddMembers => 'Agregar miembros';

  @override
  String chatInvitedMembers(int count) {
    return 'Invitados $count miembros';
  }

  @override
  String chatInviteFailed(String error) {
    return 'Error de invitacion: $error';
  }

  @override
  String get chatMemberRemoved => 'Miembro eliminado';

  @override
  String chatRemoveFailed(String error) {
    return 'Error al eliminar: $error';
  }

  @override
  String get chatRealTimeLocationShareMessage =>
      'Despues de compartir, la otra persona podra ver tu ubicacion en tiempo real por 1 hora.';

  @override
  String get chatStartSharing => 'Iniciar compartir';

  @override
  String get chatLocationServiceNotEnabled =>
      'El servicio de ubicacion no esta habilitado';

  @override
  String get chatEnableLocationService =>
      'Por favor habilita el servicio de ubicacion para usar esta funcion';

  @override
  String get chatGoToSettings => 'Ir a configuracion';

  @override
  String get chatLocationPermissionRequired =>
      'Se requiere permiso de ubicacion para esta funcion';

  @override
  String get chatLocationPermissionDeniedPermanent =>
      'El permiso de ubicacion ha sido denegado permanentemente. Por favor habilitalo en configuracion.';

  @override
  String get chatLocationPermissionDenied => 'Permiso de ubicacion denegado';

  @override
  String get chatGettingLocation => 'Obteniendo ubicacion...';

  @override
  String chatGetLocationFailed(String error) {
    return 'Error al obtener ubicacion: $error';
  }

  @override
  String get chatMapPreview => 'Vista previa del mapa';

  @override
  String get chatSearchLocation => 'Buscar ubicacion';

  @override
  String chatRedPacketSent(String amount, String token) {
    return 'Enviado sobre rojo de $amount $token';
  }

  @override
  String get chatTransferDefault => 'Transferencia';

  @override
  String chatTransferSent(String amount, String token) {
    return 'Enviada transferencia de $amount $token';
  }

  @override
  String chatPickFileFailed(String error) {
    return 'Error al seleccionar archivo: $error';
  }

  @override
  String get chatFileSizeLimit => 'El tamano del archivo no puede exceder 50MB';

  @override
  String chatFileSending(String filename) {
    return 'Enviando archivo: $filename';
  }

  @override
  String chatSendFileFailed(String error) {
    return 'Error al enviar archivo: $error';
  }

  @override
  String chatContactCardSent(String name) {
    return 'Enviada tarjeta de contacto de $name';
  }

  @override
  String get chatFavoritesFeature => 'Favoritos';

  @override
  String get chatCouponsFeature => 'Cupones';

  @override
  String get chatGiftFeature => 'Regalo';

  @override
  String chatSharedMusic(String name) {
    return 'Compartido $name';
  }

  @override
  String get chatEndPollTitle => 'Finalizar encuesta';

  @override
  String get chatEndPollConfirmMessage =>
      'Estas seguro de que quieres finalizar esta encuesta? La votacion se cerrara despues de finalizar.';

  @override
  String get chatPollEndedMessage => 'Encuesta finalizada';

  @override
  String get chatConnectingCall => 'Conectando...';

  @override
  String get chatMuteCall => 'Silenciar';

  @override
  String get chatSpeakerOff => 'Altavoz apagado';

  @override
  String get chatSpeakerOn => 'Altavoz';

  @override
  String get chatCameraOn => 'Camara encendida';

  @override
  String get chatCameraOff => 'Camara apagada';

  @override
  String get chatHangUp => 'Colgar';

  @override
  String get chatSelectForwardTargetTitle => 'Seleccionar destino de reenvio';

  @override
  String get chatNoForwardableChat => 'No hay chats disponibles para reenviar';

  @override
  String get chatNoMatchingChat => 'No se encontraron chats coincidentes';

  @override
  String get chatLocationTitle => 'Ubicacion';

  @override
  String get chatSendButton => 'Enviar';

  @override
  String get chatRetryButton => 'Reintentar';

  @override
  String get chatSearchContactHint => 'Buscar contactos';

  @override
  String get chatShareMusic => 'Compartir musica';

  @override
  String get chatRecentPlayed => 'Recientes';

  @override
  String get chatMyFavorites => 'Favoritos';

  @override
  String get chatNetworkLink => 'Enlace';

  @override
  String get chatLocalFile => 'locales';

  @override
  String get chatPasteMusicLink => 'Pegar enlace de musica';

  @override
  String get chatShareMusicButton => 'Compartir musica';

  @override
  String get chatSelectLocalAudio => 'Seleccionar archivo de audio local';

  @override
  String get chatSupportedAudioFormats => 'Soporta MP3, M4A, WAV, FLAC, etc.';

  @override
  String get chatSelectFileButton => 'Seleccionar archivo';

  @override
  String get chatPleaseEnterMusicLink => 'Por favor ingresa enlace de musica';

  @override
  String get chatPleaseEnterValidLink => 'Por favor ingresa una URL valida';

  @override
  String get chatSharedSong => 'Cancion compartida';

  @override
  String get chatSelectMember => 'Seleccionar miembro';

  @override
  String get chatSearchMemberHint => 'Buscar miembros';

  @override
  String get chatNoMatchingMembers => 'No se encontraron miembros coincidentes';

  @override
  String get commonUnknownMember => 'Desconocido';

  @override
  String chatSelectedMessagesCount(int count) {
    return '$count mensajes seleccionados';
  }

  @override
  String get chatSearchContactsOrGroups => 'Buscar contactos o grupos';

  @override
  String get chatVideoTitle => 'Vídeo';

  @override
  String get chatLoadingText => 'Cargando...';

  @override
  String get chatVideoLoadFailed => 'Error al cargar video';

  @override
  String get chatPlayerInitFailed => 'Error de inicializacion del reproductor';

  @override
  String get chatCreatePollTitle => 'Crear encuesta';

  @override
  String get chatSubmitPoll => 'Enviar';

  @override
  String get chatPollQuestionLabel => 'Pregunta de la encuesta';

  @override
  String get chatEnterPollQuestionHint =>
      'Por favor ingresa pregunta de la encuesta';

  @override
  String get chatPollOptionsLabel => 'Opciones de la encuesta';

  @override
  String chatOptionHintWithIndex(int index) {
    return 'Opcion $index';
  }

  @override
  String get chatAddOptionButton => 'Agregar opcion';

  @override
  String get chatPollSettingsLabel => 'Configuracion de encuesta';

  @override
  String get chatSelectionType => 'Tipo de seleccion';

  @override
  String get chatSingleChoiceLabel => 'Unica';

  @override
  String get chatMultiChoiceLabel => 'Multiple';

  @override
  String get chatAnonymousPollSwitch => 'Encuesta anonima';

  @override
  String get chatPleaseEnterQuestion =>
      'Por favor ingresa pregunta de la encuesta';

  @override
  String get chatAtLeastTwoOptions => 'Se requieren al menos 2 opciones';

  @override
  String chatConfirmWithCount(int count) {
    return 'Confirmar ($count)';
  }

  @override
  String get authEmailVerificationTitle => 'Verificacion de correo';

  @override
  String get authEnterValidEmailAddress =>
      'Por favor ingresa una direccion de correo valida';

  @override
  String authVerificationCodeSentTo(String email) {
    return 'Codigo de verificacion enviado a $email';
  }

  @override
  String authSendCodeFailed(String error) {
    return 'Error al enviar codigo: $error';
  }

  @override
  String get authVerificationSuccess => 'Verificacion exitosa';

  @override
  String get authVerificationFailed => 'Error de verificacion';

  @override
  String authVerificationCodeError(String error) {
    return 'Error de codigo de verificacion: $error';
  }

  @override
  String get commonEnterVerificationCode => 'Ingresa codigo de verificacion';

  @override
  String get authEnterYourEmail => 'Ingresa correo';

  @override
  String authWeSentCodeTo(String email) {
    return 'Enviamos un codigo de 6 digitos a\n$email';
  }

  @override
  String get authEnterEmailForCode =>
      'Ingresa tu direccion de correo, enviaremos codigo de verificacion';

  @override
  String get commonSendVerificationCode => 'Enviar codigo de verificacion';

  @override
  String get authResendVerificationCode => 'Reenviar codigo de verificacion';

  @override
  String authCanResendAfter(int seconds) {
    return 'Puedes reenviar despues de $seconds segundos';
  }

  @override
  String get commonChangeEmail => 'Cambiar correo';

  @override
  String get contactAddToContacts => 'Agregar a contactos';

  @override
  String get contactAddingToContacts => 'Agregando...';

  @override
  String get contactAddedToContacts => 'Agregado a contactos';

  @override
  String contactAddFailedWithError(String error) {
    return 'Error al agregar: $error';
  }

  @override
  String get contactAddPhone => 'Agregar telefono';

  @override
  String get contactAddTag => 'Agregar etiquetas';

  @override
  String get contactAddText => 'Agregar texto';

  @override
  String get contactAddPhoto => 'Agregar foto';

  @override
  String contactGroupCountLabel(int count) {
    return '$count grupos';
  }

  @override
  String get contactAddedViaSearch => 'Agregado via busqueda';

  @override
  String get contactAddTime => 'Agregar hora';

  @override
  String get contactDoneButton => 'Listo';

  @override
  String get callWaitingForParticipants =>
      'Esperando que los participantes se unan...';

  @override
  String callParticipantMe(String name) {
    return '$name (Yo)';
  }

  @override
  String get callSharingLabel => 'Compartiendo';

  @override
  String callScreenSharingBy(String name) {
    return '$name esta compartiendo pantalla';
  }

  @override
  String callParticipantCount(int count) {
    return '$count participantes';
  }

  @override
  String get callMuteLabel => 'Silenciar';

  @override
  String get callUnmuteLabel => 'Activar sonido';

  @override
  String get callTurnOffVideo => 'Apagar video';

  @override
  String get callTurnOnVideo => 'Encender video';

  @override
  String get callShareScreen => 'Compartir pantalla';

  @override
  String get callStopSharing => 'Dejar de compartir';

  @override
  String get callSwitchCameraLabel => 'Cambiar';

  @override
  String get callLeaveLabel => 'Salir';

  @override
  String get callParticipantsLabel => 'Participantes';

  @override
  String get callJoiningMeeting => 'Uniendose a la reunion...';

  @override
  String chatPollVotesFormat(int count, String percentage) {
    return '$count votos ($percentage%)';
  }

  @override
  String chatPollParticipantsFormat(int count) {
    return '$count participantes';
  }

  @override
  String get commonTapToRetry => 'Toca para reintentar';

  @override
  String get chatDefaultRedPacketGreeting => 'Que la prosperidad te acompañe';

  @override
  String get groupAllowOthersToSearchAndJoin =>
      'Permitir que otros busquen y se unan';

  @override
  String get groupConfirmClearChatHistory =>
      '¿Estás seguro de que deseas borrar el historial de chat?';

  @override
  String get groupCreateGroupToChat => 'Crea un grupo para comenzar a chatear';

  @override
  String get groupEditGroupAnnouncement => 'Editar anuncio del grupo';

  @override
  String get groupEditGroupDescription => 'Editar descripción del grupo';

  @override
  String get groupEnterGroupAnnouncement => 'Ingresa el anuncio del grupo';

  @override
  String chatErrorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String groupMemberCountClickToCopy(int count) {
    return '$count miembros, haz clic para copiar el ID del grupo';
  }

  @override
  String get chatMusicLinkLabel => 'Enlace de musica';

  @override
  String get chatNoMediaUrlAvailable => 'URL de medios no disponible';

  @override
  String get groupNoPermissionToEditGroupName =>
      'No tienes permiso para editar el nombre del grupo';

  @override
  String get chatRedPacketTransferCannotForward =>
      'Los sobres rojos y transferencias no se pueden reenviar';

  @override
  String get authEmailAddress => 'Dirección de correo electrónico';

  @override
  String get commonEnterEmailAddress =>
      'Ingrese la dirección de correo electrónico';

  @override
  String get authEmailRecoveryHint => 'Se usa para recuperar la contraseña';

  @override
  String get commonInvalidEmailFormat =>
      'Ingrese una dirección de correo electrónico válida';

  @override
  String get authOptional => 'Opcional';

  @override
  String get authResetPassword => 'Restablecer contraseña';

  @override
  String get authEnterRegisteredEmail =>
      'Ingrese la dirección de correo electrónico con la que se registró';

  @override
  String get authSendResetCode => 'Enviar código de restablecimiento';

  @override
  String authResetCodeSent(String email) {
    return 'Código de restablecimiento enviado a $email';
  }

  @override
  String get authEnterResetCode => 'Ingrese el código de restablecimiento';

  @override
  String get authSetNewPassword => 'Establecer nueva contraseña';

  @override
  String get commonConfirmNewPassword => 'Confirmar nueva contraseña';

  @override
  String get commonNewPassword => 'Nueva contraseña';

  @override
  String get authPasswordResetSuccess =>
      'Contraseña restablecida correctamente. Inicie sesión con su nueva contraseña.';

  @override
  String get authResetPasswordFailed => 'Error al restablecer la contraseña';

  @override
  String get settingsChangePassword => 'Cambiar contraseña';

  @override
  String get settingsCurrentPassword => 'Contraseña actual';

  @override
  String get settingsEnterCurrentPassword => 'Ingrese la contraseña actual';

  @override
  String get settingsEnterNewPassword => 'Ingrese la nueva contraseña';

  @override
  String get settingsPasswordChanged =>
      'Contraseña cambiada correctamente. Inicie sesión con su nueva contraseña.';

  @override
  String get settingsChangePasswordFailed => 'Error al cambiar la contraseña';

  @override
  String get settingsNewPasswordMustBeDifferent =>
      'La nueva contraseña debe ser diferente de la contraseña actual';

  @override
  String get settingsChangePasswordInfo =>
      'Después de cambiar la contraseña, se cerrará la sesión y deberá iniciar sesión con la nueva contraseña.';

  @override
  String get settingsPasswordRequirements => 'Requisitos de contraseña:';

  @override
  String get settingsSecurityNote =>
      'Por seguridad, deberá volver a iniciar sesión en todos los dispositivos después de cambiar la contraseña.';

  @override
  String get settingsSecurity => 'Seguridad';

  @override
  String get settingsCurrentBoundEmail => 'Correo electrónico actual vinculado';

  @override
  String get settingsNewEmailAddress => 'Nueva dirección de correo electrónico';

  @override
  String get settingsEnterNewEmail =>
      'Ingrese la nueva dirección de correo electrónico';

  @override
  String get settingsVerificationCode => 'Código de verificación';

  @override
  String get settingsVerificationCodeSent => 'Código de verificación enviado';

  @override
  String get settingsCodeSentTo => 'Código de verificación enviado a';

  @override
  String get settingsDidNotReceiveCode => '¿No recibió el código?';

  @override
  String get settingsEmailChangedSuccess =>
      'Correo electrónico cambiado correctamente';

  @override
  String get settingsChangeEmailFailed =>
      'Error al cambiar el correo electrónico';

  @override
  String get settingsEmailSecurityNote =>
      'Su correo electrónico se usa para recuperar la contraseña. Manténgalo seguro.';

  @override
  String get commonGoogleLogin => 'Iniciar sesión con Google';

  @override
  String get commonAppleLogin => 'Iniciar sesión con Apple';

  @override
  String get commonWechat => 'WeChat';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageChanged => 'Idioma cambiado';

  @override
  String get settingsTranslation => 'Traducción';

  @override
  String get settingsTranslateTextTo => 'Traducir texto a';

  @override
  String get settingsTranslateDescription =>
      'Seleccione el idioma al que desea que se traduzcan los mensajes.';

  @override
  String get settingsAutoTranslate =>
      'Traducir automáticamente los mensajes recibidos';

  @override
  String get settingsAutoTranslateDescription =>
      'Traduce automáticamente los mensajes recibidos en el chat al idioma seleccionado.';

  @override
  String get settingsBiometricLogin => 'Inicio biométrico';

  @override
  String authLoginWithBiometric(Object type) {
    return 'Iniciar sesión con $type';
  }

  @override
  String get settingsBiometricLoginEnabled => 'Inicio biométrico activado';

  @override
  String get settingsBiometricLoginDisabled => 'Inicio biométrico desactivado';

  @override
  String get settingsEnableBiometricLogin => 'Activar inicio biométrico';

  @override
  String get settingsBiometricEnabled =>
      'Activado - Usa biometría para iniciar sesión';

  @override
  String get settingsBiometricDisabled => 'Desactivado - Toca para activar';

  @override
  String get settingsBiometricNeedRelogin =>
      'Por favor, cierra sesión e inicia sesión de nuevo para activar el inicio biométrico';

  @override
  String get authOr => 'O';

  @override
  String get qrcodeCameraPermissionRestricted =>
      'El acceso a la cámara está restringido en este dispositivo';

  @override
  String get authPasskeyLabel => 'Clave de acceso';

  @override
  String get authGoogleLabel => 'google';

  @override
  String get authAppleLabel => 'manzana';


  @override
  String get authSsoNotConfigured => 'Este servidor no ha configurado proveedores de inicio de sesión SSO';
  @override
  String get authSsoLabel => 'SSO';

  @override
  String get transferAmountHintZero => '0.00';

  @override
  String get commonMatrixIdHint => '@username:server.com';

  @override
  String get authServerAddressHint => 'https://m.si46.world';

  @override
  String get authEmailExampleHint => 'example@email.com';

  @override
  String get authVerificationCodePlaceholder => '------';

  @override
  String get profileEnterPokeSuffixHint =>
      'Introduce el sufijo del toque, p.ej.: en el hombro';

  @override
  String get groupAlbum => 'Álbum del grupo';

  @override
  String get groupFiles => 'Archivos del grupo';

  @override
  String get groupImages => 'Imágenes';

  @override
  String get groupVideos => 'Vídeos';

  @override
  String get groupTotal => 'totales';

  @override
  String get groupSize => 'Tamaño';

  @override
  String get groupNoMedia => 'Sin medios';

  @override
  String get groupNoMediaDescription =>
      'Aún no hay fotos ni videos en este grupo';

  @override
  String get groupDocuments => 'Documentos';

  @override
  String get groupNoFiles => 'Sin archivos';

  @override
  String get groupNoFilesDescription => 'Aún no hay archivos en este grupo';

  @override
  String groupDownloadStarted(String filename) {
    return 'Descargando $filename...';
  }

  @override
  String get contactNoCommonGroups => 'Sin grupos en común';

  @override
  String get contactNoCommonGroupsDescription =>
      'No tienen ningún grupo en común';

  @override
  String get chatVoiceMessage => 'Voz';

  @override
  String get chatMessage => 'Mensaje';

  @override
  String get conversationHideChat => 'Ocultar';

  @override
  String get settingsQuickReply => 'Respuesta rápida';

  @override
  String get commonTranslate => 'Traducir';

  @override
  String get contactCreateTag => 'Crear etiqueta';

  @override
  String get contactEnterTagName => 'Introduzca el nombre de la etiqueta';

  @override
  String get contactEditTag => 'Editar etiqueta';

  @override
  String get contactDeleteTag => 'Eliminar etiqueta';

  @override
  String contactDeleteTagConfirm(String tagName) {
    return '¿Está seguro de que desea eliminar la etiqueta \"$tagName\"?';
  }

  @override
  String get contactNoTags => 'Aún no hay etiquetas';

  @override
  String get contactFriendPermissions => 'Permisos de amigos';

  @override
  String get contactSetChatOnly => 'Establecer como solo chat';

  @override
  String get contactChatOnlyDesc =>
      'Solo puedo chatear contigo, el resto del contenido estará oculto.';

  @override
  String get contactHideMyMoments => 'Ocultar mis momentos';

  @override
  String get contactHideMyMomentsDesc => 'Este amigo no puede ver mis Momentos';

  @override
  String get contactHideTheirMoments => 'Ocultar sus momentos';

  @override
  String get contactHideTheirMomentsDesc => 'No ver los Momentos de este amigo';

  @override
  String get contactHideMyStatus => 'Ocultar mi estado';

  @override
  String get contactHideMyStatusDesc =>
      'Este amigo no puede ver mis actualizaciones de estado.';

  @override
  String get contactNoChatOnlyFriends => 'No hay amigos solo para chatear';

  @override
  String get contactNoOfficialAccounts => 'Sin cuentas oficiales';

  @override
  String get contactFollowOfficialAccountsDesc =>
      'Siga las cuentas oficiales para obtener las últimas actualizaciones.';

  @override
  String get contactNoServiceAccounts => 'Sin cuentas de servicio';

  @override
  String get contactSubscribeServiceAccountsDesc =>
      'Suscríbase a cuentas de servicio para obtener servicios convenientes';

  @override
  String get contactNoEnterpriseContacts => 'Sin contactos empresariales';

  @override
  String get contactEnterpriseContactsDesc =>
      'Los contactos empresariales se mostrarán aquí';

  @override
  String get profileCardPack => 'Paquete de cartas';

  @override
  String get profileOrders => 'Órdenes';

  @override
  String get profileNoOrders => 'Sin pedidos';

  @override
  String get profileOrdersDesc => 'Tus pedidos se mostrarán aquí.';

  @override
  String get profileNoCards => 'sin tarjetas';

  @override
  String get profileCardsDesc => 'Tus tarjetas se mostrarán aquí.';

  @override
  String get favoriteEnterTagsHint =>
      'Introduzca etiquetas separadas por comas';

  @override
  String get favoriteTagsUpdated => 'Etiquetas actualizadas';

  @override
  String get favoriteForwardedContent => 'Contenido reenviado';

  @override
  String get favoriteEnterNoteContent => 'Ingrese el contenido de la nota';

  @override
  String get favoriteNoteAdded => 'Nota agregada';

  @override
  String get favoriteLinkTitle => 'Título del enlace';

  @override
  String get favoriteLinkUrl => 'https://';

  @override
  String get favoriteLinkAdded => 'Enlace agregado';

  @override
  String get contactPhotoAdded => 'Foto agregada';

  @override
  String get contactEnterPhone => 'Introduce el número de teléfono';

  @override
  String commonConversationWithId(String roomId) {
    return 'Conversacion: $roomId';
  }

  @override
  String commonContactWithId(String userId) {
    return 'Contacto: $userId';
  }

  @override
  String get commonDiscover => 'Descubrir';

  @override
  String commonDeveloping(String title) {
    return '$title\n(Proximamente)';
  }

  @override
  String get commonPageNotFound => 'Pagina no encontrada';

  @override
  String get commonBackToHome => 'Volver al inicio';

  @override
  String get settingsMessageNotifications => 'Notificaciones de mensajes';

  @override
  String get settingsReceiveNewMessageNotifications =>
      'Recibir notificaciones de nuevos mensajes';

  @override
  String get settingsShowMessagePreview => 'Mostrar vista previa del mensaje';

  @override
  String get settingsShowMessageContentInNotification =>
      'Mostrar contenido del mensaje en notificaciones';

  @override
  String get settingsNotificationSound => 'Sonido de notificacion';

  @override
  String get settingsPlaySoundOnMessage =>
      'Reproducir sonido al recibir mensajes';

  @override
  String get commonVibration => 'Vibracion';

  @override
  String get settingsVibrateOnMessage => 'Vibrar al recibir mensajes';

  @override
  String get settingsDoNotDisturbMode => 'No molestar';

  @override
  String get settingsDoNotDisturbDescription =>
      'No recibir notificaciones durante el tiempo especificado';

  @override
  String get settingsStartTime => 'Hora de inicio';

  @override
  String get settingsEndTime => 'Hora de fin';

  @override
  String get settingsDeleteQuickReply => 'Eliminar respuesta rápida';

  @override
  String get settingsEditQuickReply => 'Editar respuesta rápida';

  @override
  String get settingsAddQuickReply => 'Añadir respuesta rápida';

  @override
  String get settingsManageQuickReplies => 'Gestionar respuestas rápidas';

  @override
  String get settingsNoQuickReplies => 'Sin respuestas rápidas';

  @override
  String get settingsDefaultQuickReplies =>
      'Se mostrarán las respuestas rápidas predeterminadas';

  @override
  String get settingsWhoCanSee => 'Quien puede ver';

  @override
  String get settingsLastSeen => 'Ultima vez visto';

  @override
  String get settingsHiddenChats => 'Chats ocultos';

  @override
  String get settingsMessagesLabel => 'Mensajes';

  @override
  String get settingsAllowStrangerMessages => 'Permitir mensajes de extraños';

  @override
  String get settingsReceiveMessagesFromNonContacts =>
      'Recibir mensajes de no contactos';

  @override
  String get settingsReadReceipts => 'Confirmaciones de lectura';

  @override
  String get settingsLetOthersKnowYouRead =>
      'Permitir que otros sepan que leiste sus mensajes';

  @override
  String get settingsTypingIndicator => 'Indicador de escritura';

  @override
  String get settingsLetOthersKnowYouTyping =>
      'Permitir que otros sepan que estas escribiendo';

  @override
  String get settingsEveryone => 'Todos';

  @override
  String get settingsContactsOnly => 'Solo contactos';

  @override
  String get settingsNobody => 'Nadie';

  @override
  String settingsWhoCanSeeTitle(String title) {
    return 'Quien puede ver $title';
  }

  @override
  String settingsVersionInfo(String version) {
    return 'Versión $version';
  }

  @override
  String get settingsCheckForUpdates => 'Buscar actualizaciones';

  @override
  String get settingsOpenSourceLicenses => 'Licencias de codigo abierto';

  @override
  String get settingsFeedbackAndSuggestions => 'Comentarios y sugerencias';

  @override
  String get settingsBuiltOnMatrix => 'Basado en el protocolo Matrix';

  @override
  String get settingsNoHiddenChats => 'Sin chats ocultos';

  @override
  String get settingsNoHiddenChatsDescription =>
      'Los chats que ocultes aparecerán aquí';

  @override
  String get settingsUnhideChat => 'Mostrar';

  @override
  String get settingsDarkMode => 'Modo oscuro';

  @override
  String get settingsFontSize => 'Tamano de fuente';

  @override
  String get settingsBubbleStyle => 'Estilo de burbuja';

  @override
  String get settingsFollowSystem => 'Seguir sistema';

  @override
  String get settingsAutoSwitchBySystem =>
      'Cambiar automaticamente segun configuracion del sistema';

  @override
  String get settingsLightMode => 'Modo claro';

  @override
  String get settingsAlwaysUseLightTheme => 'Usar siempre tema claro';

  @override
  String get settingsDarkModeOption => 'Modo oscuro';

  @override
  String get settingsAlwaysUseDarkTheme => 'Usar siempre tema oscuro';

  @override
  String get settingsFontSizeSmall => 'Pequeno';

  @override
  String get settingsFontSizeStandard => 'Estandar';

  @override
  String get settingsFontSizeLarge => 'Grande';

  @override
  String get settingsFontSizeExtraLarge => 'Extra grande';

  @override
  String get settingsBubbleStyleWechat => 'Estilo WeChat';

  @override
  String get settingsBubbleStyleWechatDesc =>
      'Estilo de burbuja clasico de WeChat';

  @override
  String get settingsBubbleStyleModern => 'Estilo moderno';

  @override
  String get settingsBubbleStyleModernDesc =>
      'Estilo de burbuja moderno y limpio';

  @override
  String get settingsBubbleStyleClassic => 'Estilo clasico';

  @override
  String get settingsBubbleStyleClassicDesc => 'Estilo de burbuja tradicional';

  @override
  String get discoverVideoChannels => 'Canales';

  @override
  String get discoverLive => 'En vivo';

  @override
  String get discoverListen => 'Escuchar';

  @override
  String get discoverWatch => 'Ver';

  @override
  String get discoverSearchDiscover => 'Buscar';

  @override
  String get discoverNearbyPeople => 'Cercanos';

  @override
  String get discoverGames => 'Juegos';

  @override
  String get discoverMiniPrograms => 'Mini programas';

  @override
  String get chatAlreadyInCall => 'Ya estas en una llamada';

  @override
  String get commonConnectionFailed => 'Conexion fallida';

  @override
  String get chatCallRejected => 'Llamada rechazada';

  @override
  String get chatNoAnswer => 'Sin respuesta';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get chatSelectContact => 'Seleccionar contacto';

  @override
  String get chatVoteRemoved => 'Voto eliminado';

  @override
  String get chatVoteChanged => 'Voto cambiado';

  @override
  String get chatVoted => 'Votado';

  @override
  String chatReplyTo(String name) {
    return 'Responder a $name';
  }

  @override
  String get chatCurrentLocation => 'Ubicacion actual';

  @override
  String chatNearbyPlace(int index) {
    return 'Lugar cercano $index';
  }

  @override
  String chatApproximateDistance(String distance) {
    return 'Aproximadamente $distance';
  }

  @override
  String get chatAddress => 'Direccion';

  @override
  String get chatLatitude => 'Latitud';

  @override
  String get chatLongitude => 'Longitud';

  @override
  String get groupDescriptionUpdated => 'Descripción del grupo actualizada';

  @override
  String get groupAvatarUpdated => 'Avatar del grupo actualizado';

  @override
  String get groupVisibilityUpdated => 'Visibilidad del grupo actualizada';

  @override
  String get groupChannelCreated => 'Canal creado';

  @override
  String get groupChannelUpdated => 'Canal actualizado';

  @override
  String get groupChannelDeleted => 'Canal eliminado';

  @override
  String get callDecline => 'Rechazar';

  @override
  String get callAnswer => 'Contestar';

  @override
  String get callIncomingVideoCall => 'Videollamada entrante';

  @override
  String get callIncomingVoiceCall => 'Llamada de voz entrante';

  @override
  String get callVideoCallInProgress => 'Videollamada';

  @override
  String get callVoiceCallInProgress => 'Llamada de voz';

  @override
  String get callReconnectingCall => 'Reconectando...';

  @override
  String get callEnded => 'Llamada terminada';

  @override
  String get callFailed => 'Llamada fallida';

  @override
  String get callLivekitNotConfigured => 'LiveKit no configurado';

  @override
  String callJoinMeetingFailed(String error) {
    return 'Error al unirse a la reunion: $error';
  }

  @override
  String callScreenShareFailed(String error) {
    return 'Error al compartir pantalla: $error';
  }

  @override
  String get profileN42BeanTitle => 'Frijol N42';

  @override
  String get profileNoN42Bean => 'Sin N42 Bean';

  @override
  String get profileN42BeanDetails => 'Detalles de N42 Bean';

  @override
  String get profileN42BeanDescription =>
      'N42 Bean es un token para canjear artículos virtuales y servicios en N42. Actualmente disponible para:';

  @override
  String get profileN42BeanFeature1 =>
      'Stickers y temas exclusivos para miembros';

  @override
  String get profileN42BeanFeature2 => 'Personalización de burbujas de chat';

  @override
  String get profileN42BeanFeature3 => 'Personalización de sobres rojos';

  @override
  String get profileN42BeanFeature4 => 'Insignia de apodo exclusiva';

  @override
  String get profileN42BeanFeature5 => 'Privilegios de chat grupal';

  @override
  String get profileN42BeanFeature6 => 'Expansión de almacenamiento en la nube';

  @override
  String get profileN42BeanFeature7 => 'Filtros de belleza para videollamadas';

  @override
  String get profileN42BeanFeature8 => 'Personalización de fondo de Moments';

  @override
  String get profileN42BeanFeature9 => 'Prioridad en servicio al cliente VIP';

  @override
  String get profileGotIt => 'Entendido';

  @override
  String get profileNoN42BeanRecords => 'Sin registros de N42 Bean';

  @override
  String get profileMoodAndThoughts => 'Animo y pensamientos';

  @override
  String get profileStatusHappy => 'Feliz';

  @override
  String get profileStatusCracked => 'Destrozado';

  @override
  String get profileStatusLucky => 'Con suerte';

  @override
  String get profileStatusSunny => 'Soleado';

  @override
  String get profileStatusTired => 'Cansado';

  @override
  String get profileStatusDaydream => 'Sonando despierto';

  @override
  String get profileStatusRushing => 'Apurado';

  @override
  String get profileStatusOverthinking => 'Pensando demasiado';

  @override
  String get profileStatusEnergized => 'Energizado';

  @override
  String get profileWorkAndStudy => 'Trabajo y estudio';

  @override
  String get profileStatusWorking => 'Trabajando';

  @override
  String get profileStatusStudying => 'Estudiando';

  @override
  String get profileStatusBusy => 'Ocupado';

  @override
  String get profileStatusSlacking => 'Holgazaneando';

  @override
  String get profileStatusTraveling => 'Viajando';

  @override
  String get profileStatusGoingHome => 'Yendo a casa';

  @override
  String get profileStatusDnd => 'No molestar';

  @override
  String get profileActivities => 'Actividades';

  @override
  String get profileStatusHanging => 'Pasando el rato';

  @override
  String get profileStatusCheckIn => 'Registrandome';

  @override
  String get profileStatusExercising => 'Ejercitandome';

  @override
  String get profileStatusCoffee => 'Cafe';

  @override
  String get profileStatusBubbleTea => 'Te de burbujas';

  @override
  String get profileStatusEating => 'Comiendo';

  @override
  String get profileStatusParenting => 'Cuidando ninos';

  @override
  String get profileStatusSavingWorld => 'Salvando el mundo';

  @override
  String get profileStatusSelfie => 'autofoto';

  @override
  String get profileRest => 'Descanso';

  @override
  String get profileStatusRetreat => 'Retiro';

  @override
  String get profileStatusHome => 'En casa';

  @override
  String get profileStatusSleeping => 'Durmiendo';

  @override
  String get profileStatusCatLover => 'Amante de gatos';

  @override
  String get profileStatusDogWalking => 'Paseando al perro';

  @override
  String get profileStatusGaming => 'Jugando';

  @override
  String get profileStatusListening => 'Escuchando';

  @override
  String get profileEditAddress => 'Editar direccion';

  @override
  String get profileRecipient => 'Destinatario';

  @override
  String get profileEnterRecipientName => 'Ingresa nombre del destinatario';

  @override
  String get profilePhoneNumber => 'Numero de telefono';

  @override
  String get profileEnterPhoneNumber => 'Ingresa numero de telefono';

  @override
  String get profileRegionHint => 'Provincia/Ciudad/Distrito';

  @override
  String get profileDetailedAddress => 'Direccion detallada';

  @override
  String get profileDetailedAddressHint => 'Calle, numero de edificio, etc.';

  @override
  String get profileSetAsDefaultAddress =>
      'Establecer como direccion predeterminada';

  @override
  String get profilePleaseCompleteInfo => 'Por favor completa todos los campos';

  @override
  String get profileEditInvoice => 'Editar factura';

  @override
  String get profileInvoiceType => 'Tipo de factura: ';

  @override
  String get profileCompanyName => 'Nombre de empresa';

  @override
  String get profilePersonalName => 'Nombre personal';

  @override
  String get profileEnterCompanyName => 'Ingresa nombre de empresa';

  @override
  String get profileEnterName => 'Ingresa nombre';

  @override
  String get profileTaxIdNumber => 'Numero de identificacion fiscal';

  @override
  String get profileEnterTaxIdNumber =>
      'Ingresa numero de identificacion fiscal';

  @override
  String get profileBankNameOptional => 'Nombre del banco (opcional)';

  @override
  String get profileEnterBankName => 'Ingresa nombre del banco';

  @override
  String get profileBankAccountOptional => 'Cuenta bancaria (opcional)';

  @override
  String get profileEnterBankAccount => 'Ingresa cuenta bancaria';

  @override
  String get profileCompanyAddressOptional => 'Direccion de empresa (opcional)';

  @override
  String get profileEnterCompanyAddress => 'Ingresa direccion de empresa';

  @override
  String get profileCompanyPhoneOptional => 'Telefono de empresa (opcional)';

  @override
  String get profileEnterCompanyPhone => 'Ingresa telefono de empresa';

  @override
  String get profileSetAsDefaultInvoice =>
      'Establecer como factura predeterminada';

  @override
  String get profileRingtoneVibrate => 'Vibrar';

  @override
  String get profileRingtoneSilent => 'Silencioso';

  @override
  String get profileVibrateMode => 'Modo vibracion';

  @override
  String get profileSilentMode => 'Modo silencioso';

  @override
  String profilePlayFailed(String ringtoneName) {
    return 'Error al reproducir: $ringtoneName';
  }

  @override
  String profilePlaying(String ringtoneName) {
    return 'Reproduciendo: $ringtoneName';
  }

  @override
  String get profileStop => 'Detener';

  @override
  String get profileSelectRingtone => 'Seleccionar tono';

  @override
  String get profileLoadingRingtones => 'Cargando tonos...';

  @override
  String get profileNoRingtonesFound => 'No se encontraron tonos';

  @override
  String mainMessagesWithCount(int count) {
    return 'Mensajes($count)';
  }

  @override
  String get storyViewers => 'Espectadores';

  @override
  String get storyNoViewers => 'Aún sin espectadores';

  @override
  String get storyReplyToStory => 'Responder a la historia...';

  @override
  String get commonCopiedToClipboard => 'Copiado al portapapeles';

  @override
  String get commonMore => 'Mas';

  @override
  String get commonTranslating => 'Traduciendo...';

  @override
  String commonTranslatedFrom(String language) {
    return 'Traducido de $language';
  }

  @override
  String get commonTranslation => 'Traducción';

  @override
  String get commonTranslationFailed => 'Error en la traducción';

  @override
  String get commonAllRead => 'Todo leido';

  @override
  String commonReadCount(int count) {
    return '$count leidos';
  }

  @override
  String get commonYouRecalledMessage => 'Retiraste un mensaje';

  @override
  String get commonMessageRecalled => 'Mensaje retirado';

  @override
  String get commonReEdit => 'Reeditar';

  @override
  String get commonWalletArea => 'Area de billetera';

  @override
  String get callIncomingCall => 'Llamada entrante';

  @override
  String get callMissedCall => 'Llamada perdida';

  @override
  String get groupRemoveAdmin => 'Quitar admin';

  @override
  String get chatSelectCurrency => 'Seleccionar moneda';

  @override
  String get chatSelectEmoji => 'Seleccionar emoji';

  @override
  String get chatSelectRedPacketCover => 'Seleccionar portada';

  @override
  String get groupSetAsAdmin => 'Establecer como admin';

  @override
  String get chatVideoPlaybackFailed => 'Error de reproduccion de video';

  @override
  String get groupViewProfile => 'Ver perfil';

  @override
  String get favoriteAddLinkComingSoon =>
      'Funcion de agregar enlace proximamente';

  @override
  String get favoriteNewNoteComingSoon => 'Funcion de nueva nota proximamente';

  @override
  String get qrcodeSaveFeatureComingSoon => 'Funcion de guardar proximamente';

  @override
  String get qrcodeShareFeatureComingSoon =>
      'Funcion de compartir proximamente';

  @override
  String qrcodeProcessFailed(String error) {
    return 'Error al procesar codigo QR: $error';
  }

  @override
  String get securityDeviceIdRequired => 'Se requiere ID del dispositivo';

  @override
  String securityVerificationStartFailed(String error) {
    return 'No se pudo iniciar la verificación: $error';
  }

  @override
  String get securityVerificationFailed => 'La verificación falló';

  @override
  String securityVerificationFailedWithReason(String reason) {
    return 'Error de verificación: $reason';
  }

  @override
  String get securityEmojiMismatchRejected =>
      'Verificación rechazada: el emoji no coincide';

  @override
  String get securityWaitingForDeviceAccept =>
      'Esperando que el otro dispositivo acepte...';

  @override
  String get securityVerifyDevice => 'Verificar este dispositivo';

  @override
  String get securityConfirmEmojiMatch =>
      'Confirma que los emoji a continuación se muestran en ambos dispositivos, en el mismo orden';

  @override
  String get securityEmojiDontMatch => 'no coinciden';

  @override
  String get securityEmojiMatch => 'coinciden';

  @override
  String get securityWaitingForDeviceConfirm =>
      'Esperando que el otro dispositivo confirme...';

  @override
  String get securityVerificationSuccess => '¡Verificación exitosa!';

  @override
  String get securityDeviceVerifiedTrusted =>
      'Este dispositivo ahora está verificado y es confiable.';

  @override
  String get securityCompareEmoji => 'Compara los emoji en ambos dispositivos';

  @override
  String get securityCompareNumbers =>
      'Compara los números en ambos dispositivos';

  @override
  String get commonTryAgain => 'Inténtalo de nuevo';

  @override
  String get commonDone => 'hecho';

  @override
  String get chatExportTitle => 'Exportar chat';

  @override
  String get chatExportSuccess => 'Exportación exitosa';

  @override
  String chatExportFailed(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String get chatExportFormat => 'Formato de exportación';

  @override
  String get chatExportHtmlDesc =>
      'Legible en cualquier navegador con diseño estilizado.';

  @override
  String get chatExportJsonDesc =>
      'Formato de datos estructurados legible por máquina';

  @override
  String get chatExportDateRange => 'Rango de fechas';

  @override
  String get chatExportAll => 'Todos los mensajes';

  @override
  String get chatExportLastWeek => 'Últimos 7 días';

  @override
  String get chatExportLastMonth => 'El mes pasado';

  @override
  String get chatExportLast3Months => 'Últimos 3 meses';

  @override
  String get chatExportMessageCount => 'Mensajes para exportar';

  @override
  String get chatExportButton => 'Exportar y compartir';

  @override
  String get chatMediaGallery => 'Galería multimedia';

  @override
  String get chatExportHistory => 'Exportar historial de chat';

  @override
  String get pdfLoadFailed => 'No se pudo cargar el PDF';

  @override
  String pdfPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get mediaAll => 'Todos';

  @override
  String get mediaImages => 'Imágenes';

  @override
  String get mediaVideos => 'Vídeos';

  @override
  String get mediaFiles => 'Archivos';

  @override
  String get mediaAudio => 'Audio';

  @override
  String mediaItemsCount(int count) {
    return 'Artículos $count';
  }

  @override
  String get mediaNoMediaFound => 'No se encontraron medios';

  @override
  String get spacesTitle => 'Comunidades';

  @override
  String get spacesCreate => 'Crear comunidad';

  @override
  String get spacesJoined => 'Se unió';

  @override
  String get spacesDiscover => 'Descubrir';

  @override
  String get spacesNoJoined => 'Aún no se ha unido ninguna comunidad';

  @override
  String get spacesExplore => 'Explorar comunidades';

  @override
  String get spacesNoPublic => 'No se encontraron comunidades públicas';

  @override
  String get spacesJoin => 'Unirse';

  @override
  String get spacesSubSpaces => 'Subcomunidades';

  @override
  String get spacesChannels => 'Canales';

  @override
  String spacesMembersCount(int count) {
    return 'Miembros de $count';
  }

  @override
  String get spacesPublic => 'Público';

  @override
  String get spacesPrivate => 'Privado';

  @override
  String get spacesSuggested => 'sugerido';

  @override
  String spacesChannelsCount(int count) {
    return 'Canales $count';
  }

  @override
  String get callInCallChat => 'Chat durante la llamada';

  @override
  String callMessagesCount(int count) {
    return 'Mensajes $count';
  }

  @override
  String get callNoMessagesYet =>
      'Aún no hay mensajes.\nEnvía un mensaje para comenzar.';

  @override
  String get callTypeMessage => 'Escribe un mensaje...';

  @override
  String get callYouSender => 'tu';

  @override
  String get callChatLabel => 'Charla';

  @override
  String get chatEdited => 'Editado';

  @override
  String get chatEditHistory => 'Editar historial';

  @override
  String get chatOriginalMessage => 'Originales';

  @override
  String chatEditedAt(String time) {
    return 'Editado en $time';
  }

  @override
  String get chatViewOnce => 'Ver una vez';

  @override
  String get chatViewOncePhoto => 'Ver una vez la foto';

  @override
  String get chatViewOnceVideo => 'Ver vídeo una vez';

  @override
  String get chatViewOnceViewed => 'Visto';

  @override
  String get chatViewOnceExpired => 'Caducado';

  @override
  String get chatViewOnceTap => 'Toca para ver';

  @override
  String get chatAutoFaceBlur => 'Desenfoque facial automático';

  @override
  String get chatAutoFaceBlurDesc =>
      'Desenfocar rostros automáticamente al enviar fotos';

  @override
  String get threadReplyInThread => 'Responder en el hilo';

  @override
  String threadReplies(int count) {
    return '$count responde';
  }

  @override
  String get threadReply => '1 respuesta';

  @override
  String threadLatestReply(String preview) {
    return 'Lo último: $preview';
  }

  @override
  String get threadTitle => 'Hilo';

  @override
  String get threadReplyPlaceholder => 'Responder en el hilo...';

  @override
  String threadParticipants(int count) {
    return 'Participantes $count';
  }

  @override
  String get voiceRoomTitle => 'Sala de voz';

  @override
  String get voiceRoomCreate => 'Crear sala de voz';

  @override
  String get voiceRoomJoin => 'Unirse';

  @override
  String get voiceRoomLeave => 'salir';

  @override
  String get voiceRoomEnd => 'Sala final';

  @override
  String get voiceRoomRaiseHand => 'levantar la mano';

  @override
  String get voiceRoomLowerHand => 'Mano inferior';

  @override
  String get voiceRoomMute => 'Silenciar';

  @override
  String get voiceRoomUnmute => 'Dejar de silenciar';

  @override
  String get voiceRoomHost => 'Anfitrión';

  @override
  String get voiceRoomSpeakers => 'Altavoces';

  @override
  String get voiceRoomListeners => 'Oyentes';

  @override
  String get voiceRoomLive => 'EN VIVO';

  @override
  String get voiceRoomEnded => 'Terminado';

  @override
  String get voiceRoomScheduled => 'Programado';

  @override
  String get voiceRoomApprove => 'Aprobar';

  @override
  String get voiceRoomDemote => 'Mover al oyente';

  @override
  String voiceRoomHandRaised(String name) {
    return '$name levantaron la mano';
  }

  @override
  String get voiceRoomName => 'Nombre de la habitación';

  @override
  String get voiceRoomTopic => 'Tema (opcional)';

  @override
  String get voiceRoomNoActive => 'No hay salas de voz activas';

  @override
  String get voiceRoomConnecting => 'Conectando...';

  @override
  String get usernameTitle => 'Nombre de usuario';

  @override
  String get usernameSet => 'Establecer nombre de usuario';

  @override
  String get usernameChange => 'Cambiar nombre de usuario';

  @override
  String get usernamePlaceholder => 'Ingrese el nombre de usuario';

  @override
  String get usernameAvailable => 'Nombre de usuario disponible';

  @override
  String get usernameUnavailable => 'Nombre de usuario ya tomado';

  @override
  String get usernameInvalid =>
      '3-30 caracteres, letras minúsculas, números, guiones bajos. Debe comenzar con una letra.';

  @override
  String get usernameReserved => 'Este nombre de usuario está reservado';

  @override
  String get usernameSaved => 'Nombre de usuario guardado';

  @override
  String get usernameSearchHint => 'Buscar por @nombredeusuario';

  @override
  String get ensName => 'Nombre ENS';

  @override
  String get ensLinked => 'Vinculado a la ENS';

  @override
  String get ensResolving => 'Resolviendo ENS...';

  @override
  String get ensNotFound => 'Nombre ENS no encontrado';

  @override
  String get tokenGateTitle => 'Puerta de fichas';

  @override
  String get tokenGateEnable => 'Habilitar puerta de token';

  @override
  String get tokenGateDisable => 'Deshabilitar la puerta de tokens';

  @override
  String get tokenGateAddRule => 'Agregar regla';

  @override
  String get tokenGateRemoveRule => 'Eliminar regla';

  @override
  String get tokenGateContractAddress => 'Dirección del contrato';

  @override
  String get tokenGateMinBalance => 'Saldo Mínimo';

  @override
  String get tokenGateTokenId => 'ID de token (ERC-1155)';

  @override
  String get tokenGateChainId => 'ID de cadena';

  @override
  String get tokenGateVerifying => 'Verificando tenencias de tokens...';

  @override
  String get tokenGateVerified => 'Verificación aprobada';

  @override
  String get tokenGateDenied => 'No cumples con los requisitos del token';

  @override
  String get tokenGateOperatorAnd => 'Debe cumplir TODAS las reglas';

  @override
  String get tokenGateOperatorOr => 'Debe cumplir CUALQUIER regla';

  @override
  String get tokenGateRuleErc20 => 'Ficha ERC-20';

  @override
  String get tokenGateRuleErc721 => 'NFT (ERC-721)';

  @override
  String get tokenGateRuleErc1155 => 'Token múltiple (ERC-1155)';

  @override
  String get tokenGateRuleNative => 'Ficha nativa';

  @override
  String get tokenGateSaved => 'Puerta de token guardada';

  @override
  String get tokenGateEnableDescription =>
      'Requerir que los miembros tengan tokens para unirse';

  @override
  String get tokenGateOperator => 'Lógica de reglas';

  @override
  String get tokenGateRules => 'Reglas';

  @override
  String get tokenGateSymbol => 'Símbolo (opcional)';

  @override
  String get tokenGateChain => 'cadena';

  @override
  String get tokenGateTokenStandard => 'Estándar de token';

  @override
  String get tokenGateDenialMessage => 'Mensaje de negación';

  @override
  String get tokenGateDenialMessageHint =>
      'Mensaje que se muestra cuando falla la verificación';

  @override
  String get tokenGateVerifyTitle => 'Verificación de tokens';

  @override
  String get tokenGateVerifyPassed => 'Verificación aprobada';

  @override
  String get tokenGateVerifyFailed => 'Verificación fallida';

  @override
  String get tokenGateRetryVerify => 'Reintentar';

  @override
  String get tokenGateRequired => 'Requerido';

  @override
  String get tokenGateYourBalance => 'Tu saldo';

  @override
  String get tokenGateRulesActive => 'reglas activas';

  @override
  String get tokenGateDisabled => 'Discapacitado';

  @override
  String get ensNotBound => 'no obligado';

  @override
  String get liveLocation => 'Ubicación en vivo';

  @override
  String get stopLiveLocation => 'dejar de compartir';

  @override
  String get startLiveLocation => 'Empezar a compartir';

  @override
  String get selectDuration => 'Seleccionar duración';

  @override
  String get groupChatFiles => 'Archivos de chat';

  @override
  String get groupLinks => 'Enlaces';

  @override
  String get groupNoLinks => 'Aún no hay enlaces';

  @override
  String get chatBackground => 'Fondo de conversación';

  @override
  String get solidColors => 'Colores sólidos';

  @override
  String get gradients => 'Degradados';

  @override
  String get defaultBackground => 'Predeterminado';

  @override
  String get settingsFontSizeSlider => 'Tamaño de fuente';

  @override
  String get autoDownload => 'Descarga automática';

  @override
  String get images => 'Imágenes';

  @override
  String get voice => 'Voz';

  @override
  String get video => 'Vídeo';

  @override
  String get files => 'Archivos';

  @override
  String get mobileData => 'Datos móviles';

  @override
  String get roaming => 'itinerancia';

  @override
  String get storageManagement => 'Almacenamiento';

  @override
  String get totalUsage => 'Uso total';

  @override
  String get cache => 'caché';

  @override
  String get other => 'Otro';

  @override
  String get clearCache => 'Borrar caché';

  @override
  String get cacheCleared => 'Caché borrado';

  @override
  String get clearCacheFailed => 'No se pudo borrar el caché';

  @override
  String get confirmClearCache => '¿Borrar todos los datos del caché?';

  @override
  String get mapView => 'Vista de mapa';

  @override
  String liveLocationSharingCount(int count) {
    return '$count personas compartiendo ubicación';
  }

  @override
  String get minutes15 => '15 minutos';

  @override
  String get minutes30 => '30 minutos';

  @override
  String get hour1 => '1 hora';

  @override
  String get hours8 => '8 horas';

  @override
  String get personalCard => 'Tarjeta personal';

  @override
  String get downloadFailed => 'Descarga fallida';

  @override
  String get locationExpired => 'Caducado';

  @override
  String secondsRemaining(int count) {
    return '$count segundos';
  }

  @override
  String minutesRemaining(int count) {
    return '$count minutos';
  }

  @override
  String hoursMinutesRemaining(int hours, int minutes) {
    return '$hours horas $minutes minutos';
  }

  @override
  String get favoriteMessages => 'Favoritos';

  @override
  String get linksCopied => 'Enlace copiado';

  @override
  String get noLinksFound => 'No se encontraron enlaces';

  @override
  String get roomStorageRanking =>
      'Clasificación de almacenamiento en habitación';

  @override
  String get downloadComplete => 'Descarga completa';

  @override
  String get downloading => 'Descargando...';

  @override
  String get draftSaved => 'Borrador guardado';

  @override
  String get voiceRecording => 'Grabación de voz';

  @override
  String get searchLocation => 'Buscar ubicación';

  @override
  String get tapToSearch => 'Toca para buscar';

  @override
  String get settingsThisDevice => 'este dispositivo';

  @override
  String get settingsJustNow => 'Justo ahora';

  @override
  String get settingsDeviceId => 'ID del dispositivo';

  @override
  String get settingsStatus => 'Estado';

  @override
  String get settingsLastActive => 'Último activo';

  @override
  String get settingsIpAddress => 'dirección IP';

  @override
  String get settingsRenameDevice => 'Cambiar nombre del dispositivo';

  @override
  String get settingsDeviceNameHint => 'Introduzca el nombre del dispositivo';

  @override
  String get settingsDeviceRenamed => 'Dispositivo renombrado';

  @override
  String get settingsRenameFailed => 'Error al cambiar el nombre';

  @override
  String get settingsRemoteLogout => 'Cierre de sesión remoto';

  @override
  String settingsRemoteLogoutConfirm(String deviceName) {
    return '¿Está seguro de que desea cerrar sesión en \"$deviceName\"? Esta acción no se puede deshacer.';
  }

  @override
  String get settingsDeviceLoggedOut => 'Dispositivo desconectado';

  @override
  String get settingsLogoutFailed => 'Error al cerrar sesión';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get settingsVerifyIdentity => 'Verificar identidad';

  @override
  String get settingsEnterPasswordToConfirm =>
      'Ingrese su contraseña para confirmar esta acción.';

  @override
  String get scheduledSendTitle => 'Programar mensaje';

  @override
  String get scheduledSendInOneHour => 'en 1 hora';

  @override
  String get scheduledSendTonight => 'Esta noche (8:00 p.m.)';

  @override
  String get scheduledSendTomorrowMorning => 'Mañana por la mañana (9:00 a.m.)';

  @override
  String get scheduledSendCustom => 'Elige una fecha y hora';

  @override
  String get scheduledMessageLabel => 'Programado';

  @override
  String get scheduledMessageCancel => 'Cancelar mensaje programado';

  @override
  String get chatLockTitle => 'Bloqueo de chat';

  @override
  String get chatLockEnable => 'Bloquear este chat';

  @override
  String get chatLockDisable => 'Desbloquear este chat';

  @override
  String get chatLockDescription =>
      'Los chats bloqueados requieren verificación biométrica o PIN para abrirse';

  @override
  String get chatLockVerifyTitle => 'Chat bloqueado';

  @override
  String get chatLockVerifySubtitle => 'Verificar para acceder a este chat';

  @override
  String get chatLockVerifyFailed => 'La verificación falló';

  @override
  String get chatLockEnabled => 'Chat bloqueado';

  @override
  String get chatLockDisabled => 'Chat desbloqueado';

  @override
  String get chatLockPinTitle => 'Introducir PIN';

  @override
  String get chatLockPinSetTitle => 'Establecer PIN';

  @override
  String get chatLockPinConfirmTitle => 'Confirmar PIN';

  @override
  String get chatLockPinMismatch => 'El PIN no coincide';

  @override
  String get chatLockUseBiometric => 'Usar biométrico';

  @override
  String get chatLockUsePin => 'Usar PIN';

  @override
  String get mediaEditorUndo => 'Deshacer';

  @override
  String get mediaEditorRedo => 'Rehacer';

  @override
  String get mediaEditorCrop => 'Cultivo';

  @override
  String get mediaEditorFilter => 'Filtrar';

  @override
  String get mediaEditorDraw => 'Dibujar';

  @override
  String get mediaEditorText => 'Texto';

  @override
  String get aiAssistant => 'Asistente de IA';

  @override
  String get aiAssistantWelcome =>
      '¡Hola! Soy el asistente de IA de N42. ¿Le puedo ayudar en algo?';

  @override
  String get aiAssistantNotConfigured => 'Servicio de IA no configurado';

  @override
  String get aiAssistantSettings => 'Configuración de IA';

  @override
  String get aiAssistantClearHistory => 'Borrar historial de chat';

  @override
  String get aiAssistantClearHistoryConfirm =>
      '¿Estás seguro de que quieres borrar todo el historial de chat de IA?';

  @override
  String get aiAssistantStopGenerating => 'dejar de generar';

  @override
  String get aiAssistantModel => 'modelo';

  @override
  String get aiAssistantTemperature => 'Temperatura';

  @override
  String get aiAssistantMaxTokens => 'Fichas máximas';

  @override
  String get aiAssistantContextWindow => 'ventana contextual';

  @override
  String get aiAssistantServiceStatus => 'Estado del servicio';

  @override
  String get aiAssistantAvailable => 'Disponible';

  @override
  String get aiAssistantUnavailable => 'No disponible';

  @override
  String get aiSummarize => 'Resumen de IA';

  @override
  String aiSummarizeUnread(int count) {
    return 'Resumir mensajes no leídos $count';
  }

  @override
  String get aiSummarizeLoading => 'Resumiendo...';

  @override
  String get aiSummarizeError => 'No se pudo resumir';

  @override
  String get aiRewrite => 'Reescritura de IA';

  @override
  String get aiRewriteFormal => 'formales';

  @override
  String get aiRewriteCasual => 'Informal';

  @override
  String get aiRewritePlayful => 'juguetón';

  @override
  String get aiRewriteProfessional => 'Profesional';

  @override
  String get aiRewriteAccept => 'uso';

  @override
  String get aiRewriteCancel => 'Cancelar';

  @override
  String get aiRewriteLoading => 'Reescribiendo...';

  @override
  String get aiLinkSummary => 'Resumen de IA';

  @override
  String get aiLinkSummaryAnalyzing => 'Analizando...';

  @override
  String get chatFolderManagement => 'Administrar carpetas';

  @override
  String get chatFolderSystem => 'Carpetas del sistema';

  @override
  String get chatFolderCustom => 'Carpetas personalizadas';

  @override
  String get chatFolderEmpty => 'Aún no hay carpetas personalizadas';

  @override
  String get chatFolderCreate => 'Crear carpeta';

  @override
  String get chatFolderEdit => 'Editar carpeta';

  @override
  String get chatFolderNameHint => 'Nombre de la carpeta';

  @override
  String get chatFolderAll => 'Todos';

  @override
  String get chatFolderUnread => 'No leído';

  @override
  String get chatFolderPersonal => 'personales';

  @override
  String get chatFolderGroups => 'Grupos';

  @override
  String get chatFolderChannels => 'Canales';

  @override
  String get chatFolderMuted => 'silenciado';

  @override
  String get storyAddMusic => 'Agregar música';

  @override
  String get storyChangeMusic => 'cambiar musica';

  @override
  String get storyBackgroundMusic => 'Música de fondo';

  @override
  String get storyMusicPreview => 'Vista previa (máximo 15 s)';

  @override
  String get storyChooseFromDevice => 'Elija entre dispositivo';

  @override
  String get storyUseThisMusic => 'Usa esta música';

  @override
  String get authPasskeyNotSupported =>
      'La clave de acceso no es compatible con este dispositivo';

  @override
  String get authPasskeyRegister => 'Registrar clave de acceso';

  @override
  String get authPasskeyNoRegistered => 'No hay claves registradas';

  @override
  String get authPasskeyRegisterHint =>
      'Registre una clave de acceso para esta cuenta. El inicio de sesión con contraseña independiente se habilitará más adelante.';

  @override
  String get authPasskeyNameYours => 'Nombra tu clave de acceso';

  @override
  String get authPasskeyRegistered => 'Clave guardada en esta cuenta';

  @override
  String get authPasskeyDeleted => 'Clave de acceso eliminada de esta cuenta';

  @override
  String authPasskeyDeleteConfirm(String name) {
    return '¿Eliminar la clave de acceso \"$name\"? Deberá registrarlo nuevamente antes de utilizar el inicio de sesión con contraseña más adelante.';
  }

  @override
  String get momentVisibilityPublic => 'Público';

  @override
  String get momentVisibilityPrivate => 'Privado';

  @override
  String get momentVisibilityPartial => 'Amigos seleccionados';

  @override
  String get momentVisibilityExcluded => 'Excluir algunos amigos';

  @override
  String momentUserMoments(String userName) {
    return 'Momentos de $userName';
  }

  @override
  String get momentForwardTo => 'Reenviar a';

  @override
  String get momentForwardSuccess => 'Reenviado exitosamente';

  @override
  String get momentSelectFriends => 'Seleccionar amigos';

  @override
  String get momentSelectTags => 'Seleccionar por etiquetas';

  @override
  String momentSelectedCount(int count) {
    return 'Seleccionado ($count)';
  }

  @override
  String get momentNoMomentsYet => 'Aún no hay momentos';

  @override
  String get momentForwardMoment => 'Momento de avance';

  @override
  String get momentAddComment => 'Añade un comentario...';

  @override
  String momentForwardContent(String content) {
    return '[Momento] $content';
  }

  @override
  String get momentDeleteMoment => 'Eliminar momento';

  @override
  String get momentDeleteConfirm =>
      '¿Estás seguro de que quieres eliminar este momento?';

  @override
  String get momentComment => 'Comentario';

  @override
  String get momentWriteComment => 'Escribe un comentario...';

  @override
  String get momentLike => 'Me gusta';

  @override
  String get momentUnlike => 'a diferencia';

  @override
  String get momentForward => 'Adelante';

  @override
  String get momentDelete => 'Eliminar';

  @override
  String get momentReply => 'responder';

  @override
  String get momentMoment => 'momento';

  @override
  String momentLikesCount(int count) {
    return 'A $count le gusta';
  }

  @override
  String momentCommentsCount(int count) {
    return 'Comentarios sobre $count';
  }

  @override
  String get momentNoComments => 'Aún no hay comentarios';

  @override
  String get momentFailedToLoad => 'No se pudo cargar la imagen';

  @override
  String momentReplyTo(String userName) {
    return 'Responder a $userName...';
  }

  @override
  String get momentNoConversations => 'Sin conversaciones';

  @override
  String get momentJustNow => 'justo ahora';

  @override
  String momentMinutesAgo(int count) {
    return 'Hace ${count}m';
  }

  @override
  String momentHoursAgo(int count) {
    return 'Hace ${count}h';
  }

  @override
  String momentDaysAgo(int count) {
    return 'Hace ${count}d';
  }

  @override
  String get chatGroupAnnouncementHint => 'Ingresar anuncio de grupo';

  @override
  String get chatGroupAnnouncementEmpty => 'Sin anuncio';

  @override
  String get chatEditNickname => 'Editar apodo';

  @override
  String get chatNicknameHint => 'Introduce tu apodo en este grupo';

  @override
  String get contactAddPhoneHint => 'Introduce el número de teléfono';

  @override
  String get contactNotesHint => 'Agregar notas sobre este contacto';

  @override
  String get reportTitle => 'Informe';

  @override
  String get reportReasonSpam => 'spam';

  @override
  String get reportReasonHarassment => 'Acoso';

  @override
  String get reportReasonFraud => 'fraude';

  @override
  String get reportReasonOther => 'Otro';

  @override
  String get reportSubmitted => 'Informe enviado';

  @override
  String get reportDescription => 'Descripción adicional (opcional)';

  @override
  String get qrcodeSaved => 'Código QR guardado en el álbum';

  @override
  String get chatSendRedPacketInChat =>
      'Por favor envíe el paquete rojo en el chat.';

  @override
  String get commonSaveFailed => 'Error al guardar';

  @override
  String get reportSelectReason => 'Por favor seleccione un motivo';

  @override
  String get gameCenter => 'Juegos';

  @override
  String get gameHighScore => 'Récord';

  @override
  String get gameScore => 'Puntuación';

  @override
  String get gameOver => 'Fin del juego';

  @override
  String get gamePlayAgain => 'Jugar de nuevo';

  @override
  String get gameLeaderboard => 'Clasificación';

  @override
  String get gamePause => 'Pausado';

  @override
  String get gameResume => 'Toca para continuar';

  @override
  String get gameConfirmExit => '¿Salir del juego?';

  @override
  String get gameNoScores => 'Sin puntuaciones';

  @override
  String get game2048 => '2048';

  @override
  String get game2048Desc => 'Combina fichas hasta llegar a 2048';

  @override
  String get gameBlockDrop => 'Caída de bloque';

  @override
  String get gameBlockDropDesc => 'Deja caer y elimina líneas';

  @override
  String get gameMinesweeper => 'Buscaminas';

  @override
  String get gameMinesweeperDesc => 'Encuentra todas las celdas seguras';

  @override
  String get gameMatch3 => 'Partido 3';

  @override
  String get gameMatch3Desc => 'Conecta 3 o más gemas';

  @override
  String get gameMinesweeperEasy => 'Fácil';

  @override
  String get gameMinesweeperMedium => 'Medio';

  @override
  String get gameMinesLeft => 'Minas restantes';

  @override
  String get gameTimeLeft => 'Tiempo';

  @override
  String get gameLevel => 'Nivel';

  @override
  String get gameNext => 'Siguiente';

  @override
  String get gameBestTime => 'Mejor tiempo';

  @override
  String get gameNewRecord => '¡Nuevo récord!';

  @override
  String get gameLines => 'Líneas';

  @override
  String get storyMyStory => 'Mi historia';

  @override
  String get storageSmartCleanup => 'Limpieza inteligente';

  @override
  String get storageOldMediaFiles => 'Archivos multimedia antiguos';

  @override
  String get storageLargeFiles => 'Archivos grandes';

  @override
  String get storageAppCache => 'Caché de aplicaciones';

  @override
  String get storageSettings => 'Configuración de almacenamiento';

  @override
  String get storageAutoCleanup => 'Limpieza automática';

  @override
  String storageAutoCleanupDesc(int days) {
    return 'Limpiar automáticamente archivos de más de días $days';
  }

  @override
  String get storageCleanupPeriod => 'Período de limpieza';

  @override
  String get storagePreserveThumbnails => 'Conservar miniaturas';

  @override
  String get storagePreserveThumbnailsDesc =>
      'Mantener miniaturas de imágenes durante la limpieza';

  @override
  String get storageWarningHigh =>
      'El uso de almacenamiento es alto. Considere la posibilidad de limpiar archivos antiguos.';

  @override
  String get storageWarningCritical =>
      'El almacenamiento es críticamente bajo. Por favor, limpie para liberar espacio.';

  @override
  String storageFreed(String size, int count) {
    return '$size liberado (archivos $count)';
  }

  @override
  String storageDays(int days) {
    return '$days días';
  }

  @override
  String storageViewAllRooms(int count) {
    return 'Ver todas las habitaciones $count';
  }

  @override
  String get storageNoFiles => 'No se encontraron archivos';

  @override
  String get storageFilePinned => 'Fijado';

  @override
  String storageDeleteSelected(int count) {
    return '¿Eliminar los archivos seleccionados $count? Se pueden volver a descargar desde el servidor.';
  }

  @override
  String get backupRestore => 'Copia de seguridad y restauración';

  @override
  String get backupCreate => 'Crear copia de seguridad';

  @override
  String get backupCreateDesc =>
      'Haga una copia de seguridad de su configuración y claves de cifrado. Los mensajes se restaurarán desde el servidor después de volver a iniciar sesión.';

  @override
  String get backupIncludeKeys => 'Incluir claves de cifrado';

  @override
  String get backupIncludeKeysDesc => 'Requerido para leer mensajes cifrados';

  @override
  String get backupPasswordProtect => 'Proteger con contraseña';

  @override
  String get backupEnterPassword => 'Ingrese la contraseña de respaldo';

  @override
  String get backupHistory => 'Historial de copias de seguridad';

  @override
  String get backupNoBackups => 'Aún no hay copias de seguridad';

  @override
  String get backupRestore2 => 'Restaurar';

  @override
  String get backupDelete => 'Eliminar';

  @override
  String get backupDeleteConfirm =>
      '¿Estás seguro de que deseas eliminar esta copia de seguridad? Esto no se puede deshacer.';

  @override
  String get backupRestoreFromFile => 'Restaurar desde archivo';

  @override
  String get backupRestoreFromFileDesc =>
      'Importe un archivo de copia de seguridad .n42 desde otro dispositivo o una copia de seguridad anterior.';

  @override
  String get backupChooseFile => 'Elija el archivo de copia de seguridad';

  @override
  String get backupRestoring => 'Restaurando...';

  @override
  String backupCreated(int rooms, int messages) {
    return 'Copia de seguridad creada: salas $rooms, mensajes $messages';
  }

  @override
  String backupRestored(int settings, int rooms) {
    return 'Configuración $settings restaurada de las salas $rooms';
  }

  @override
  String backupFailed(String error) {
    return 'Error en la copia de seguridad: $error';
  }

  @override
  String get backupPasswordRequired =>
      'Esta copia de seguridad está protegida con contraseña';

  @override
  String get blocGroupNotFound => 'Grupo no encontrado';

  @override
  String blocGroupMembersInvited(int count) {
    return 'Miembro(s) invitado(s) de $count';
  }

  @override
  String get blocGroupMemberRemoved => 'Miembro eliminado';

  @override
  String get blocGroupAdminRemoved => 'Administrador eliminado';

  @override
  String get blocGroupLeft => 'Dejó el grupo';

  @override
  String get blocGroupDisbanded => 'Grupo disuelto';

  @override
  String get blocGroupJoined => 'Se unió al grupo';

  @override
  String get blocGroupInviteDeclined => 'Invitación rechazada';

  @override
  String get blocGroupTokenGateUpdated => 'Puerta de token actualizada';

  @override
  String get blocTransferProcessing => 'Procesando transferencia...';

  @override
  String get blocTransferCancelled => 'Transferencia cancelada';

  @override
  String get blocTransferFailed => 'Transferencia fallida';

  @override
  String get blocPaymentProcessing => 'Procesando pago...';

  @override
  String get blocPaymentFailed => 'Pago fallido';

  @override
  String get groupMaxMembers => 'Límite de miembros';

  @override
  String get groupMaxMembersUnlimited => 'Ilimitado';

  @override
  String get groupMaxMembersHint =>
      'Ingrese el límite (déjelo vacío para ilimitado)';

  @override
  String get groupMaxMembersUpdated => 'Límite de miembros actualizado';

  @override
  String get groupFull => 'El grupo está al límite de su capacidad.';

  @override
  String get groupChannels => 'Canales temáticos';

  @override
  String get groupChannelsEmpty => 'Aún no hay canales';

  @override
  String get groupChannelsCount => 'canales';

  @override
  String get groupChannelCreate => 'Nuevo canal';

  @override
  String get groupChannelName => 'Nombre del canal';

  @override
  String get groupChannelTopic => 'Tema del canal (opcional)';

  @override
  String get groupChannelDelete => 'Eliminar canal';

  @override
  String get groupChannelDeleteConfirm =>
      '¿Eliminar este canal? Todos los mensajes se perderán.';

  @override
  String get groupBotSettings => 'Configuración de robots';

  @override
  String get groupBotEnabled => 'Habilitar robot';

  @override
  String get groupBotWelcomeMessage => 'Plantilla de mensaje de bienvenida';

  @override
  String get groupBotWelcomeHint =>
      'Utilice \'nombre\' como marcador de posición para el nombre del nuevo miembro';

  @override
  String get groupBotConfigUpdated => 'Configuración del bot actualizada';

  @override
  String get groupContentFilter => 'Filtro de contenido';

  @override
  String get groupContentFilterEnabled => 'Habilitar filtro de palabras clave';

  @override
  String get groupContentFilterReplace => 'Reemplazar con ***';

  @override
  String get groupContentFilterHide => 'Ocultar mensaje';

  @override
  String get groupContentFilterAddWord => 'Agregar palabra clave';

  @override
  String get groupContentFilterUpdated => 'Filtro de contenido actualizado';

  @override
  String get chatSlashCommands => 'Comandos';

  @override
  String get chatCommandPoll => '/encuesta — Crear una encuesta';

  @override
  String get chatCommandAnnounce => '/announce — Enviar anuncio';

  @override
  String get chatCommandWelcome =>
      '/welcome — Establecer mensaje de bienvenida';

  @override
  String get chatReportMessage => 'Informe';

  @override
  String get chatReportReason => 'Motivo del informe';

  @override
  String get chatReportSpam => 'spam';

  @override
  String get chatReportHarassment => 'Acoso';

  @override
  String get chatReportInappropriate => 'Contenido inapropiado';

  @override
  String get chatReportOther => 'Otro';

  @override
  String get chatReportSuccess => 'Informe enviado';

  @override
  String get spacesName => 'Nombre de la comunidad';

  @override
  String get spacesNameHint => 'por ej. Comerciantes de criptomonedas';

  @override
  String get spacesNameRequired => 'El nombre es obligatorio';

  @override
  String get spacesDescription => 'Descripción';

  @override
  String get spacesDescriptionHint => '¿De qué se trata esta comunidad?';

  @override
  String get spacesType => 'Tipo de comunidad';

  @override
  String get spacesPublicDesc => 'Cualquiera puede descubrir y unirse.';

  @override
  String get spacesPrivateDesc => 'Sólo los miembros invitados pueden unirse';

  @override
  String get spacesNotFound => 'Comunidad no encontrada';

  @override
  String get spacesSearch => 'Buscar comunidades...';

  @override
  String get spacesMembers => 'Miembros';

  @override
  String get spacesNoChannels => 'Aún no hay canales';

  @override
  String get spacesLeave => 'Salir de la comunidad';

  @override
  String spacesLeaveConfirm(String name) {
    return '¿Está seguro de que desea dejar \"$name\"?';
  }

  @override
  String get spacesDelete => 'Eliminar comunidad';

  @override
  String spacesDeleteConfirm(String name) {
    return 'Esto eliminará permanentemente \"$name\" y todos sus canales. Esta acción no se puede deshacer.';
  }

  @override
  String get spacesCreateChannel => 'Agregar canal';

  @override
  String get spacesChannelName => 'Nombre del canal';

  @override
  String get spacesChannelTopic => 'Tema (opcional)';

  @override
  String get spacesDeleteChannel => 'Eliminar canal';

  @override
  String spacesDeleteChannelConfirm(String name) {
    return '¿Está seguro de que desea eliminar \"#$name\"?';
  }

  @override
  String get spacesEditName => 'Editar nombre';

  @override
  String get spacesEditDescription => 'Editar descripción';

  @override
  String spacesViewAllMembers(int count) {
    return 'Ver todos los miembros de $count';
  }

  @override
  String spacesKickMemberTitle(String name) {
    return 'Patada $name';
  }

  @override
  String spacesBanMemberTitle(String name) {
    return 'Prohibición $name';
  }

  @override
  String get spacesPromoteAdmin => 'Promocionar a administrador';

  @override
  String get spacesDemoteAdmin => 'Eliminar administrador';

  @override
  String get spacesInviteMember => 'Invitar miembro';

  @override
  String get spacesInviteMemberUserId =>
      'ID de usuario (por ejemplo, @user:server.com)';

  @override
  String get spacesSave => 'Guardar';

  @override
  String get settingsScreenshotProtection =>
      'Protección de captura de pantalla';

  @override
  String get settingsScreenshotProtectionDesc =>
      'Evitar capturas de pantalla y grabaciones de pantalla';

  @override
  String get chatSelfDestructTimer => 'Autodestrucción';

  @override
  String get chatTimerPickerTitle => 'Temporizador de autodestrucción';

  @override
  String get chatTimerOff => 'Apagado';

  @override
  String get onChainNotificationsTitle => 'Eventos on-chain';

  @override
  String get onChainMarkAllRead => 'Marcar todo como leído';

  @override
  String get onChainNoNotifications => 'Aún no hay eventos on-chain';

  @override
  String get onChainNoNotificationsDesc =>
      'Los eventos de los canales suscritos aparecerán aquí';

  @override
  String get onChainViewDetails => 'Ver detalles';

  @override
  String get chatCommandHelp => '/help — Ver todos los comandos';

  @override
  String get chatCommandPrice => '/price — Obtener precio del token';

  @override
  String get chatCommandBalance => '/balance — Ver saldo de la billetera';

  @override
  String get chatCommandChains => '/chains — Listar 236+ redes soportadas';

  @override
  String get chatMiniApps => 'Aplicaciones';

  @override
  String get miniAppMarketTitle => 'Miniaplicaciones';

  @override
  String get miniAppCategoryAll => 'Todas';

  @override
  String get miniAppSearch => 'Buscar apps...';

  @override
  String get miniAppFeatured => 'Destacados';

  @override
  String get miniAppAllApps => 'Todas las Apps';

  @override
  String get miniAppNoResults => 'No se encontraron apps';

  @override
  String get slideToPayLabel => '→→→  Desliza para confirmar';

  @override
  String get slideToPayConfirming => 'Confirmando...';

  @override
  String get redPacketBestLuck => 'Mejor suerte';

  @override
  String get redPacketBestLuckCongrats => '¡Mejor suerte! ¡Recibiste más!';

  @override
  String redPacketStats(int claimed, int total) {
    return '$claimed / $total reclamados';
  }

  @override
  String get redPacketStatsTotal => 'total';

  @override
  String redPacketGrabbedViral(String amount, String token) {
    return '🧧 Recibió un sobre rojo • $amount $token';
  }

  @override
  String get web3SearchHint => '@matrix:id  •  dirección 0x  •  name.eth';

  @override
  String get web3SearchPlaceholder => 'Buscar por ID, wallet o ENS...';

  @override
  String get web3WalletAddress => 'Dirección de wallet';

  @override
  String get web3AddressCopied => 'Dirección copiada';

  @override
  String get web3Copy => 'Copiar';

  @override
  String get web3SendMessage => 'Enviar mensaje';

  @override
  String get web3SendToWallet => 'Mensaje al wallet';

  @override
  String get web3WalletOnlyHint =>
      'Esta dirección no tiene cuenta N42. El mensaje se entregará cuando se registre.';

  @override
  String get web3NftAvatar => 'Avatar NFT';

  @override
  String get web3ResolveFailed => 'Error al resolver identidad';

  @override
  String web3EnsNotFound(String name) {
    return 'Nombre ENS \"$name\" no encontrado';
  }

  @override
  String get web3NoN42AccountTitle => 'Sin cuenta N42';

  @override
  String get web3NoN42AccountDesc =>
      'Esta dirección de billetera aún no tiene una cuenta N42. Puedes compartir tu enlace de invitación de N42 con ellos para comenzar.';

  @override
  String get web3ShareInvite => 'Compartir invitación';

  @override
  String get nftPickerTitle => 'Seleccionar avatar NFT';

  @override
  String get nftPickerTabPopular => 'populares';

  @override
  String get nftPickerTabCustom => 'Personalizado';

  @override
  String get nftPickerChain => 'cadena';

  @override
  String get nftPickerContract => 'Dirección del contrato';

  @override
  String get nftPickerTokenId => 'ID de token';

  @override
  String get nftPickerVerifyOwnership => 'Verificar propiedad y previsualizar';

  @override
  String get nftPickerUseAsAvatar => 'Usar como avatar';

  @override
  String get nftPickerPreview => 'Vista previa';

  @override
  String get nftPickerNotOwned => 'No posees este NFT';

  @override
  String get nftPickerInvalidTokenId => 'ID de token no válido';

  @override
  String get nftPickerEnterBoth =>
      'Ingrese la dirección del contrato y el ID del token';

  @override
  String get nftPickerInfoTitle => 'Avatar NFT — Verificado en cadena';

  @override
  String get nftPickerInfoDesc =>
      'Vincula un NFT de tu propiedad como tu avatar. Cualquiera puede verificar la propiedad en la cadena. Se muestra con un anillo dorado en N42.';

  @override
  String get nftPickerPopularCollections => 'Colecciones populares';

  @override
  String get nftPickerWalletHint =>
      'Conecta tu wallet N42 para descubrir automáticamente tus NFT en 236+ cadenas.';

  @override
  String get profileBindNftAvatar => 'Vincular avatar NFT';

  @override
  String get profileChangeAvatar => 'Cambiar avatar';

  @override
  String get groupTopics => 'Temas';

  @override
  String get groupTopicsEmpty => 'Sin temas aún';

  @override
  String get syncInProgress => 'Sincronizando historial de mensajes...';

  @override
  String get recoveryKeyReminderTitle => 'Protege tus mensajes';

  @override
  String get recoveryKeyReminderDesc =>
      'Crea una clave de recuperación para sincronizar mensajes cifrados en todos los dispositivos';

  @override
  String get recoveryKeySetupNow => 'Configurar ahora';

  @override
  String get recoveryKeyRemindLater => 'Recordar después';

  @override
  String get channelReadOnly =>
      'Solo los administradores pueden publicar en este canal.';

  @override
  String get channelSubscribers => 'suscriptores';

  @override
  String get channelVerified => 'Canal verificado';

  @override
  String get redPacketHistory => 'Historia del paquete rojo';

  @override
  String get redPacketSent => 'Enviado';

  @override
  String get redPacketReceived => 'Recibido';

  @override
  String get redPacketExpired => 'Caducado';

  @override
  String get redPacketClaimed => 'Reclamado';

  @override
  String get redPacketInsufficientBalance => 'Saldo insuficiente';

  @override
  String selfDestructCountdown(String time) {
    return 'Autodestrucción en $time';
  }

  @override
  String get messageDestroyed => 'Mensaje destruido';

  @override
  String miniAppPermissionDenied(String permission) {
    return 'Permiso denegado: $permission';
  }

  @override
  String get aiSuggestionGasFee => '¿Qué es la tarifa del gas?';

  @override
  String get aiSuggestionDefi => 'Guía para principiantes de DeFi';

  @override
  String get aiSuggestionSecurity => 'Cómo comprobar la seguridad del contrato';

  @override
  String get aiSuggestionBridge => 'Puente entre cadenas';

  @override
  String get channelDiscoverTitle => 'Descubrir canales';

  @override
  String get channelDiscoverSearch => 'Buscar canales...';

  @override
  String get channelJoin => 'Unirse';

  @override
  String get channelJoined => 'Se unió';

  @override
  String get channelCategory => 'categoría';

  @override
  String slowModeCooldown(int seconds) {
    return 'Modo lento: espera ${seconds}s';
  }

  @override
  String get addressCopyAction => 'Copiar dirección';

  @override
  String get addressSendMessage => 'Enviar mensaje';

  @override
  String get addressViewProfile => 'Ver perfil';

  @override
  String get sendToAddress => 'Enviar a la dirección de la billetera';

  @override
  String get blocAuthSendVerificationCodeFailed =>
      'No se pudo enviar el código de verificación';

  @override
  String get blocAuthServerNoEmailPasswordReset =>
      'Este servidor no admite el restablecimiento de contraseña de correo electrónico';

  @override
  String get blocAuthResetPasswordFailed =>
      'No se pudo restablecer la contraseña';

  @override
  String get blocAuthChangePasswordFailed => 'No se pudo cambiar la contraseña';

  @override
  String get blocAuthOldPasswordWrong => 'Contraseña actual incorrecta';

  @override
  String get blocAuthLoginCancelled => 'Inicio de sesión cancelado';

  @override
  String get blocAuthGoogleLoginFailed => 'Error al iniciar sesión en Google';

  @override
  String get blocAuthAppleLoginFailed => 'Error al iniciar sesión en Apple';

  @override
  String get blocAuthSsoLoginFailed => 'Error al iniciar sesión en SSO';

  @override
  String get blocAuthFacebookLoginFailed =>
      'Error al iniciar sesión en Facebook';

  @override
  String get blocAuthTwitterLoginFailed => 'Error al iniciar sesión en Twitter';

  @override
  String get blocAuthWeChatLoginFailed => 'Error al iniciar sesión en WeChat';

  @override
  String get blocAuthWeChatNotConfigured =>
      'Inicio de sesión de WeChat no configurado';

  @override
  String get blocAuthWeChatNotInstalled => 'Instale WeChat primero';

  @override
  String get blocAuthPasswordWrong => 'Contraseña incorrecta';

  @override
  String get blocAuthEmailAlreadyBound =>
      'Este correo electrónico ya está vinculado a otra cuenta.';

  @override
  String get blocAuthChangeEmailFailed =>
      'No se pudo cambiar el correo electrónico';

  @override
  String get blocAuthVerificationCodeInvalid =>
      'El código de verificación es incorrecto o ha caducado';

  @override
  String get blocAuthSessionExpired =>
      'La sesión expiró, inicie sesión nuevamente';

  @override
  String get blocAuthSessionIncomplete =>
      'Datos de sesión incompletos, inicie sesión nuevamente';
}

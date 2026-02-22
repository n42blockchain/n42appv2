// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a pt locale. All the
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
  String get localeName => 'pt';

  static String m0(deviceName, os) =>
      "Sua conta acabou de ser conectada em ${deviceName} (${os}). Se não foi você, recomendamos alterar sua senha.";

  static String m1(value) => "Eu sou ${value}";

  static String m2(value) => "Membro do chat (${value})";

  static String m3(value) =>
      "Tem certeza que deseja adicionar ${value} como amigo";

  static String m4(value) =>
      "Você já está vinculado e não pode ser revinculado no momento. Endereço vinculado: ${value}.";

  static String m5(value) =>
      "Vinculação bem-sucedida. Endereço vinculado: ${value}";

  static String m6(value) => "Não há N42chain na carteira ${value}!";

  static String m7(value) => "Correspondência bem-sucedida. Endereço:${value}.";

  static String m8(value) => "Valor maior que ${value}.";

  static String m9(value) =>
      "A carteira já existe, o nome da carteira é \"${value}\"";

  static String m10(value) => "Digite um valor maior que ${value}.";

  static String m11(gas) =>
      "O gas de execução (${gas}) está alto. O contrato chamado pode consumir mais gas do que o esperado.";

  static String m12(gas) =>
      "A primeira transação inclui a implantação da conta (~${gas} gas). As transações subsequentes serão mais baratas.";

  static String m13(gas) =>
      "O overhead de gas do paymaster (${gas}) está alto. Transações sem gas podem custar mais.";

  static String m14(gas) =>
      "O gas total estimado (${gas}) está incomumente alto. Verifique sua transação por erros.";

  static String m15(gas) =>
      "O gas de verificação (${gas}) pode estar muito alto. Isso pode ocorrer com lógica de conta complexa.";

  static String m16(value) => "${value} dias restantes";

  static String m17(value) => "Endereço duplicado na linha ${value}";

  static String m18(value) => "Endereço inválido na linha ${value}";

  static String m19(value) => "Valor inválido na linha ${value}";

  static String m20(value) => "Máximo ${value} destinatários";

  static String m21(value) => "+${value} pts/day";

  static String m22(value) => "Earn up to ${value}% APY";

  static String m23(value) => "Congratulations! You now own ${value}";

  static String m24(value) => "Please wait ${value} seconds";

  static String m25(value) => "Auto-refresh every ${value} seconds";

  static String m26(address) => "Conta ${address} adicionada";

  static String m27(address, network) =>
      "Deseja rastrear esta conta de hardware wallet?\n\nEndereço: ${address}\nRede: ${network}";

  static String m28(app) => "Current app: ${app}";

  static String m29(days) => "${days} days ago";

  static String m30(value) => "Falha ao importar conta: ${value}";

  static String m31(date) => "Last connected: ${date}";

  static String m32(value) =>
      "Por favor abra o app ${value} no seu dispositivo";

  static String m33(app) =>
      "Certifique-se de que o aplicativo ${app} está aberto no seu Ledger";

  static String m34(name) =>
      "Are you sure you want to remove \"${name}\" from saved devices?";

  static String m35(value) => "Earn ${value} points";

  static String m36(value) => "Earn ${value} points for each friend who joins!";

  static String m37(value) => "${value} pontos para o próximo nível";

  static String m38(amount, token) => "≈ ${amount}${token}";

  static String m39(amount) => "≈ ${amount} USDT";

  static String m40(value) =>
      "Tem certeza que deseja excluir o contato ${value}?";

  static String m41(value) => "${value}d unbond";

  static String m42(value) => "${value} dias restantes";

  static String m43(value) => "${value} days remaining";

  static String m44(value) => "Você não tem \"${value}\" suficiente";

  static String m45(value) => "Falha ao obter conta \"${value}\"";

  static String m46(value) =>
      "Mínimo de ${value} XRP para primeira transferência";

  static String m47(value) => "${value}d ago";

  static String m48(value) => "${value}h ago";

  static String m49(value) => "${value}m ago";

  static String m50(value) => "Verification code sent to ${value}";

  static String m51(value) => "Nenhuma rede ${value} adicionada.";

  static String m52(value) =>
      "${value} tem transações não finalizadas, por favor tente novamente mais tarde.";

  static String m53(value) => "Nenhum endereço encontrado para ${value}.";

  static String m54(value) => "Saldo insuficiente de ${value}.";

  static String m55(value, value1) =>
      "Cada conta XRP deve reservar ${value} XRP (${value1} drops) como base, que não pode ser gasto.";

  static String m56(value, value1) =>
      "Para cada objeto que a conta possui, ${value} XRP (${value1} drops) é adicionado à reserva.";

  static String m57(value, value1) =>
      "Esta conta possui ${value} objetos, o que significa que ${value1} XRP adicional é reservado.";

  static String m58(value) =>
      "Erro na senha de padrão, você tem ${value} tentativas";

  static String m59(value) =>
      "Erro na senha de padrão, você tem ${value} tentativa";

  static String m60(value) =>
      "Você configurou com sucesso um ${value} e começará a verificação com a N42Wallet!";

  static String m61(value) =>
      "Junte-se ao meu grupo ${value} na @N42Wallet para ser um minerador inicial de uma blockchain Layer 1 e ganhe criptomoedas no seu celular!";

  static String m62(value) => "Bloqueie ${value} N para executar um validador.";

  static String m63(value) => "Falha na importação:${value}";

  static String m64(value) =>
      "É necessário um saldo de staking de pelo menos ${value} para receber recompensas.";

  static String m65(value, value1) =>
      "${value} N a cada ${value1} blocos minerados";

  static String m66(value) => "Deve ter ${value} caracteres";

  static String m67(value) => "Saldo insuficiente de ${value}.";

  static String m68(value) => "${value} a caminho...";

  static String m69(value) =>
      "${value} trocados no app serão distribuídos em breve para sua carteira e não podem ser vendidos por este processo. Pode ser usado para executar um nó.";

  static String m70(value) => "Máximo de ${value} caracteres";

  static String m71(value) => "A rede ${value} já é suportada pelo APP!";

  static String m72(value) =>
      "A rede ${value} já é suportada pelo APP, deseja adicioná-la?";

  static String m73(value) =>
      "Falha no teste de conexão do endereço da rede ${value}!";

  static String m74(value) =>
      "O aplicativo será desbloqueado em ${value} segundos.";

  static String m75(value) =>
      "Erro na senha de padrão, você tem ${value} tentativas";

  static String m76(value) => "Erro na senha, você tem ${value} tentativas";

  static String m77(value) => "Erro na senha, você tem ${value} tentativa";

  static String m78(value) => "Digite a senha ${value}";

  static String m79(value) => "0~${value} caracteres";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Create_account": MessageLookupByLibrary.simpleMessage("Criar conta"),
    "Create_your_account": MessageLookupByLibrary.simpleMessage(
      "Crie sua conta",
    ),
    "Edit": MessageLookupByLibrary.simpleMessage("Editar"),
    "Verification": MessageLookupByLibrary.simpleMessage("Verificação"),
    "address_Information": MessageLookupByLibrary.simpleMessage(
      "Informações de Endereço",
    ),
    "code_403": MessageLookupByLibrary.simpleMessage(
      "Conta temporariamente bloqueada por um dia",
    ),
    "code_err_tips": MessageLookupByLibrary.simpleMessage(
      "O código está incorreto. Por favor, tente novamente.",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copiado com sucesso"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("Copiar Endereço"),
    "descO": MessageLookupByLibrary.simpleMessage("Descrição (Opcional)"),
    "device_login_change_password": MessageLookupByLibrary.simpleMessage(
      "Alterar senha",
    ),
    "device_login_dismiss": MessageLookupByLibrary.simpleMessage("Entendi"),
    "device_login_message": m0,
    "device_login_title": MessageLookupByLibrary.simpleMessage(
      "Novo login de dispositivo",
    ),
    "editPhoto": MessageLookupByLibrary.simpleMessage("Editar foto"),
    "email_code_error": MessageLookupByLibrary.simpleMessage(
      "Falha ao obter código de autenticação",
    ),
    "email_code_finish": MessageLookupByLibrary.simpleMessage(
      "Código de autenticação enviado com sucesso, por favor verifique seu e-mail",
    ),
    "email_code_input_error": MessageLookupByLibrary.simpleMessage(
      "Erro no código de autenticação",
    ),
    "email_error": MessageLookupByLibrary.simpleMessage(
      "Endereço de e-mail inválido",
    ),
    "email_verification": MessageLookupByLibrary.simpleMessage(
      "Autenticação de Endereço de E-mail",
    ),
    "email_verification_message1": MessageLookupByLibrary.simpleMessage(
      "O autenticador de endereço de e-mail protege seus saques e conta N42Wallet.",
    ),
    "email_verification_message2": MessageLookupByLibrary.simpleMessage(
      "Adicionar verificação de e-mail?",
    ),
    "file": MessageLookupByLibrary.simpleMessage("Arquivo"),
    "g_2fa_backup_hint": MessageLookupByLibrary.simpleMessage(
      "Salve esta chave — você precisará dela se perder o telefone.",
    ),
    "g_2fa_backup_share": MessageLookupByLibrary.simpleMessage("Compartilhar"),
    "g_2fa_backup_share_text": MessageLookupByLibrary.simpleMessage(
      "Chave de backup do Google Authenticator N42Wallet",
    ),
    "g_2fa_disable_confirm_hint": MessageLookupByLibrary.simpleMessage(
      "Insira o código de 6 dígitos do Google Authenticator para desativar o 2FA.",
    ),
    "g_2fa_disable_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Desativar Google 2FA",
    ),
    "g_2fa_disable_error": MessageLookupByLibrary.simpleMessage(
      "Falha ao desativar o Google 2FA. Verifique o código e tente novamente.",
    ),
    "g_2fa_disable_success": MessageLookupByLibrary.simpleMessage(
      "Google 2FA foi desativado",
    ),
    "g_2fa_invalid_format": MessageLookupByLibrary.simpleMessage(
      "Insira um código válido de 6 dígitos",
    ),
    "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
      "Tokens só podem ser enviados dentro da mesma rede. Enviar de outras redes pode resultar em perda.",
    ),
    "g_app_share_key_2": MessageLookupByLibrary.simpleMessage(
      "Escaneie para receber",
    ),
    "g_biometric_locked_out": MessageLookupByLibrary.simpleMessage(
      "Muitas tentativas. Biometria bloqueada — use a senha.",
    ),
    "g_biometric_not_enrolled": MessageLookupByLibrary.simpleMessage(
      "Biometria não configurada. Ative nas Configurações.",
    ),
    "g_biometric_retry": MessageLookupByLibrary.simpleMessage(
      "Usar Face ID / Touch ID",
    ),
    "g_browser_key1": MessageLookupByLibrary.simpleMessage(
      "Por favor, digite a URL",
    ),
    "g_browser_key10": MessageLookupByLibrary.simpleMessage(
      "Digite uma descrição",
    ),
    "g_browser_key11": MessageLookupByLibrary.simpleMessage("Navegador"),
    "g_browser_key12": MessageLookupByLibrary.simpleMessage(
      "Limpar Cache do Navegador",
    ),
    "g_browser_key13": MessageLookupByLibrary.simpleMessage(
      "Conectar DApp automaticamente",
    ),
    "g_browser_key14": MessageLookupByLibrary.simpleMessage(
      "Por favor, confirme a conexão com o DApp",
    ),
    "g_browser_key16": MessageLookupByLibrary.simpleMessage("Fechar tudo"),
    "g_browser_key17": MessageLookupByLibrary.simpleMessage("Concluído"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("Favoritos"),
    "g_browser_key4": MessageLookupByLibrary.simpleMessage(
      "Nenhum favorito adicionado ainda",
    ),
    "g_browser_key5": MessageLookupByLibrary.simpleMessage("Favorito"),
    "g_browser_key6": MessageLookupByLibrary.simpleMessage("Nome"),
    "g_browser_key7": MessageLookupByLibrary.simpleMessage(
      "Por favor, digite o nome",
    ),
    "g_browser_key8": MessageLookupByLibrary.simpleMessage("URL"),
    "g_browser_key9": MessageLookupByLibrary.simpleMessage("Descrição"),
    "g_chat_key_1": MessageLookupByLibrary.simpleMessage(
      "Iniciar conversa em grupo",
    ),
    "g_chat_key_10": m1,
    "g_chat_key_11": MessageLookupByLibrary.simpleMessage("Convidar amigos"),
    "g_chat_key_12": MessageLookupByLibrary.simpleMessage("Selecionar contato"),
    "g_chat_key_13": MessageLookupByLibrary.simpleMessage("Concluir"),
    "g_chat_key_14": MessageLookupByLibrary.simpleMessage(
      "Selecione pelo menos 2 contatos",
    ),
    "g_chat_key_16": MessageLookupByLibrary.simpleMessage("Detalhes do amigo"),
    "g_chat_key_17": MessageLookupByLibrary.simpleMessage("Detalhes do grupo"),
    "g_chat_key_18": MessageLookupByLibrary.simpleMessage(
      "Ver mais membros do grupo",
    ),
    "g_chat_key_19": MessageLookupByLibrary.simpleMessage("Nome do grupo"),
    "g_chat_key_2": MessageLookupByLibrary.simpleMessage("Novo amigo"),
    "g_chat_key_20": MessageLookupByLibrary.simpleMessage(
      "Tem certeza que deseja dissolver?",
    ),
    "g_chat_key_21": MessageLookupByLibrary.simpleMessage(
      "Tem certeza que deseja sair deste grupo?",
    ),
    "g_chat_key_22": MessageLookupByLibrary.simpleMessage("Dissolver grupo"),
    "g_chat_key_23": MessageLookupByLibrary.simpleMessage("Sair do grupo"),
    "g_chat_key_24": MessageLookupByLibrary.simpleMessage(
      "Alterar o nome do grupo",
    ),
    "g_chat_key_25": MessageLookupByLibrary.simpleMessage(
      "Quando o nome do grupo for alterado, outros membros serão notificados dentro do grupo.",
    ),
    "g_chat_key_26": MessageLookupByLibrary.simpleMessage("Concluir"),
    "g_chat_key_27": MessageLookupByLibrary.simpleMessage(
      "Solicitação de amizade",
    ),
    "g_chat_key_28": MessageLookupByLibrary.simpleMessage(
      "Solicitação para adicionar você como amigo",
    ),
    "g_chat_key_29": MessageLookupByLibrary.simpleMessage(
      "Solicitação de amizade aprovada",
    ),
    "g_chat_key_3": MessageLookupByLibrary.simpleMessage("Adicionado"),
    "g_chat_key_30": MessageLookupByLibrary.simpleMessage(
      "Você foi adicionado como amigo",
    ),
    "g_chat_key_31": MessageLookupByLibrary.simpleMessage("concordar"),
    "g_chat_key_32": m2,
    "g_chat_key_33": MessageLookupByLibrary.simpleMessage(
      "A senha não pode ser analisada corretamente, e a mensagem não pode ser enviada temporariamente. Por favor, importe a carteira ao entrar no grupo",
    ),
    "g_chat_key_34": MessageLookupByLibrary.simpleMessage(
      "Excluir o histórico de chat?",
    ),
    "g_chat_key_35": MessageLookupByLibrary.simpleMessage("Remover membro"),
    "g_chat_key_36": MessageLookupByLibrary.simpleMessage("Meu Código QR"),
    "g_chat_key_4": MessageLookupByLibrary.simpleMessage("Expirou"),
    "g_chat_key_40": MessageLookupByLibrary.simpleMessage("Denunciar"),
    "g_chat_key_41": MessageLookupByLibrary.simpleMessage("Novo Chat"),
    "g_chat_key_42": MessageLookupByLibrary.simpleMessage("Novo Grupo"),
    "g_chat_key_43": MessageLookupByLibrary.simpleMessage("Código QR"),
    "g_chat_key_44": MessageLookupByLibrary.simpleMessage(
      "Denunciar e Bloquear",
    ),
    "g_chat_key_45": MessageLookupByLibrary.simpleMessage(
      "Esta mensagem será encaminhada para a N42Wallet. Este contato não será notificado.",
    ),
    "g_chat_key_46": MessageLookupByLibrary.simpleMessage("Vídeo"),
    "g_chat_key_47": MessageLookupByLibrary.simpleMessage("Foto"),
    "g_chat_key_48": MessageLookupByLibrary.simpleMessage("Excluir Mensagem"),
    "g_chat_key_49": MessageLookupByLibrary.simpleMessage(
      "Excluir do meu dispositivo",
    ),
    "g_chat_key_5": MessageLookupByLibrary.simpleMessage("Aguardar"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("Concordar"),
    "g_chat_key_54": MessageLookupByLibrary.simpleMessage("Motivo da Denúncia"),
    "g_chat_key_55": MessageLookupByLibrary.simpleMessage(
      "Digite o motivo da denúncia",
    ),
    "g_chat_key_56": MessageLookupByLibrary.simpleMessage(
      "Verificaremos sua denúncia e responderemos em 24 horas.",
    ),
    "g_chat_key_57": MessageLookupByLibrary.simpleMessage(
      "Você denunciou isso - Clique para ver",
    ),
    "g_chat_key_58": MessageLookupByLibrary.simpleMessage("Lista negra"),
    "g_chat_key_59": MessageLookupByLibrary.simpleMessage("Remover"),
    "g_chat_key_6": m3,
    "g_chat_key_60": MessageLookupByLibrary.simpleMessage(
      "Nenhum contato ainda",
    ),
    "g_chat_key_61": MessageLookupByLibrary.simpleMessage("Hoje"),
    "g_chat_key_62": MessageLookupByLibrary.simpleMessage("Há mais de 3 dias"),
    "g_chat_key_63": MessageLookupByLibrary.simpleMessage("Bloquear"),
    "g_chat_key_64": MessageLookupByLibrary.simpleMessage(
      "Olá, estou usando a N42Wallet para conversar e enviar dinheiro. Instale a Wallet e me envie uma mensagem em",
    ),
    "g_chat_key_66": MessageLookupByLibrary.simpleMessage("Responder"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage(
      "A mensagem foi excluída",
    ),
    "g_chat_key_68": MessageLookupByLibrary.simpleMessage(
      "Alguém me mencionou",
    ),
    "g_chat_key_69": MessageLookupByLibrary.simpleMessage("Dizer oi"),
    "g_chat_key_8": MessageLookupByLibrary.simpleMessage("Adicionar amigos"),
    "g_chat_key_9": MessageLookupByLibrary.simpleMessage(
      "Motivo da solicitação",
    ),
    "g_coin_key_1": MessageLookupByLibrary.simpleMessage("Transações"),
    "g_connect_key1": MessageLookupByLibrary.simpleMessage("Conectar"),
    "g_connect_key11": MessageLookupByLibrary.simpleMessage(
      "Redes Disponíveis",
    ),
    "g_connect_key12": MessageLookupByLibrary.simpleMessage(
      "Assinatura de mensagem",
    ),
    "g_connect_key13": MessageLookupByLibrary.simpleMessage("Conectando"),
    "g_connect_key14": MessageLookupByLibrary.simpleMessage(
      "Pareando, por favor aguarde.",
    ),
    "g_connect_key2": MessageLookupByLibrary.simpleMessage("Desconectar"),
    "g_connect_key3": MessageLookupByLibrary.simpleMessage("Rejeitar"),
    "g_face_1": MessageLookupByLibrary.simpleMessage(
      "Dicas de Verificação Biométrica",
    ),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "Escaneie sua impressão digital ou rosto para autenticação.",
    ),
    "g_face_2": MessageLookupByLibrary.simpleMessage(
      "A verificação biométrica não funcionou",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("Dicas"),
    "g_face_4": MessageLookupByLibrary.simpleMessage(
      "Verificação biométrica bem-sucedida",
    ),
    "g_face_5": MessageLookupByLibrary.simpleMessage("Configurar"),
    "g_face_6": MessageLookupByLibrary.simpleMessage(
      "Você não configurou o login biométrico. Vá para Configurações do Sistema para configurar.",
    ),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "Escaneie seu rosto ou impressão digital para continuar.",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("Voltar"),
    "g_face_9": MessageLookupByLibrary.simpleMessage(
      "Recomendamos que você reative a biometria.",
    ),
    "g_face_liveness_failed": MessageLookupByLibrary.simpleMessage(
      "Rosto não detectado. Por favor, olhe diretamente para a câmera e tente novamente.",
    ),
    "g_face_match_key1": MessageLookupByLibrary.simpleMessage(
      "Método de correspondência facial",
    ),
    "g_face_match_key10": m4,
    "g_face_match_key11": m5,
    "g_face_match_key12": MessageLookupByLibrary.simpleMessage("Revincular"),
    "g_face_match_key13": MessageLookupByLibrary.simpleMessage("Vincular"),
    "g_face_match_key14": MessageLookupByLibrary.simpleMessage("Verificar"),
    "g_face_match_key15": MessageLookupByLibrary.simpleMessage(
      "Você pode vincular seus dados faciais a um endereço de carteira diretamente (se você já vinculou um anteriormente, o antigo endereço será substituído), ou se você já vinculou um endereço anteriormente, pode verificar manualmente para recuperar o endereço vinculado.",
    ),
    "g_face_match_key16": MessageLookupByLibrary.simpleMessage(
      "O endereço de carteira vinculado aos seus dados faciais foi detectado conforme abaixo, mas você ainda não importou esta carteira para sua lista de carteiras.",
    ),
    "g_face_match_key17": MessageLookupByLibrary.simpleMessage(
      "Você vinculou seus dados faciais a esta carteira.",
    ),
    "g_face_match_key18": MessageLookupByLibrary.simpleMessage(
      "Aviso ao Usuário",
    ),
    "g_face_match_key19": MessageLookupByLibrary.simpleMessage(
      "O que é Vinculação Facial?",
    ),
    "g_face_match_key20": MessageLookupByLibrary.simpleMessage(
      "A vinculação facial utiliza tecnologia de reconhecimento facial para combinar suas características biométricas faciais com o endereço da sua carteira blockchain.",
    ),
    "g_face_match_key21": MessageLookupByLibrary.simpleMessage(
      "Este processo não apenas melhora a conveniência das transações, mas também fortalece a segurança da conta, garantindo que cada ação seja autorizada por você.",
    ),
    "g_face_match_key22": MessageLookupByLibrary.simpleMessage(
      "Por que a Vinculação Facial é Necessária?",
    ),
    "g_face_match_key23": MessageLookupByLibrary.simpleMessage(
      "Ao vincular seus dados faciais, sua identidade é diretamente ligada às atividades de transação, simplificando o processo de verificação de identidade e melhorando a eficiência operacional. Esta tecnologia garante verificação de identidade rápida e segura ao realizar operações sensíveis, como transferir ativos ou interagir com contratos.",
    ),
    "g_face_match_key24": MessageLookupByLibrary.simpleMessage(
      "Como Meus Dados Faciais São Armazenados e É Seguro?",
    ),
    "g_face_match_key25": MessageLookupByLibrary.simpleMessage(
      "Seus dados faciais são armazenados de forma criptografada em uma blockchain pública, não em nenhum banco de dados centralizado. Isso significa que o sistema só pode descriptografar e usar seus dados para verificação de identidade quando autorizado por você, garantindo sua privacidade e segurança de dados.",
    ),
    "g_face_match_key26": MessageLookupByLibrary.simpleMessage(
      "Como a Vinculação Facial Afeta a Segurança da Minha Conta?",
    ),
    "g_face_match_key27": MessageLookupByLibrary.simpleMessage(
      "A vinculação facial melhora a segurança da sua conta, garantindo que todas as ações sensíveis sejam realizadas apenas com sua autorização explícita. Usamos tecnologia de criptografia líder do setor para proteger seus dados biométricos, prevenindo acesso não autorizado.",
    ),
    "g_face_match_key28": MessageLookupByLibrary.simpleMessage(
      "Meus Dados Faciais Estão Seguros?",
    ),
    "g_face_match_key29": MessageLookupByLibrary.simpleMessage(
      "Absolutamente. Todos os dados biométricos passam por criptografia rigorosa, e os mais altos padrões de segurança são seguidos para transmissão e armazenamento de dados. O sistema só descriptografará esses dados quando necessário para completar a verificação de identidade.",
    ),
    "g_face_match_key3": MessageLookupByLibrary.simpleMessage(
      "Correspondência falhou!",
    ),
    "g_face_match_key30": MessageLookupByLibrary.simpleMessage("Entendi"),
    "g_face_match_key31": MessageLookupByLibrary.simpleMessage(
      "Selecionar endereço de carteira",
    ),
    "g_face_match_key32": m6,
    "g_face_match_key33": MessageLookupByLibrary.simpleMessage("Desvinculando"),
    "g_face_match_key34": MessageLookupByLibrary.simpleMessage(
      "Falha na verificação de dados faciais!",
    ),
    "g_face_match_key35": MessageLookupByLibrary.simpleMessage(
      "Falha na desvinculação de dados faciais!",
    ),
    "g_face_match_key4": m7,
    "g_face_match_key5": MessageLookupByLibrary.simpleMessage(
      "Erro de endereço!",
    ),
    "g_face_match_key6": MessageLookupByLibrary.simpleMessage(
      "Vinculação de Dados Faciais",
    ),
    "g_face_match_key7": MessageLookupByLibrary.simpleMessage(
      "Correspondência facial",
    ),
    "g_face_match_key8": MessageLookupByLibrary.simpleMessage("Reselecionar"),
    "g_face_match_key9": MessageLookupByLibrary.simpleMessage("Corresponder"),
    "g_face_network_error": MessageLookupByLibrary.simpleMessage(
      "Erro de rede. Por favor, verifique sua conexão e tente novamente.",
    ),
    "g_face_sdk_init_failed": MessageLookupByLibrary.simpleMessage(
      "Falha ao iniciar o reconhecimento facial. Por favor, tente novamente.",
    ),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("Perfil"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("Notícias"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("Verificação"),
    "g_home_key5": MessageLookupByLibrary.simpleMessage("Mensagens"),
    "g_home_key6": MessageLookupByLibrary.simpleMessage("Aprender"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("Convidar um amigo"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("Falha ao remover!"),
    "g_key_100": MessageLookupByLibrary.simpleMessage("Enviar"),
    "g_key_101": MessageLookupByLibrary.simpleMessage("Limite de gás"),
    "g_key_105": MessageLookupByLibrary.simpleMessage("Não há mais"),
    "g_key_106": MessageLookupByLibrary.simpleMessage("Carregando "),
    "g_key_108": MessageLookupByLibrary.simpleMessage("Agenda de Endereços"),
    "g_key_11": MessageLookupByLibrary.simpleMessage("Importar carteira"),
    "g_key_110": MessageLookupByLibrary.simpleMessage("Gerenciar"),
    "g_key_112": MessageLookupByLibrary.simpleMessage("Novo endereço"),
    "g_key_113": MessageLookupByLibrary.simpleMessage("Excluir"),
    "g_key_115": MessageLookupByLibrary.simpleMessage("Salvar"),
    "g_key_119": MessageLookupByLibrary.simpleMessage("Copiar"),
    "g_key_12": MessageLookupByLibrary.simpleMessage("Criar/Importar carteira"),
    "g_key_126": MessageLookupByLibrary.simpleMessage("Tema"),
    "g_key_127": MessageLookupByLibrary.simpleMessage("Sistema"),
    "g_key_128": MessageLookupByLibrary.simpleMessage("Claro"),
    "g_key_129": MessageLookupByLibrary.simpleMessage("Escuro"),
    "g_key_13": MessageLookupByLibrary.simpleMessage("Lista de Carteiras"),
    "g_key_132": MessageLookupByLibrary.simpleMessage("Sem dados"),
    "g_key_134": MessageLookupByLibrary.simpleMessage("Valor inválido"),
    "g_key_135": m8,
    "g_key_14": MessageLookupByLibrary.simpleMessage("Carteira Principal"),
    "g_key_140": MessageLookupByLibrary.simpleMessage("Transação bem-sucedida"),
    "g_key_146": MessageLookupByLibrary.simpleMessage("Senha incorreta"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("Rede de teste"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("Rede principal"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("Idioma do sistema"),
    "g_key_15": MessageLookupByLibrary.simpleMessage(
      "Definir como Carteira Principal",
    ),
    "g_key_154": MessageLookupByLibrary.simpleMessage("Enviar"),
    "g_key_155": MessageLookupByLibrary.simpleMessage("Endereço da carteira"),
    "g_key_156": MessageLookupByLibrary.simpleMessage(
      "Escaneie para copiar o endereço",
    ),
    "g_key_159": MessageLookupByLibrary.simpleMessage("Adicionar"),
    "g_key_16": MessageLookupByLibrary.simpleMessage(
      "Selecionar Carteira de Verificação",
    ),
    "g_key_163": MessageLookupByLibrary.simpleMessage("Símbolo"),
    "g_key_166": MessageLookupByLibrary.simpleMessage("Colar"),
    "g_key_17": MessageLookupByLibrary.simpleMessage("Escolher Rede"),
    "g_key_175": MessageLookupByLibrary.simpleMessage("Transação falhou"),
    "g_key_179": MessageLookupByLibrary.simpleMessage(
      "Este é o meu endereço de carteira",
    ),
    "g_key_181": MessageLookupByLibrary.simpleMessage("Outros"),
    "g_key_185": MessageLookupByLibrary.simpleMessage("Salvo com sucesso"),
    "g_key_191": MessageLookupByLibrary.simpleMessage("Sucesso"),
    "g_key_192": MessageLookupByLibrary.simpleMessage(
      "Tem certeza que deseja excluir a carteira?",
    ),
    "g_key_193": MessageLookupByLibrary.simpleMessage("Ativo"),
    "g_key_195": MessageLookupByLibrary.simpleMessage(
      "Sem permissão para acessar a câmera.",
    ),
    "g_key_196": MessageLookupByLibrary.simpleMessage("Explorador"),
    "g_key_197": MessageLookupByLibrary.simpleMessage("Máx"),
    "g_key_198": MessageLookupByLibrary.simpleMessage("Ativos"),
    "g_key_2": MessageLookupByLibrary.simpleMessage("O registro está vazio!"),
    "g_key_202": MessageLookupByLibrary.simpleMessage("Resumo da Transação"),
    "g_key_203": MessageLookupByLibrary.simpleMessage(
      "Erro de conexão, escaneie o código QR novamente.",
    ),
    "g_key_205": MessageLookupByLibrary.simpleMessage(
      "Sem permissão para acessar a galeria de fotos.",
    ),
    "g_key_206": MessageLookupByLibrary.simpleMessage("Alterar Senha"),
    "g_key_207": MessageLookupByLibrary.simpleMessage("Senha Antiga"),
    "g_key_208": MessageLookupByLibrary.simpleMessage(
      "Sincronizando saldos...",
    ),
    "g_key_209": MessageLookupByLibrary.simpleMessage("Chave Privada"),
    "g_key_21": MessageLookupByLibrary.simpleMessage(
      "Digite a senha da carteira",
    ),
    "g_key_210": MessageLookupByLibrary.simpleMessage("Erro na chave privada"),
    "g_key_211": MessageLookupByLibrary.simpleMessage("Comprar"),
    "g_key_212": MessageLookupByLibrary.simpleMessage("Vender"),
    "g_key_213": MessageLookupByLibrary.simpleMessage("Informações de Mercado"),
    "g_key_214": m9,
    "g_key_25": MessageLookupByLibrary.simpleMessage(
      "A senha não corresponde.",
    ),
    "g_key_29": MessageLookupByLibrary.simpleMessage("Saldo"),
    "g_key_3": MessageLookupByLibrary.simpleMessage("Falha ao adicionar!"),
    "g_key_33": MessageLookupByLibrary.simpleMessage("Receber"),
    "g_key_37": MessageLookupByLibrary.simpleMessage("Transferir"),
    "g_key_38": MessageLookupByLibrary.simpleMessage("Para"),
    "g_key_4": MessageLookupByLibrary.simpleMessage("Escanear código QR"),
    "g_key_41": MessageLookupByLibrary.simpleMessage(
      "Digite um endereço de carteira",
    ),
    "g_key_43": MessageLookupByLibrary.simpleMessage("Saldo Disponível"),
    "g_key_44": MessageLookupByLibrary.simpleMessage("Valor"),
    "g_key_46": m10,
    "g_key_47": MessageLookupByLibrary.simpleMessage(
      "Saldo insuficiente para cobrir esta transação.",
    ),
    "g_key_48": MessageLookupByLibrary.simpleMessage("Enviar"),
    "g_key_5": MessageLookupByLibrary.simpleMessage("Falha ao carregar!"),
    "g_key_6": MessageLookupByLibrary.simpleMessage("Carteira"),
    "g_key_7": MessageLookupByLibrary.simpleMessage("Criar"),
    "g_key_75": MessageLookupByLibrary.simpleMessage("De"),
    "g_key_78": MessageLookupByLibrary.simpleMessage("Confirmar"),
    "g_key_79": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "g_key_8": MessageLookupByLibrary.simpleMessage("Observação"),
    "g_key_85": MessageLookupByLibrary.simpleMessage("Frase de recuperação"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("Todos os tokens"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("Configurações"),
    "g_key_aa_account_created": MessageLookupByLibrary.simpleMessage(
      "Account Created Successfully",
    ),
    "g_key_aa_account_details": MessageLookupByLibrary.simpleMessage(
      "Account Details",
    ),
    "g_key_aa_account_name": MessageLookupByLibrary.simpleMessage(
      "Account Name",
    ),
    "g_key_aa_account_name_hint": MessageLookupByLibrary.simpleMessage(
      "Enter account name",
    ),
    "g_key_aa_account_type": MessageLookupByLibrary.simpleMessage(
      "Account Type",
    ),
    "g_key_aa_active": MessageLookupByLibrary.simpleMessage("Active"),
    "g_key_aa_add_first_operation": MessageLookupByLibrary.simpleMessage(
      "Add your first operation",
    ),
    "g_key_aa_add_operation": MessageLookupByLibrary.simpleMessage(
      "Add Operation",
    ),
    "g_key_aa_address_calculating": MessageLookupByLibrary.simpleMessage(
      "Calculando endereço...",
    ),
    "g_key_aa_address_error": MessageLookupByLibrary.simpleMessage(
      "Falha ao calcular endereço. Por favor, tente novamente.",
    ),
    "g_key_aa_address_preview": MessageLookupByLibrary.simpleMessage(
      "This address is pre-computed and will be deployed when you make your first transaction.",
    ),
    "g_key_aa_approve": MessageLookupByLibrary.simpleMessage("Approve"),
    "g_key_aa_batch": MessageLookupByLibrary.simpleMessage("Batch"),
    "g_key_aa_batch_atomic": MessageLookupByLibrary.simpleMessage(
      "Atomic Execution",
    ),
    "g_key_aa_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Execute multiple operations at once",
    ),
    "g_key_aa_batch_description": MessageLookupByLibrary.simpleMessage(
      "Send multiple transactions in a single operation",
    ),
    "g_key_aa_batch_failed": MessageLookupByLibrary.simpleMessage(
      "Batch execution failed",
    ),
    "g_key_aa_batch_no_templates": MessageLookupByLibrary.simpleMessage(
      "No saved templates",
    ),
    "g_key_aa_batch_operations": MessageLookupByLibrary.simpleMessage(
      "Batch Operations",
    ),
    "g_key_aa_batch_save_gas": MessageLookupByLibrary.simpleMessage("Save Gas"),
    "g_key_aa_batch_save_template": MessageLookupByLibrary.simpleMessage(
      "Save as Template",
    ),
    "g_key_aa_batch_submitting": MessageLookupByLibrary.simpleMessage(
      "Submitting...",
    ),
    "g_key_aa_batch_success": MessageLookupByLibrary.simpleMessage(
      "Batch submitted successfully",
    ),
    "g_key_aa_batch_template_load": MessageLookupByLibrary.simpleMessage(
      "Load Template",
    ),
    "g_key_aa_batch_template_name": MessageLookupByLibrary.simpleMessage(
      "Template Name",
    ),
    "g_key_aa_batch_template_name_hint": MessageLookupByLibrary.simpleMessage(
      "Enter template name",
    ),
    "g_key_aa_batch_template_saved": MessageLookupByLibrary.simpleMessage(
      "Template saved",
    ),
    "g_key_aa_batch_templates": MessageLookupByLibrary.simpleMessage(
      "Templates",
    ),
    "g_key_aa_batch_title": MessageLookupByLibrary.simpleMessage(
      "Batch Transfer",
    ),
    "g_key_aa_batch_transaction": MessageLookupByLibrary.simpleMessage(
      "Batch Transaction",
    ),
    "g_key_aa_biconomy_account": MessageLookupByLibrary.simpleMessage(
      "Conta Biconomy",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "Conta inteligente ERC-7579 modular com suporte a transações sem gas",
    ),
    "g_key_aa_by": MessageLookupByLibrary.simpleMessage("by"),
    "g_key_aa_chain": MessageLookupByLibrary.simpleMessage("Chain"),
    "g_key_aa_chain_id": MessageLookupByLibrary.simpleMessage("Chain ID"),
    "g_key_aa_change": MessageLookupByLibrary.simpleMessage("Change"),
    "g_key_aa_clear_all": MessageLookupByLibrary.simpleMessage("Clear All"),
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage("Coming Soon"),
    "g_key_aa_continue": MessageLookupByLibrary.simpleMessage("Continue"),
    "g_key_aa_contract": MessageLookupByLibrary.simpleMessage("Contract"),
    "g_key_aa_counterfactual_address": MessageLookupByLibrary.simpleMessage(
      "Counterfactual Address",
    ),
    "g_key_aa_counterfactual_note": MessageLookupByLibrary.simpleMessage(
      "This is a counterfactual address. It will be deployed on your first transaction.",
    ),
    "g_key_aa_create_account": MessageLookupByLibrary.simpleMessage(
      "Create Smart Account",
    ),
    "g_key_aa_create_first": MessageLookupByLibrary.simpleMessage(
      "Create your first smart account",
    ),
    "g_key_aa_create_first_account": MessageLookupByLibrary.simpleMessage(
      "Create a smart account to get started",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage(
      "Create Session Key",
    ),
    "g_key_aa_create_session_desc": MessageLookupByLibrary.simpleMessage(
      "Session keys allow DApps to execute transactions on your behalf with limited permissions and time constraints.",
    ),
    "g_key_aa_create_smart_account": MessageLookupByLibrary.simpleMessage(
      "Create Smart Account",
    ),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("Created"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "g_key_aa_deploy": MessageLookupByLibrary.simpleMessage("Deploy"),
    "g_key_aa_deploy_failed": MessageLookupByLibrary.simpleMessage(
      "Deploy Failed",
    ),
    "g_key_aa_deploy_failed_desc": MessageLookupByLibrary.simpleMessage(
      "Deployment failed. Please try again.",
    ),
    "g_key_aa_deploy_started": MessageLookupByLibrary.simpleMessage(
      "Deployment started",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("Deployed"),
    "g_key_aa_deployed_desc": MessageLookupByLibrary.simpleMessage(
      "Account is ready to use",
    ),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage("Deploying..."),
    "g_key_aa_deploying_desc": MessageLookupByLibrary.simpleMessage(
      "Deployment transaction is being processed",
    ),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "Deployment will occur automatically with your first transaction.",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "Experience the next generation of Ethereum accounts with enhanced features",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("Details"),
    "g_key_aa_eip7702_account": MessageLookupByLibrary.simpleMessage(
      "EIP-7702 Account",
    ),
    "g_key_aa_eip7702_badge": MessageLookupByLibrary.simpleMessage("EIP-7702"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "Hybrid EOA/Smart Account - No deployment needed",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("Error"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage(
      "Estimated Gas",
    ),
    "g_key_aa_estimating": MessageLookupByLibrary.simpleMessage(
      "Estimating...",
    ),
    "g_key_aa_execute_batch": MessageLookupByLibrary.simpleMessage(
      "Execute Batch",
    ),
    "g_key_aa_expired": MessageLookupByLibrary.simpleMessage("Expired"),
    "g_key_aa_expires": MessageLookupByLibrary.simpleMessage("Expires"),
    "g_key_aa_factory": MessageLookupByLibrary.simpleMessage("Factory"),
    "g_key_aa_feature_batch": MessageLookupByLibrary.simpleMessage(
      "Batch multiple transactions",
    ),
    "g_key_aa_feature_gas": MessageLookupByLibrary.simpleMessage(
      "Pay gas in any token",
    ),
    "g_key_aa_feature_security": MessageLookupByLibrary.simpleMessage(
      "Enhanced security",
    ),
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("FREE"),
    "g_key_aa_full_access": MessageLookupByLibrary.simpleMessage("Full Access"),
    "g_key_aa_gas_estimate": MessageLookupByLibrary.simpleMessage(
      "Gas Estimate",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage("Gas Payment"),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "Gas Payment Options",
    ),
    "g_key_aa_gas_savings": MessageLookupByLibrary.simpleMessage("Gas Savings"),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage(
      "Gas Sponsored",
    ),
    "g_key_aa_gas_warn_call_high": MessageLookupByLibrary.simpleMessage(
      "Gas de Execução Alto",
    ),
    "g_key_aa_gas_warn_call_high_desc": m11,
    "g_key_aa_gas_warn_deploy": MessageLookupByLibrary.simpleMessage(
      "Overhead de Gas de Implantação",
    ),
    "g_key_aa_gas_warn_deploy_desc": m12,
    "g_key_aa_gas_warn_paymaster": MessageLookupByLibrary.simpleMessage(
      "Overhead do Paymaster Alto",
    ),
    "g_key_aa_gas_warn_paymaster_desc": m13,
    "g_key_aa_gas_warn_total_high": MessageLookupByLibrary.simpleMessage(
      "Limite de Gas Muito Alto",
    ),
    "g_key_aa_gas_warn_total_high_desc": m14,
    "g_key_aa_gas_warn_under_est": MessageLookupByLibrary.simpleMessage(
      "Possível Sub-Estimativa de Gas",
    ),
    "g_key_aa_gas_warn_under_est_desc": MessageLookupByLibrary.simpleMessage(
      "O gas real utilizado pode exceder a estimativa. Considere adicionar um buffer maior.",
    ),
    "g_key_aa_gas_warn_verify_high": MessageLookupByLibrary.simpleMessage(
      "Gas de Verificação Alto",
    ),
    "g_key_aa_gas_warn_verify_high_desc": m15,
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("Gasless"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "Gasless transactions & batch operations",
    ),
    "g_key_aa_home_title": MessageLookupByLibrary.simpleMessage(
      "Account Abstraction",
    ),
    "g_key_aa_just_now": MessageLookupByLibrary.simpleMessage("Just now"),
    "g_key_aa_kernel_account": MessageLookupByLibrary.simpleMessage(
      "Kernel Account",
    ),
    "g_key_aa_kernel_desc": MessageLookupByLibrary.simpleMessage(
      "Modular account with plugin support from ZeroDev",
    ),
    "g_key_aa_label": MessageLookupByLibrary.simpleMessage("Label"),
    "g_key_aa_last_activity": MessageLookupByLibrary.simpleMessage(
      "Last Activity",
    ),
    "g_key_aa_my_accounts": MessageLookupByLibrary.simpleMessage(
      "My Smart Accounts",
    ),
    "g_key_aa_never": MessageLookupByLibrary.simpleMessage("Never"),
    "g_key_aa_no_accounts": MessageLookupByLibrary.simpleMessage(
      "No smart accounts yet",
    ),
    "g_key_aa_no_accounts_filter": MessageLookupByLibrary.simpleMessage(
      "No accounts match your filter",
    ),
    "g_key_aa_no_operations": MessageLookupByLibrary.simpleMessage(
      "No operations added",
    ),
    "g_key_aa_no_session_keys": MessageLookupByLibrary.simpleMessage(
      "No session keys",
    ),
    "g_key_aa_not_deployed": MessageLookupByLibrary.simpleMessage(
      "Not Deployed",
    ),
    "g_key_aa_not_deployed_desc": MessageLookupByLibrary.simpleMessage(
      "Account will be deployed on first transaction",
    ),
    "g_key_aa_operations": MessageLookupByLibrary.simpleMessage("Operations"),
    "g_key_aa_owner": MessageLookupByLibrary.simpleMessage("Owner"),
    "g_key_aa_pay_gas_with_token": MessageLookupByLibrary.simpleMessage(
      "Pay gas with token",
    ),
    "g_key_aa_pay_gas_yourself": MessageLookupByLibrary.simpleMessage(
      "Pay gas with your ETH",
    ),
    "g_key_aa_pay_with": MessageLookupByLibrary.simpleMessage("Pay with"),
    "g_key_aa_pay_with_eth": MessageLookupByLibrary.simpleMessage(
      "Pay with ETH",
    ),
    "g_key_aa_paymaster_balance": MessageLookupByLibrary.simpleMessage("Saldo"),
    "g_key_aa_paymaster_chains_supported": MessageLookupByLibrary.simpleMessage(
      "cadeias suportadas",
    ),
    "g_key_aa_paymaster_checking": MessageLookupByLibrary.simpleMessage(
      "Verificando disponibilidade...",
    ),
    "g_key_aa_paymaster_coverage": MessageLookupByLibrary.simpleMessage(
      "Cobertura de cadeia",
    ),
    "g_key_aa_paymaster_description": MessageLookupByLibrary.simpleMessage(
      "Choose how you want to pay for transaction gas fees",
    ),
    "g_key_aa_paymaster_est_cost": MessageLookupByLibrary.simpleMessage(
      "Custo est.",
    ),
    "g_key_aa_paymaster_load_failed": MessageLookupByLibrary.simpleMessage(
      "Falha ao carregar opções de gás",
    ),
    "g_key_aa_paymaster_not_supported": MessageLookupByLibrary.simpleMessage(
      "Não disponível nesta cadeia",
    ),
    "g_key_aa_paymaster_quote_expired": MessageLookupByLibrary.simpleMessage(
      "Cotação expirada",
    ),
    "g_key_aa_paymaster_retry": MessageLookupByLibrary.simpleMessage(
      "Tentar novamente",
    ),
    "g_key_aa_paymaster_sponsored_unavailable":
        MessageLookupByLibrary.simpleMessage("Patrocínio não disponível"),
    "g_key_aa_pending": MessageLookupByLibrary.simpleMessage("Pending"),
    "g_key_aa_permission": MessageLookupByLibrary.simpleMessage("Permission"),
    "g_key_aa_preview_address": MessageLookupByLibrary.simpleMessage(
      "Preview Address",
    ),
    "g_key_aa_ready": MessageLookupByLibrary.simpleMessage("Ready"),
    "g_key_aa_recommended": MessageLookupByLibrary.simpleMessage("Recommended"),
    "g_key_aa_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "g_key_aa_revoke": MessageLookupByLibrary.simpleMessage("Revoke"),
    "g_key_aa_revoke_confirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to revoke this session key? The authorized DApp will no longer be able to execute transactions.",
    ),
    "g_key_aa_revoke_session": MessageLookupByLibrary.simpleMessage(
      "Revoke Session Key",
    ),
    "g_key_aa_revoked": MessageLookupByLibrary.simpleMessage(
      "Session key revoked",
    ),
    "g_key_aa_revoked_status": MessageLookupByLibrary.simpleMessage("Revoked"),
    "g_key_aa_revoking": MessageLookupByLibrary.simpleMessage(
      "Revoking session key...",
    ),
    "g_key_aa_safe_account": MessageLookupByLibrary.simpleMessage(
      "Safe Account",
    ),
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "Multi-signature account with advanced security features",
    ),
    "g_key_aa_safe_guardians": MessageLookupByLibrary.simpleMessage(
      "Guardiões",
    ),
    "g_key_aa_safe_threshold": MessageLookupByLibrary.simpleMessage("Limite"),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("saved"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage(
      "Select Chain",
    ),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "Select Paymaster",
    ),
    "g_key_aa_select_type": MessageLookupByLibrary.simpleMessage(
      "Select Account Type",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage(
      "Send tokens using your smart account",
    ),
    "g_key_aa_send_title": MessageLookupByLibrary.simpleMessage("AA Transfer"),
    "g_key_aa_session_1d": MessageLookupByLibrary.simpleMessage("1 dia"),
    "g_key_aa_session_1h": MessageLookupByLibrary.simpleMessage("1 hora"),
    "g_key_aa_session_30d": MessageLookupByLibrary.simpleMessage("30 dias"),
    "g_key_aa_session_7d": MessageLookupByLibrary.simpleMessage("7 dias"),
    "g_key_aa_session_allowed": MessageLookupByLibrary.simpleMessage(
      "Permitido",
    ),
    "g_key_aa_session_amount_hint": MessageLookupByLibrary.simpleMessage(
      "ex. 100,00",
    ),
    "g_key_aa_session_amount_limit": MessageLookupByLibrary.simpleMessage(
      "Valor máximo",
    ),
    "g_key_aa_session_blocked": MessageLookupByLibrary.simpleMessage(
      "Bloqueado",
    ),
    "g_key_aa_session_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "Entendo as permissões desta chave",
    ),
    "g_key_aa_session_contract_can": MessageLookupByLibrary.simpleMessage(
      "Interagir com contratos DApp aprovados",
    ),
    "g_key_aa_session_create_failed": MessageLookupByLibrary.simpleMessage(
      "Falha ao criar chave de sessão",
    ),
    "g_key_aa_session_create_success": MessageLookupByLibrary.simpleMessage(
      "Chave de sessão criada",
    ),
    "g_key_aa_session_dapp_hint": MessageLookupByLibrary.simpleMessage(
      "ex. Uniswap, Aave...",
    ),
    "g_key_aa_session_dapp_label": MessageLookupByLibrary.simpleMessage(
      "Rótulo / Nome DApp",
    ),
    "g_key_aa_session_details": MessageLookupByLibrary.simpleMessage(
      "Session Key Details",
    ),
    "g_key_aa_session_expiry": MessageLookupByLibrary.simpleMessage(
      "Válido por",
    ),
    "g_key_aa_session_full_warning": MessageLookupByLibrary.simpleMessage(
      "Alto risco — apenas DApps verificadas",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage(
      "Session Keys",
    ),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "Authorize DApps with temporary access to your smart account",
    ),
    "g_key_aa_session_preset_contract": MessageLookupByLibrary.simpleMessage(
      "Acesso DApp",
    ),
    "g_key_aa_session_preset_full": MessageLookupByLibrary.simpleMessage(
      "Controle total",
    ),
    "g_key_aa_session_preset_transfer": MessageLookupByLibrary.simpleMessage(
      "Apenas enviar",
    ),
    "g_key_aa_session_risk_high": MessageLookupByLibrary.simpleMessage(
      "Alto risco",
    ),
    "g_key_aa_session_risk_low": MessageLookupByLibrary.simpleMessage(
      "Baixo risco",
    ),
    "g_key_aa_session_risk_medium": MessageLookupByLibrary.simpleMessage(
      "Risco médio",
    ),
    "g_key_aa_session_risk_warning": MessageLookupByLibrary.simpleMessage(
      "Revise as permissões antes de confirmar",
    ),
    "g_key_aa_session_select_preset": MessageLookupByLibrary.simpleMessage(
      "Escolher nível de permissão",
    ),
    "g_key_aa_session_transfer_can": MessageLookupByLibrary.simpleMessage(
      "Transferir tokens dentro do limite definido",
    ),
    "g_key_aa_simple_account": MessageLookupByLibrary.simpleMessage(
      "Simple Account",
    ),
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "Basic smart account with single owner - recommended for most users",
    ),
    "g_key_aa_smart_account": MessageLookupByLibrary.simpleMessage(
      "Smart Account",
    ),
    "g_key_aa_smart_accounts": MessageLookupByLibrary.simpleMessage(
      "Smart Accounts",
    ),
    "g_key_aa_smart_wallet": MessageLookupByLibrary.simpleMessage(
      "Smart Wallet",
    ),
    "g_key_aa_spending_limit": MessageLookupByLibrary.simpleMessage(
      "Spending Limit",
    ),
    "g_key_aa_sponsored": MessageLookupByLibrary.simpleMessage(
      "Sponsored (Free)",
    ),
    "g_key_aa_title": MessageLookupByLibrary.simpleMessage("Smart Account"),
    "g_key_aa_total_gas": MessageLookupByLibrary.simpleMessage("Total Gas"),
    "g_key_aa_total_value": MessageLookupByLibrary.simpleMessage("Total Value"),
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage(
      "Transactions",
    ),
    "g_key_aa_unavailable": MessageLookupByLibrary.simpleMessage("Unavailable"),
    "g_key_aa_version_v07": MessageLookupByLibrary.simpleMessage("v0.7"),
    "g_key_aa_version_v08": MessageLookupByLibrary.simpleMessage("v0.8"),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage("View All"),
    "g_key_account_linked": MessageLookupByLibrary.simpleMessage(
      "Account linked successfully",
    ),
    "g_key_account_unlinked": MessageLookupByLibrary.simpleMessage(
      "Account unlinked successfully",
    ),
    "g_key_address": MessageLookupByLibrary.simpleMessage("Endereço"),
    "g_key_address_1": MessageLookupByLibrary.simpleMessage(
      "Por favor, digite um nome",
    ),
    "g_key_address_2": MessageLookupByLibrary.simpleMessage(
      "Por favor, digite o endereço",
    ),
    "g_key_address_3": MessageLookupByLibrary.simpleMessage(
      "Por favor, selecione um tipo de moeda",
    ),
    "g_key_address_4": MessageLookupByLibrary.simpleMessage("Editar endereço"),
    "g_key_address_5": MessageLookupByLibrary.simpleMessage(
      "Excluído com sucesso",
    ),
    "g_key_address_6": MessageLookupByLibrary.simpleMessage("Escolher Moedas"),
    "g_key_address_7": MessageLookupByLibrary.simpleMessage("Pesquisar moedas"),
    "g_key_advanced_features": MessageLookupByLibrary.simpleMessage(
      "Advanced Features",
    ),
    "g_key_airdrop_active": MessageLookupByLibrary.simpleMessage("Ativo"),
    "g_key_airdrop_check_eligibility": MessageLookupByLibrary.simpleMessage(
      "Verificar Elegibilidade",
    ),
    "g_key_airdrop_claim": MessageLookupByLibrary.simpleMessage("Resgatar"),
    "g_key_airdrop_claimed": MessageLookupByLibrary.simpleMessage("Resgatado"),
    "g_key_airdrop_days_left": m16,
    "g_key_airdrop_deadline": MessageLookupByLibrary.simpleMessage("Prazo"),
    "g_key_airdrop_eligible": MessageLookupByLibrary.simpleMessage("Elegível"),
    "g_key_airdrop_estimated_value": MessageLookupByLibrary.simpleMessage(
      "Valor Estimado",
    ),
    "g_key_airdrop_expired": MessageLookupByLibrary.simpleMessage("Expirado"),
    "g_key_airdrop_filter": MessageLookupByLibrary.simpleMessage("Filtrar"),
    "g_key_airdrop_no_airdrops": MessageLookupByLibrary.simpleMessage(
      "Nenhum airdrop disponível",
    ),
    "g_key_airdrop_not_eligible": MessageLookupByLibrary.simpleMessage(
      "Não Elegível",
    ),
    "g_key_airdrop_pending": MessageLookupByLibrary.simpleMessage("Pendente"),
    "g_key_airdrop_priority_high": MessageLookupByLibrary.simpleMessage(
      "Alta Prioridade",
    ),
    "g_key_airdrop_priority_low": MessageLookupByLibrary.simpleMessage(
      "Baixa Prioridade",
    ),
    "g_key_airdrop_priority_medium": MessageLookupByLibrary.simpleMessage(
      "Média Prioridade",
    ),
    "g_key_airdrop_requirement_met": MessageLookupByLibrary.simpleMessage(
      "Requisito cumprido",
    ),
    "g_key_airdrop_requirement_not_met": MessageLookupByLibrary.simpleMessage(
      "Não cumprido",
    ),
    "g_key_airdrop_requirements": MessageLookupByLibrary.simpleMessage(
      "Requisitos",
    ),
    "g_key_airdrop_sort_by": MessageLookupByLibrary.simpleMessage(
      "Ordenar Por",
    ),
    "g_key_airdrop_title": MessageLookupByLibrary.simpleMessage(
      "Rastreador de Airdrop",
    ),
    "g_key_airdrop_total_claimed": MessageLookupByLibrary.simpleMessage(
      "Total Resgatado",
    ),
    "g_key_airdrop_upcoming": MessageLookupByLibrary.simpleMessage("Em Breve"),
    "g_key_apple_sign_in_cancelled": MessageLookupByLibrary.simpleMessage(
      "Apple sign-in cancelled",
    ),
    "g_key_apply": MessageLookupByLibrary.simpleMessage("Apply"),
    "g_key_batch_add_recipient": MessageLookupByLibrary.simpleMessage(
      "Adicionar Destinatário",
    ),
    "g_key_batch_broadcasting": MessageLookupByLibrary.simpleMessage(
      "Broadcasting...",
    ),
    "g_key_batch_clear_all": MessageLookupByLibrary.simpleMessage(
      "Limpar Tudo",
    ),
    "g_key_batch_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Confirm Batch Transfer",
    ),
    "g_key_batch_continue": MessageLookupByLibrary.simpleMessage("Continue"),
    "g_key_batch_csv_format": MessageLookupByLibrary.simpleMessage(
      "Formato CSV: endereço,valor,rótulo",
    ),
    "g_key_batch_done": MessageLookupByLibrary.simpleMessage("Done"),
    "g_key_batch_duplicate_address": m17,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "Estimating Gas...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "Batch transfer supports EVM chains only",
    ),
    "g_key_batch_execute": MessageLookupByLibrary.simpleMessage(
      "Executar Lote",
    ),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage(
      "Exportar CSV",
    ),
    "g_key_batch_gas_savings": MessageLookupByLibrary.simpleMessage(
      "Economia de Gas",
    ),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage(
      "Batch Transfer Help",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage(
      "Importar CSV",
    ),
    "g_key_batch_invalid_address": m18,
    "g_key_batch_invalid_amount": m19,
    "g_key_batch_max_recipients": m20,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "Memo is optional",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "Use Multicall3 for lower gas fees",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "No supported tokens",
    ),
    "g_key_batch_preview": MessageLookupByLibrary.simpleMessage(
      "Pré-visualizar",
    ),
    "g_key_batch_recipients": MessageLookupByLibrary.simpleMessage(
      "Destinatários",
    ),
    "g_key_batch_select_token": MessageLookupByLibrary.simpleMessage(
      "Select Token",
    ),
    "g_key_batch_send_multiple": MessageLookupByLibrary.simpleMessage(
      "Send tokens to multiple addresses in one transaction",
    ),
    "g_key_batch_signing": MessageLookupByLibrary.simpleMessage("Signing..."),
    "g_key_batch_swipe_remove": MessageLookupByLibrary.simpleMessage(
      "Swipe left to remove a recipient",
    ),
    "g_key_batch_title": MessageLookupByLibrary.simpleMessage(
      "Transferência em Lote",
    ),
    "g_key_batch_total_amount": MessageLookupByLibrary.simpleMessage(
      "Valor Total",
    ),
    "g_key_bridge_amount": MessageLookupByLibrary.simpleMessage("Valor"),
    "g_key_bridge_cheapest": MessageLookupByLibrary.simpleMessage(
      "Mais Barato",
    ),
    "g_key_bridge_estimated_receive": MessageLookupByLibrary.simpleMessage(
      "Você receberá (estimado)",
    ),
    "g_key_bridge_fastest": MessageLookupByLibrary.simpleMessage("Mais Rápido"),
    "g_key_bridge_fee": MessageLookupByLibrary.simpleMessage("Taxa de Bridge"),
    "g_key_bridge_from_chain": MessageLookupByLibrary.simpleMessage(
      "Chain de Origem",
    ),
    "g_key_bridge_get_quote": MessageLookupByLibrary.simpleMessage(
      "Obter Cotação",
    ),
    "g_key_bridge_history": MessageLookupByLibrary.simpleMessage(
      "Histórico de Bridge",
    ),
    "g_key_bridge_no_routes": MessageLookupByLibrary.simpleMessage(
      "Nenhuma rota disponível",
    ),
    "g_key_bridge_recommended": MessageLookupByLibrary.simpleMessage(
      "Recomendado",
    ),
    "g_key_bridge_refresh": MessageLookupByLibrary.simpleMessage("Atualizar"),
    "g_key_bridge_route": MessageLookupByLibrary.simpleMessage("Rota"),
    "g_key_bridge_search_chain": MessageLookupByLibrary.simpleMessage(
      "Buscar chain...",
    ),
    "g_key_bridge_select_token": MessageLookupByLibrary.simpleMessage(
      "Selecionar Token",
    ),
    "g_key_bridge_slippage": MessageLookupByLibrary.simpleMessage("Slippage"),
    "g_key_bridge_swap": MessageLookupByLibrary.simpleMessage("Bridge"),
    "g_key_bridge_time": MessageLookupByLibrary.simpleMessage("Tempo Estimado"),
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("Bridge"),
    "g_key_bridge_to_chain": MessageLookupByLibrary.simpleMessage(
      "Chain de Destino",
    ),
    "g_key_bridge_tx_failed": MessageLookupByLibrary.simpleMessage(
      "Bridge Falhou",
    ),
    "g_key_bridge_tx_pending": MessageLookupByLibrary.simpleMessage(
      "Transação Pendente",
    ),
    "g_key_bridge_tx_success": MessageLookupByLibrary.simpleMessage(
      "Bridge Bem-sucedido",
    ),
    "g_key_burn_got_it": MessageLookupByLibrary.simpleMessage("Got it"),
    "g_key_burn_nft_step1": MessageLookupByLibrary.simpleMessage(
      "1. Select a token with NFT support",
    ),
    "g_key_burn_nft_step2": MessageLookupByLibrary.simpleMessage(
      "2. Go to NFT tab",
    ),
    "g_key_burn_nft_step3": MessageLookupByLibrary.simpleMessage(
      "3. Select the NFT you want to burn",
    ),
    "g_key_burn_nft_step4": MessageLookupByLibrary.simpleMessage(
      "4. Tap \"Burn\" button",
    ),
    "g_key_burn_nft_steps": MessageLookupByLibrary.simpleMessage("Steps:"),
    "g_key_burn_nft_tip": MessageLookupByLibrary.simpleMessage(
      "To burn an NFT, please go to the NFT details page and tap the \"Burn\" button.",
    ),
    "g_key_burn_nft_title": MessageLookupByLibrary.simpleMessage("Burn NFT"),
    "g_key_change_email": MessageLookupByLibrary.simpleMessage("Change Email"),
    "g_key_change_password": MessageLookupByLibrary.simpleMessage(
      "Change Password",
    ),
    "g_key_change_password_desc": MessageLookupByLibrary.simpleMessage(
      "Enter your current password and set a new password",
    ),
    "g_key_code_length": MessageLookupByLibrary.simpleMessage(
      "Please enter 6-digit code",
    ),
    "g_key_code_required": MessageLookupByLibrary.simpleMessage(
      "Verification code is required",
    ),
    "g_key_code_sent": MessageLookupByLibrary.simpleMessage(
      "Verification code sent",
    ),
    "g_key_confirm_new_password": MessageLookupByLibrary.simpleMessage(
      "Confirm New Password",
    ),
    "g_key_continue_with_apple": MessageLookupByLibrary.simpleMessage(
      "Continue with Apple",
    ),
    "g_key_continue_with_google": MessageLookupByLibrary.simpleMessage(
      "Continue with Google",
    ),
    "g_key_deadline_reminders": MessageLookupByLibrary.simpleMessage(
      "Deadline reminders",
    ),
    "g_key_dex_best_route": MessageLookupByLibrary.simpleMessage("Melhor Rota"),
    "g_key_dex_best_source": MessageLookupByLibrary.simpleMessage(
      "Melhor Fonte",
    ),
    "g_key_dex_chain": MessageLookupByLibrary.simpleMessage("Rede"),
    "g_key_dex_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Confirmar Swap",
    ),
    "g_key_dex_gas_estimate": MessageLookupByLibrary.simpleMessage(
      "Estimativa de Gas",
    ),
    "g_key_dex_history_title": MessageLookupByLibrary.simpleMessage(
      "Histórico DEX",
    ),
    "g_key_dex_no_tokens": MessageLookupByLibrary.simpleMessage("Sem tokens"),
    "g_key_dex_no_tokens_found": MessageLookupByLibrary.simpleMessage(
      "Nenhum token encontrado",
    ),
    "g_key_dex_price_impact": MessageLookupByLibrary.simpleMessage(
      "Impacto no Preço",
    ),
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage(
      "Cotação falhou",
    ),
    "g_key_dex_retry": MessageLookupByLibrary.simpleMessage("Tentar Novamente"),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage(
      "Pesquisar símbolo / nome / endereço",
    ),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage(
      "Selecionar",
    ),
    "g_key_dex_slippage": MessageLookupByLibrary.simpleMessage(
      "Tolerância de Slippage",
    ),
    "g_key_dex_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Solana DEX swap ainda não suportado no app",
    ),
    "g_key_dex_status_confirmed": MessageLookupByLibrary.simpleMessage(
      "Confirmado",
    ),
    "g_key_dex_status_failed": MessageLookupByLibrary.simpleMessage("Falhou"),
    "g_key_dex_status_pending": MessageLookupByLibrary.simpleMessage(
      "Pendente",
    ),
    "g_key_dex_status_quoted": MessageLookupByLibrary.simpleMessage("Cotado"),
    "g_key_dex_swap_btn": MessageLookupByLibrary.simpleMessage("Trocar"),
    "g_key_dex_swap_success": MessageLookupByLibrary.simpleMessage(
      "Swap enviado com sucesso",
    ),
    "g_key_dex_tx_failed": MessageLookupByLibrary.simpleMessage(
      "Transação falhou",
    ),
    "g_key_dex_you_pay": MessageLookupByLibrary.simpleMessage("Você Paga"),
    "g_key_dex_you_receive": MessageLookupByLibrary.simpleMessage(
      "Você Recebe",
    ),
    "g_key_domain_resolve_hint": MessageLookupByLibrary.simpleMessage(
      "Suporta ENS (.eth), Unstoppable Domains (.crypto/.wallet/…) e Solana SNS (.sol)",
    ),
    "g_key_domain_sns_name": MessageLookupByLibrary.simpleMessage(
      "Serviço de Nomes Solana",
    ),
    "g_key_domain_sns_not_found": MessageLookupByLibrary.simpleMessage(
      "Domínio Solana não encontrado",
    ),
    "g_key_domain_ud_name": MessageLookupByLibrary.simpleMessage(
      "Unstoppable Domains",
    ),
    "g_key_domain_ud_not_found": MessageLookupByLibrary.simpleMessage(
      "Domínio Unstoppable não encontrado ou sem endereço para esta rede",
    ),
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage(
      "Active Products",
    ),
    "g_key_earn_batch": MessageLookupByLibrary.simpleMessage(
      "Transferência em lote",
    ),
    "g_key_earn_burn": MessageLookupByLibrary.simpleMessage("Queimar"),
    "g_key_earn_buy_n": MessageLookupByLibrary.simpleMessage("Comprar N"),
    "g_key_earn_buy_n_desc": MessageLookupByLibrary.simpleMessage(
      "Compre N com o protocolo AST",
    ),
    "g_key_earn_claim_free": MessageLookupByLibrary.simpleMessage(
      "Claim free tokens",
    ),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage(
      "Cross-chain transfer",
    ),
    "g_key_earn_daily_bonus": MessageLookupByLibrary.simpleMessage(
      "Daily check-in bonus",
    ),
    "g_key_earn_dex_desc": MessageLookupByLibrary.simpleMessage(
      "Troque qualquer token via Uniswap / 1inch",
    ),
    "g_key_earn_dex_swap": MessageLookupByLibrary.simpleMessage("Troca DEX"),
    "g_key_earn_gas": MessageLookupByLibrary.simpleMessage("Gas"),
    "g_key_earn_go_staking": MessageLookupByLibrary.simpleMessage(
      "Iniciar staking",
    ),
    "g_key_earn_ledger": MessageLookupByLibrary.simpleMessage("Ledger"),
    "g_key_earn_loading_apy": MessageLookupByLibrary.simpleMessage(
      "Carregando APY...",
    ),
    "g_key_earn_mining": MessageLookupByLibrary.simpleMessage("Mineração"),
    "g_key_earn_more": MessageLookupByLibrary.simpleMessage("Earn More"),
    "g_key_earn_native_sol": MessageLookupByLibrary.simpleMessage(
      "Native Solana staking",
    ),
    "g_key_earn_no_positions": MessageLookupByLibrary.simpleMessage(
      "Sem posições ativas",
    ),
    "g_key_earn_node_mining": MessageLookupByLibrary.simpleMessage(
      "Mineração de nós",
    ),
    "g_key_earn_node_mining_desc": MessageLookupByLibrary.simpleMessage(
      "Ganhe recompensas participando da mineração de nós",
    ),
    "g_key_earn_points_daily": MessageLookupByLibrary.simpleMessage(
      "Earn points daily",
    ),
    "g_key_earn_pts_day": m21,
    "g_key_earn_quick_tools": MessageLookupByLibrary.simpleMessage(
      "Quick Tools",
    ),
    "g_key_earn_recommended": MessageLookupByLibrary.simpleMessage(
      "Recommended",
    ),
    "g_key_earn_select_swap": MessageLookupByLibrary.simpleMessage(
      "Selecionar tipo de troca",
    ),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "Stake ETH with Lido",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("Trocar"),
    "g_key_earn_title": MessageLookupByLibrary.simpleMessage("Earn"),
    "g_key_earn_total_earnings": MessageLookupByLibrary.simpleMessage(
      "Total Earnings",
    ),
    "g_key_earn_up_to_apy": m22,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage("View All"),
    "g_key_eligibility_alerts": MessageLookupByLibrary.simpleMessage(
      "Eligibility alerts",
    ),
    "g_key_eligible_only": MessageLookupByLibrary.simpleMessage(
      "Eligible only",
    ),
    "g_key_email": MessageLookupByLibrary.simpleMessage("Email"),
    "g_key_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid email address",
    ),
    "g_key_email_required": MessageLookupByLibrary.simpleMessage(
      "Email is required",
    ),
    "g_key_ens_address_updated": MessageLookupByLibrary.simpleMessage(
      "Resolved address updated",
    ),
    "g_key_ens_advanced": MessageLookupByLibrary.simpleMessage("Advanced"),
    "g_key_ens_annual_fee": MessageLookupByLibrary.simpleMessage("Annual Fee"),
    "g_key_ens_available": MessageLookupByLibrary.simpleMessage("Available"),
    "g_key_ens_base_price": MessageLookupByLibrary.simpleMessage("Base Price"),
    "g_key_ens_checking": MessageLookupByLibrary.simpleMessage(
      "Checking availability...",
    ),
    "g_key_ens_commit": MessageLookupByLibrary.simpleMessage("Commit"),
    "g_key_ens_commit_failed": MessageLookupByLibrary.simpleMessage(
      "Commit failed",
    ),
    "g_key_ens_commit_tx": MessageLookupByLibrary.simpleMessage(
      "Committing transaction...",
    ),
    "g_key_ens_commitment_expired_msg": MessageLookupByLibrary.simpleMessage(
      "O compromisso de registro expirou. Por favor, reinicie o processo de registro.",
    ),
    "g_key_ens_committing": MessageLookupByLibrary.simpleMessage(
      "Committing...",
    ),
    "g_key_ens_confirm_renew": MessageLookupByLibrary.simpleMessage(
      "Confirm Renewal",
    ),
    "g_key_ens_confirm_send": MessageLookupByLibrary.simpleMessage(
      "Confirm & Send",
    ),
    "g_key_ens_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Confirm ENS Resolution",
    ),
    "g_key_ens_copy_address": MessageLookupByLibrary.simpleMessage(
      "Endereço copiado",
    ),
    "g_key_ens_current_expiry": MessageLookupByLibrary.simpleMessage(
      "Current Expiry",
    ),
    "g_key_ens_days_left": MessageLookupByLibrary.simpleMessage("days left"),
    "g_key_ens_description": MessageLookupByLibrary.simpleMessage(
      "Register and manage your .eth domain names",
    ),
    "g_key_ens_detected": MessageLookupByLibrary.simpleMessage(
      "ENS Name Detected",
    ),
    "g_key_ens_duration": MessageLookupByLibrary.simpleMessage(
      "Registration Period",
    ),
    "g_key_ens_edit_records": MessageLookupByLibrary.simpleMessage(
      "Edit Records",
    ),
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage("Expired"),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage("Expires"),
    "g_key_ens_expiring_soon": MessageLookupByLibrary.simpleMessage(
      "Expiring Soon",
    ),
    "g_key_ens_extend_period": MessageLookupByLibrary.simpleMessage(
      "Extend Registration Period",
    ),
    "g_key_ens_failed": MessageLookupByLibrary.simpleMessage("Failed"),
    "g_key_ens_finalizing": MessageLookupByLibrary.simpleMessage(
      "Finalizing registration",
    ),
    "g_key_ens_get_started": MessageLookupByLibrary.simpleMessage(
      "Get started with ENS",
    ),
    "g_key_ens_get_your_name": MessageLookupByLibrary.simpleMessage(
      "Get your .eth name",
    ),
    "g_key_ens_home_title": MessageLookupByLibrary.simpleMessage("ENS Manager"),
    "g_key_ens_invalid_address": MessageLookupByLibrary.simpleMessage(
      "Invalid address (must be 0x + 40 hex chars)",
    ),
    "g_key_ens_invalid_name": MessageLookupByLibrary.simpleMessage(
      "Invalid ENS name",
    ),
    "g_key_ens_is_yours": MessageLookupByLibrary.simpleMessage("is now yours!"),
    "g_key_ens_keep_app_open": MessageLookupByLibrary.simpleMessage(
      "Please keep the app open during registration",
    ),
    "g_key_ens_manage_your_identity": MessageLookupByLibrary.simpleMessage(
      "Manage your Web3 identity",
    ),
    "g_key_ens_management_title": MessageLookupByLibrary.simpleMessage(
      "Manage ENS",
    ),
    "g_key_ens_min_length": MessageLookupByLibrary.simpleMessage(
      "Minimum 3 characters",
    ),
    "g_key_ens_my_domains": MessageLookupByLibrary.simpleMessage("My Domains"),
    "g_key_ens_name": MessageLookupByLibrary.simpleMessage("ENS Name"),
    "g_key_ens_new_expiry": MessageLookupByLibrary.simpleMessage("New Expiry"),
    "g_key_ens_new_owner": MessageLookupByLibrary.simpleMessage(
      "New Owner Address",
    ),
    "g_key_ens_no_domains": MessageLookupByLibrary.simpleMessage(
      "No domains yet",
    ),
    "g_key_ens_no_names": MessageLookupByLibrary.simpleMessage(
      "You don\'t own any ENS names yet",
    ),
    "g_key_ens_owned_names": MessageLookupByLibrary.simpleMessage(
      "My ENS Names",
    ),
    "g_key_ens_owner": MessageLookupByLibrary.simpleMessage("Owner"),
    "g_key_ens_please_wait": MessageLookupByLibrary.simpleMessage(
      "Please wait",
    ),
    "g_key_ens_premium_name": MessageLookupByLibrary.simpleMessage(
      "Premium Name",
    ),
    "g_key_ens_price_breakdown": MessageLookupByLibrary.simpleMessage(
      "Price Breakdown",
    ),
    "g_key_ens_price_per_year": MessageLookupByLibrary.simpleMessage(
      "per year",
    ),
    "g_key_ens_primary": MessageLookupByLibrary.simpleMessage("Primary"),
    "g_key_ens_primary_set": MessageLookupByLibrary.simpleMessage(
      "Primary name set successfully",
    ),
    "g_key_ens_processing": MessageLookupByLibrary.simpleMessage(
      "Processing...",
    ),
    "g_key_ens_purchase_title": MessageLookupByLibrary.simpleMessage(
      "Register ENS",
    ),
    "g_key_ens_records": MessageLookupByLibrary.simpleMessage("Records"),
    "g_key_ens_register": MessageLookupByLibrary.simpleMessage("Register"),
    "g_key_ens_register_description": MessageLookupByLibrary.simpleMessage(
      "Your decentralized identity on Ethereum",
    ),
    "g_key_ens_register_failed": MessageLookupByLibrary.simpleMessage(
      "Registration failed",
    ),
    "g_key_ens_register_now": MessageLookupByLibrary.simpleMessage(
      "Register Now",
    ),
    "g_key_ens_register_tx": MessageLookupByLibrary.simpleMessage(
      "Registering name...",
    ),
    "g_key_ens_registering": MessageLookupByLibrary.simpleMessage(
      "Registering...",
    ),
    "g_key_ens_registration_info": MessageLookupByLibrary.simpleMessage(
      "Registration Info",
    ),
    "g_key_ens_registration_period": MessageLookupByLibrary.simpleMessage(
      "Registration Period",
    ),
    "g_key_ens_reminder_disabled": MessageLookupByLibrary.simpleMessage(
      "Lembrete desativado",
    ),
    "g_key_ens_reminder_enable": MessageLookupByLibrary.simpleMessage(
      "Ativar lembrete de expiração",
    ),
    "g_key_ens_reminder_enabled": MessageLookupByLibrary.simpleMessage(
      "Lembrete ativado",
    ),
    "g_key_ens_reminder_hint": MessageLookupByLibrary.simpleMessage(
      "Notificar 30, 7 e 1 dia antes da expiração",
    ),
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("Renew"),
    "g_key_ens_renew_cost": MessageLookupByLibrary.simpleMessage(
      "Renewal Cost",
    ),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage(
      "Extend your domain registration",
    ),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage(
      "Renewal successful",
    ),
    "g_key_ens_renew_title": MessageLookupByLibrary.simpleMessage("Renew ENS"),
    "g_key_ens_resolution_failed": MessageLookupByLibrary.simpleMessage(
      "ENS resolution failed",
    ),
    "g_key_ens_resolved_address": MessageLookupByLibrary.simpleMessage(
      "Resolved Address",
    ),
    "g_key_ens_resolving": MessageLookupByLibrary.simpleMessage(
      "Resolving ENS...",
    ),
    "g_key_ens_search": MessageLookupByLibrary.simpleMessage("Search"),
    "g_key_ens_search_desc": MessageLookupByLibrary.simpleMessage(
      "Find available .eth names",
    ),
    "g_key_ens_search_hint": MessageLookupByLibrary.simpleMessage(
      "Search for a .eth name",
    ),
    "g_key_ens_search_prompt": MessageLookupByLibrary.simpleMessage(
      "Enter an ENS name to search",
    ),
    "g_key_ens_search_register": MessageLookupByLibrary.simpleMessage(
      "Search & Register",
    ),
    "g_key_ens_search_title": MessageLookupByLibrary.simpleMessage(
      "Search ENS",
    ),
    "g_key_ens_self_transfer": MessageLookupByLibrary.simpleMessage(
      "Não é possível enviar para seu próprio endereço",
    ),
    "g_key_ens_service": MessageLookupByLibrary.simpleMessage(
      "Ethereum Name Service",
    ),
    "g_key_ens_set_primary": MessageLookupByLibrary.simpleMessage(
      "Set as Primary",
    ),
    "g_key_ens_standard_name": MessageLookupByLibrary.simpleMessage(
      "Standard Name",
    ),
    "g_key_ens_start_registration": MessageLookupByLibrary.simpleMessage(
      "Start Registration",
    ),
    "g_key_ens_step_1": MessageLookupByLibrary.simpleMessage("Step 1"),
    "g_key_ens_step_2": MessageLookupByLibrary.simpleMessage("Step 2"),
    "g_key_ens_step_3": MessageLookupByLibrary.simpleMessage("Step 3"),
    "g_key_ens_step_commit": MessageLookupByLibrary.simpleMessage("Commit"),
    "g_key_ens_step_register": MessageLookupByLibrary.simpleMessage("Register"),
    "g_key_ens_step_success": MessageLookupByLibrary.simpleMessage("Success"),
    "g_key_ens_step_wait": MessageLookupByLibrary.simpleMessage("Wait"),
    "g_key_ens_subdomain_create": MessageLookupByLibrary.simpleMessage(
      "Create Subdomain",
    ),
    "g_key_ens_subdomain_created": MessageLookupByLibrary.simpleMessage(
      "Subdomain created",
    ),
    "g_key_ens_subdomain_delete": MessageLookupByLibrary.simpleMessage(
      "Delete Subdomain",
    ),
    "g_key_ens_subdomain_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "This subdomain will be permanently deleted.",
    ),
    "g_key_ens_subdomain_deleted": MessageLookupByLibrary.simpleMessage(
      "Subdomain deleted",
    ),
    "g_key_ens_subdomain_empty": MessageLookupByLibrary.simpleMessage(
      "No subdomains yet",
    ),
    "g_key_ens_subdomain_invalid_label": MessageLookupByLibrary.simpleMessage(
      "Use letters, numbers and hyphens only",
    ),
    "g_key_ens_subdomain_label": MessageLookupByLibrary.simpleMessage(
      "Subdomain label",
    ),
    "g_key_ens_subdomain_label_hint": MessageLookupByLibrary.simpleMessage(
      "e.g. blog, mail, app",
    ),
    "g_key_ens_subdomain_owner": MessageLookupByLibrary.simpleMessage(
      "Owner address",
    ),
    "g_key_ens_subdomain_owner_hint": MessageLookupByLibrary.simpleMessage(
      "Leave empty to use current wallet",
    ),
    "g_key_ens_subdomains": MessageLookupByLibrary.simpleMessage("Subdomains"),
    "g_key_ens_success": MessageLookupByLibrary.simpleMessage("Success!"),
    "g_key_ens_success_message": m23,
    "g_key_ens_suggestions": MessageLookupByLibrary.simpleMessage(
      "Suggestions",
    ),
    "g_key_ens_text_records": MessageLookupByLibrary.simpleMessage(
      "Text Records",
    ),
    "g_key_ens_title": MessageLookupByLibrary.simpleMessage("ENS Manager"),
    "g_key_ens_total": MessageLookupByLibrary.simpleMessage("Total"),
    "g_key_ens_total_cost": MessageLookupByLibrary.simpleMessage("Total Cost"),
    "g_key_ens_transfer": MessageLookupByLibrary.simpleMessage("Transfer"),
    "g_key_ens_transfer_desc": MessageLookupByLibrary.simpleMessage(
      "Transfer ownership to another address",
    ),
    "g_key_ens_transfer_success": MessageLookupByLibrary.simpleMessage(
      "Transfer successful",
    ),
    "g_key_ens_transfer_warning": MessageLookupByLibrary.simpleMessage(
      "Transfer is irreversible. Make sure the new owner address is correct.",
    ),
    "g_key_ens_try_another": MessageLookupByLibrary.simpleMessage(
      "Try another name",
    ),
    "g_key_ens_two_step_process": MessageLookupByLibrary.simpleMessage(
      "ENS registration is a two-step process",
    ),
    "g_key_ens_unavailable": MessageLookupByLibrary.simpleMessage(
      "Unavailable",
    ),
    "g_key_ens_wait": MessageLookupByLibrary.simpleMessage("Wait"),
    "g_key_ens_wait_explanation": MessageLookupByLibrary.simpleMessage(
      "Waiting period prevents front-running attacks",
    ),
    "g_key_ens_wait_time_info": MessageLookupByLibrary.simpleMessage(
      "A waiting period prevents front-running",
    ),
    "g_key_ens_wait_timer": m24,
    "g_key_ens_waiting": MessageLookupByLibrary.simpleMessage("Waiting..."),
    "g_key_ens_warning": MessageLookupByLibrary.simpleMessage(
      "Please verify the resolved address before proceeding. ENS names can be transferred or changed by their owner.",
    ),
    "g_key_ens_year": MessageLookupByLibrary.simpleMessage("year"),
    "g_key_ens_years": MessageLookupByLibrary.simpleMessage("years"),
    "g_key_ens_your_identity": MessageLookupByLibrary.simpleMessage(
      "Your Identity",
    ),
    "g_key_enter_confirm_password": MessageLookupByLibrary.simpleMessage(
      "Re-enter new password",
    ),
    "g_key_enter_email": MessageLookupByLibrary.simpleMessage(
      "Enter your email address",
    ),
    "g_key_enter_new_password": MessageLookupByLibrary.simpleMessage(
      "Enter new password",
    ),
    "g_key_enter_old_password": MessageLookupByLibrary.simpleMessage(
      "Enter current password",
    ),
    "g_key_error_1": MessageLookupByLibrary.simpleMessage(
      "Erro ao analisar dados de resposta!",
    ),
    "g_key_error_10": MessageLookupByLibrary.simpleMessage("Erro de conexão"),
    "g_key_error_11": MessageLookupByLibrary.simpleMessage(
      "Erro de sintaxe na solicitação",
    ),
    "g_key_error_12": MessageLookupByLibrary.simpleMessage(
      "Não autorizado, por favor faça login",
    ),
    "g_key_error_13": MessageLookupByLibrary.simpleMessage("Acesso negado"),
    "g_key_error_1301": MessageLookupByLibrary.simpleMessage(
      "Conta ou senha incorreta",
    ),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage(
      "Erro na solicitação",
    ),
    "g_key_error_1403": MessageLookupByLibrary.simpleMessage(
      "Você já está conectado em outro dispositivo e foi desconectado.",
    ),
    "g_key_error_15": MessageLookupByLibrary.simpleMessage(
      "Tempo limite da solicitação esgotado",
    ),
    "g_key_error_16": MessageLookupByLibrary.simpleMessage(
      "Servidor com problemas",
    ),
    "g_key_error_17": MessageLookupByLibrary.simpleMessage(
      "Serviço não implementado",
    ),
    "g_key_error_18": MessageLookupByLibrary.simpleMessage("Erro de gateway"),
    "g_key_error_19": MessageLookupByLibrary.simpleMessage(
      "Serviço indisponível",
    ),
    "g_key_error_20": MessageLookupByLibrary.simpleMessage(
      "Tempo limite do gateway esgotado",
    ),
    "g_key_error_21": MessageLookupByLibrary.simpleMessage(
      "Versão HTTP não suportada",
    ),
    "g_key_error_22": MessageLookupByLibrary.simpleMessage(
      "A solicitação falhou, código de erro:",
    ),
    "g_key_error_23": MessageLookupByLibrary.simpleMessage(
      "Sistema ocupado, tente novamente mais tarde",
    ),
    "g_key_error_24": MessageLookupByLibrary.simpleMessage(
      "Frequência de solicitação muito alta",
    ),
    "g_key_error_25": MessageLookupByLibrary.simpleMessage(
      "Falha na decodificação",
    ),
    "g_key_error_26": MessageLookupByLibrary.simpleMessage(
      "A transação já está na blockchain",
    ),
    "g_key_error_27": MessageLookupByLibrary.simpleMessage(
      "Erro de configuração do certificado!",
    ),
    "g_key_error_28": MessageLookupByLibrary.simpleMessage(
      "Erro de configuração do código de status!",
    ),
    "g_key_error_3": MessageLookupByLibrary.simpleMessage("Erro desconhecido!"),
    "g_key_error_4": MessageLookupByLibrary.simpleMessage(
      "Tempo limite de conexão de rede esgotado, verifique as configurações de rede!",
    ),
    "g_key_error_5": MessageLookupByLibrary.simpleMessage(
      "O servidor está com problemas. Por favor, tente novamente mais tarde!",
    ),
    "g_key_error_8": MessageLookupByLibrary.simpleMessage(
      "Solicitação cancelada, por favor tente novamente!",
    ),
    "g_key_ex_keystore": MessageLookupByLibrary.simpleMessage(
      "Exportar Keystore",
    ),
    "g_key_ex_keystore_1": MessageLookupByLibrary.simpleMessage(
      "Dicas de Backup",
    ),
    "g_key_ex_keystore_10": MessageLookupByLibrary.simpleMessage(
      "Use uma ferramenta de gerenciamento de senhas para armazenar.",
    ),
    "g_key_ex_keystore_11": MessageLookupByLibrary.simpleMessage("Copiado"),
    "g_key_ex_keystore_12": MessageLookupByLibrary.simpleMessage(
      "Cópia cancelada",
    ),
    "g_key_ex_keystore_13": MessageLookupByLibrary.simpleMessage(
      "Carteira de identidade",
    ),
    "g_key_ex_keystore_15": MessageLookupByLibrary.simpleMessage(
      "Arquivo de chave privada criptografada.",
    ),
    "g_key_ex_keystore_16": MessageLookupByLibrary.simpleMessage(
      "Método de importação",
    ),
    "g_key_ex_keystore_17": MessageLookupByLibrary.simpleMessage(
      "Arquivo Keystore",
    ),
    "g_key_ex_keystore_18": MessageLookupByLibrary.simpleMessage(
      "Por favor, digite as informações do Keystore.",
    ),
    "g_key_ex_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Exportar Chave Privada",
    ),
    "g_key_ex_keystore_2": MessageLookupByLibrary.simpleMessage(
      "Obter o Keystore e a senha dará ao portador controle total sobre os ativos da carteira.",
    ),
    "g_key_ex_keystore_3": MessageLookupByLibrary.simpleMessage(
      "Registre cuidadosamente e armazene em um local seguro. Manter múltiplas cópias físicas é o método de armazenamento mais seguro.",
    ),
    "g_key_ex_keystore_4": MessageLookupByLibrary.simpleMessage(
      "Se sua chave privada for perdida, ela não poderá ser recuperada. Faça backup físico e armazene com segurança.",
    ),
    "g_key_ex_keystore_5": MessageLookupByLibrary.simpleMessage(
      "Salvar offline",
    ),
    "g_key_ex_keystore_6": MessageLookupByLibrary.simpleMessage(
      "Não salve em nenhum e-mail, bloco de notas, armazenamento em nuvem ou software de chat que não seja seguro.",
    ),
    "g_key_ex_keystore_7": MessageLookupByLibrary.simpleMessage(
      "Por favor, use transmissão de rede",
    ),
    "g_key_ex_keystore_8": MessageLookupByLibrary.simpleMessage(
      "Por favor, certifique-se de transmiti-lo através de ferramentas de rede. Uma vez que hackers o obtenham, causará perdas econômicas irreparáveis",
    ),
    "g_key_ex_keystore_9": MessageLookupByLibrary.simpleMessage(
      "Use ferramentas para salvar",
    ),
    "g_key_ex_keystore_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "Entendo que qualquer pessoa que obtenha este arquivo e a senha tem controle total sobre meus fundos — a perda é permanente e irrecuperável",
    ),
    "g_key_ex_keystore_pwd_title": MessageLookupByLibrary.simpleMessage(
      "Insira a senha da carteira para confirmar a exportação",
    ),
    "g_key_ex_pk_pwd_title": MessageLookupByLibrary.simpleMessage(
      "Insira a senha da carteira para ver a chave privada",
    ),
    "g_key_feedback": MessageLookupByLibrary.simpleMessage("Feedback"),
    "g_key_feedback_1": MessageLookupByLibrary.simpleMessage(
      "Por favor, preencha as informações de feedback",
    ),
    "g_key_feedback_2": MessageLookupByLibrary.simpleMessage(
      "Há anexos não enviados",
    ),
    "g_key_feedback_3": MessageLookupByLibrary.simpleMessage("Falha no Envio"),
    "g_key_feedback_4": MessageLookupByLibrary.simpleMessage(
      "Enviado com sucesso",
    ),
    "g_key_feedback_5": MessageLookupByLibrary.simpleMessage("Anexos"),
    "g_key_feedback_6": MessageLookupByLibrary.simpleMessage(
      "Envie até 5 anexos, cada anexo não pode ser maior que 100MB",
    ),
    "g_key_feedback_7": MessageLookupByLibrary.simpleMessage("Falhou"),
    "g_key_feedback_8": MessageLookupByLibrary.simpleMessage(
      "Clique para tentar",
    ),
    "g_key_feedback_9": MessageLookupByLibrary.simpleMessage(
      "Por favor, faça login",
    ),
    "g_key_filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "g_key_filter_type": MessageLookupByLibrary.simpleMessage("Type"),
    "g_key_forgot_password": MessageLookupByLibrary.simpleMessage(
      "Forgot Password?",
    ),
    "g_key_gas_alert": MessageLookupByLibrary.simpleMessage("Gas Alert"),
    "g_key_gas_alert_above": MessageLookupByLibrary.simpleMessage(
      "Alert when above",
    ),
    "g_key_gas_alert_below": MessageLookupByLibrary.simpleMessage(
      "Alert when below",
    ),
    "g_key_gas_alert_save": MessageLookupByLibrary.simpleMessage("Save"),
    "g_key_gas_alert_threshold": MessageLookupByLibrary.simpleMessage(
      "Threshold (Gwei)",
    ),
    "g_key_gas_auto_refresh": m25,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("Taxa Base"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage("Personalizado"),
    "g_key_gas_estimated_time": MessageLookupByLibrary.simpleMessage(
      "Tempo Est.",
    ),
    "g_key_gas_fast": MessageLookupByLibrary.simpleMessage("Rápido"),
    "g_key_gas_footer": MessageLookupByLibrary.simpleMessage(
      "Gas prices fluctuate based on network demand. Lower gas = slower confirmation, higher gas = faster confirmation.",
    ),
    "g_key_gas_max_fee": MessageLookupByLibrary.simpleMessage("Taxa Máxima"),
    "g_key_gas_network_busy": MessageLookupByLibrary.simpleMessage(
      "Rede congestionada",
    ),
    "g_key_gas_network_idle": MessageLookupByLibrary.simpleMessage(
      "Rede livre",
    ),
    "g_key_gas_network_normal": MessageLookupByLibrary.simpleMessage(
      "Rede normal",
    ),
    "g_key_gas_price_trend": MessageLookupByLibrary.simpleMessage(
      "Price Trend",
    ),
    "g_key_gas_priority_fee": MessageLookupByLibrary.simpleMessage(
      "Taxa de Prioridade",
    ),
    "g_key_gas_realtime_prices": MessageLookupByLibrary.simpleMessage(
      "Real-time Gas Prices",
    ),
    "g_key_gas_settings": MessageLookupByLibrary.simpleMessage(
      "Configurações de Gas",
    ),
    "g_key_gas_slow": MessageLookupByLibrary.simpleMessage("Lento"),
    "g_key_gas_standard": MessageLookupByLibrary.simpleMessage("Padrão"),
    "g_key_gas_tracker": MessageLookupByLibrary.simpleMessage("Gas Tracker"),
    "g_key_gesture_medium": MessageLookupByLibrary.simpleMessage("Médio"),
    "g_key_gesture_strong": MessageLookupByLibrary.simpleMessage("Forte"),
    "g_key_gesture_too_simple": MessageLookupByLibrary.simpleMessage(
      "Padrão muito simples, adicione mais nós",
    ),
    "g_key_gesture_weak": MessageLookupByLibrary.simpleMessage("Fraco"),
    "g_key_google_sign_in_cancelled": MessageLookupByLibrary.simpleMessage(
      "Google sign-in cancelled",
    ),
    "g_key_high_value_only": MessageLookupByLibrary.simpleMessage(
      "High value only",
    ),
    "g_key_hw_account_added": m26,
    "g_key_hw_accounts": MessageLookupByLibrary.simpleMessage("Contas"),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("Adicionar"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage(
      "Adicionar Conta",
    ),
    "g_key_hw_add_account_content": m27,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "Endereço copiado",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "Make sure your device is unlocked and Bluetooth is enabled before connecting.",
    ),
    "g_key_hw_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage("Check App"),
    "g_key_hw_confirm_on_device": MessageLookupByLibrary.simpleMessage(
      "Confirme no seu dispositivo",
    ),
    "g_key_hw_connect": MessageLookupByLibrary.simpleMessage(
      "Conectar Carteira Hardware",
    ),
    "g_key_hw_connect_new_device": MessageLookupByLibrary.simpleMessage(
      "Connect New Device",
    ),
    "g_key_hw_connect_new_keystone": MessageLookupByLibrary.simpleMessage(
      "Air-gap with Keystone (QR)",
    ),
    "g_key_hw_connect_new_ledger": MessageLookupByLibrary.simpleMessage(
      "Connect Ledger (Bluetooth)",
    ),
    "g_key_hw_connect_new_trezor": MessageLookupByLibrary.simpleMessage(
      "Connect Trezor (USB)",
    ),
    "g_key_hw_connected": MessageLookupByLibrary.simpleMessage("Connected"),
    "g_key_hw_connecting": MessageLookupByLibrary.simpleMessage(
      "Connecting...",
    ),
    "g_key_hw_current_app_label": m28,
    "g_key_hw_days_ago": m29,
    "g_key_hw_derivation_path": MessageLookupByLibrary.simpleMessage(
      "Caminho de Derivação",
    ),
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("Disconnect"),
    "g_key_hw_disconnected": MessageLookupByLibrary.simpleMessage(
      "Desconectado",
    ),
    "g_key_hw_enable_bluetooth": MessageLookupByLibrary.simpleMessage(
      "Por favor ative o Bluetooth",
    ),
    "g_key_hw_firmware": MessageLookupByLibrary.simpleMessage(
      "Versão do Firmware",
    ),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage("Voltar"),
    "g_key_hw_import_failed": m30,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "Connect Keystone",
    ),
    "g_key_hw_keystone_invalid_response": MessageLookupByLibrary.simpleMessage(
      "Invalid response from Keystone device",
    ),
    "g_key_hw_keystone_scan_error": MessageLookupByLibrary.simpleMessage(
      "Failed to parse QR code. Please try again.",
    ),
    "g_key_hw_keystone_scan_request_hint": MessageLookupByLibrary.simpleMessage(
      "Scan this QR code with your Keystone device to sign the transaction",
    ),
    "g_key_hw_keystone_scan_response_hint":
        MessageLookupByLibrary.simpleMessage(
          "Point your camera at the QR code displayed on your Keystone device",
        ),
    "g_key_hw_keystone_scan_response_title":
        MessageLookupByLibrary.simpleMessage("Scan Keystone Signature"),
    "g_key_hw_keystone_scan_xpub_hint": MessageLookupByLibrary.simpleMessage(
      "Scan the QR code from your Keystone device to import accounts",
    ),
    "g_key_hw_keystone_signature_received":
        MessageLookupByLibrary.simpleMessage("Signature received successfully"),
    "g_key_hw_keystone_signing": MessageLookupByLibrary.simpleMessage(
      "Waiting for Keystone signature...",
    ),
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "Tap to scan Keystone response",
    ),
    "g_key_hw_last_connected": m31,
    "g_key_hw_ledger": MessageLookupByLibrary.simpleMessage("Ledger"),
    "g_key_hw_load_more": MessageLookupByLibrary.simpleMessage("Carregar mais"),
    "g_key_hw_loading_accounts": MessageLookupByLibrary.simpleMessage(
      "Carregando contas...",
    ),
    "g_key_hw_loading_hint": MessageLookupByLibrary.simpleMessage(
      "Por favor confirme no dispositivo se solicitado",
    ),
    "g_key_hw_no_accounts_found": MessageLookupByLibrary.simpleMessage(
      "Nenhuma conta encontrada",
    ),
    "g_key_hw_no_app_open": MessageLookupByLibrary.simpleMessage(
      "No app is currently open",
    ),
    "g_key_hw_no_devices": MessageLookupByLibrary.simpleMessage(
      "Nenhum dispositivo encontrado",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "Dispositivo não conectado",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "Not Connected",
    ),
    "g_key_hw_open_app": m32,
    "g_key_hw_open_ledger_app_hint": m33,
    "g_key_hw_rejected": MessageLookupByLibrary.simpleMessage(
      "Rejeitado no dispositivo",
    ),
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage(
      "Remove Device",
    ),
    "g_key_hw_remove_device_confirm": m34,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage(
      "Saved Devices",
    ),
    "g_key_hw_scanning": MessageLookupByLibrary.simpleMessage(
      "Procurando dispositivos...",
    ),
    "g_key_hw_select_device": MessageLookupByLibrary.simpleMessage(
      "Selecionar Dispositivo",
    ),
    "g_key_hw_sign_message": MessageLookupByLibrary.simpleMessage(
      "Assinar Mensagem",
    ),
    "g_key_hw_sign_tx": MessageLookupByLibrary.simpleMessage(
      "Assinar Transação",
    ),
    "g_key_hw_signal_strength": MessageLookupByLibrary.simpleMessage(
      "Força do Sinal",
    ),
    "g_key_hw_supported_devices": MessageLookupByLibrary.simpleMessage(
      "Supported Devices",
    ),
    "g_key_hw_timeout": MessageLookupByLibrary.simpleMessage(
      "Tempo de conexão esgotado",
    ),
    "g_key_hw_title": MessageLookupByLibrary.simpleMessage("Carteira Hardware"),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("Today"),
    "g_key_hw_trezor": MessageLookupByLibrary.simpleMessage("Trezor"),
    "g_key_hw_trezor_connect_failed": MessageLookupByLibrary.simpleMessage(
      "Failed to connect to Trezor. Make sure USB is connected.",
    ),
    "g_key_hw_trezor_connect_title": MessageLookupByLibrary.simpleMessage(
      "Connect Trezor",
    ),
    "g_key_hw_trezor_connected": MessageLookupByLibrary.simpleMessage(
      "Trezor connected successfully",
    ),
    "g_key_hw_trezor_connecting": MessageLookupByLibrary.simpleMessage(
      "Connecting to Trezor...",
    ),
    "g_key_hw_trezor_passphrase_required": MessageLookupByLibrary.simpleMessage(
      "Enter passphrase on your Trezor device",
    ),
    "g_key_hw_trezor_pin_required": MessageLookupByLibrary.simpleMessage(
      "Enter PIN on your Trezor device",
    ),
    "g_key_hw_trezor_usb_hint": MessageLookupByLibrary.simpleMessage(
      "Connect your Trezor device via USB cable and unlock it",
    ),
    "g_key_hw_view_accounts": MessageLookupByLibrary.simpleMessage(
      "View Accounts",
    ),
    "g_key_hw_wallet_accounts": MessageLookupByLibrary.simpleMessage(
      "Contas da Carteira",
    ),
    "g_key_hw_yesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Uma carteira de moeda atual já existe.",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "Não foi possível ler o Keystore",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage("Keystore"),
    "g_key_link_account": MessageLookupByLibrary.simpleMessage("Link Account"),
    "g_key_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "Linked Accounts",
    ),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Entrar"),
    "g_key_login_success": MessageLookupByLibrary.simpleMessage(
      "Login successful",
    ),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Sair"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Tem certeza que deseja sair do aplicativo?",
    ),
    "g_key_loyalty_available_points": MessageLookupByLibrary.simpleMessage(
      "Pontos Disponíveis",
    ),
    "g_key_loyalty_checked_today": MessageLookupByLibrary.simpleMessage(
      "Checked in today!",
    ),
    "g_key_loyalty_checkin_btn": MessageLookupByLibrary.simpleMessage(
      "Check In",
    ),
    "g_key_loyalty_checkin_done": MessageLookupByLibrary.simpleMessage("Done"),
    "g_key_loyalty_checkin_failed": MessageLookupByLibrary.simpleMessage(
      "Check-in failed, please try again",
    ),
    "g_key_loyalty_checkin_success": MessageLookupByLibrary.simpleMessage(
      "Check-in successful!",
    ),
    "g_key_loyalty_claim_points": MessageLookupByLibrary.simpleMessage(
      "Resgatar Pontos",
    ),
    "g_key_loyalty_complete_failed": MessageLookupByLibrary.simpleMessage(
      "Task failed, please try again",
    ),
    "g_key_loyalty_complete_success": MessageLookupByLibrary.simpleMessage(
      "Task completed!",
    ),
    "g_key_loyalty_copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "g_key_loyalty_daily_checkin": MessageLookupByLibrary.simpleMessage(
      "Check-in Diário",
    ),
    "g_key_loyalty_earn_points": m35,
    "g_key_loyalty_earned": MessageLookupByLibrary.simpleMessage("Ganho"),
    "g_key_loyalty_history": MessageLookupByLibrary.simpleMessage(
      "Histórico de Pontos",
    ),
    "g_key_loyalty_invite": MessageLookupByLibrary.simpleMessage("Invite"),
    "g_key_loyalty_invite_bonus": m36,
    "g_key_loyalty_invite_friends": MessageLookupByLibrary.simpleMessage(
      "Invite Friends",
    ),
    "g_key_loyalty_invited_friends": MessageLookupByLibrary.simpleMessage(
      "Amigos Convidados",
    ),
    "g_key_loyalty_max_level": MessageLookupByLibrary.simpleMessage(
      "Max Level",
    ),
    "g_key_loyalty_next_prefix": MessageLookupByLibrary.simpleMessage("Next"),
    "g_key_loyalty_next_tier": MessageLookupByLibrary.simpleMessage(
      "Próximo Nível",
    ),
    "g_key_loyalty_no_rewards": MessageLookupByLibrary.simpleMessage(
      "Nenhuma recompensa disponível",
    ),
    "g_key_loyalty_no_tasks": MessageLookupByLibrary.simpleMessage(
      "Nenhuma tarefa disponível",
    ),
    "g_key_loyalty_points": MessageLookupByLibrary.simpleMessage("Pontos"),
    "g_key_loyalty_points_to_next": m37,
    "g_key_loyalty_redeem": MessageLookupByLibrary.simpleMessage("Trocar"),
    "g_key_loyalty_referral": MessageLookupByLibrary.simpleMessage("Indicação"),
    "g_key_loyalty_referral_bonus": MessageLookupByLibrary.simpleMessage(
      "Bônus de Indicação",
    ),
    "g_key_loyalty_referral_code": MessageLookupByLibrary.simpleMessage(
      "Seu Código de Indicação",
    ),
    "g_key_loyalty_referral_link": MessageLookupByLibrary.simpleMessage(
      "Link de Indicação",
    ),
    "g_key_loyalty_rewards": MessageLookupByLibrary.simpleMessage(
      "Recompensas",
    ),
    "g_key_loyalty_share": MessageLookupByLibrary.simpleMessage("Share"),
    "g_key_loyalty_spent": MessageLookupByLibrary.simpleMessage("Gasto"),
    "g_key_loyalty_task_complete": MessageLookupByLibrary.simpleMessage(
      "Tarefa Completa",
    ),
    "g_key_loyalty_tasks": MessageLookupByLibrary.simpleMessage("Tarefas"),
    "g_key_loyalty_tier": MessageLookupByLibrary.simpleMessage("Nível"),
    "g_key_loyalty_tier_bronze": MessageLookupByLibrary.simpleMessage("Bronze"),
    "g_key_loyalty_tier_diamond": MessageLookupByLibrary.simpleMessage(
      "Diamante",
    ),
    "g_key_loyalty_tier_gold": MessageLookupByLibrary.simpleMessage("Ouro"),
    "g_key_loyalty_tier_platinum": MessageLookupByLibrary.simpleMessage(
      "Platina",
    ),
    "g_key_loyalty_tier_silver": MessageLookupByLibrary.simpleMessage("Prata"),
    "g_key_loyalty_title": MessageLookupByLibrary.simpleMessage("Pontos"),
    "g_key_loyalty_total_earned": MessageLookupByLibrary.simpleMessage(
      "Total Earned",
    ),
    "g_key_loyalty_total_points": MessageLookupByLibrary.simpleMessage(
      "Pontos Totais",
    ),
    "g_key_loyalty_used": MessageLookupByLibrary.simpleMessage("Used"),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("Facebook"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("Twitter"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("Reddit"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("Navegador"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("Telegram"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("Discord"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("Youtube"),
    "g_key_m_19": MessageLookupByLibrary.simpleMessage("Instagram"),
    "g_key_m_2": MessageLookupByLibrary.simpleMessage(
      "Capitalização de Mercado",
    ),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("Volume de Negociação"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("Fornecimento Total"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("Em Circulação"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("Sobre"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("Mais"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("Links"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("Site"),
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage("Available"),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "Requires staking",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage(
      "Por favor, digite a frase de recuperação",
    ),
    "g_key_new_airdrops": MessageLookupByLibrary.simpleMessage("New airdrops"),
    "g_key_new_password": MessageLookupByLibrary.simpleMessage("New Password"),
    "g_key_new_password_same_as_old": MessageLookupByLibrary.simpleMessage(
      "New password must be different from current password",
    ),
    "g_key_next": MessageLookupByLibrary.simpleMessage("Next"),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("Total"),
    "g_key_nft_16": MessageLookupByLibrary.simpleMessage("Câmera"),
    "g_key_nft_17": MessageLookupByLibrary.simpleMessage("Selecionar foto"),
    "g_key_nft_18": MessageLookupByLibrary.simpleMessage("Conteúdo"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Nome"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Voltar"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage("Transação enviada"),
    "g_key_nft_47": MessageLookupByLibrary.simpleMessage("Selecionar vídeo"),
    "g_key_no_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "No linked accounts",
    ),
    "g_key_notification_settings": MessageLookupByLibrary.simpleMessage(
      "Notification Settings",
    ),
    "g_key_oidc_login": MessageLookupByLibrary.simpleMessage(
      "Enterprise Login (SSO)",
    ),
    "g_key_oidc_not_configured": MessageLookupByLibrary.simpleMessage(
      "Enterprise SSO not configured",
    ),
    "g_key_old_password": MessageLookupByLibrary.simpleMessage(
      "Current Password",
    ),
    "g_key_or": MessageLookupByLibrary.simpleMessage("or"),
    "g_key_password_changed_success": MessageLookupByLibrary.simpleMessage(
      "Password changed successfully",
    ),
    "g_key_password_min_length": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters",
    ),
    "g_key_password_req_different": MessageLookupByLibrary.simpleMessage(
      "Different from current password",
    ),
    "g_key_password_req_length": MessageLookupByLibrary.simpleMessage(
      "At least 6 characters",
    ),
    "g_key_password_required": MessageLookupByLibrary.simpleMessage(
      "Password is required",
    ),
    "g_key_password_requirements": MessageLookupByLibrary.simpleMessage(
      "Password Requirements",
    ),
    "g_key_password_reset_success": MessageLookupByLibrary.simpleMessage(
      "Password reset successfully",
    ),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "g_key_payment_amount_invalid": MessageLookupByLibrary.simpleMessage(
      "Valor inválido",
    ),
    "g_key_payment_approx_token": m38,
    "g_key_payment_approx_usdt": m39,
    "g_key_payment_code_title": MessageLookupByLibrary.simpleMessage(
      "QR de pagamento",
    ),
    "g_key_payment_confirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
    "g_key_payment_history": MessageLookupByLibrary.simpleMessage(
      "Histórico de pagamentos",
    ),
    "g_key_payment_history_btn": MessageLookupByLibrary.simpleMessage(
      "Histórico",
    ),
    "g_key_payment_incoming": MessageLookupByLibrary.simpleMessage("Entrada"),
    "g_key_payment_load_failed": MessageLookupByLibrary.simpleMessage(
      "Falha ao carregar",
    ),
    "g_key_payment_name_not_set": MessageLookupByLibrary.simpleMessage(
      "Não definido",
    ),
    "g_key_payment_native_insufficient": MessageLookupByLibrary.simpleMessage(
      "Saldo nativo insuficiente!",
    ),
    "g_key_payment_native_not_found": MessageLookupByLibrary.simpleMessage(
      "Cadeia nativa não encontrada!",
    ),
    "g_key_payment_outgoing": MessageLookupByLibrary.simpleMessage("Saída"),
    "g_key_payment_set_amount_title": MessageLookupByLibrary.simpleMessage(
      "Definir valor",
    ),
    "g_key_payment_success": MessageLookupByLibrary.simpleMessage(
      "Pagamento bem-sucedido!",
    ),
    "g_key_payment_title": MessageLookupByLibrary.simpleMessage("Pagamento"),
    "g_key_payment_usdt_insufficient": MessageLookupByLibrary.simpleMessage(
      "Saldo USDT insuficiente!",
    ),
    "g_key_payment_usdt_not_found": MessageLookupByLibrary.simpleMessage(
      "Adicione o token USDT!",
    ),
    "g_key_payment_wallet": MessageLookupByLibrary.simpleMessage("Carteira"),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
      "Selecionar da galeria do telefone",
    ),
    "g_key_resend_code": MessageLookupByLibrary.simpleMessage("Resend Code"),
    "g_key_reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "g_key_reset_password": MessageLookupByLibrary.simpleMessage(
      "Reset Password",
    ),
    "g_key_reset_password_email_desc": MessageLookupByLibrary.simpleMessage(
      "Enter your email address to receive a verification code",
    ),
    "g_key_saml_login": MessageLookupByLibrary.simpleMessage("SAML Login"),
    "g_key_saml_not_configured": MessageLookupByLibrary.simpleMessage(
      "SAML not configured",
    ),
    "g_key_send_code": MessageLookupByLibrary.simpleMessage(
      "Send Verification Code",
    ),
    "g_key_set_new_password_desc": MessageLookupByLibrary.simpleMessage(
      "Set your new password",
    ),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage(
      "Compartilhar código QR",
    ),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage(
      "Compartilhar link",
    ),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage(
      "Método de compartilhamento",
    ),
    "g_key_sign_in_failed": MessageLookupByLibrary.simpleMessage(
      "Sign in failed",
    ),
    "g_key_social_login": MessageLookupByLibrary.simpleMessage("Social Login"),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Chat"),
    "g_key_squad_k11": MessageLookupByLibrary.simpleMessage(
      "O arquivo é muito grande para upload",
    ),
    "g_key_squad_k15": m40,
    "g_key_squad_k18": MessageLookupByLibrary.simpleMessage(
      "Adicionar Contato",
    ),
    "g_key_squad_k24": MessageLookupByLibrary.simpleMessage("Contato"),
    "g_key_squad_k25": MessageLookupByLibrary.simpleMessage(
      "Pesquisar por e-mail",
    ),
    "g_key_stake_active": MessageLookupByLibrary.simpleMessage("Ativo"),
    "g_key_stake_active_positions": MessageLookupByLibrary.simpleMessage(
      "Active Positions",
    ),
    "g_key_stake_apy": MessageLookupByLibrary.simpleMessage("APY"),
    "g_key_stake_avg_apy": MessageLookupByLibrary.simpleMessage("Avg APY"),
    "g_key_stake_claim": MessageLookupByLibrary.simpleMessage(
      "Resgatar Recompensas",
    ),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage("Comissão"),
    "g_key_stake_d_unbond": m41,
    "g_key_stake_days_left": m42,
    "g_key_stake_days_remaining": m43,
    "g_key_stake_delegators": MessageLookupByLibrary.simpleMessage(
      "Delegadores",
    ),
    "g_key_stake_liquid": MessageLookupByLibrary.simpleMessage(
      "Staking Líquido",
    ),
    "g_key_stake_liquid_tag": MessageLookupByLibrary.simpleMessage("Liquid"),
    "g_key_stake_min_stake": MessageLookupByLibrary.simpleMessage(
      "Stake Mínimo",
    ),
    "g_key_stake_no_lock": MessageLookupByLibrary.simpleMessage("No lock"),
    "g_key_stake_no_positions": MessageLookupByLibrary.simpleMessage(
      "Sem posições de staking",
    ),
    "g_key_stake_no_positions_yet": MessageLookupByLibrary.simpleMessage(
      "No staking positions yet",
    ),
    "g_key_stake_overview": MessageLookupByLibrary.simpleMessage(
      "Total Staking Overview",
    ),
    "g_key_stake_pending_rewards": MessageLookupByLibrary.simpleMessage(
      "Recompensas Pendentes",
    ),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage(
      "Minhas Posições",
    ),
    "g_key_stake_protocol": MessageLookupByLibrary.simpleMessage("Protocolo"),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("Protocols"),
    "g_key_stake_restake": MessageLookupByLibrary.simpleMessage(
      "Refazer Stake",
    ),
    "g_key_stake_rewards": MessageLookupByLibrary.simpleMessage("Recompensas"),
    "g_key_stake_select_validator": MessageLookupByLibrary.simpleMessage(
      "Selecionar Validador",
    ),
    "g_key_stake_stake": MessageLookupByLibrary.simpleMessage("Fazer Stake"),
    "g_key_stake_staked": MessageLookupByLibrary.simpleMessage("Staked"),
    "g_key_stake_start_staking": MessageLookupByLibrary.simpleMessage(
      "Start Staking",
    ),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("Staking"),
    "g_key_stake_total_staked": MessageLookupByLibrary.simpleMessage(
      "Total em Stake",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage(
      "Desbloqueando",
    ),
    "g_key_stake_unbonding_period": MessageLookupByLibrary.simpleMessage(
      "Período de Desbloqueio",
    ),
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage(
      "Desfazer Stake",
    ),
    "g_key_stake_uptime": MessageLookupByLibrary.simpleMessage("Tempo Ativo"),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("Validador"),
    "g_key_stake_validators": MessageLookupByLibrary.simpleMessage(
      "Validadores",
    ),
    "g_key_step_email": MessageLookupByLibrary.simpleMessage("Email"),
    "g_key_step_password": MessageLookupByLibrary.simpleMessage("Password"),
    "g_key_step_verify": MessageLookupByLibrary.simpleMessage("Verify"),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Concluído"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Preço do gás"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("Taxa máxima de gás"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage("Taxa máxima por gás"),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("Pendente"),
    "g_key_t_29": m44,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("Falhou"),
    "g_key_t_30": MessageLookupByLibrary.simpleMessage("Taxa do Minerador"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("Prosseguir"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage("Senha da carteira"),
    "g_key_t_33": MessageLookupByLibrary.simpleMessage(
      "A senha da carteira não pode estar vazia",
    ),
    "g_key_t_34": MessageLookupByLibrary.simpleMessage(
      "Senha da carteira incorreta",
    ),
    "g_key_t_35": MessageLookupByLibrary.simpleMessage(
      "Por favor, digite a senha da carteira",
    ),
    "g_key_t_36": MessageLookupByLibrary.simpleMessage("Taxa de Gás"),
    "g_key_t_37": MessageLookupByLibrary.simpleMessage(
      "Média da taxa de gás do último bloco",
    ),
    "g_key_t_4": MessageLookupByLibrary.simpleMessage("Transferência enviada"),
    "g_key_t_43": MessageLookupByLibrary.simpleMessage(
      "Digite um número inteiro maior que 0.",
    ),
    "g_key_t_44": MessageLookupByLibrary.simpleMessage("Falha ao obter dados"),
    "g_key_t_45": m45,
    "g_key_t_46": MessageLookupByLibrary.simpleMessage(
      "Verificar conta do endereço de recebimento",
    ),
    "g_key_t_47": MessageLookupByLibrary.simpleMessage("Buscar"),
    "g_key_t_49": MessageLookupByLibrary.simpleMessage("Sem conta"),
    "g_key_t_5": MessageLookupByLibrary.simpleMessage("Transferência recebida"),
    "g_key_t_50": MessageLookupByLibrary.simpleMessage("Endereço inválido"),
    "g_key_t_51": MessageLookupByLibrary.simpleMessage(
      "Verificação da conta bem-sucedida",
    ),
    "g_key_t_52": m46,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "O endereço de recebimento não possui conta, e a primeira transferência deve ser de pelo menos 10XRP",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Gás Utilizado"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Gás"),
    "g_key_time_days_ago": m47,
    "g_key_time_hours_ago": m48,
    "g_key_time_just_now": MessageLookupByLibrary.simpleMessage("Just now"),
    "g_key_time_minutes_ago": m49,
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage(
      "Histórico de transações",
    ),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage(
      "Detalhes da Transação",
    ),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage(
      "Por favor, visualize os recibos de transação no histórico",
    ),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage("Valor gasto"),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage("Valor recebido"),
    "g_key_tx_filter_date_from": MessageLookupByLibrary.simpleMessage(
      "Start Date",
    ),
    "g_key_tx_filter_date_range": MessageLookupByLibrary.simpleMessage(
      "Date Range",
    ),
    "g_key_tx_filter_date_to": MessageLookupByLibrary.simpleMessage("End Date"),
    "g_key_tx_filter_direction": MessageLookupByLibrary.simpleMessage(
      "Direction",
    ),
    "g_key_tx_no_results": MessageLookupByLibrary.simpleMessage(
      "No transactions match your filter",
    ),
    "g_key_u_10": MessageLookupByLibrary.simpleMessage("Tipos de NFT"),
    "g_key_u_11": MessageLookupByLibrary.simpleMessage("Seguidores"),
    "g_key_u_12": MessageLookupByLibrary.simpleMessage("Tipos de Usuário"),
    "g_key_u_13": MessageLookupByLibrary.simpleMessage("Site"),
    "g_key_u_14": MessageLookupByLibrary.simpleMessage("Link dos produtos"),
    "g_key_u_15": MessageLookupByLibrary.simpleMessage("Plataformas de mídia"),
    "g_key_u_16": MessageLookupByLibrary.simpleMessage("Endereço da carteira"),
    "g_key_u_2": MessageLookupByLibrary.simpleMessage("Apelido"),
    "g_key_u_23": MessageLookupByLibrary.simpleMessage(
      "Falha ao carregar avatar",
    ),
    "g_key_u_3": MessageLookupByLibrary.simpleMessage("Descrição"),
    "g_key_u_5": MessageLookupByLibrary.simpleMessage("Informações do artista"),
    "g_key_u_6": MessageLookupByLibrary.simpleMessage("Você não é um artista"),
    "g_key_u_7": MessageLookupByLibrary.simpleMessage(
      "Clique aqui para se candidatar a artista",
    ),
    "g_key_u_8": MessageLookupByLibrary.simpleMessage("Nome"),
    "g_key_u_9": MessageLookupByLibrary.simpleMessage("Receita"),
    "g_key_unlink_account": MessageLookupByLibrary.simpleMessage(
      "Unlink Account",
    ),
    "g_key_user_p1": MessageLookupByLibrary.simpleMessage("Li e aceito os "),
    "g_key_user_p2": MessageLookupByLibrary.simpleMessage("Termos e Condições"),
    "g_key_user_p3": MessageLookupByLibrary.simpleMessage(
      "Política de Privacidade e Declaração de Coleta de Informações Pessoais",
    ),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage(
      "Nova versão encontrada",
    ),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage(
      "Atualizar imediatamente",
    ),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage(
      "Nova versão encontrada",
    ),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage(
      "Já está na versão mais recente",
    ),
    "g_key_verification_code": MessageLookupByLibrary.simpleMessage(
      "Verification Code",
    ),
    "g_key_verification_code_sent": m50,
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage(
      "Ver Frase de Recuperação",
    ),
    "g_key_wallet_c11": MessageLookupByLibrary.simpleMessage(
      "Por favor, certifique-se de registrar sua frase de recuperação e armazená-la com segurança.",
    ),
    "g_key_wallet_c12": MessageLookupByLibrary.simpleMessage(
      "Agora tente inserir sua frase de recuperação novamente.",
    ),
    "g_key_wallet_c13": MessageLookupByLibrary.simpleMessage("Importar Conta"),
    "g_key_wallet_c14": MessageLookupByLibrary.simpleMessage("Criar Conta"),
    "g_key_wallet_c15": MessageLookupByLibrary.simpleMessage("Tudo pronto!"),
    "g_key_wallet_c16": MessageLookupByLibrary.simpleMessage(
      "Agora você pode aproveitar sua carteira completamente.",
    ),
    "g_key_wallet_c17": MessageLookupByLibrary.simpleMessage("Começar"),
    "g_key_wallet_c18": MessageLookupByLibrary.simpleMessage("Pular por agora"),
    "g_key_wallet_c19": MessageLookupByLibrary.simpleMessage(
      "Você pode pular o backup da frase de recuperação por agora e fazer isso novamente nas Configurações a qualquer momento, se necessário.",
    ),
    "g_key_wallet_c21": MessageLookupByLibrary.simpleMessage(
      "Criar diretamente",
    ),
    "g_key_wallet_c22": MessageLookupByLibrary.simpleMessage(
      "criado com sucesso",
    ),
    "g_key_wallet_c23": MessageLookupByLibrary.simpleMessage(
      "Se você quiser verificar os detalhes da sua carteira ou exportar o keystore, vá para Menu Lateral > Gerenciar Carteira ",
    ),
    "g_key_wallet_c24": MessageLookupByLibrary.simpleMessage(
      "Exportar meu keystore",
    ),
    "g_key_wallet_c25": MessageLookupByLibrary.simpleMessage(
      "Proteja sua carteira fazendo backup",
    ),
    "g_key_wallet_c26": MessageLookupByLibrary.simpleMessage(
      "Um keystore é um repositório de certificados de segurança e chaves privadas associadas.",
    ),
    "g_key_wallet_c27": MessageLookupByLibrary.simpleMessage(
      "Passo 1: Vá para Gerenciar Carteira.",
    ),
    "g_key_wallet_c28": MessageLookupByLibrary.simpleMessage(
      "Passo 2: Selecione o Endereço da Carteira.",
    ),
    "g_key_wallet_c29": MessageLookupByLibrary.simpleMessage(
      "Passo 3: Pressione Exportar Keystore.",
    ),
    "g_key_wallet_c30": MessageLookupByLibrary.simpleMessage(
      "Ir para Gerenciar Carteira",
    ),
    "g_key_wallet_c31": MessageLookupByLibrary.simpleMessage(
      "Voltar para a página inicial",
    ),
    "g_key_wallet_c32": MessageLookupByLibrary.simpleMessage(
      "Adicionar Carteira",
    ),
    "g_key_wallet_c33": MessageLookupByLibrary.simpleMessage(
      "Criar uma carteira usando uma frase de recuperação.",
    ),
    "g_key_wallet_c34": MessageLookupByLibrary.simpleMessage(
      "Digite um nome para a carteira",
    ),
    "g_key_wallet_c35": MessageLookupByLibrary.simpleMessage(
      "Você não fez backup da sua frase de recuperação!",
    ),
    "g_key_wallet_c36": MessageLookupByLibrary.simpleMessage(
      "Fazer Backup Agora",
    ),
    "g_key_wallet_c37": MessageLookupByLibrary.simpleMessage(
      "Definir Senha da Carteira",
    ),
    "g_key_wallet_c38": MessageLookupByLibrary.simpleMessage(
      "Fazer Backup da Carteira",
    ),
    "g_key_wallet_c39": MessageLookupByLibrary.simpleMessage(
      "Por favor, registre a seguinte frase de recuperação",
    ),
    "g_key_wallet_c4": MessageLookupByLibrary.simpleMessage("Iniciar"),
    "g_key_wallet_c40": MessageLookupByLibrary.simpleMessage(
      "Dispositivos conectados à internet podem expor suas informações. Recomendamos que você anote a frase de recuperação e a armazene com segurança.",
    ),
    "g_key_wallet_c41": MessageLookupByLibrary.simpleMessage(
      "Aviso: Não divulgue sua frase de recuperação a ninguém. A N42Wallet nunca pedirá essas informações. Por favor, seja extremamente cauteloso e armazene-a offline com segurança. Se sua frase de recuperação for exposta, você pode perder todos os seus ativos e não conseguir recuperá-los.",
    ),
    "g_key_wallet_c42": MessageLookupByLibrary.simpleMessage(
      "Aviso: A frase de recuperação é a única maneira de recuperar os ativos da sua carteira.",
    ),
    "g_key_wallet_c43": MessageLookupByLibrary.simpleMessage("Próximo passo"),
    "g_key_wallet_c44": MessageLookupByLibrary.simpleMessage(
      "Clique para ver a frase de recuperação",
    ),
    "g_key_wallet_c45": MessageLookupByLibrary.simpleMessage(
      "Por favor, certifique-se de que não há outras pessoas ou câmeras por perto",
    ),
    "g_key_wallet_c46": MessageLookupByLibrary.simpleMessage(
      "Confirmar Frase de Recuperação",
    ),
    "g_key_wallet_c47": MessageLookupByLibrary.simpleMessage(
      "Informações da Carteira",
    ),
    "g_key_wallet_c48": MessageLookupByLibrary.simpleMessage(
      "Nome da carteira",
    ),
    "g_key_wallet_c49": MessageLookupByLibrary.simpleMessage(
      "Por favor, faça backup da sua frase de recuperação primeiro!",
    ),
    "g_key_wallet_c6": MessageLookupByLibrary.simpleMessage(
      "Verificar Frase de Recuperação",
    ),
    "g_key_wallet_c7": MessageLookupByLibrary.simpleMessage(
      "Agora digite sua frase de recuperação.",
    ),
    "g_key_wallet_c8": MessageLookupByLibrary.simpleMessage("Definir Frase"),
    "g_key_wallet_c9": MessageLookupByLibrary.simpleMessage(
      "Por favor, certifique-se de registrar sua frase de recuperação e armazená-la com segurança. Você precisará dela para importar ou recuperar sua carteira de criptomoedas.",
    ),
    "g_key_wallet_edit": MessageLookupByLibrary.simpleMessage(
      "Editar carteira",
    ),
    "g_key_wallet_k25": MessageLookupByLibrary.simpleMessage("Hora"),
    "g_key_wallet_k33": MessageLookupByLibrary.simpleMessage("Resultado"),
    "g_key_wallet_k37": MessageLookupByLibrary.simpleMessage(
      "Hash da transação",
    ),
    "g_key_wallet_k47": MessageLookupByLibrary.simpleMessage("Adicionar"),
    "g_key_wallet_k53": MessageLookupByLibrary.simpleMessage("Caminho"),
    "g_key_wallet_k54": MessageLookupByLibrary.simpleMessage("Bloco"),
    "g_key_wallet_k55": MessageLookupByLibrary.simpleMessage("Valor"),
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage("Nonce"),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("Acelerar"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("Nota"),
    "g_key_wallet_m1": m51,
    "g_key_wallet_m11": MessageLookupByLibrary.simpleMessage(
      "Tem certeza que deseja cancelar sua conta?",
    ),
    "g_key_wallet_m13": MessageLookupByLibrary.simpleMessage(
      "Confirmar logout",
    ),
    "g_key_wallet_m17": MessageLookupByLibrary.simpleMessage(
      "Por favor, digite o código de verificação do Google.",
    ),
    "g_key_wallet_m19": m52,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "O token atual não foi adicionado.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Digite sua frase de recuperação com palavras separadas por espaços",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage(
      "Importar Carteira",
    ),
    "g_key_wallet_m3": m53,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "O saldo do token atual é insuficiente.",
    ),
    "g_key_wallet_m5": m54,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage(
      "Erro de assinatura",
    ),
    "g_key_wallet_m8": MessageLookupByLibrary.simpleMessage(
      "Cancelamento de conta",
    ),
    "g_key_wallet_m9": MessageLookupByLibrary.simpleMessage(
      "Digite o código de verificação do e-mail.",
    ),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage(
      "Gerenciar Carteira",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("Reservado"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("Reserva Base"),
    "g_key_xml_11": m55,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("Reserva Incremental"),
    "g_key_xml_22": m56,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "Contagem de Objetos Possuídos",
    ),
    "g_key_xml_33": m57,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage(
      "Como calcular o valor total reservado",
    ),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "Reserva Total = Reserva Base + (Contagem de Objetos Possuídos × Reserva Incremental)",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch ID e Face ID"),
    "g_lock_key10": MessageLookupByLibrary.simpleMessage("Senha atual"),
    "g_lock_key11": MessageLookupByLibrary.simpleMessage("Nova senha"),
    "g_lock_key12": MessageLookupByLibrary.simpleMessage(
      "Confirmar nova senha",
    ),
    "g_lock_key13": MessageLookupByLibrary.simpleMessage("Número de 6 dígitos"),
    "g_lock_key15": MessageLookupByLibrary.simpleMessage("Senhas e biometria"),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("Senha de padrão"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage(
      "Definir código de padrão",
    ),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "Para a segurança da sua conta, por favor defina uma senha de grupo",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage(
      "Desenhar padrão de senha secundário",
    ),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage(
      "Desenhar senha de padrão",
    ),
    "g_lock_key21": m58,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Redefinir a senha de padrão",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Muitas tentativas incorretas, por favor redefina a senha",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "Adicionar Senha da Carteira?",
    ),
    "g_lock_key25": m59,
    "g_lock_key3": MessageLookupByLibrary.simpleMessage(
      "Página de bloqueio de tela",
    ),
    "g_lock_key4": MessageLookupByLibrary.simpleMessage("Bloqueio automático"),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("Sucesso"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("Falhou"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage(
      "Reconhecimento biométrico não está ativado",
    ),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage(
      "Adicionar verificação biométrica?",
    ),
    "g_lock_key9": MessageLookupByLibrary.simpleMessage("Redefinir senha"),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("Desbloquear N?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage(
      "Atividade de Verificação na Nuvem",
    ),
    "g_mining_key46": MessageLookupByLibrary.simpleMessage(
      "A configuração requer uma pequena quantidade para gás.",
    ),
    "g_mining_key60": MessageLookupByLibrary.simpleMessage(
      "Você ingressou com sucesso em um Nó de Grupo na N42Wallet. Compartilhe o link para convidar amigos, ativar o Nó e começar a verificação!",
    ),
    "g_mining_key61": MessageLookupByLibrary.simpleMessage(
      "Compartilhar com amigos",
    ),
    "g_mining_key62": MessageLookupByLibrary.simpleMessage("Continuar"),
    "g_mining_key63": m60,
    "g_mining_key73": m61,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "Acabei de configurar um nó na @N42Wallet e comecei a verificação em dispositivos móveis! Venha se juntar a mim. O futuro descentralizado é móvel!",
    ),
    "g_mining_key76": m62,
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "Resgate disponível após 768s.",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "Solicitações antes disso não serão processadas.",
    ),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage(
      "Recompensa de hoje",
    ),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "Por favor, trate os dados abaixo como uma chave importante. Recomendamos copiar e fazer backup em um local confiável imediatamente.",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage("Copiar Dados"),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("Inativo"),
    "g_mining_key_103": MessageLookupByLibrary.simpleMessage(
      "Lista de Validadores",
    ),
    "g_mining_key_104": MessageLookupByLibrary.simpleMessage(
      "Importação bem-sucedida",
    ),
    "g_mining_key_105": MessageLookupByLibrary.simpleMessage(
      "Dados criptografados não podem estar vazios!",
    ),
    "g_mining_key_106": MessageLookupByLibrary.simpleMessage(
      "A senha não pode estar vazia!",
    ),
    "g_mining_key_107": MessageLookupByLibrary.simpleMessage(
      "Falha na descriptografia. Por favor, verifique se a senha está correta!",
    ),
    "g_mining_key_108": MessageLookupByLibrary.simpleMessage(
      "Formato de dados criptografados não suportado!",
    ),
    "g_mining_key_109": m63,
    "g_mining_key_11": MessageLookupByLibrary.simpleMessage(
      "Recompensas de Ontem",
    ),
    "g_mining_key_110": MessageLookupByLibrary.simpleMessage(
      "Dados criptografados",
    ),
    "g_mining_key_111": MessageLookupByLibrary.simpleMessage(
      "Importar arquivos",
    ),
    "g_mining_key_112": MessageLookupByLibrary.simpleMessage(
      "Por favor, digite os dados criptografados.",
    ),
    "g_mining_key_113": MessageLookupByLibrary.simpleMessage("Importando..."),
    "g_mining_key_114": MessageLookupByLibrary.simpleMessage("Confirmação"),
    "g_mining_key_115": MessageLookupByLibrary.simpleMessage(
      "O resgate leva algum tempo, por favor aguarde um momento!",
    ),
    "g_mining_key_116": m64,
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "A recompensa acumula diariamente e só é enviada para sua carteira N quando atinge ~0,5 N.",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage(
      "Total de Recompensas",
    ),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("Valor Minerado"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage(
      "Calculado com base no preço de mercado de N * total de recompensas em N.",
    ),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage("Número de lucros"),
    "g_mining_key_31": MessageLookupByLibrary.simpleMessage(
      "Selecionar Planos",
    ),
    "g_mining_key_32": MessageLookupByLibrary.simpleMessage(
      "Período de Desbloqueio: Desbloqueável a qualquer momento",
    ),
    "g_mining_key_33": MessageLookupByLibrary.simpleMessage(
      "Recompensa Máxima Anual",
    ),
    "g_mining_key_34": MessageLookupByLibrary.simpleMessage(
      "Distribuição de Recompensas",
    ),
    "g_mining_key_35": MessageLookupByLibrary.simpleMessage("Limite Diário"),
    "g_mining_key_36": MessageLookupByLibrary.simpleMessage("Velocidade"),
    "g_mining_key_37": MessageLookupByLibrary.simpleMessage(
      "Planos de Verificação",
    ),
    "g_mining_key_38": MessageLookupByLibrary.simpleMessage(
      "Selecione o método de pagamento",
    ),
    "g_mining_key_39": MessageLookupByLibrary.simpleMessage(
      "Métodos de Pagamento",
    ),
    "g_mining_key_40": MessageLookupByLibrary.simpleMessage("Pagar com N"),
    "g_mining_key_42": MessageLookupByLibrary.simpleMessage(
      "Saldo da Carteira",
    ),
    "g_mining_key_43": MessageLookupByLibrary.simpleMessage(
      "Você não tem N suficiente para esta transação",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Desativado"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("Ver mais"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage(
      "Status da Verificação",
    ),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Bloqueie N para começar a receber recompensas de verificação.",
    ),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Entrada"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("Nó Avançado"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("Nó Inicial"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Nó Pro"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 blocos/dia~70 mins",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage(
      "Selecione um Plano",
    ),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 blocos/dia~15 mins",
    ),
    "g_mining_key_71": m65,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage(
      "128 segundos por verificação",
    ),
    "g_mining_key_73": MessageLookupByLibrary.simpleMessage(
      "Verificação na Nuvem Iniciada",
    ),
    "g_mining_key_74": MessageLookupByLibrary.simpleMessage(
      "A rede de teste está sendo atualizada e os blocos não podem ser verificados temporariamente.",
    ),
    "g_mining_key_75": MessageLookupByLibrary.simpleMessage(
      "Falhar em completar tarefas por quatro dias consecutivos resultará em nenhum ganho e risco de penalidade.",
    ),
    "g_mining_key_76": MessageLookupByLibrary.simpleMessage(
      "Pontuação de Risco",
    ),
    "g_mining_key_77": MessageLookupByLibrary.simpleMessage("Resgatar"),
    "g_mining_key_78": MessageLookupByLibrary.simpleMessage(
      "Por favor, salve primeiro o par de chaves pública e privada do validador.",
    ),
    "g_mining_key_79": MessageLookupByLibrary.simpleMessage("Exportar"),
    "g_mining_key_80": MessageLookupByLibrary.simpleMessage(
      "Saldo insuficiente para transferência.",
    ),
    "g_mining_key_81": MessageLookupByLibrary.simpleMessage(
      "Lista de Validadores",
    ),
    "g_mining_key_82": MessageLookupByLibrary.simpleMessage(
      "Importar validador",
    ),
    "g_mining_key_83": MessageLookupByLibrary.simpleMessage(
      "O validador já existe",
    ),
    "g_mining_key_84": MessageLookupByLibrary.simpleMessage("Risco Baixo"),
    "g_mining_key_85": MessageLookupByLibrary.simpleMessage(
      "Risco Moderadamente",
    ),
    "g_mining_key_86": MessageLookupByLibrary.simpleMessage(
      "Recompensas dos últimos 7 dias",
    ),
    "g_mining_key_87": MessageLookupByLibrary.simpleMessage("Risco Alto"),
    "g_mining_key_88": MessageLookupByLibrary.simpleMessage(
      "O contrato está carregando e não pode ser verificado no momento. Por favor, aguarde um momento!",
    ),
    "g_mining_key_89": MessageLookupByLibrary.simpleMessage(
      "Dicas de Segurança",
    ),
    "g_mining_key_9": MessageLookupByLibrary.simpleMessage(
      "Verificação em Segundo Plano",
    ),
    "g_mining_key_90": MessageLookupByLibrary.simpleMessage(
      "Por favor, mantenha sua chave privada ou frase de recuperação em segurança.",
    ),
    "g_mining_key_91": MessageLookupByLibrary.simpleMessage(
      "Sua chave privada ou frase de recuperação é a única credencial para acessar os ativos da sua carteira.",
    ),
    "g_mining_key_92": MessageLookupByLibrary.simpleMessage(
      "Por favor, guarde-a em um lugar seguro (papel, gerenciador de senhas, etc.).",
    ),
    "g_mining_key_93": MessageLookupByLibrary.simpleMessage(
      "Não tire capturas de tela, não faça upload na internet ou compartilhe com ninguém.",
    ),
    "g_mining_key_94": MessageLookupByLibrary.simpleMessage(
      "Uma vez perdida ou comprometida, os ativos da sua carteira não podem ser recuperados.",
    ),
    "g_mining_key_95": MessageLookupByLibrary.simpleMessage(
      "Confirmar e salvar",
    ),
    "g_mining_key_96": MessageLookupByLibrary.simpleMessage(
      "Definir uma senha e criptografar",
    ),
    "g_mining_key_97": MessageLookupByLibrary.simpleMessage(
      "Por favor, digite a senha de criptografia",
    ),
    "g_mining_key_98": m66,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "Por favor, digite novamente sua senha para confirmar",
    ),
    "g_mining_unlock_period": MessageLookupByLibrary.simpleMessage(
      "Período de Desbloqueio:",
    ),
    "g_mining_unlockable_anytime": MessageLookupByLibrary.simpleMessage(
      "Desbloqueável a qualquer momento",
    ),
    "g_notification_key_1": MessageLookupByLibrary.simpleMessage(
      "Notificações",
    ),
    "g_phishing_go_back": MessageLookupByLibrary.simpleMessage(
      "Voltar (Seguro)",
    ),
    "g_phishing_proceed_anyway": MessageLookupByLibrary.simpleMessage(
      "Continuar mesmo assim",
    ),
    "g_phishing_warning_body": MessageLookupByLibrary.simpleMessage(
      "Este site foi identificado como potencialmente malicioso. Pode estar tentando roubar seus ativos de criptomoeda ou chaves privadas.",
    ),
    "g_phishing_warning_title": MessageLookupByLibrary.simpleMessage(
      "Aviso de Segurança",
    ),
    "g_phishing_warning_url_label": MessageLookupByLibrary.simpleMessage(
      "URL Suspeita:",
    ),
    "g_share_v2_key_5": MessageLookupByLibrary.simpleMessage("Compartilhar"),
    "g_share_v3_key_2": MessageLookupByLibrary.simpleMessage("Indicação"),
    "g_share_v3_key_3": MessageLookupByLibrary.simpleMessage(
      "Indique amigos e ganhe Tokens N!",
    ),
    "g_share_v3_key_4": MessageLookupByLibrary.simpleMessage("Você ganha até "),
    "g_share_v3_key_5": MessageLookupByLibrary.simpleMessage(
      " N quando seu indicado começar a verificação!",
    ),
    "g_share_v3_key_6": MessageLookupByLibrary.simpleMessage("Indicar via"),
    "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("Link"),
    "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("código"),
    "g_swap_key_14": m67,
    "g_swap_key_15": MessageLookupByLibrary.simpleMessage(
      "Erro ao obter preço da moeda.",
    ),
    "g_swap_key_16": MessageLookupByLibrary.simpleMessage(
      "Ao prosseguir, você concorda com os seguintes ",
    ),
    "g_swap_key_17": MessageLookupByLibrary.simpleMessage(
      "Termos e Condições.",
    ),
    "g_swap_key_18": MessageLookupByLibrary.simpleMessage("Concluir"),
    "g_swap_key_19": MessageLookupByLibrary.simpleMessage(
      "Sua troca será distribuída em breve. Por favor, aguarde.",
    ),
    "g_swap_key_20": m68,
    "g_swap_key_21": MessageLookupByLibrary.simpleMessage(
      "Custos para executar um nó: Verificação em Grupo 1-49 N Nó Básico: 50 N Nó Premium: 100 N Nó Pro: 500 N.",
    ),
    "g_swap_key_22": MessageLookupByLibrary.simpleMessage("Expirado"),
    "g_swap_key_23": MessageLookupByLibrary.simpleMessage("Não pago"),
    "g_swap_key_24": MessageLookupByLibrary.simpleMessage(
      "Confirmando pagamento",
    ),
    "g_swap_key_25": MessageLookupByLibrary.simpleMessage("A ser distribuído"),
    "g_swap_key_28": MessageLookupByLibrary.simpleMessage("Resumo da Troca"),
    "g_swap_key_29": MessageLookupByLibrary.simpleMessage("Novo Saldo"),
    "g_swap_key_3": MessageLookupByLibrary.simpleMessage("Você paga"),
    "g_swap_key_30": MessageLookupByLibrary.simpleMessage("Data"),
    "g_swap_key_31": m69,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "Trocas podem ser visualizadas nos exploradores de blockchain relevantes (Etherscan, BscScan, TRONSCAN e o nosso próprio).",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Trocar para N"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("Trocar"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("Você recebe"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("Prévia da Troca"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("Tentar novamente"),
    "g_token_m_key_1": m70,
    "g_token_m_key_10": MessageLookupByLibrary.simpleMessage(
      "Qualquer pessoa pode criar um token, incluindo versões falsas de tokens existentes. Sempre pesquise um token antes de importá-lo.",
    ),
    "g_token_m_key_11": MessageLookupByLibrary.simpleMessage("Tokens"),
    "g_token_m_key_12": MessageLookupByLibrary.simpleMessage("Pesquisar Token"),
    "g_token_m_key_13": MessageLookupByLibrary.simpleMessage("Nome da Rede"),
    "g_token_m_key_14": MessageLookupByLibrary.simpleMessage("Símbolo da rede"),
    "g_token_m_key_15": MessageLookupByLibrary.simpleMessage("ID da Rede"),
    "g_token_m_key_16": MessageLookupByLibrary.simpleMessage("Casas Decimais"),
    "g_token_m_key_17": MessageLookupByLibrary.simpleMessage("RPC"),
    "g_token_m_key_18": MessageLookupByLibrary.simpleMessage("API"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage(
      "Adicionar rede personalizada",
    ),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18 dígitos"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage(
      "Adicionar Tokens",
    ),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage(
      "Erro de Formato!",
    ),
    "g_token_m_key_22": m71,
    "g_token_m_key_23": m72,
    "g_token_m_key_24": m73,
    "g_token_m_key_3": MessageLookupByLibrary.simpleMessage("Importar tokens"),
    "g_token_m_key_4": MessageLookupByLibrary.simpleMessage("Todas as redes"),
    "g_token_m_key_5": MessageLookupByLibrary.simpleMessage(
      "Token Personalizado",
    ),
    "g_token_m_key_6": MessageLookupByLibrary.simpleMessage(
      "Endereço do token",
    ),
    "g_token_m_key_7": MessageLookupByLibrary.simpleMessage("Símbolo do token"),
    "g_token_m_key_8": MessageLookupByLibrary.simpleMessage(
      "Casas decimais do token",
    ),
    "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("Importar"),
    "g_unlock_key10": m74,
    "g_unlock_key2": MessageLookupByLibrary.simpleMessage(
      "Impressão digital ou reconhecimento facial não está ativado?",
    ),
    "g_unlock_key3": MessageLookupByLibrary.simpleMessage(
      "Desenhar senha de padrão",
    ),
    "g_unlock_key4": m75,
    "g_unlock_key5": MessageLookupByLibrary.simpleMessage("Digite a senha"),
    "g_unlock_key6": m76,
    "g_unlock_key7": MessageLookupByLibrary.simpleMessage(
      "Falha na autenticação",
    ),
    "g_unlock_key8": m77,
    "g_unlock_key9": MessageLookupByLibrary.simpleMessage("Você também pode "),
    "google_verification": MessageLookupByLibrary.simpleMessage(
      "Autenticação Google",
    ),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "Vincular",
    ),
    "google_verification_message11": MessageLookupByLibrary.simpleMessage(
      "Baixar Google Authentication",
    ),
    "google_verification_message12": MessageLookupByLibrary.simpleMessage(
      "Instruções",
    ),
    "google_verification_message13": MessageLookupByLibrary.simpleMessage(
      "Abra o Google Authenticator.",
    ),
    "google_verification_message14": MessageLookupByLibrary.simpleMessage(
      "Você verá um código de verificação de 6 dígitos na tela.",
    ),
    "google_verification_message15": MessageLookupByLibrary.simpleMessage(
      "Copie o código de 6 dígitos e cole-o na N42Wallet.",
    ),
    "google_verification_message16": MessageLookupByLibrary.simpleMessage(
      "Em seguida, seu Authenticator será vinculado com sucesso.",
    ),
    "google_verification_message17": MessageLookupByLibrary.simpleMessage(
      "Chave de Backup",
    ),
    "google_verification_message18": MessageLookupByLibrary.simpleMessage(
      "Copie a chave para o Google Authentication",
    ),
    "google_verification_message19": MessageLookupByLibrary.simpleMessage(
      "Digite o código de verificação do Google",
    ),
    "google_verification_message20": MessageLookupByLibrary.simpleMessage(
      "Digite o código de verificação de e-mail",
    ),
    "google_verification_message21": m78,
    "google_verification_message3": MessageLookupByLibrary.simpleMessage(
      "Falha ao obter chave do Google",
    ),
    "google_verification_message5": MessageLookupByLibrary.simpleMessage(
      "Autenticação de Dois Fatores (2FA)",
    ),
    "google_verification_message6": MessageLookupByLibrary.simpleMessage(
      "Para proteger sua conta, é recomendado ativar pelo menos uma 2FA.",
    ),
    "google_verification_message7": MessageLookupByLibrary.simpleMessage(
      "O aplicativo Google Authenticator protege seus saques e conta N42Wallet.",
    ),
    "google_verification_message8": MessageLookupByLibrary.simpleMessage(
      "Baixar e Instalar",
    ),
    "google_verification_message9": MessageLookupByLibrary.simpleMessage(
      "Por favor, baixe e instale o Google Authenticator. Em seguida, pressione \'Vincular\' para vincular sua conta N42Wallet.",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage("Aviso Importante"),
    "login_button_text": MessageLookupByLibrary.simpleMessage("Entrar"),
    "login_email": MessageLookupByLibrary.simpleMessage("E-mail"),
    "login_forgot_password": MessageLookupByLibrary.simpleMessage(
      "Esqueceu a senha?",
    ),
    "login_invite_code": MessageLookupByLibrary.simpleMessage(
      "Código de indicação",
    ),
    "login_invite_code_title": MessageLookupByLibrary.simpleMessage(
      "Código de indicação",
    ),
    "login_message_1": MessageLookupByLibrary.simpleMessage(
      "Não tem uma conta? ",
    ),
    "login_message_10": MessageLookupByLibrary.simpleMessage(
      "Criado com sucesso",
    ),
    "login_message_11": MessageLookupByLibrary.simpleMessage(
      "Redefinido com sucesso",
    ),
    "login_message_2": MessageLookupByLibrary.simpleMessage(
      "Já tem uma conta? ",
    ),
    "login_message_6": MessageLookupByLibrary.simpleMessage(
      "Reenviar código em ",
    ),
    "login_message_7": MessageLookupByLibrary.simpleMessage(
      "Código enviado com sucesso",
    ),
    "login_message_8": MessageLookupByLibrary.simpleMessage(
      "E-mail não cadastrado",
    ),
    "login_message_9": MessageLookupByLibrary.simpleMessage(
      "Falha ao enviar código",
    ),
    "login_need_login": MessageLookupByLibrary.simpleMessage(
      "por favor, faça login primeiro",
    ),
    "login_password": MessageLookupByLibrary.simpleMessage("Senha"),
    "next": MessageLookupByLibrary.simpleMessage("Próximo"),
    "nicknameMessage": m79,
    "password_diff": MessageLookupByLibrary.simpleMessage(
      "As senhas não coincidem",
    ),
    "personalInformation": MessageLookupByLibrary.simpleMessage(
      "Editar Perfil",
    ),
    "photograph": MessageLookupByLibrary.simpleMessage("Fotografia"),
    "please_enter_code": MessageLookupByLibrary.simpleMessage(
      "Digite o código de verificação",
    ),
    "please_enter_email": MessageLookupByLibrary.simpleMessage(
      "Por favor, digite o e-mail",
    ),
    "please_enter_password": MessageLookupByLibrary.simpleMessage(
      "Por favor, digite a senha",
    ),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "Por favor, digite o endereço",
    ),
    "repeatPassword": MessageLookupByLibrary.simpleMessage(
      "Digite a Senha Novamente",
    ),
    "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
      "Escolha uma senha (8~18 caracteres)",
    ),
    "rest_Confirm_password": MessageLookupByLibrary.simpleMessage(
      "Confirmar Senha",
    ),
    "rest_Enter_the_password_again": MessageLookupByLibrary.simpleMessage(
      "Digite a senha novamente",
    ),
    "rest_Please_enter": MessageLookupByLibrary.simpleMessage(
      "Digite o código",
    ),
    "rest_Verification_code": MessageLookupByLibrary.simpleMessage(
      "Código OTP",
    ),
    "rest_your_password": MessageLookupByLibrary.simpleMessage(
      "Redefina sua senha",
    ),
    "s_key_1": MessageLookupByLibrary.simpleMessage("Gerenciar Carteira"),
    "s_key_10": MessageLookupByLibrary.simpleMessage("Sobre o App"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("Segurança"),
    "s_key_12": MessageLookupByLibrary.simpleMessage("Usar novo Chat"),
    "s_key_13": MessageLookupByLibrary.simpleMessage(
      "Ativar experiência de Chat aprimorada",
    ),
    "s_key_2": MessageLookupByLibrary.simpleMessage("Endereços da Carteira"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("Transação"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("Idioma"),
    "s_key_5": MessageLookupByLibrary.simpleMessage("Tema"),
    "search": MessageLookupByLibrary.simpleMessage("Pesquisar"),
    "selected_user_protocol": MessageLookupByLibrary.simpleMessage(
      "Por favor, leia o acordo e confirme",
    ),
    "verification": MessageLookupByLibrary.simpleMessage("verificação"),
    "w_item_1": MessageLookupByLibrary.simpleMessage(
      "Se eu perder minha frase secreta, meus fundos serão perdidos para sempre.",
    ),
    "w_item_2": MessageLookupByLibrary.simpleMessage(
      "Se eu revelar ou compartilhar minha frase de recuperação com alguém, meus fundos podem ser roubados.",
    ),
    "w_item_3": MessageLookupByLibrary.simpleMessage(
      "É minha responsabilidade manter minha frase de recuperação segura.",
    ),
    "w_key_12": MessageLookupByLibrary.simpleMessage(
      "Frase de recuperação incorreta.",
    ),
    "w_key_8": MessageLookupByLibrary.simpleMessage(
      "Digite a frase de recuperação da carteira que você deseja importar.",
    ),
  };
}

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

  static String m1(price) => "Preço atual: \$${price}";

  static String m2(symbol) => "Alerta de preço · ${symbol}";

  static String m3(value) => "Eu sou ${value}";

  static String m4(value) => "Membro do chat (${value})";

  static String m5(value) =>
      "Tem certeza que deseja adicionar ${value} como amigo";

  static String m6(email) => "Código de verificação enviado para ${email}";

  static String m7(s) => "Reenviar em ${s}s";

  static String m8(value) =>
      "Você já está vinculado e não pode ser revinculado no momento. Endereço vinculado: ${value}.";

  static String m9(value) =>
      "Vinculação bem-sucedida. Endereço vinculado: ${value}";

  static String m10(value) => "Não há N42chain na carteira ${value}!";

  static String m11(value) =>
      "Correspondência bem-sucedida. Endereço:${value}.";

  static String m12(message) => "Falha na compra: ${message}";

  static String m13(productId) => "Compra bem-sucedida: ${productId}";

  static String m14(productId) => "Restaurado: ${productId}";

  static String m15(value) => "Valor maior que ${value}.";

  static String m16(value) =>
      "A carteira já existe, o nome da carteira é \"${value}\"";

  static String m17(value) => "Digite um valor maior que ${value}.";

  static String m18(gas) =>
      "O gas de execução (${gas}) está alto. O contrato chamado pode consumir mais gas do que o esperado.";

  static String m19(gas) =>
      "A primeira transação inclui a implantação da conta (~${gas} gas). As transações subsequentes serão mais baratas.";

  static String m20(gas) =>
      "O overhead de gas do paymaster (${gas}) está alto. Transações sem gas podem custar mais.";

  static String m21(gas) =>
      "O gas total estimado (${gas}) está incomumente alto. Verifique sua transação por erros.";

  static String m22(gas) =>
      "O gas de verificação (${gas}) pode estar muito alto. Isso pode ocorrer com lógica de conta complexa.";

  static String m23(value) => "${value} dias restantes";

  static String m24(value) => "Endereço duplicado na linha ${value}";

  static String m25(value) =>
      "Saldo insuficiente: o valor total excederia o disponível ${value}";

  static String m26(value) => "Endereço inválido na linha ${value}";

  static String m27(value) => "Valor inválido na linha ${value}";

  static String m28(value) => "Máximo ${value} destinatários";

  static String m29(token) => "Aprove ${token} para continuar";

  static String m30(impact) =>
      "Impacto de alto preço (${impact})! Proceda com cautela.";

  static String m31(secs) => "A cotação expira em ${secs}s";

  static String m32(value) => "+${value} pontos/dia";

  static String m33(value) => "Ganhe até ${value}% APY";

  static String m34(value) => "Parabéns! Agora você possui ${value}";

  static String m35(value) => "Aguarde ${value} segundos";

  static String m36(value) => "Atualização automática a cada ${value} segundos";

  static String m37(address) => "Conta ${address} adicionada";

  static String m38(address, network) =>
      "Deseja rastrear esta conta de hardware wallet?\n\nEndereço: ${address}\nRede: ${network}";

  static String m39(app) => "Aplicativo atual: ${app}";

  static String m40(days) => "${days} dias atrás";

  static String m41(value) => "Falha ao importar conta: ${value}";

  static String m42(date) => "Última conexão: ${date}";

  static String m43(value) =>
      "Por favor abra o app ${value} no seu dispositivo";

  static String m44(app) =>
      "Certifique-se de que o aplicativo ${app} está aberto no seu Ledger";

  static String m45(name) =>
      "Tem certeza de que deseja remover \"${name}\" dos dispositivos salvos?";

  static String m46(value) => "Ganhe pontos ${value}";

  static String m47(value) =>
      "Ganhe pontos ${value} para cada amigo que aderir!";

  static String m48(value) => "${value} pontos para o próximo nível";

  static String m49(amount, token) => "≈ ${amount}${token}";

  static String m50(amount) => "≈ ${amount} USDT";

  static String m51(value) => "Est. gás: ~${value} unidades";

  static String m52(reason) => "Motivo: ${reason}";

  static String m53(value) =>
      "Tem certeza que deseja excluir o contato ${value}?";

  static String m54(value) => "${value}d desvinculado";

  static String m55(value) => "${value} dias restantes";

  static String m56(value) => "${value} dias restantes";

  static String m57(value) =>
      "O desempate leva ${value} dias. Seus tokens serão bloqueados durante este período.";

  static String m58(value) => "Você não tem \"${value}\" suficiente";

  static String m59(value) => "Falha ao obter conta \"${value}\"";

  static String m60(value) =>
      "Mínimo de ${value} XRP para primeira transferência";

  static String m61(value) => "${value}d atrás";

  static String m62(value) => "${value}h atrás";

  static String m63(value) => "${value}m atrás";

  static String m64(count) => "Adicionar (${count})";

  static String m65(count) =>
      "${Intl.plural(count, one: '1 novo token detectado', other: 'Novos tokens ${count} detectados')} — toque para revisar";

  static String m66(value) => "Código de verificação enviado para ${value}";

  static String m67(value) => "Nenhuma rede ${value} adicionada.";

  static String m68(value) =>
      "${value} tem transações não finalizadas, por favor tente novamente mais tarde.";

  static String m69(value) => "Nenhum endereço encontrado para ${value}.";

  static String m70(value) => "Saldo insuficiente de ${value}.";

  static String m71(value, value1) =>
      "Cada conta XRP deve reservar ${value} XRP (${value1} drops) como base, que não pode ser gasto.";

  static String m72(value, value1) =>
      "Para cada objeto que a conta possui, ${value} XRP (${value1} drops) é adicionado à reserva.";

  static String m73(value, value1) =>
      "Esta conta possui ${value} objetos, o que significa que ${value1} XRP adicional é reservado.";

  static String m74(value) =>
      "Erro na senha de padrão, você tem ${value} tentativas";

  static String m75(value) =>
      "Erro na senha de padrão, você tem ${value} tentativa";

  static String m76(value) =>
      "Você configurou com sucesso um ${value} e começará a verificação com a N42Wallet!";

  static String m77(value) =>
      "Junte-se ao meu grupo ${value} na @N42Wallet para ser um minerador inicial de uma blockchain Layer 1 e ganhe criptomoedas no seu celular!";

  static String m78(value, value1) =>
      "Tem certeza de que deseja bloquear ${value} N até ${value1} para executar um nó?";

  static String m79(value) => "Falha na importação:${value}";

  static String m80(value) =>
      "É necessário um saldo de staking de pelo menos ${value} para receber recompensas.";

  static String m81(value, value1) =>
      "${value} N a cada ${value1} blocos minerados";

  static String m82(value) => "Deve ter ${value} caracteres";

  static String m83(value) => "Saldo insuficiente de ${value}.";

  static String m84(value) => "${value} a caminho...";

  static String m85(value) =>
      "${value} trocados no app serão distribuídos em breve para sua carteira e não podem ser vendidos por este processo. Pode ser usado para executar um nó.";

  static String m86(value) => "Máximo de ${value} caracteres";

  static String m87(value) => "A rede ${value} já é suportada pelo APP!";

  static String m88(value) =>
      "A rede ${value} já é suportada pelo APP, deseja adicioná-la?";

  static String m89(value) =>
      "Falha no teste de conexão do endereço da rede ${value}!";

  static String m90(value) =>
      "O aplicativo será desbloqueado em ${value} segundos.";

  static String m91(value) =>
      "Erro na senha de padrão, você tem ${value} tentativas";

  static String m92(value) => "Erro na senha, você tem ${value} tentativas";

  static String m93(value) => "Erro na senha, você tem ${value} tentativa";

  static String m94(value) => "Digite a senha ${value}";

  static String m95(value) => "0~${value} caracteres";

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
    "g_alert_above": MessageLookupByLibrary.simpleMessage("Vai acima ↑"),
    "g_alert_below": MessageLookupByLibrary.simpleMessage("Cai abaixo ↓"),
    "g_alert_current_price": m1,
    "g_alert_direction": MessageLookupByLibrary.simpleMessage(
      "Avise-me quando o preço",
    ),
    "g_alert_enable": MessageLookupByLibrary.simpleMessage(
      "Habilite este alerta",
    ),
    "g_alert_invalid_price": MessageLookupByLibrary.simpleMessage(
      "Insira um preço válido maior que 0",
    ),
    "g_alert_remove": MessageLookupByLibrary.simpleMessage("Remover"),
    "g_alert_set": MessageLookupByLibrary.simpleMessage("Definir alerta"),
    "g_alert_target_price": MessageLookupByLibrary.simpleMessage(
      "Preço alvo (USD)",
    ),
    "g_alert_title": m2,
    "g_alert_update": MessageLookupByLibrary.simpleMessage(
      "Alerta de atualização",
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
    "g_browser_key18": MessageLookupByLibrary.simpleMessage("Histórico"),
    "g_browser_key19": MessageLookupByLibrary.simpleMessage(
      "Limpar todo o histórico",
    ),
    "g_browser_key20": MessageLookupByLibrary.simpleMessage(
      "Limpar todo o histórico de navegação?",
    ),
    "g_browser_key21": MessageLookupByLibrary.simpleMessage("Histórico limpo"),
    "g_browser_key22": MessageLookupByLibrary.simpleMessage("Hoje"),
    "g_browser_key23": MessageLookupByLibrary.simpleMessage("Ontem"),
    "g_browser_key24": MessageLookupByLibrary.simpleMessage("Descobrir DApps"),
    "g_browser_key25": MessageLookupByLibrary.simpleMessage("Populares"),
    "g_browser_key26": MessageLookupByLibrary.simpleMessage("DES"),
    "g_browser_key27": MessageLookupByLibrary.simpleMessage("DeFi"),
    "g_browser_key28": MessageLookupByLibrary.simpleMessage("NFT"),
    "g_browser_key29": MessageLookupByLibrary.simpleMessage("Ponte"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("Favoritos"),
    "g_browser_key30": MessageLookupByLibrary.simpleMessage("Ferramentas"),
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
    "g_chat_key_10": m3,
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
    "g_chat_key_32": m4,
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
    "g_chat_key_6": m5,
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
    "g_dapp_security_blocked": MessageLookupByLibrary.simpleMessage(
      "Bloqueado",
    ),
    "g_dapp_security_caution": MessageLookupByLibrary.simpleMessage("Cuidado"),
    "g_dapp_security_safe": MessageLookupByLibrary.simpleMessage("Seguro"),
    "g_dapp_security_title": MessageLookupByLibrary.simpleMessage(
      "Segurança de DApps",
    ),
    "g_dapp_security_verified": MessageLookupByLibrary.simpleMessage(
      "Verificado",
    ),
    "g_email_also_sync": MessageLookupByLibrary.simpleMessage(
      "Sincronize também o e-mail da conta do Chat",
    ),
    "g_email_back_to_email": MessageLookupByLibrary.simpleMessage(
      "← Alterar endereço de e-mail",
    ),
    "g_email_both_success": MessageLookupByLibrary.simpleMessage(
      "Ambas as contas foram atualizadas com sucesso!",
    ),
    "g_email_change_title": MessageLookupByLibrary.simpleMessage(
      "Alterar e-mail",
    ),
    "g_email_chat_code_hint": MessageLookupByLibrary.simpleMessage(
      "Insira o código de bate-papo de 6 dígitos",
    ),
    "g_email_chat_code_sent_to": MessageLookupByLibrary.simpleMessage(
      "Código de bate-papo enviado para",
    ),
    "g_email_chat_confirm": MessageLookupByLibrary.simpleMessage(
      "Confirmar sincronização de bate-papo",
    ),
    "g_email_chat_send_fail": MessageLookupByLibrary.simpleMessage(
      "Falha ao enviar o código do chat",
    ),
    "g_email_chat_sending": MessageLookupByLibrary.simpleMessage(
      "Enviando código de verificação do Chat...",
    ),
    "g_email_chat_sync_title": MessageLookupByLibrary.simpleMessage(
      "Sincronizar e-mail da conta de bate-papo",
    ),
    "g_email_code_invalid": MessageLookupByLibrary.simpleMessage(
      "Por favor insira o código de 6 dígitos",
    ),
    "g_email_code_resent": MessageLookupByLibrary.simpleMessage(
      "Código reenviado",
    ),
    "g_email_code_sent_to": m6,
    "g_email_code_wrong": MessageLookupByLibrary.simpleMessage(
      "Código incorreto, tente novamente",
    ),
    "g_email_confirm_change": MessageLookupByLibrary.simpleMessage(
      "Confirmar alteração",
    ),
    "g_email_confirm_continue": MessageLookupByLibrary.simpleMessage(
      "Confirme e continue para sincronização de bate-papo",
    ),
    "g_email_current_label": MessageLookupByLibrary.simpleMessage(
      "E-mail atual",
    ),
    "g_email_enter_code": MessageLookupByLibrary.simpleMessage(
      "Digite o código de 6 dígitos",
    ),
    "g_email_error_empty": MessageLookupByLibrary.simpleMessage(
      "Por favor insira um novo endereço de e-mail",
    ),
    "g_email_error_invalid": MessageLookupByLibrary.simpleMessage(
      "Endereço de e-mail inválido",
    ),
    "g_email_error_same": MessageLookupByLibrary.simpleMessage(
      "O novo e-mail deve ser diferente do e-mail atual",
    ),
    "g_email_n42_only": MessageLookupByLibrary.simpleMessage(
      "E-mail N42 atualizado. O e-mail do bate-papo pode ser atualizado em Bate-papo > Configurações.",
    ),
    "g_email_n42_updated": MessageLookupByLibrary.simpleMessage(
      "E-mail da conta N42 atualizado",
    ),
    "g_email_new_hint": MessageLookupByLibrary.simpleMessage(
      "Insira o novo endereço de e-mail",
    ),
    "g_email_new_label": MessageLookupByLibrary.simpleMessage(
      "Novo endereço de e-mail",
    ),
    "g_email_pwd_hint": MessageLookupByLibrary.simpleMessage("Digite a senha"),
    "g_email_pwd_label": MessageLookupByLibrary.simpleMessage(
      "Senha atual (para bate-papo)",
    ),
    "g_email_pwd_required": MessageLookupByLibrary.simpleMessage(
      "Senha necessária para sincronização do Chat",
    ),
    "g_email_resend": MessageLookupByLibrary.simpleMessage("Reenviar código"),
    "g_email_resend_countdown": m7,
    "g_email_send_code": MessageLookupByLibrary.simpleMessage(
      "Enviar código de verificação",
    ),
    "g_email_skip": MessageLookupByLibrary.simpleMessage("Pular"),
    "g_email_skip_full": MessageLookupByLibrary.simpleMessage(
      "Pular – o e-mail N42 já está atualizado",
    ),
    "g_email_success": MessageLookupByLibrary.simpleMessage(
      "E-mail atualizado com sucesso",
    ),
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
    "g_face_match_key10": m8,
    "g_face_match_key11": m9,
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
    "g_face_match_key32": m10,
    "g_face_match_key33": MessageLookupByLibrary.simpleMessage("Desvinculando"),
    "g_face_match_key34": MessageLookupByLibrary.simpleMessage(
      "Falha na verificação de dados faciais!",
    ),
    "g_face_match_key35": MessageLookupByLibrary.simpleMessage(
      "Falha na desvinculação de dados faciais!",
    ),
    "g_face_match_key4": m11,
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
    "g_iap_cancelled": MessageLookupByLibrary.simpleMessage("Cancelado"),
    "g_iap_check_network": MessageLookupByLibrary.simpleMessage(
      "Verifique a sua ligação de rede e tente novamente",
    ),
    "g_iap_failed": m12,
    "g_iap_no_products": MessageLookupByLibrary.simpleMessage(
      "Sem produtos disponíveis",
    ),
    "g_iap_purchased": m13,
    "g_iap_restore": MessageLookupByLibrary.simpleMessage("Restaurar compras"),
    "g_iap_restored": m14,
    "g_iap_restoring": MessageLookupByLibrary.simpleMessage(
      "A restaurar compras…",
    ),
    "g_iap_retry": MessageLookupByLibrary.simpleMessage("Tentar novamente"),
    "g_iap_store_unavailable": MessageLookupByLibrary.simpleMessage(
      "Loja indisponível",
    ),
    "g_iap_title": MessageLookupByLibrary.simpleMessage("Comprar"),
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
    "g_key_135": m15,
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
    "g_key_214": m16,
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
    "g_key_46": m17,
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
      "Conta criada com sucesso",
    ),
    "g_key_aa_account_details": MessageLookupByLibrary.simpleMessage(
      "Detalhes da conta",
    ),
    "g_key_aa_account_name": MessageLookupByLibrary.simpleMessage(
      "Nome da conta",
    ),
    "g_key_aa_account_name_hint": MessageLookupByLibrary.simpleMessage(
      "Insira o nome da conta",
    ),
    "g_key_aa_account_type": MessageLookupByLibrary.simpleMessage(
      "Tipo de conta",
    ),
    "g_key_aa_active": MessageLookupByLibrary.simpleMessage("Ativo"),
    "g_key_aa_add_first_operation": MessageLookupByLibrary.simpleMessage(
      "Adicione sua primeira operação",
    ),
    "g_key_aa_add_operation": MessageLookupByLibrary.simpleMessage(
      "Adicionar operação",
    ),
    "g_key_aa_address_calculating": MessageLookupByLibrary.simpleMessage(
      "Calculando endereço...",
    ),
    "g_key_aa_address_error": MessageLookupByLibrary.simpleMessage(
      "Falha ao calcular endereço. Por favor, tente novamente.",
    ),
    "g_key_aa_address_preview": MessageLookupByLibrary.simpleMessage(
      "Este endereço é pré-calculado e será implantado quando você fizer sua primeira transação.",
    ),
    "g_key_aa_approve": MessageLookupByLibrary.simpleMessage("Aprovar"),
    "g_key_aa_batch": MessageLookupByLibrary.simpleMessage("Lote"),
    "g_key_aa_batch_atomic": MessageLookupByLibrary.simpleMessage(
      "Execução Atômica",
    ),
    "g_key_aa_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Execute várias operações ao mesmo tempo",
    ),
    "g_key_aa_batch_description": MessageLookupByLibrary.simpleMessage(
      "Envie múltiplas transações em uma única operação",
    ),
    "g_key_aa_batch_failed": MessageLookupByLibrary.simpleMessage(
      "Falha na execução em lote",
    ),
    "g_key_aa_batch_no_templates": MessageLookupByLibrary.simpleMessage(
      "Nenhum modelo salvo",
    ),
    "g_key_aa_batch_operations": MessageLookupByLibrary.simpleMessage(
      "Operações em lote",
    ),
    "g_key_aa_batch_save_gas": MessageLookupByLibrary.simpleMessage(
      "Economize gás",
    ),
    "g_key_aa_batch_save_template": MessageLookupByLibrary.simpleMessage(
      "Salvar como modelo",
    ),
    "g_key_aa_batch_submitting": MessageLookupByLibrary.simpleMessage(
      "Enviando...",
    ),
    "g_key_aa_batch_success": MessageLookupByLibrary.simpleMessage(
      "Lote enviado com sucesso",
    ),
    "g_key_aa_batch_template_load": MessageLookupByLibrary.simpleMessage(
      "Carregar modelo",
    ),
    "g_key_aa_batch_template_name": MessageLookupByLibrary.simpleMessage(
      "Nome do modelo",
    ),
    "g_key_aa_batch_template_name_hint": MessageLookupByLibrary.simpleMessage(
      "Insira o nome do modelo",
    ),
    "g_key_aa_batch_template_saved": MessageLookupByLibrary.simpleMessage(
      "Modelo salvo",
    ),
    "g_key_aa_batch_templates": MessageLookupByLibrary.simpleMessage("Modelos"),
    "g_key_aa_batch_title": MessageLookupByLibrary.simpleMessage(
      "Transferência em lote",
    ),
    "g_key_aa_batch_transaction": MessageLookupByLibrary.simpleMessage(
      "Transação em lote",
    ),
    "g_key_aa_benefit_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Aprove e troque em uma transação — chega de confirmações em duas etapas",
    ),
    "g_key_aa_benefit_batch_title": MessageLookupByLibrary.simpleMessage(
      "Ações em lote com um clique",
    ),
    "g_key_aa_benefit_gas_desc": MessageLookupByLibrary.simpleMessage(
      "Patrocine transações ou pague taxas com tokens ERC-20 em vez de ETH",
    ),
    "g_key_aa_benefit_gas_title": MessageLookupByLibrary.simpleMessage(
      "Pague gasolina com qualquer token",
    ),
    "g_key_aa_benefit_recovery_desc": MessageLookupByLibrary.simpleMessage(
      "Recupere o acesso através de contatos confiáveis se você perder sua chave privada",
    ),
    "g_key_aa_benefit_recovery_title": MessageLookupByLibrary.simpleMessage(
      "Recuperação Social",
    ),
    "g_key_aa_biconomy_account": MessageLookupByLibrary.simpleMessage(
      "Conta Biconomy",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "Conta inteligente ERC-7579 modular com suporte a transações sem gas",
    ),
    "g_key_aa_by": MessageLookupByLibrary.simpleMessage("por"),
    "g_key_aa_chain": MessageLookupByLibrary.simpleMessage("Corrente"),
    "g_key_aa_chain_id": MessageLookupByLibrary.simpleMessage("ID da cadeia"),
    "g_key_aa_change": MessageLookupByLibrary.simpleMessage("Mudança"),
    "g_key_aa_check_status": MessageLookupByLibrary.simpleMessage(
      "Verifique o status",
    ),
    "g_key_aa_clear_all": MessageLookupByLibrary.simpleMessage("Limpar tudo"),
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage("Em breve"),
    "g_key_aa_continue": MessageLookupByLibrary.simpleMessage("Continuar"),
    "g_key_aa_contract": MessageLookupByLibrary.simpleMessage("Contrato"),
    "g_key_aa_counterfactual_address": MessageLookupByLibrary.simpleMessage(
      "Endereço Contrafactual",
    ),
    "g_key_aa_counterfactual_note": MessageLookupByLibrary.simpleMessage(
      "Este é um endereço contrafactual. Ele será implantado em sua primeira transação.",
    ),
    "g_key_aa_create_account": MessageLookupByLibrary.simpleMessage(
      "Criar conta inteligente",
    ),
    "g_key_aa_create_first": MessageLookupByLibrary.simpleMessage(
      "Crie sua primeira conta inteligente",
    ),
    "g_key_aa_create_first_account": MessageLookupByLibrary.simpleMessage(
      "Crie uma conta inteligente para começar",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage(
      "Criar chave de sessão",
    ),
    "g_key_aa_create_session_desc": MessageLookupByLibrary.simpleMessage(
      "As chaves de sessão permitem que DApps executem transações em seu nome com permissões limitadas e restrições de tempo.",
    ),
    "g_key_aa_create_smart_account": MessageLookupByLibrary.simpleMessage(
      "Criar conta inteligente",
    ),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("Criado"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage("Personalizado"),
    "g_key_aa_deploy": MessageLookupByLibrary.simpleMessage("Implantar"),
    "g_key_aa_deploy_auto_note": MessageLookupByLibrary.simpleMessage(
      "A conta será implantada automaticamente na sua primeira transação",
    ),
    "g_key_aa_deploy_failed": MessageLookupByLibrary.simpleMessage(
      "Falha na implantação",
    ),
    "g_key_aa_deploy_failed_desc": MessageLookupByLibrary.simpleMessage(
      "A implantação falhou. Por favor, tente novamente.",
    ),
    "g_key_aa_deploy_started": MessageLookupByLibrary.simpleMessage(
      "Implantação iniciada",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("Implantado"),
    "g_key_aa_deployed_desc": MessageLookupByLibrary.simpleMessage(
      "A conta está pronta para uso",
    ),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage(
      "Implantando...",
    ),
    "g_key_aa_deploying_desc": MessageLookupByLibrary.simpleMessage(
      "A transação de implantação está sendo processada",
    ),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "A implantação ocorrerá automaticamente com sua primeira transação.",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "Experimente a próxima geração de contas Ethereum com recursos aprimorados",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("Detalhes"),
    "g_key_aa_eip7702_account": MessageLookupByLibrary.simpleMessage(
      "Conta EIP-7702",
    ),
    "g_key_aa_eip7702_badge": MessageLookupByLibrary.simpleMessage("EIP-7702"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "Conta híbrida EOA/Smart - Não é necessária implantação",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("Erro"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage(
      "Gás estimado",
    ),
    "g_key_aa_estimating": MessageLookupByLibrary.simpleMessage("Estimando..."),
    "g_key_aa_execute_batch": MessageLookupByLibrary.simpleMessage(
      "Executar lote",
    ),
    "g_key_aa_expired": MessageLookupByLibrary.simpleMessage("Expirado"),
    "g_key_aa_expires": MessageLookupByLibrary.simpleMessage("Expira"),
    "g_key_aa_factory": MessageLookupByLibrary.simpleMessage("Fábrica"),
    "g_key_aa_feature_batch": MessageLookupByLibrary.simpleMessage(
      "Transações múltiplas em lote",
    ),
    "g_key_aa_feature_gas": MessageLookupByLibrary.simpleMessage(
      "Pague gasolina com qualquer token",
    ),
    "g_key_aa_feature_security": MessageLookupByLibrary.simpleMessage(
      "Segurança aprimorada",
    ),
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("GRÁTIS"),
    "g_key_aa_full_access": MessageLookupByLibrary.simpleMessage(
      "Acesso total",
    ),
    "g_key_aa_gas_estimate": MessageLookupByLibrary.simpleMessage(
      "Estimativa de Gás",
    ),
    "g_key_aa_gas_estimate_failed": MessageLookupByLibrary.simpleMessage(
      "Falha na estimativa de gás, usando padrão",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage(
      "Pagamento de gás",
    ),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "Opções de pagamento de gás",
    ),
    "g_key_aa_gas_savings": MessageLookupByLibrary.simpleMessage(
      "Economia de gás",
    ),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage(
      "Gás patrocinado",
    ),
    "g_key_aa_gas_warn_call_high": MessageLookupByLibrary.simpleMessage(
      "Gas de Execução Alto",
    ),
    "g_key_aa_gas_warn_call_high_desc": m18,
    "g_key_aa_gas_warn_deploy": MessageLookupByLibrary.simpleMessage(
      "Overhead de Gas de Implantação",
    ),
    "g_key_aa_gas_warn_deploy_desc": m19,
    "g_key_aa_gas_warn_paymaster": MessageLookupByLibrary.simpleMessage(
      "Overhead do Paymaster Alto",
    ),
    "g_key_aa_gas_warn_paymaster_desc": m20,
    "g_key_aa_gas_warn_total_high": MessageLookupByLibrary.simpleMessage(
      "Limite de Gas Muito Alto",
    ),
    "g_key_aa_gas_warn_total_high_desc": m21,
    "g_key_aa_gas_warn_under_est": MessageLookupByLibrary.simpleMessage(
      "Possível Sub-Estimativa de Gas",
    ),
    "g_key_aa_gas_warn_under_est_desc": MessageLookupByLibrary.simpleMessage(
      "O gas real utilizado pode exceder a estimativa. Considere adicionar um buffer maior.",
    ),
    "g_key_aa_gas_warn_verify_high": MessageLookupByLibrary.simpleMessage(
      "Gas de Verificação Alto",
    ),
    "g_key_aa_gas_warn_verify_high_desc": m22,
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("Sem gás"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "Transações sem gás e operações em lote",
    ),
    "g_key_aa_home_title": MessageLookupByLibrary.simpleMessage(
      "Abstração de conta",
    ),
    "g_key_aa_just_now": MessageLookupByLibrary.simpleMessage("Agora mesmo"),
    "g_key_aa_kernel_account": MessageLookupByLibrary.simpleMessage(
      "Conta do Kernel",
    ),
    "g_key_aa_kernel_desc": MessageLookupByLibrary.simpleMessage(
      "Conta modular com suporte a plugins da ZeroDev",
    ),
    "g_key_aa_label": MessageLookupByLibrary.simpleMessage("Etiqueta"),
    "g_key_aa_last_activity": MessageLookupByLibrary.simpleMessage(
      "Última atividade",
    ),
    "g_key_aa_my_accounts": MessageLookupByLibrary.simpleMessage(
      "Minhas contas inteligentes",
    ),
    "g_key_aa_never": MessageLookupByLibrary.simpleMessage("Nunca"),
    "g_key_aa_no_accounts": MessageLookupByLibrary.simpleMessage(
      "Ainda não há contas inteligentes",
    ),
    "g_key_aa_no_accounts_filter": MessageLookupByLibrary.simpleMessage(
      "Nenhuma conta corresponde ao seu filtro",
    ),
    "g_key_aa_no_operations": MessageLookupByLibrary.simpleMessage(
      "Nenhuma operação adicionada",
    ),
    "g_key_aa_no_session_keys": MessageLookupByLibrary.simpleMessage(
      "Nenhuma chave de sessão",
    ),
    "g_key_aa_not_deployed": MessageLookupByLibrary.simpleMessage(
      "Não implantado",
    ),
    "g_key_aa_not_deployed_desc": MessageLookupByLibrary.simpleMessage(
      "A conta será implantada na primeira transação",
    ),
    "g_key_aa_onboard_step1": MessageLookupByLibrary.simpleMessage(
      "Crie uma conta inteligente (gratuita, sem necessidade de ETH)",
    ),
    "g_key_aa_onboard_step2": MessageLookupByLibrary.simpleMessage(
      "Financie – receba qualquer token EVM",
    ),
    "g_key_aa_onboard_step3": MessageLookupByLibrary.simpleMessage(
      "Faça transações sem gás com Paymaster",
    ),
    "g_key_aa_operations": MessageLookupByLibrary.simpleMessage("Operações"),
    "g_key_aa_owner": MessageLookupByLibrary.simpleMessage("Proprietário"),
    "g_key_aa_pay_gas_with_token": MessageLookupByLibrary.simpleMessage(
      "Pague gasolina com token",
    ),
    "g_key_aa_pay_gas_yourself": MessageLookupByLibrary.simpleMessage(
      "Pague gasolina com seu ETH",
    ),
    "g_key_aa_pay_with": MessageLookupByLibrary.simpleMessage("Pague com"),
    "g_key_aa_pay_with_eth": MessageLookupByLibrary.simpleMessage(
      "Pague com ETH",
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
      "Escolha como você deseja pagar as taxas de gás de transação",
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
    "g_key_aa_pending": MessageLookupByLibrary.simpleMessage("Pendente"),
    "g_key_aa_permission": MessageLookupByLibrary.simpleMessage("Permissão"),
    "g_key_aa_preview_address": MessageLookupByLibrary.simpleMessage(
      "Endereço de visualização",
    ),
    "g_key_aa_ready": MessageLookupByLibrary.simpleMessage("Pronto"),
    "g_key_aa_receive_address": MessageLookupByLibrary.simpleMessage(
      "Endereço de recebimento",
    ),
    "g_key_aa_recommended": MessageLookupByLibrary.simpleMessage("Recomendado"),
    "g_key_aa_retry": MessageLookupByLibrary.simpleMessage("Tentar novamente"),
    "g_key_aa_revoke": MessageLookupByLibrary.simpleMessage("Revogar"),
    "g_key_aa_revoke_confirm": MessageLookupByLibrary.simpleMessage(
      "Tem certeza de que deseja revogar esta chave de sessão? O DApp autorizado não poderá mais executar transações.",
    ),
    "g_key_aa_revoke_session": MessageLookupByLibrary.simpleMessage(
      "Revogar chave de sessão",
    ),
    "g_key_aa_revoked": MessageLookupByLibrary.simpleMessage(
      "Chave de sessão revogada",
    ),
    "g_key_aa_revoked_status": MessageLookupByLibrary.simpleMessage("Revogado"),
    "g_key_aa_revoking": MessageLookupByLibrary.simpleMessage(
      "Revogando chave de sessão...",
    ),
    "g_key_aa_safe_account": MessageLookupByLibrary.simpleMessage(
      "Conta segura",
    ),
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "Conta com múltiplas assinaturas com recursos avançados de segurança",
    ),
    "g_key_aa_safe_guardians": MessageLookupByLibrary.simpleMessage(
      "Guardiões",
    ),
    "g_key_aa_safe_threshold": MessageLookupByLibrary.simpleMessage("Limite"),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("salvo"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage(
      "Selecione Cadeia",
    ),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "Selecione Pagador",
    ),
    "g_key_aa_select_type": MessageLookupByLibrary.simpleMessage(
      "Selecione o tipo de conta",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("Selecionado"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage(
      "Envie tokens usando sua conta inteligente",
    ),
    "g_key_aa_send_title": MessageLookupByLibrary.simpleMessage(
      "Transferência AA",
    ),
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
      "Detalhes da chave da sessão",
    ),
    "g_key_aa_session_expiry": MessageLookupByLibrary.simpleMessage(
      "Válido por",
    ),
    "g_key_aa_session_full_warning": MessageLookupByLibrary.simpleMessage(
      "Alto risco — apenas DApps verificadas",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage(
      "Chaves de sessão",
    ),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "Autorize DApps com acesso temporário à sua conta inteligente",
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
      "Conta Simples",
    ),
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "Conta inteligente básica com único proprietário – recomendada para a maioria dos usuários",
    ),
    "g_key_aa_smart_account": MessageLookupByLibrary.simpleMessage(
      "Conta inteligente",
    ),
    "g_key_aa_smart_accounts": MessageLookupByLibrary.simpleMessage(
      "Contas inteligentes",
    ),
    "g_key_aa_smart_wallet": MessageLookupByLibrary.simpleMessage(
      "Carteira Inteligente",
    ),
    "g_key_aa_spending_limit": MessageLookupByLibrary.simpleMessage(
      "Limite de gastos",
    ),
    "g_key_aa_sponsored": MessageLookupByLibrary.simpleMessage(
      "Patrocinado (grátis)",
    ),
    "g_key_aa_title": MessageLookupByLibrary.simpleMessage("Conta inteligente"),
    "g_key_aa_total_gas": MessageLookupByLibrary.simpleMessage("Gás Total"),
    "g_key_aa_total_value": MessageLookupByLibrary.simpleMessage("Valor total"),
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage("Transações"),
    "g_key_aa_unavailable": MessageLookupByLibrary.simpleMessage(
      "Indisponível",
    ),
    "g_key_aa_version_v07": MessageLookupByLibrary.simpleMessage("v0.7"),
    "g_key_aa_version_v08": MessageLookupByLibrary.simpleMessage("v0.8"),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage("Ver tudo"),
    "g_key_account_linked": MessageLookupByLibrary.simpleMessage(
      "Conta vinculada com sucesso",
    ),
    "g_key_account_unlinked": MessageLookupByLibrary.simpleMessage(
      "Conta desvinculada com sucesso",
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
      "Recursos avançados",
    ),
    "g_key_airdrop_active": MessageLookupByLibrary.simpleMessage("Ativo"),
    "g_key_airdrop_check_eligibility": MessageLookupByLibrary.simpleMessage(
      "Verificar Elegibilidade",
    ),
    "g_key_airdrop_claim": MessageLookupByLibrary.simpleMessage("Resgatar"),
    "g_key_airdrop_claimed": MessageLookupByLibrary.simpleMessage("Resgatado"),
    "g_key_airdrop_days_left": m23,
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
      "Login da Apple cancelado",
    ),
    "g_key_apply": MessageLookupByLibrary.simpleMessage("Aplicar"),
    "g_key_batch_add_recipient": MessageLookupByLibrary.simpleMessage(
      "Adicionar Destinatário",
    ),
    "g_key_batch_broadcasting": MessageLookupByLibrary.simpleMessage(
      "Transmitindo...",
    ),
    "g_key_batch_clear_all": MessageLookupByLibrary.simpleMessage(
      "Limpar Tudo",
    ),
    "g_key_batch_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Confirmar transferência em lote",
    ),
    "g_key_batch_continue": MessageLookupByLibrary.simpleMessage("Continuar"),
    "g_key_batch_csv_format": MessageLookupByLibrary.simpleMessage(
      "Formato CSV: endereço,valor,rótulo",
    ),
    "g_key_batch_done": MessageLookupByLibrary.simpleMessage("Concluído"),
    "g_key_batch_duplicate_address": m24,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "Estimando Gás...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "A transferência em lote suporta apenas cadeias EVM",
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
      "Ajuda para transferência em lote",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage(
      "Importar CSV",
    ),
    "g_key_batch_insufficient_balance": m25,
    "g_key_batch_invalid_address": m26,
    "g_key_batch_invalid_amount": m27,
    "g_key_batch_max_recipients": m28,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "Memorando é opcional",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "Use Multicall3 para taxas de gás mais baixas",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "Nenhum token compatível",
    ),
    "g_key_batch_preview": MessageLookupByLibrary.simpleMessage(
      "Pré-visualizar",
    ),
    "g_key_batch_recipients": MessageLookupByLibrary.simpleMessage(
      "Destinatários",
    ),
    "g_key_batch_select_token": MessageLookupByLibrary.simpleMessage(
      "Selecione o token",
    ),
    "g_key_batch_send_multiple": MessageLookupByLibrary.simpleMessage(
      "Envie tokens para vários endereços em uma transação",
    ),
    "g_key_batch_signing": MessageLookupByLibrary.simpleMessage("Assinando..."),
    "g_key_batch_swipe_remove": MessageLookupByLibrary.simpleMessage(
      "Deslize para a esquerda para remover um destinatário",
    ),
    "g_key_batch_title": MessageLookupByLibrary.simpleMessage(
      "Transferência em Lote",
    ),
    "g_key_batch_total_amount": MessageLookupByLibrary.simpleMessage(
      "Valor Total",
    ),
    "g_key_bridge_amount": MessageLookupByLibrary.simpleMessage("Valor"),
    "g_key_bridge_chain_not_supported": MessageLookupByLibrary.simpleMessage(
      "Cadeia não suportada",
    ),
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
    "g_key_bridge_select": MessageLookupByLibrary.simpleMessage("Selecione"),
    "g_key_bridge_select_token": MessageLookupByLibrary.simpleMessage(
      "Selecionar Token",
    ),
    "g_key_bridge_slippage": MessageLookupByLibrary.simpleMessage(
      "Deslizamento",
    ),
    "g_key_bridge_status_completed": MessageLookupByLibrary.simpleMessage(
      "Concluído",
    ),
    "g_key_bridge_status_failed": MessageLookupByLibrary.simpleMessage("Falha"),
    "g_key_bridge_status_in_progress": MessageLookupByLibrary.simpleMessage(
      "Em andamento",
    ),
    "g_key_bridge_status_pending": MessageLookupByLibrary.simpleMessage(
      "Pendente",
    ),
    "g_key_bridge_swap": MessageLookupByLibrary.simpleMessage("Ponte"),
    "g_key_bridge_time": MessageLookupByLibrary.simpleMessage("Tempo Estimado"),
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("Ponte"),
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
    "g_key_btc_redeem_locked_until": MessageLookupByLibrary.simpleMessage(
      "Bloqueado até",
    ),
    "g_key_btc_redeem_reminder": MessageLookupByLibrary.simpleMessage(
      "Verifique se o período de bloqueio expirou antes de enviar seu resgate.",
    ),
    "g_key_btc_redeem_still_locked": MessageLookupByLibrary.simpleMessage(
      "BTC ainda bloqueado",
    ),
    "g_key_btc_redeem_title": MessageLookupByLibrary.simpleMessage(
      "Resgatar vBTC",
    ),
    "g_key_btc_redeem_unlocked": MessageLookupByLibrary.simpleMessage(
      "Desbloqueado – pronto para resgatar",
    ),
    "g_key_btc_stake_acknowledge": MessageLookupByLibrary.simpleMessage(
      "Entendo os riscos e desejo prosseguir",
    ),
    "g_key_btc_stake_continue": MessageLookupByLibrary.simpleMessage(
      "Continuar a apostar",
    ),
    "g_key_btc_stake_how_it_works": MessageLookupByLibrary.simpleMessage(
      "Como funciona",
    ),
    "g_key_btc_stake_reminder": MessageLookupByLibrary.simpleMessage(
      "O BTC ficará bloqueado até que o timelock expire. Conclua o processo de piquetagem na interface abaixo.",
    ),
    "g_key_btc_stake_risk1": MessageLookupByLibrary.simpleMessage(
      "Seu BTC ficará bloqueado durante todo o período de staking. A retirada antecipada não é possível.",
    ),
    "g_key_btc_stake_risk2": MessageLookupByLibrary.simpleMessage(
      "O bloqueio é imposto pelo Bitcoin OP_CHECKLOCKTIMEVERIFY (CLTV) e não pode ser ignorado.",
    ),
    "g_key_btc_stake_risk3": MessageLookupByLibrary.simpleMessage(
      "Risco de contrato inteligente: embora auditado, nenhum protocolo é totalmente isento de riscos.",
    ),
    "g_key_btc_stake_risk4": MessageLookupByLibrary.simpleMessage(
      "Stake mínimo: 0,001 BTC. Período mínimo de bloqueio: 0,125 dias (~3 horas).",
    ),
    "g_key_btc_stake_risk_warning": MessageLookupByLibrary.simpleMessage(
      "Aviso de risco",
    ),
    "g_key_btc_stake_step1_desc": MessageLookupByLibrary.simpleMessage(
      "Seu BTC está bloqueado em um endereço multisig 2 de 2 com bloqueio de tempo (CLTV), protegido por sua chave e pela chave da caixa N42.",
    ),
    "g_key_btc_stake_step1_title": MessageLookupByLibrary.simpleMessage(
      "Bloqueie seu BTC",
    ),
    "g_key_btc_stake_step2_desc": MessageLookupByLibrary.simpleMessage(
      "Após a confirmação na rede, o vBTC é cunhado em sua carteira na proporção de 1:1.",
    ),
    "g_key_btc_stake_step2_title": MessageLookupByLibrary.simpleMessage(
      "Menta vBTC",
    ),
    "g_key_btc_stake_step3_desc": MessageLookupByLibrary.simpleMessage(
      "Segure vBTC para ganhar recompensas de aposta. O vBTC também pode ser usado em protocolos DeFi.",
    ),
    "g_key_btc_stake_step3_title": MessageLookupByLibrary.simpleMessage(
      "Ganhe recompensas",
    ),
    "g_key_btc_stake_step4_desc": MessageLookupByLibrary.simpleMessage(
      "Quando o período de bloqueio expirar, queime seu vBTC para receber seu BTC original de volta.",
    ),
    "g_key_btc_stake_step4_title": MessageLookupByLibrary.simpleMessage(
      "Resgatar após desbloquear",
    ),
    "g_key_btc_stake_subtitle": MessageLookupByLibrary.simpleMessage(
      "Bloqueie BTC para cunhar vBTC e ganhar recompensas",
    ),
    "g_key_btc_stake_title": MessageLookupByLibrary.simpleMessage(
      "Estacamento de autocustódia BTC",
    ),
    "g_key_burn_got_it": MessageLookupByLibrary.simpleMessage("Entendi"),
    "g_key_burn_nft_step1": MessageLookupByLibrary.simpleMessage(
      "1. Selecione um token com suporte NFT",
    ),
    "g_key_burn_nft_step2": MessageLookupByLibrary.simpleMessage(
      "2. Vá para a guia NFT",
    ),
    "g_key_burn_nft_step3": MessageLookupByLibrary.simpleMessage(
      "3. Selecione o NFT que deseja gravar",
    ),
    "g_key_burn_nft_step4": MessageLookupByLibrary.simpleMessage(
      "4. Toque no botão \"Gravar\"",
    ),
    "g_key_burn_nft_steps": MessageLookupByLibrary.simpleMessage("Etapas:"),
    "g_key_burn_nft_tip": MessageLookupByLibrary.simpleMessage(
      "Para gravar um NFT, vá para a página de detalhes do NFT e toque no botão \"Gravar\".",
    ),
    "g_key_burn_nft_title": MessageLookupByLibrary.simpleMessage("Queimar NFT"),
    "g_key_chain_transfer_not_supported": MessageLookupByLibrary.simpleMessage(
      "Esta rede ainda não suporta transferências, fique atento",
    ),
    "g_key_change_email": MessageLookupByLibrary.simpleMessage(
      "Alterar e-mail",
    ),
    "g_key_change_password": MessageLookupByLibrary.simpleMessage(
      "Alterar senha",
    ),
    "g_key_change_password_desc": MessageLookupByLibrary.simpleMessage(
      "Digite sua senha atual e defina uma nova senha",
    ),
    "g_key_code_length": MessageLookupByLibrary.simpleMessage(
      "Por favor insira o código de 6 dígitos",
    ),
    "g_key_code_required": MessageLookupByLibrary.simpleMessage(
      "O código de verificação é obrigatório",
    ),
    "g_key_code_sent": MessageLookupByLibrary.simpleMessage(
      "Código de verificação enviado",
    ),
    "g_key_coin_list_all_hidden": MessageLookupByLibrary.simpleMessage(
      "Todos os ativos estão abaixo de US\$ 1",
    ),
    "g_key_coin_list_separator": MessageLookupByLibrary.simpleMessage(
      "Outros ativos",
    ),
    "g_key_coin_list_show_all": MessageLookupByLibrary.simpleMessage(
      "Toque para mostrar tudo",
    ),
    "g_key_coin_search_recent": MessageLookupByLibrary.simpleMessage("Recente"),
    "g_key_confirm_new_password": MessageLookupByLibrary.simpleMessage(
      "Confirme a nova senha",
    ),
    "g_key_continue_with_apple": MessageLookupByLibrary.simpleMessage(
      "Continuar com a Apple",
    ),
    "g_key_continue_with_google": MessageLookupByLibrary.simpleMessage(
      "Continuar com o Google",
    ),
    "g_key_deadline_reminders": MessageLookupByLibrary.simpleMessage(
      "Lembretes de prazo",
    ),
    "g_key_dex_approval_success": MessageLookupByLibrary.simpleMessage(
      "Aprovado! Toque em Trocar para continuar.",
    ),
    "g_key_dex_approve_exact": MessageLookupByLibrary.simpleMessage(
      "Valor exato",
    ),
    "g_key_dex_approve_required": m29,
    "g_key_dex_approve_unlimited": MessageLookupByLibrary.simpleMessage(
      "Ilimitado",
    ),
    "g_key_dex_approve_unlimited_info": MessageLookupByLibrary.simpleMessage(
      "Aprovação ilimitada: o roteador pode gastar este token a qualquer momento. Prática padrão, mas arriscada se o contrato for comprometido.",
    ),
    "g_key_dex_approving": MessageLookupByLibrary.simpleMessage("Aprovando…"),
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
    "g_key_dex_min_received": MessageLookupByLibrary.simpleMessage(
      "Min. Recebido",
    ),
    "g_key_dex_no_tokens": MessageLookupByLibrary.simpleMessage("Sem tokens"),
    "g_key_dex_no_tokens_found": MessageLookupByLibrary.simpleMessage(
      "Nenhum token encontrado",
    ),
    "g_key_dex_price_chart": MessageLookupByLibrary.simpleMessage(
      "Gráfico de preço",
    ),
    "g_key_dex_price_impact": MessageLookupByLibrary.simpleMessage(
      "Impacto no Preço",
    ),
    "g_key_dex_price_impact_high": m30,
    "g_key_dex_quote_expires": m31,
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage(
      "Cotação falhou",
    ),
    "g_key_dex_quote_refreshed": MessageLookupByLibrary.simpleMessage(
      "Cotação atualizada",
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
    "g_key_dex_slippage_label": MessageLookupByLibrary.simpleMessage(
      "Deslizamento máximo",
    ),
    "g_key_dex_sol_note": MessageLookupByLibrary.simpleMessage(
      "Troca Solana: assine a transação em sua carteira Solana.",
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
      "Domínios imparáveis",
    ),
    "g_key_domain_ud_not_found": MessageLookupByLibrary.simpleMessage(
      "Domínio Unstoppable não encontrado ou sem endereço para esta rede",
    ),
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage(
      "Produtos ativos",
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
      "Reivindique tokens grátis",
    ),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage(
      "Transferência entre cadeias",
    ),
    "g_key_earn_daily_bonus": MessageLookupByLibrary.simpleMessage(
      "Bônus de check-in diário",
    ),
    "g_key_earn_dex_desc": MessageLookupByLibrary.simpleMessage(
      "Troque qualquer token via Uniswap / 1inch",
    ),
    "g_key_earn_dex_swap": MessageLookupByLibrary.simpleMessage("Troca DEX"),
    "g_key_earn_gas": MessageLookupByLibrary.simpleMessage("Gás"),
    "g_key_earn_go_staking": MessageLookupByLibrary.simpleMessage(
      "Iniciar staking",
    ),
    "g_key_earn_ledger": MessageLookupByLibrary.simpleMessage("Razão"),
    "g_key_earn_loading_apy": MessageLookupByLibrary.simpleMessage(
      "Carregando APY...",
    ),
    "g_key_earn_mining": MessageLookupByLibrary.simpleMessage("Mineração"),
    "g_key_earn_more": MessageLookupByLibrary.simpleMessage("Ganhe mais"),
    "g_key_earn_native_sol": MessageLookupByLibrary.simpleMessage(
      "Estaqueamento nativo Solana",
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
      "Ganhe pontos diariamente",
    ),
    "g_key_earn_pts_day": m32,
    "g_key_earn_quick_tools": MessageLookupByLibrary.simpleMessage(
      "Ferramentas rápidas",
    ),
    "g_key_earn_recommended": MessageLookupByLibrary.simpleMessage(
      "Recomendado",
    ),
    "g_key_earn_select_swap": MessageLookupByLibrary.simpleMessage(
      "Selecionar tipo de troca",
    ),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "Aposte ETH com Lido",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("Trocar"),
    "g_key_earn_title": MessageLookupByLibrary.simpleMessage("Ganhe"),
    "g_key_earn_total_earnings": MessageLookupByLibrary.simpleMessage(
      "Ganhos totais",
    ),
    "g_key_earn_up_to_apy": m33,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage("Ver tudo"),
    "g_key_eligibility_alerts": MessageLookupByLibrary.simpleMessage(
      "Alertas de elegibilidade",
    ),
    "g_key_eligible_only": MessageLookupByLibrary.simpleMessage(
      "Elegível apenas",
    ),
    "g_key_email": MessageLookupByLibrary.simpleMessage("E-mail"),
    "g_key_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Por favor insira um endereço de e-mail válido",
    ),
    "g_key_email_required": MessageLookupByLibrary.simpleMessage(
      "O e-mail é obrigatório",
    ),
    "g_key_ens_address_updated": MessageLookupByLibrary.simpleMessage(
      "Endereço resolvido atualizado",
    ),
    "g_key_ens_advanced": MessageLookupByLibrary.simpleMessage("Avançado"),
    "g_key_ens_annual_fee": MessageLookupByLibrary.simpleMessage("Taxa Anual"),
    "g_key_ens_available": MessageLookupByLibrary.simpleMessage("Disponível"),
    "g_key_ens_base_price": MessageLookupByLibrary.simpleMessage("Preço Base"),
    "g_key_ens_checking": MessageLookupByLibrary.simpleMessage(
      "Verificando disponibilidade...",
    ),
    "g_key_ens_commit": MessageLookupByLibrary.simpleMessage("Confirmar"),
    "g_key_ens_commit_failed": MessageLookupByLibrary.simpleMessage(
      "Falha na confirmação",
    ),
    "g_key_ens_commit_tx": MessageLookupByLibrary.simpleMessage(
      "Confirmando transação...",
    ),
    "g_key_ens_commitment_expired_msg": MessageLookupByLibrary.simpleMessage(
      "O compromisso de registro expirou. Por favor, reinicie o processo de registro.",
    ),
    "g_key_ens_committing": MessageLookupByLibrary.simpleMessage(
      "Comprometendo-se...",
    ),
    "g_key_ens_confirm_renew": MessageLookupByLibrary.simpleMessage(
      "Confirmar renovação",
    ),
    "g_key_ens_confirm_send": MessageLookupByLibrary.simpleMessage(
      "Confirmar e enviar",
    ),
    "g_key_ens_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Confirme a resolução do ENS",
    ),
    "g_key_ens_copy_address": MessageLookupByLibrary.simpleMessage(
      "Endereço copiado",
    ),
    "g_key_ens_current_expiry": MessageLookupByLibrary.simpleMessage(
      "Expiração Atual",
    ),
    "g_key_ens_days_left": MessageLookupByLibrary.simpleMessage(
      "dias restantes",
    ),
    "g_key_ens_description": MessageLookupByLibrary.simpleMessage(
      "Registre e gerencie seus nomes de domínio .eth",
    ),
    "g_key_ens_detected": MessageLookupByLibrary.simpleMessage(
      "Nome do ENS detectado",
    ),
    "g_key_ens_duration": MessageLookupByLibrary.simpleMessage(
      "Período de inscrição",
    ),
    "g_key_ens_edit_records": MessageLookupByLibrary.simpleMessage(
      "Editar registros",
    ),
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage("Expirado"),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage("Expira"),
    "g_key_ens_expiring_soon": MessageLookupByLibrary.simpleMessage(
      "Expirando em breve",
    ),
    "g_key_ens_extend_period": MessageLookupByLibrary.simpleMessage(
      "Estender o período de registro",
    ),
    "g_key_ens_failed": MessageLookupByLibrary.simpleMessage("Falha"),
    "g_key_ens_finalizing": MessageLookupByLibrary.simpleMessage(
      "Finalizando registro",
    ),
    "g_key_ens_get_started": MessageLookupByLibrary.simpleMessage(
      "Comece com ENS",
    ),
    "g_key_ens_get_your_name": MessageLookupByLibrary.simpleMessage(
      "Obtenha seu nome .eth",
    ),
    "g_key_ens_home_title": MessageLookupByLibrary.simpleMessage("Gerente ENS"),
    "g_key_ens_invalid_address": MessageLookupByLibrary.simpleMessage(
      "Endereço inválido (deve ser 0x + 40 caracteres hexadecimais)",
    ),
    "g_key_ens_invalid_name": MessageLookupByLibrary.simpleMessage(
      "Nome ENS inválido",
    ),
    "g_key_ens_is_yours": MessageLookupByLibrary.simpleMessage("agora é seu!"),
    "g_key_ens_keep_app_open": MessageLookupByLibrary.simpleMessage(
      "Por favor, mantenha o aplicativo aberto durante o registro",
    ),
    "g_key_ens_manage_your_identity": MessageLookupByLibrary.simpleMessage(
      "Gerencie sua identidade Web3",
    ),
    "g_key_ens_management_title": MessageLookupByLibrary.simpleMessage(
      "Gerenciar ENS",
    ),
    "g_key_ens_min_length": MessageLookupByLibrary.simpleMessage(
      "Mínimo 3 caracteres",
    ),
    "g_key_ens_my_domains": MessageLookupByLibrary.simpleMessage(
      "Meus domínios",
    ),
    "g_key_ens_name": MessageLookupByLibrary.simpleMessage("Nome ENS"),
    "g_key_ens_new_expiry": MessageLookupByLibrary.simpleMessage(
      "Nova expiração",
    ),
    "g_key_ens_new_owner": MessageLookupByLibrary.simpleMessage(
      "Endereço do novo proprietário",
    ),
    "g_key_ens_no_domains": MessageLookupByLibrary.simpleMessage(
      "Nenhum domínio ainda",
    ),
    "g_key_ens_no_names": MessageLookupByLibrary.simpleMessage(
      "Você ainda não possui nenhum nome ENS",
    ),
    "g_key_ens_owned_names": MessageLookupByLibrary.simpleMessage(
      "Meus nomes ENS",
    ),
    "g_key_ens_owner": MessageLookupByLibrary.simpleMessage("Proprietário"),
    "g_key_ens_please_wait": MessageLookupByLibrary.simpleMessage(
      "Por favor, espere",
    ),
    "g_key_ens_premium_name": MessageLookupByLibrary.simpleMessage(
      "Nome Premium",
    ),
    "g_key_ens_price_breakdown": MessageLookupByLibrary.simpleMessage(
      "Divisão de preços",
    ),
    "g_key_ens_price_per_year": MessageLookupByLibrary.simpleMessage("por ano"),
    "g_key_ens_primary": MessageLookupByLibrary.simpleMessage("Primário"),
    "g_key_ens_primary_set": MessageLookupByLibrary.simpleMessage(
      "Nome principal definido com sucesso",
    ),
    "g_key_ens_processing": MessageLookupByLibrary.simpleMessage(
      "Processando...",
    ),
    "g_key_ens_purchase_title": MessageLookupByLibrary.simpleMessage(
      "Registrar ENS",
    ),
    "g_key_ens_records": MessageLookupByLibrary.simpleMessage("Registros"),
    "g_key_ens_register": MessageLookupByLibrary.simpleMessage("Cadastre-se"),
    "g_key_ens_register_description": MessageLookupByLibrary.simpleMessage(
      "Sua identidade descentralizada no Ethereum",
    ),
    "g_key_ens_register_failed": MessageLookupByLibrary.simpleMessage(
      "Falha no registro",
    ),
    "g_key_ens_register_now": MessageLookupByLibrary.simpleMessage(
      "Cadastre-se agora",
    ),
    "g_key_ens_register_tx": MessageLookupByLibrary.simpleMessage(
      "Registrando nome...",
    ),
    "g_key_ens_registering": MessageLookupByLibrary.simpleMessage(
      "Registrando...",
    ),
    "g_key_ens_registration_info": MessageLookupByLibrary.simpleMessage(
      "Informações de registro",
    ),
    "g_key_ens_registration_period": MessageLookupByLibrary.simpleMessage(
      "Período de inscrição",
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
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("Renovar"),
    "g_key_ens_renew_cost": MessageLookupByLibrary.simpleMessage(
      "Custo de renovação",
    ),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage(
      "Estenda o registro do seu domínio",
    ),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage(
      "Renovação bem-sucedida",
    ),
    "g_key_ens_renew_title": MessageLookupByLibrary.simpleMessage(
      "Renovar ENS",
    ),
    "g_key_ens_resolution_failed": MessageLookupByLibrary.simpleMessage(
      "Falha na resolução do ENS",
    ),
    "g_key_ens_resolved_address": MessageLookupByLibrary.simpleMessage(
      "Endereço Resolvido",
    ),
    "g_key_ens_resolving": MessageLookupByLibrary.simpleMessage(
      "Resolvendo ENS...",
    ),
    "g_key_ens_search": MessageLookupByLibrary.simpleMessage("Pesquisar"),
    "g_key_ens_search_desc": MessageLookupByLibrary.simpleMessage(
      "Encontre nomes .eth disponíveis",
    ),
    "g_key_ens_search_hint": MessageLookupByLibrary.simpleMessage(
      "Procure um nome .eth",
    ),
    "g_key_ens_search_prompt": MessageLookupByLibrary.simpleMessage(
      "Insira um nome ENS para pesquisar",
    ),
    "g_key_ens_search_register": MessageLookupByLibrary.simpleMessage(
      "Pesquise e registre-se",
    ),
    "g_key_ens_search_title": MessageLookupByLibrary.simpleMessage(
      "Pesquisa ENS",
    ),
    "g_key_ens_self_transfer": MessageLookupByLibrary.simpleMessage(
      "Não é possível enviar para seu próprio endereço",
    ),
    "g_key_ens_service": MessageLookupByLibrary.simpleMessage(
      "Serviço de nomes Ethereum",
    ),
    "g_key_ens_set_primary": MessageLookupByLibrary.simpleMessage(
      "Definir como principal",
    ),
    "g_key_ens_standard_name": MessageLookupByLibrary.simpleMessage(
      "Nome Padrão",
    ),
    "g_key_ens_start_registration": MessageLookupByLibrary.simpleMessage(
      "Iniciar registro",
    ),
    "g_key_ens_step_1": MessageLookupByLibrary.simpleMessage("Passo 1"),
    "g_key_ens_step_2": MessageLookupByLibrary.simpleMessage("Etapa 2"),
    "g_key_ens_step_3": MessageLookupByLibrary.simpleMessage("Etapa 3"),
    "g_key_ens_step_commit": MessageLookupByLibrary.simpleMessage("Confirmar"),
    "g_key_ens_step_register": MessageLookupByLibrary.simpleMessage(
      "Cadastre-se",
    ),
    "g_key_ens_step_success": MessageLookupByLibrary.simpleMessage("Sucesso"),
    "g_key_ens_step_wait": MessageLookupByLibrary.simpleMessage("Espere"),
    "g_key_ens_subdomain_create": MessageLookupByLibrary.simpleMessage(
      "Criar subdomínio",
    ),
    "g_key_ens_subdomain_created": MessageLookupByLibrary.simpleMessage(
      "Subdomínio criado",
    ),
    "g_key_ens_subdomain_delete": MessageLookupByLibrary.simpleMessage(
      "Excluir subdomínio",
    ),
    "g_key_ens_subdomain_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "Este subdomínio será excluído permanentemente.",
    ),
    "g_key_ens_subdomain_deleted": MessageLookupByLibrary.simpleMessage(
      "Subdomínio excluído",
    ),
    "g_key_ens_subdomain_empty": MessageLookupByLibrary.simpleMessage(
      "Ainda não há subdomínios",
    ),
    "g_key_ens_subdomain_invalid_label": MessageLookupByLibrary.simpleMessage(
      "Use apenas letras, números e hífens",
    ),
    "g_key_ens_subdomain_label": MessageLookupByLibrary.simpleMessage(
      "Rótulo de subdomínio",
    ),
    "g_key_ens_subdomain_label_hint": MessageLookupByLibrary.simpleMessage(
      "por exemplo blog, e-mail, aplicativo",
    ),
    "g_key_ens_subdomain_owner": MessageLookupByLibrary.simpleMessage(
      "Endereço do proprietário",
    ),
    "g_key_ens_subdomain_owner_hint": MessageLookupByLibrary.simpleMessage(
      "Deixe em branco para usar a carteira atual",
    ),
    "g_key_ens_subdomains": MessageLookupByLibrary.simpleMessage("Subdomínios"),
    "g_key_ens_success": MessageLookupByLibrary.simpleMessage("Sucesso!"),
    "g_key_ens_success_message": m34,
    "g_key_ens_suggestions": MessageLookupByLibrary.simpleMessage("Sugestões"),
    "g_key_ens_text_records": MessageLookupByLibrary.simpleMessage(
      "Registros de texto",
    ),
    "g_key_ens_title": MessageLookupByLibrary.simpleMessage("Gerente ENS"),
    "g_key_ens_total": MessageLookupByLibrary.simpleMessage("Total"),
    "g_key_ens_total_cost": MessageLookupByLibrary.simpleMessage("Custo total"),
    "g_key_ens_transfer": MessageLookupByLibrary.simpleMessage("Transferência"),
    "g_key_ens_transfer_desc": MessageLookupByLibrary.simpleMessage(
      "Transferir a propriedade para outro endereço",
    ),
    "g_key_ens_transfer_success": MessageLookupByLibrary.simpleMessage(
      "Transferência bem-sucedida",
    ),
    "g_key_ens_transfer_warning": MessageLookupByLibrary.simpleMessage(
      "A transferência é irreversível. Certifique-se de que o endereço do novo proprietário esteja correto.",
    ),
    "g_key_ens_try_another": MessageLookupByLibrary.simpleMessage(
      "Tente outro nome",
    ),
    "g_key_ens_two_step_process": MessageLookupByLibrary.simpleMessage(
      "O registro do ENS é um processo de duas etapas",
    ),
    "g_key_ens_unavailable": MessageLookupByLibrary.simpleMessage(
      "Indisponível",
    ),
    "g_key_ens_wait": MessageLookupByLibrary.simpleMessage("Espere"),
    "g_key_ens_wait_explanation": MessageLookupByLibrary.simpleMessage(
      "O período de espera evita ataques frontais",
    ),
    "g_key_ens_wait_time_info": MessageLookupByLibrary.simpleMessage(
      "Um período de espera impede o front-running",
    ),
    "g_key_ens_wait_timer": m35,
    "g_key_ens_waiting": MessageLookupByLibrary.simpleMessage("Esperando..."),
    "g_key_ens_warning": MessageLookupByLibrary.simpleMessage(
      "Verifique o endereço resolvido antes de continuar. Os nomes ENS podem ser transferidos ou alterados pelo seu proprietário.",
    ),
    "g_key_ens_year": MessageLookupByLibrary.simpleMessage("ano"),
    "g_key_ens_years": MessageLookupByLibrary.simpleMessage("anos"),
    "g_key_ens_your_identity": MessageLookupByLibrary.simpleMessage(
      "Sua Identidade",
    ),
    "g_key_enter_confirm_password": MessageLookupByLibrary.simpleMessage(
      "Digite novamente a nova senha",
    ),
    "g_key_enter_email": MessageLookupByLibrary.simpleMessage(
      "Digite seu endereço de e-mail",
    ),
    "g_key_enter_new_password": MessageLookupByLibrary.simpleMessage(
      "Digite a nova senha",
    ),
    "g_key_enter_old_password": MessageLookupByLibrary.simpleMessage(
      "Digite a senha atual",
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
    "g_key_feedback": MessageLookupByLibrary.simpleMessage("Comentários"),
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
    "g_key_filter": MessageLookupByLibrary.simpleMessage("Filtro"),
    "g_key_filter_type": MessageLookupByLibrary.simpleMessage("Tipo"),
    "g_key_forgot_password": MessageLookupByLibrary.simpleMessage(
      "Esqueceu a senha?",
    ),
    "g_key_gas_alert": MessageLookupByLibrary.simpleMessage("Alerta de gás"),
    "g_key_gas_alert_above": MessageLookupByLibrary.simpleMessage(
      "Alerta quando acima",
    ),
    "g_key_gas_alert_below": MessageLookupByLibrary.simpleMessage(
      "Alerta quando abaixo",
    ),
    "g_key_gas_alert_save": MessageLookupByLibrary.simpleMessage("Salvar"),
    "g_key_gas_alert_threshold": MessageLookupByLibrary.simpleMessage(
      "Limite (Gwei)",
    ),
    "g_key_gas_auto_refresh": m36,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("Taxa Base"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage("Personalizado"),
    "g_key_gas_estimated_time": MessageLookupByLibrary.simpleMessage(
      "Tempo Est.",
    ),
    "g_key_gas_fast": MessageLookupByLibrary.simpleMessage("Rápido"),
    "g_key_gas_footer": MessageLookupByLibrary.simpleMessage(
      "Os preços do gás flutuam com base na demanda da rede. Gás mais baixo = confirmação mais lenta, gás mais alto = confirmação mais rápida.",
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
      "Tendência de preços",
    ),
    "g_key_gas_priority_fee": MessageLookupByLibrary.simpleMessage(
      "Taxa de Prioridade",
    ),
    "g_key_gas_realtime_prices": MessageLookupByLibrary.simpleMessage(
      "Preços do gás em tempo real",
    ),
    "g_key_gas_settings": MessageLookupByLibrary.simpleMessage(
      "Configurações de Gas",
    ),
    "g_key_gas_slow": MessageLookupByLibrary.simpleMessage("Lento"),
    "g_key_gas_standard": MessageLookupByLibrary.simpleMessage("Padrão"),
    "g_key_gas_tracker": MessageLookupByLibrary.simpleMessage(
      "Rastreador de Gás",
    ),
    "g_key_gesture_medium": MessageLookupByLibrary.simpleMessage("Médio"),
    "g_key_gesture_strong": MessageLookupByLibrary.simpleMessage("Forte"),
    "g_key_gesture_too_simple": MessageLookupByLibrary.simpleMessage(
      "Padrão muito simples, adicione mais nós",
    ),
    "g_key_gesture_weak": MessageLookupByLibrary.simpleMessage("Fraco"),
    "g_key_google_sign_in_cancelled": MessageLookupByLibrary.simpleMessage(
      "Login do Google cancelado",
    ),
    "g_key_high_value_only": MessageLookupByLibrary.simpleMessage(
      "Somente valor alto",
    ),
    "g_key_hw_account_added": m37,
    "g_key_hw_account_already_imported": MessageLookupByLibrary.simpleMessage(
      "Conta já importada",
    ),
    "g_key_hw_accounts": MessageLookupByLibrary.simpleMessage("Contas"),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("Adicionar"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage(
      "Adicionar Conta",
    ),
    "g_key_hw_add_account_content": m38,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "Endereço copiado",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "Certifique-se de que seu dispositivo esteja desbloqueado e que o Bluetooth esteja ativado antes de conectar.",
    ),
    "g_key_hw_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage(
      "Verifique o aplicativo",
    ),
    "g_key_hw_confirm_on_device": MessageLookupByLibrary.simpleMessage(
      "Confirme no seu dispositivo",
    ),
    "g_key_hw_connect": MessageLookupByLibrary.simpleMessage(
      "Conectar Carteira Hardware",
    ),
    "g_key_hw_connect_new_device": MessageLookupByLibrary.simpleMessage(
      "Conecte novo dispositivo",
    ),
    "g_key_hw_connect_new_keystone": MessageLookupByLibrary.simpleMessage(
      "Entreferro com Keystone (QR)",
    ),
    "g_key_hw_connect_new_ledger": MessageLookupByLibrary.simpleMessage(
      "Conectar Ledger (Bluetooth)",
    ),
    "g_key_hw_connect_new_trezor": MessageLookupByLibrary.simpleMessage(
      "Conecte o Trezor (USB)",
    ),
    "g_key_hw_connected": MessageLookupByLibrary.simpleMessage("Conectado"),
    "g_key_hw_connecting": MessageLookupByLibrary.simpleMessage(
      "Conectando...",
    ),
    "g_key_hw_current_app_label": m39,
    "g_key_hw_days_ago": m40,
    "g_key_hw_derivation_path": MessageLookupByLibrary.simpleMessage(
      "Caminho de Derivação",
    ),
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("Desconectar"),
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
    "g_key_hw_import_failed": m41,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "Conectar Keystone",
    ),
    "g_key_hw_keystone_invalid_response": MessageLookupByLibrary.simpleMessage(
      "Resposta inválida do dispositivo Keystone",
    ),
    "g_key_hw_keystone_scan_error": MessageLookupByLibrary.simpleMessage(
      "Falha ao analisar o código QR. Por favor, tente novamente.",
    ),
    "g_key_hw_keystone_scan_request_hint": MessageLookupByLibrary.simpleMessage(
      "Digitalize este código QR com seu dispositivo Keystone para assinar a transação",
    ),
    "g_key_hw_keystone_scan_response_hint": MessageLookupByLibrary.simpleMessage(
      "Aponte sua câmera para o código QR exibido no seu dispositivo Keystone",
    ),
    "g_key_hw_keystone_scan_response_title":
        MessageLookupByLibrary.simpleMessage("Digitalizar assinatura Keystone"),
    "g_key_hw_keystone_scan_xpub_hint": MessageLookupByLibrary.simpleMessage(
      "Digitalize o código QR do seu dispositivo Keystone para importar contas",
    ),
    "g_key_hw_keystone_signature_received":
        MessageLookupByLibrary.simpleMessage("Assinatura recebida com sucesso"),
    "g_key_hw_keystone_signing": MessageLookupByLibrary.simpleMessage(
      "Aguardando assinatura da Keystone...",
    ),
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "Toque para verificar a resposta Keystone",
    ),
    "g_key_hw_last_connected": m42,
    "g_key_hw_ledger": MessageLookupByLibrary.simpleMessage("Razão"),
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
      "Nenhum aplicativo está aberto no momento",
    ),
    "g_key_hw_no_devices": MessageLookupByLibrary.simpleMessage(
      "Nenhum dispositivo encontrado",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "Dispositivo não conectado",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "Não conectado",
    ),
    "g_key_hw_open_app": m43,
    "g_key_hw_open_ledger_app_hint": m44,
    "g_key_hw_rejected": MessageLookupByLibrary.simpleMessage(
      "Rejeitado no dispositivo",
    ),
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("Remover"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage(
      "Remover dispositivo",
    ),
    "g_key_hw_remove_device_confirm": m45,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage(
      "Dispositivos salvos",
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
      "Dispositivos Suportados",
    ),
    "g_key_hw_timeout": MessageLookupByLibrary.simpleMessage(
      "Tempo de conexão esgotado",
    ),
    "g_key_hw_title": MessageLookupByLibrary.simpleMessage("Carteira Hardware"),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("Hoje"),
    "g_key_hw_trezor": MessageLookupByLibrary.simpleMessage("Trezor"),
    "g_key_hw_trezor_connect_failed": MessageLookupByLibrary.simpleMessage(
      "Falha ao conectar-se ao Trezor. Certifique-se de que o USB esteja conectado.",
    ),
    "g_key_hw_trezor_connect_title": MessageLookupByLibrary.simpleMessage(
      "Conectar Trezor",
    ),
    "g_key_hw_trezor_connected": MessageLookupByLibrary.simpleMessage(
      "Trezor conectado com sucesso",
    ),
    "g_key_hw_trezor_connecting": MessageLookupByLibrary.simpleMessage(
      "Conectando ao Trezor...",
    ),
    "g_key_hw_trezor_passphrase_required": MessageLookupByLibrary.simpleMessage(
      "Digite a senha no seu dispositivo Trezor",
    ),
    "g_key_hw_trezor_pin_required": MessageLookupByLibrary.simpleMessage(
      "Digite o PIN no seu dispositivo Trezor",
    ),
    "g_key_hw_trezor_usb_hint": MessageLookupByLibrary.simpleMessage(
      "Conecte seu dispositivo Trezor via cabo USB e desbloqueie-o",
    ),
    "g_key_hw_view_accounts": MessageLookupByLibrary.simpleMessage(
      "Ver contas",
    ),
    "g_key_hw_wallet_accounts": MessageLookupByLibrary.simpleMessage(
      "Contas da Carteira",
    ),
    "g_key_hw_yesterday": MessageLookupByLibrary.simpleMessage("Ontem"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Uma carteira de moeda atual já existe.",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "Não foi possível ler o Keystore",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage(
      "Armazenamento de chaves",
    ),
    "g_key_link_account": MessageLookupByLibrary.simpleMessage(
      "Vincular conta",
    ),
    "g_key_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "Contas vinculadas",
    ),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Entrar"),
    "g_key_login_success": MessageLookupByLibrary.simpleMessage(
      "Login bem-sucedido",
    ),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Sair"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Tem certeza que deseja sair do aplicativo?",
    ),
    "g_key_loyalty_available_points": MessageLookupByLibrary.simpleMessage(
      "Pontos Disponíveis",
    ),
    "g_key_loyalty_checked_today": MessageLookupByLibrary.simpleMessage(
      "Check-in hoje!",
    ),
    "g_key_loyalty_checkin_btn": MessageLookupByLibrary.simpleMessage(
      "Check-in",
    ),
    "g_key_loyalty_checkin_done": MessageLookupByLibrary.simpleMessage(
      "Concluído",
    ),
    "g_key_loyalty_checkin_failed": MessageLookupByLibrary.simpleMessage(
      "Falha no check-in, tente novamente",
    ),
    "g_key_loyalty_checkin_success": MessageLookupByLibrary.simpleMessage(
      "Check-in realizado com sucesso!",
    ),
    "g_key_loyalty_claim_points": MessageLookupByLibrary.simpleMessage(
      "Resgatar Pontos",
    ),
    "g_key_loyalty_complete_failed": MessageLookupByLibrary.simpleMessage(
      "Falha na tarefa, tente novamente",
    ),
    "g_key_loyalty_complete_success": MessageLookupByLibrary.simpleMessage(
      "Tarefa concluída!",
    ),
    "g_key_loyalty_copy": MessageLookupByLibrary.simpleMessage("Copiar"),
    "g_key_loyalty_daily_checkin": MessageLookupByLibrary.simpleMessage(
      "Check-in Diário",
    ),
    "g_key_loyalty_earn_points": m46,
    "g_key_loyalty_earned": MessageLookupByLibrary.simpleMessage("Ganho"),
    "g_key_loyalty_history": MessageLookupByLibrary.simpleMessage(
      "Histórico de Pontos",
    ),
    "g_key_loyalty_invite": MessageLookupByLibrary.simpleMessage("Convidar"),
    "g_key_loyalty_invite_bonus": m47,
    "g_key_loyalty_invite_friends": MessageLookupByLibrary.simpleMessage(
      "Convide amigos",
    ),
    "g_key_loyalty_invited_friends": MessageLookupByLibrary.simpleMessage(
      "Amigos Convidados",
    ),
    "g_key_loyalty_max_level": MessageLookupByLibrary.simpleMessage(
      "Nível máximo",
    ),
    "g_key_loyalty_next_prefix": MessageLookupByLibrary.simpleMessage(
      "Próximo",
    ),
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
    "g_key_loyalty_points_to_next": m48,
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
    "g_key_loyalty_share": MessageLookupByLibrary.simpleMessage("Compartilhar"),
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
      "Total ganho",
    ),
    "g_key_loyalty_total_points": MessageLookupByLibrary.simpleMessage(
      "Pontos Totais",
    ),
    "g_key_loyalty_used": MessageLookupByLibrary.simpleMessage("Usado"),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("Facebook"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("Twitter"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("Reddit"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("Navegador"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("Telegrama"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("Discórdia"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("YouTube"),
    "g_key_m_19": MessageLookupByLibrary.simpleMessage("Instagram"),
    "g_key_m_2": MessageLookupByLibrary.simpleMessage(
      "Capitalização de Mercado",
    ),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("Volume de Negociação"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("Fornecimento Total"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("Em Circulação"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("Sobre"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("Mais"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("Ligações"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("Site"),
    "g_key_manage_chains": MessageLookupByLibrary.simpleMessage(
      "Gerenciar cadeias",
    ),
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage(
      "Disponível",
    ),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "Requer piquetagem",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage(
      "Por favor, digite a frase de recuperação",
    ),
    "g_key_new_airdrops": MessageLookupByLibrary.simpleMessage(
      "Novos lançamentos aéreos",
    ),
    "g_key_new_password": MessageLookupByLibrary.simpleMessage("Nova senha"),
    "g_key_new_password_same_as_old": MessageLookupByLibrary.simpleMessage(
      "A nova senha deve ser diferente da senha atual",
    ),
    "g_key_next": MessageLookupByLibrary.simpleMessage("Próximo"),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("Total"),
    "g_key_nft_16": MessageLookupByLibrary.simpleMessage("Câmera"),
    "g_key_nft_17": MessageLookupByLibrary.simpleMessage("Selecionar foto"),
    "g_key_nft_18": MessageLookupByLibrary.simpleMessage("Conteúdo"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Nome"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Voltar"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage("Transação enviada"),
    "g_key_nft_47": MessageLookupByLibrary.simpleMessage("Selecionar vídeo"),
    "g_key_nft_address_invalid": MessageLookupByLibrary.simpleMessage(
      "Endereço de carteira inválido",
    ),
    "g_key_nft_balance": MessageLookupByLibrary.simpleMessage("Equilíbrio"),
    "g_key_nft_burn_confirm": MessageLookupByLibrary.simpleMessage(
      "Esta ação é irreversível. O NFT será enviado para o endereço de gravação.",
    ),
    "g_key_nft_burn_evm_only": MessageLookupByLibrary.simpleMessage(
      "Burn é compatível apenas com cadeias EVM",
    ),
    "g_key_nft_burn_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "A queima de Solana NFT chegará em breve",
    ),
    "g_key_nft_burn_title": MessageLookupByLibrary.simpleMessage("Queimar NFT"),
    "g_key_nft_collection": MessageLookupByLibrary.simpleMessage("Coleção"),
    "g_key_nft_contract": MessageLookupByLibrary.simpleMessage("Contrato"),
    "g_key_nft_description": MessageLookupByLibrary.simpleMessage("Descrição"),
    "g_key_nft_error_retry": MessageLookupByLibrary.simpleMessage(
      "Falha ao carregar NFTs. Toque para tentar novamente.",
    ),
    "g_key_nft_filter_all": MessageLookupByLibrary.simpleMessage("Todos"),
    "g_key_nft_filter_video": MessageLookupByLibrary.simpleMessage("Vídeo"),
    "g_key_nft_floor_price": MessageLookupByLibrary.simpleMessage("Piso"),
    "g_key_nft_gallery": MessageLookupByLibrary.simpleMessage("Galeria NFT"),
    "g_key_nft_inscription": MessageLookupByLibrary.simpleMessage(
      "Inscrição #",
    ),
    "g_key_nft_no_items": MessageLookupByLibrary.simpleMessage(
      "Nenhum NFT encontrado",
    ),
    "g_key_nft_no_url": MessageLookupByLibrary.simpleMessage(
      "Nenhum link do explorador disponível",
    ),
    "g_key_nft_no_video_support": MessageLookupByLibrary.simpleMessage(
      "A reprodução de vídeo não é suportada",
    ),
    "g_key_nft_open_browser": MessageLookupByLibrary.simpleMessage(
      "Ver no Explorer",
    ),
    "g_key_nft_ordinals": MessageLookupByLibrary.simpleMessage("Ordinais"),
    "g_key_nft_ordinals_unsupported": MessageLookupByLibrary.simpleMessage(
      "As transferências ordinais ainda não são suportadas",
    ),
    "g_key_nft_quantity": MessageLookupByLibrary.simpleMessage("Quantidade"),
    "g_key_nft_search_hint": MessageLookupByLibrary.simpleMessage(
      "Pesquise por nome ou coleção",
    ),
    "g_key_nft_send": MessageLookupByLibrary.simpleMessage("Enviar NFT"),
    "g_key_nft_send_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "As transferências Solana NFT chegarão em breve",
    ),
    "g_key_nft_token_id": MessageLookupByLibrary.simpleMessage("ID do token"),
    "g_key_nft_type": MessageLookupByLibrary.simpleMessage("Tipo"),
    "g_key_no_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "Nenhuma conta vinculada",
    ),
    "g_key_notification_settings": MessageLookupByLibrary.simpleMessage(
      "Configurações de notificação",
    ),
    "g_key_oidc_login": MessageLookupByLibrary.simpleMessage(
      "Login corporativo (SSO)",
    ),
    "g_key_oidc_not_configured": MessageLookupByLibrary.simpleMessage(
      "SSO empresarial não configurado",
    ),
    "g_key_old_password": MessageLookupByLibrary.simpleMessage("Senha atual"),
    "g_key_or": MessageLookupByLibrary.simpleMessage("ou"),
    "g_key_password_changed_success": MessageLookupByLibrary.simpleMessage(
      "Senha alterada com sucesso",
    ),
    "g_key_password_min_length": MessageLookupByLibrary.simpleMessage(
      "A senha deve ter pelo menos 6 caracteres",
    ),
    "g_key_password_req_different": MessageLookupByLibrary.simpleMessage(
      "Diferente da senha atual",
    ),
    "g_key_password_req_length": MessageLookupByLibrary.simpleMessage(
      "Pelo menos 6 caracteres",
    ),
    "g_key_password_required": MessageLookupByLibrary.simpleMessage(
      "A senha é obrigatória",
    ),
    "g_key_password_requirements": MessageLookupByLibrary.simpleMessage(
      "Requisitos de senha",
    ),
    "g_key_password_reset_success": MessageLookupByLibrary.simpleMessage(
      "Redefinição de senha com sucesso",
    ),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "As senhas não coincidem",
    ),
    "g_key_payment_amount_invalid": MessageLookupByLibrary.simpleMessage(
      "Valor inválido",
    ),
    "g_key_payment_approx_token": m49,
    "g_key_payment_approx_usdt": m50,
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
    "g_key_resend_code": MessageLookupByLibrary.simpleMessage(
      "Reenviar código",
    ),
    "g_key_reset": MessageLookupByLibrary.simpleMessage("Redefinir"),
    "g_key_reset_password": MessageLookupByLibrary.simpleMessage(
      "Redefinir senha",
    ),
    "g_key_reset_password_email_desc": MessageLookupByLibrary.simpleMessage(
      "Digite seu endereço de e-mail para receber um código de verificação",
    ),
    "g_key_saml_login": MessageLookupByLibrary.simpleMessage("Login SAML"),
    "g_key_saml_not_configured": MessageLookupByLibrary.simpleMessage(
      "SAML não configurado",
    ),
    "g_key_security_goplus_caution": MessageLookupByLibrary.simpleMessage(
      "Tenha cuidado",
    ),
    "g_key_security_goplus_checking": MessageLookupByLibrary.simpleMessage(
      "Verificando a segurança do contrato...",
    ),
    "g_key_security_goplus_danger": MessageLookupByLibrary.simpleMessage(
      "Alto risco detectado",
    ),
    "g_key_security_goplus_powered_by": MessageLookupByLibrary.simpleMessage(
      "Go Plus",
    ),
    "g_key_security_goplus_safe": MessageLookupByLibrary.simpleMessage(
      "Contrato verificado como seguro",
    ),
    "g_key_send_code": MessageLookupByLibrary.simpleMessage(
      "Enviar código de verificação",
    ),
    "g_key_send_memo_hint": MessageLookupByLibrary.simpleMessage(
      "Memorando / Nota",
    ),
    "g_key_send_memo_label": MessageLookupByLibrary.simpleMessage(
      "Memo/nota (opcional)",
    ),
    "g_key_set_new_password_desc": MessageLookupByLibrary.simpleMessage(
      "Defina sua nova senha",
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
      "Falha no login",
    ),
    "g_key_sim_gas_estimate": m51,
    "g_key_sim_reverted": MessageLookupByLibrary.simpleMessage(
      "A transação provavelmente falhará",
    ),
    "g_key_sim_reverted_reason": m52,
    "g_key_sim_simulating": MessageLookupByLibrary.simpleMessage(
      "Simulando transação…",
    ),
    "g_key_sim_success": MessageLookupByLibrary.simpleMessage(
      "Simulação de transação aprovada",
    ),
    "g_key_sim_unavailable": MessageLookupByLibrary.simpleMessage(
      "Simulação indisponível para esta rede",
    ),
    "g_key_social_login": MessageLookupByLibrary.simpleMessage("Login Social"),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Bate-papo"),
    "g_key_squad_k11": MessageLookupByLibrary.simpleMessage(
      "O arquivo é muito grande para upload",
    ),
    "g_key_squad_k15": m53,
    "g_key_squad_k18": MessageLookupByLibrary.simpleMessage(
      "Adicionar Contato",
    ),
    "g_key_squad_k24": MessageLookupByLibrary.simpleMessage("Contato"),
    "g_key_squad_k25": MessageLookupByLibrary.simpleMessage(
      "Pesquisar por e-mail",
    ),
    "g_key_stake_active": MessageLookupByLibrary.simpleMessage("Ativo"),
    "g_key_stake_active_positions": MessageLookupByLibrary.simpleMessage(
      "Posições Ativas",
    ),
    "g_key_stake_amount": MessageLookupByLibrary.simpleMessage("Quantidade"),
    "g_key_stake_amount_unstake": MessageLookupByLibrary.simpleMessage(
      "Valor a ser desembolsado",
    ),
    "g_key_stake_apy": MessageLookupByLibrary.simpleMessage("APY"),
    "g_key_stake_avg_apy": MessageLookupByLibrary.simpleMessage("APY médio"),
    "g_key_stake_claim": MessageLookupByLibrary.simpleMessage(
      "Resgatar Recompensas",
    ),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage("Comissão"),
    "g_key_stake_d_unbond": m54,
    "g_key_stake_days_left": m55,
    "g_key_stake_days_remaining": m56,
    "g_key_stake_delegators": MessageLookupByLibrary.simpleMessage(
      "Delegadores",
    ),
    "g_key_stake_estimated_daily": MessageLookupByLibrary.simpleMessage(
      "Est. Recompensa Diária",
    ),
    "g_key_stake_estimated_yearly": MessageLookupByLibrary.simpleMessage(
      "Est. Recompensa Anual",
    ),
    "g_key_stake_go_to_swap": MessageLookupByLibrary.simpleMessage(
      "Vá para Trocar",
    ),
    "g_key_stake_liquid": MessageLookupByLibrary.simpleMessage(
      "Staking Líquido",
    ),
    "g_key_stake_liquid_staking_label": MessageLookupByLibrary.simpleMessage(
      "Estacamento Líquido",
    ),
    "g_key_stake_liquid_tag": MessageLookupByLibrary.simpleMessage("Líquido"),
    "g_key_stake_liquid_unstake_desc": MessageLookupByLibrary.simpleMessage(
      "Seu token líquido pode ser negociado diretamente no DEX. Use Swap para trocá-lo de volta pelo ativo nativo.",
    ),
    "g_key_stake_min_stake": MessageLookupByLibrary.simpleMessage(
      "Stake Mínimo",
    ),
    "g_key_stake_no_active_positions": MessageLookupByLibrary.simpleMessage(
      "Nenhuma posição ativa para desempacotar",
    ),
    "g_key_stake_no_lock": MessageLookupByLibrary.simpleMessage("Sem bloqueio"),
    "g_key_stake_no_positions": MessageLookupByLibrary.simpleMessage(
      "Sem posições de staking",
    ),
    "g_key_stake_no_positions_yet": MessageLookupByLibrary.simpleMessage(
      "Ainda não há posições de piquetagem",
    ),
    "g_key_stake_no_validators": MessageLookupByLibrary.simpleMessage(
      "Nenhum validador encontrado",
    ),
    "g_key_stake_no_wallet": MessageLookupByLibrary.simpleMessage(
      "Endereço da carteira não disponível",
    ),
    "g_key_stake_overview": MessageLookupByLibrary.simpleMessage(
      "Visão geral do total de apostas",
    ),
    "g_key_stake_pending_rewards": MessageLookupByLibrary.simpleMessage(
      "Recompensas Pendentes",
    ),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage(
      "Minhas Posições",
    ),
    "g_key_stake_protocol": MessageLookupByLibrary.simpleMessage("Protocolo"),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("Protocolos"),
    "g_key_stake_restake": MessageLookupByLibrary.simpleMessage(
      "Refazer Stake",
    ),
    "g_key_stake_rewards": MessageLookupByLibrary.simpleMessage("Recompensas"),
    "g_key_stake_search_validator": MessageLookupByLibrary.simpleMessage(
      "Pesquisar validadores...",
    ),
    "g_key_stake_select_a_validator": MessageLookupByLibrary.simpleMessage(
      "Selecione um validador",
    ),
    "g_key_stake_select_position": MessageLookupByLibrary.simpleMessage(
      "Selecione uma posição para desstake",
    ),
    "g_key_stake_select_validator": MessageLookupByLibrary.simpleMessage(
      "Selecionar Validador",
    ),
    "g_key_stake_sort_by": MessageLookupByLibrary.simpleMessage(
      "Classificar por",
    ),
    "g_key_stake_stake": MessageLookupByLibrary.simpleMessage("Fazer Stake"),
    "g_key_stake_staked": MessageLookupByLibrary.simpleMessage("Apostado"),
    "g_key_stake_start_staking": MessageLookupByLibrary.simpleMessage(
      "Comece a apostar",
    ),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("Estacamento"),
    "g_key_stake_total_staked": MessageLookupByLibrary.simpleMessage(
      "Total em Stake",
    ),
    "g_key_stake_tx_prepared": MessageLookupByLibrary.simpleMessage(
      "Transação preparada com sucesso",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage(
      "Desbloqueando",
    ),
    "g_key_stake_unbonding_period": MessageLookupByLibrary.simpleMessage(
      "Período de Desbloqueio",
    ),
    "g_key_stake_unbonding_warning": m57,
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage(
      "Desfazer Stake",
    ),
    "g_key_stake_updating": MessageLookupByLibrary.simpleMessage(
      "Atualizando...",
    ),
    "g_key_stake_uptime": MessageLookupByLibrary.simpleMessage("Tempo Ativo"),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("Validador"),
    "g_key_stake_validators": MessageLookupByLibrary.simpleMessage(
      "Validadores",
    ),
    "g_key_stake_you_receive": MessageLookupByLibrary.simpleMessage(
      "Você receberá",
    ),
    "g_key_step_email": MessageLookupByLibrary.simpleMessage("E-mail"),
    "g_key_step_password": MessageLookupByLibrary.simpleMessage("Senha"),
    "g_key_step_verify": MessageLookupByLibrary.simpleMessage("Verifique"),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Concluído"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Preço do gás"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("Taxa máxima de gás"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage("Taxa máxima por gás"),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("Pendente"),
    "g_key_t_29": m58,
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
    "g_key_t_45": m59,
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
    "g_key_t_52": m60,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "O endereço de recebimento não possui conta, e a primeira transferência deve ser de pelo menos 10XRP",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Gás Utilizado"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Gás"),
    "g_key_time_days_ago": m61,
    "g_key_time_hours_ago": m62,
    "g_key_time_just_now": MessageLookupByLibrary.simpleMessage("Agora mesmo"),
    "g_key_time_minutes_ago": m63,
    "g_key_token_discovery_add": MessageLookupByLibrary.simpleMessage(
      "Adicionar",
    ),
    "g_key_token_discovery_add_selected": m64,
    "g_key_token_discovery_added": MessageLookupByLibrary.simpleMessage(
      "Token adicionado",
    ),
    "g_key_token_discovery_banner": m65,
    "g_key_token_discovery_deselect_all": MessageLookupByLibrary.simpleMessage(
      "Desmarcar tudo",
    ),
    "g_key_token_discovery_empty": MessageLookupByLibrary.simpleMessage(
      "Nenhum novo token encontrado",
    ),
    "g_key_token_discovery_ignore": MessageLookupByLibrary.simpleMessage(
      "Ignorar",
    ),
    "g_key_token_discovery_select_all": MessageLookupByLibrary.simpleMessage(
      "Selecionar tudo",
    ),
    "g_key_token_discovery_title": MessageLookupByLibrary.simpleMessage(
      "Tokens descobertos",
    ),
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
      "Data de início",
    ),
    "g_key_tx_filter_date_range": MessageLookupByLibrary.simpleMessage(
      "Período",
    ),
    "g_key_tx_filter_date_to": MessageLookupByLibrary.simpleMessage(
      "Data de término",
    ),
    "g_key_tx_filter_direction": MessageLookupByLibrary.simpleMessage(
      "Direção",
    ),
    "g_key_tx_no_results": MessageLookupByLibrary.simpleMessage(
      "Nenhuma transação corresponde ao seu filtro",
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
      "Desvincular conta",
    ),
    "g_key_user_p1": MessageLookupByLibrary.simpleMessage("Li e aceito os "),
    "g_key_user_p2": MessageLookupByLibrary.simpleMessage("Termos e Condições"),
    "g_key_user_p3": MessageLookupByLibrary.simpleMessage(
      "Política de Privacidade e Declaração de Coleta de Informações Pessoais",
    ),
    "g_key_uuid": MessageLookupByLibrary.simpleMessage("UUID"),
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
      "Código de verificação",
    ),
    "g_key_verification_code_sent": m66,
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
    "g_key_wallet_m1": m67,
    "g_key_wallet_m11": MessageLookupByLibrary.simpleMessage(
      "Tem certeza que deseja cancelar sua conta?",
    ),
    "g_key_wallet_m13": MessageLookupByLibrary.simpleMessage(
      "Confirmar logout",
    ),
    "g_key_wallet_m17": MessageLookupByLibrary.simpleMessage(
      "Por favor, digite o código de verificação do Google.",
    ),
    "g_key_wallet_m19": m68,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "O token atual não foi adicionado.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Digite sua frase de recuperação com palavras separadas por espaços",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage(
      "Importar Carteira",
    ),
    "g_key_wallet_m3": m69,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "O saldo do token atual é insuficiente.",
    ),
    "g_key_wallet_m5": m70,
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
    "g_key_watch_address_hint": MessageLookupByLibrary.simpleMessage(
      "Insira o endereço Ethereum (0x...)",
    ),
    "g_key_watch_only_banner": MessageLookupByLibrary.simpleMessage(
      "Somente assistir",
    ),
    "g_key_watch_only_cant_send": MessageLookupByLibrary.simpleMessage(
      "A carteira somente para observação não pode enviar ou assinar transações",
    ),
    "g_key_watch_wallet": MessageLookupByLibrary.simpleMessage(
      "Assistir carteira",
    ),
    "g_key_watch_wallet_desc": MessageLookupByLibrary.simpleMessage(
      "Rastreie qualquer endereço EVM sem chave privada",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("Reservado"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("Reserva Base"),
    "g_key_xml_11": m71,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("Reserva Incremental"),
    "g_key_xml_22": m72,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "Contagem de Objetos Possuídos",
    ),
    "g_key_xml_33": m73,
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
    "g_lock_key21": m74,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Redefinir a senha de padrão",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Muitas tentativas incorretas, por favor redefina a senha",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "Adicionar Senha da Carteira?",
    ),
    "g_lock_key25": m75,
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
    "g_market_30d_change": MessageLookupByLibrary.simpleMessage("Mudança 30D"),
    "g_market_7d_change": MessageLookupByLibrary.simpleMessage("Mudança 7D"),
    "g_market_ath": MessageLookupByLibrary.simpleMessage("ATH"),
    "g_market_atl": MessageLookupByLibrary.simpleMessage("ATL"),
    "g_market_depth": MessageLookupByLibrary.simpleMessage(
      "Profundidade do mercado",
    ),
    "g_market_empty_watchlist": MessageLookupByLibrary.simpleMessage(
      "Ainda não há lista de observação",
    ),
    "g_market_empty_watchlist_hint": MessageLookupByLibrary.simpleMessage(
      "Toque em ★ em qualquer moeda para adicionar",
    ),
    "g_market_fdv": MessageLookupByLibrary.simpleMessage("FDV"),
    "g_market_high_24h": MessageLookupByLibrary.simpleMessage("Alto 24H"),
    "g_market_liquidity_score": MessageLookupByLibrary.simpleMessage(
      "Pontuação de liquidez",
    ),
    "g_market_low_24h": MessageLookupByLibrary.simpleMessage("Baixo 24H"),
    "g_market_news": MessageLookupByLibrary.simpleMessage("Notícias"),
    "g_market_no_chart": MessageLookupByLibrary.simpleMessage(
      "Nenhum dado do gráfico",
    ),
    "g_market_no_results": MessageLookupByLibrary.simpleMessage(
      "Nenhum resultado",
    ),
    "g_market_rank": MessageLookupByLibrary.simpleMessage("Classificação"),
    "g_market_search": MessageLookupByLibrary.simpleMessage("Pesquisar"),
    "g_market_search_hint": MessageLookupByLibrary.simpleMessage(
      "Pesquisar moedas...",
    ),
    "g_market_trending": MessageLookupByLibrary.simpleMessage("Tendências"),
    "g_market_watchlist": MessageLookupByLibrary.simpleMessage(
      "Lista de observação",
    ),
    "g_mining_inactivity_warning": MessageLookupByLibrary.simpleMessage(
      "A pontuação de inatividade do validador está alta. Verifique o status do seu nó para evitar penalidades.",
    ),
    "g_mining_key15": MessageLookupByLibrary.simpleMessage("Detalhe da tarefa"),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("Desbloquear N?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage(
      "Atividade de Verificação na Nuvem",
    ),
    "g_mining_key33": MessageLookupByLibrary.simpleMessage(
      "Configurações de verificação",
    ),
    "g_mining_key34": MessageLookupByLibrary.simpleMessage(
      "Música de verificação de fundo",
    ),
    "g_mining_key35": MessageLookupByLibrary.simpleMessage("Padrão"),
    "g_mining_key36": MessageLookupByLibrary.simpleMessage("Mudo"),
    "g_mining_key37": MessageLookupByLibrary.simpleMessage(
      "Quando a verificação em segundo plano estiver ativada, a música será reproduzida em segundo plano. Se a música parar, a verificação também será interrompida.",
    ),
    "g_mining_key38": MessageLookupByLibrary.simpleMessage("Seu nível"),
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
    "g_mining_key63": m76,
    "g_mining_key7": MessageLookupByLibrary.simpleMessage(
      "Data de desbloqueio",
    ),
    "g_mining_key73": m77,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "Acabei de configurar um nó na @N42Wallet e comecei a verificação em dispositivos móveis! Venha se juntar a mim. O futuro descentralizado é móvel!",
    ),
    "g_mining_key76": m78,
    "g_mining_key82": MessageLookupByLibrary.simpleMessage("mineral"),
    "g_mining_key83": MessageLookupByLibrary.simpleMessage("Nó"),
    "g_mining_key84": MessageLookupByLibrary.simpleMessage("Rede"),
    "g_mining_key85": MessageLookupByLibrary.simpleMessage(
      "Alterne entre testnet e mainnet para mineração em nuvem.",
    ),
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "Resgate disponível após 768s.",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "Solicitações antes disso não serão processadas.",
    ),
    "g_mining_key_1": MessageLookupByLibrary.simpleMessage("Página inicial"),
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
    "g_mining_key_109": m79,
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
    "g_mining_key_116": m80,
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "A recompensa acumula diariamente e só é enviada para sua carteira N quando atinge ~0,5 N.",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage(
      "Total de Recompensas",
    ),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("Valor Minerado"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage(
      "Detalhe da tarefa",
    ),
    "g_mining_key_19": MessageLookupByLibrary.simpleMessage("Resumo"),
    "g_mining_key_2": MessageLookupByLibrary.simpleMessage("Atividades"),
    "g_mining_key_20": MessageLookupByLibrary.simpleMessage(
      "Valor total extraído",
    ),
    "g_mining_key_21": MessageLookupByLibrary.simpleMessage(
      "Verificação desde",
    ),
    "g_mining_key_22": MessageLookupByLibrary.simpleMessage(
      "Distribuição de recompensas",
    ),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage("Número de lucros"),
    "g_mining_key_24": MessageLookupByLibrary.simpleMessage("Valor verificado"),
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
    "g_mining_key_45": MessageLookupByLibrary.simpleMessage(
      "Tem certeza de que deseja pular?",
    ),
    "g_mining_key_46": MessageLookupByLibrary.simpleMessage(
      "Você não receberá nenhuma recompensa de verificação até escolher um dos planos.",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Desativado"),
    "g_mining_key_48": MessageLookupByLibrary.simpleMessage("Recompensa"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("Ver mais"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage(
      "Status da Verificação",
    ),
    "g_mining_key_50": MessageLookupByLibrary.simpleMessage("Para desbloquear"),
    "g_mining_key_52": MessageLookupByLibrary.simpleMessage("Pular"),
    "g_mining_key_58": MessageLookupByLibrary.simpleMessage("Últimos 7 dias"),
    "g_mining_key_59": MessageLookupByLibrary.simpleMessage(
      "Recompensas acumuladas",
    ),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Bloqueie N para começar a receber recompensas de verificação.",
    ),
    "g_mining_key_60": MessageLookupByLibrary.simpleMessage(
      "Recompensas recebidas",
    ),
    "g_mining_key_61": MessageLookupByLibrary.simpleMessage("Avançado"),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Entrada"),
    "g_mining_key_63": MessageLookupByLibrary.simpleMessage("Pró"),
    "g_mining_key_64": MessageLookupByLibrary.simpleMessage("NÓ COMPLETO"),
    "g_mining_key_65": MessageLookupByLibrary.simpleMessage("MINUTOS/DIA"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("Nó Avançado"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("Nó Inicial"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Nó Pro"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 blocos/dia~70 mins",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage(
      "Data de desbloqueio",
    ),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 blocos/dia~15 mins",
    ),
    "g_mining_key_71": m81,
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
    "g_mining_key_8": MessageLookupByLibrary.simpleMessage(
      "Hora de verificação de hoje",
    ),
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
    "g_mining_key_98": m82,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "Por favor, digite novamente sua senha para confirmar",
    ),
    "g_mining_node_key1": MessageLookupByLibrary.simpleMessage(
      "Detalhes do Nó Completo",
    ),
    "g_mining_node_key2": MessageLookupByLibrary.simpleMessage("ID do Nó"),
    "g_mining_node_key3": MessageLookupByLibrary.simpleMessage("WS Conectado"),
    "g_mining_node_key4": MessageLookupByLibrary.simpleMessage(
      "WS Desconectado",
    ),
    "g_mining_node_key5": MessageLookupByLibrary.simpleMessage(
      "WS Reconectando",
    ),
    "g_mining_node_key6": MessageLookupByLibrary.simpleMessage("Expiração"),
    "g_mining_unlock_period": MessageLookupByLibrary.simpleMessage(
      "Período de Desbloqueio:",
    ),
    "g_mining_unlockable_anytime": MessageLookupByLibrary.simpleMessage(
      "Desbloqueável a qualquer momento",
    ),
    "g_news_empty": MessageLookupByLibrary.simpleMessage(
      "Nenhuma notícia disponível",
    ),
    "g_news_source": MessageLookupByLibrary.simpleMessage("Fonte"),
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
    "g_pnl_add_trade": MessageLookupByLibrary.simpleMessage(
      "Adicionar negociação",
    ),
    "g_pnl_avg_cost": MessageLookupByLibrary.simpleMessage("Custo médio"),
    "g_pnl_buy_price_usd": MessageLookupByLibrary.simpleMessage(
      "Preço de compra (USD)",
    ),
    "g_pnl_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "g_pnl_cost_basis": MessageLookupByLibrary.simpleMessage("Base de custo"),
    "g_pnl_no_trades": MessageLookupByLibrary.simpleMessage(
      "Nenhuma negociação registrada",
    ),
    "g_pnl_quantity": MessageLookupByLibrary.simpleMessage("Quantidade"),
    "g_pnl_save": MessageLookupByLibrary.simpleMessage("Salvar"),
    "g_pnl_unrealized": MessageLookupByLibrary.simpleMessage(
      "Lucros e perdas não realizados",
    ),
    "g_portfolio_24h": MessageLookupByLibrary.simpleMessage("Mudança 24h"),
    "g_portfolio_all_holdings": MessageLookupByLibrary.simpleMessage(
      "Todos os ativos",
    ),
    "g_portfolio_allocation": MessageLookupByLibrary.simpleMessage(
      "Alocação de ativos",
    ),
    "g_portfolio_gainers": MessageLookupByLibrary.simpleMessage(
      "Principais ganhadores",
    ),
    "g_portfolio_losers": MessageLookupByLibrary.simpleMessage(
      "Maiores perdas",
    ),
    "g_portfolio_movers": MessageLookupByLibrary.simpleMessage(
      "Transportadores 24h",
    ),
    "g_portfolio_no_assets": MessageLookupByLibrary.simpleMessage(
      "Nenhum recurso encontrado",
    ),
    "g_portfolio_others": MessageLookupByLibrary.simpleMessage("Outros"),
    "g_portfolio_pie_total": MessageLookupByLibrary.simpleMessage("Total"),
    "g_portfolio_title": MessageLookupByLibrary.simpleMessage("Portfólio"),
    "g_portfolio_total": MessageLookupByLibrary.simpleMessage("Valor total"),
    "g_referral_downloaded": MessageLookupByLibrary.simpleMessage("Baixado"),
    "g_referral_invite_code": MessageLookupByLibrary.simpleMessage(
      "Código de convite",
    ),
    "g_referral_invited": MessageLookupByLibrary.simpleMessage("Convidados"),
    "g_referral_mining": MessageLookupByLibrary.simpleMessage(
      "Nós de mineração",
    ),
    "g_referral_reward": MessageLookupByLibrary.simpleMessage("Recompensa (N)"),
    "g_referral_stats_title": MessageLookupByLibrary.simpleMessage(
      "Estatísticas de indicação",
    ),
    "g_setting_mining_v1_label": MessageLookupByLibrary.simpleMessage(
      "Mineração Clássica (V1)",
    ),
    "g_setting_mining_v2_label": MessageLookupByLibrary.simpleMessage(
      "Mineração (V2)",
    ),
    "g_setting_mining_version": MessageLookupByLibrary.simpleMessage(
      "Interface de Mineração",
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
    "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("Ligação"),
    "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("código"),
    "g_swap_key_14": m83,
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
    "g_swap_key_20": m84,
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
    "g_swap_key_31": m85,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "Trocas podem ser visualizadas nos exploradores de blockchain relevantes (Etherscan, BscScan, TRONSCAN e o nosso próprio).",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Trocar para N"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("Trocar"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("Você recebe"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("Prévia da Troca"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("Tentar novamente"),
    "g_theme_accent_color": MessageLookupByLibrary.simpleMessage(
      "Cor de destaque",
    ),
    "g_theme_accent_reset": MessageLookupByLibrary.simpleMessage(
      "Redefinir para o padrão",
    ),
    "g_token_m_key_1": m86,
    "g_token_m_key_10": MessageLookupByLibrary.simpleMessage(
      "Qualquer pessoa pode criar um token, incluindo versões falsas de tokens existentes. Sempre pesquise um token antes de importá-lo.",
    ),
    "g_token_m_key_11": MessageLookupByLibrary.simpleMessage("Fichas"),
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
    "g_token_m_key_22": m87,
    "g_token_m_key_23": m88,
    "g_token_m_key_24": m89,
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
    "g_tx_risk_caution": MessageLookupByLibrary.simpleMessage("Cuidado"),
    "g_tx_risk_danger": MessageLookupByLibrary.simpleMessage("Alto Risco"),
    "g_tx_risk_safe": MessageLookupByLibrary.simpleMessage("Seguro"),
    "g_unlock_key10": m90,
    "g_unlock_key2": MessageLookupByLibrary.simpleMessage(
      "Impressão digital ou reconhecimento facial não está ativado?",
    ),
    "g_unlock_key3": MessageLookupByLibrary.simpleMessage(
      "Desenhar senha de padrão",
    ),
    "g_unlock_key4": m91,
    "g_unlock_key5": MessageLookupByLibrary.simpleMessage("Digite a senha"),
    "g_unlock_key6": m92,
    "g_unlock_key7": MessageLookupByLibrary.simpleMessage(
      "Falha na autenticação",
    ),
    "g_unlock_key8": m93,
    "g_unlock_key9": MessageLookupByLibrary.simpleMessage("Você também pode "),
    "g_version_later": MessageLookupByLibrary.simpleMessage("Mais tarde"),
    "g_wc_connection_lost": MessageLookupByLibrary.simpleMessage(
      "Conexão perdida. Por favor, reconecte.",
    ),
    "g_wc_dapp_disconnected": MessageLookupByLibrary.simpleMessage(
      "O DApp desconectou",
    ),
    "g_wc_disconnect_all": MessageLookupByLibrary.simpleMessage(
      "Desconectar tudo",
    ),
    "g_wc_disconnect_all_confirm": MessageLookupByLibrary.simpleMessage(
      "Desconectar de todos os DApps?",
    ),
    "g_wc_disconnect_confirm": MessageLookupByLibrary.simpleMessage(
      "Desconectar deste DApp?",
    ),
    "g_wc_new_connection": MessageLookupByLibrary.simpleMessage("Nova conexão"),
    "g_wc_no_sessions": MessageLookupByLibrary.simpleMessage(
      "Sem conexões ativas",
    ),
    "g_wc_no_sessions_desc": MessageLookupByLibrary.simpleMessage(
      "Escaneie um código QR para conectar a um DApp",
    ),
    "g_wc_proposal_timeout": MessageLookupByLibrary.simpleMessage(
      "A solicitação de conexão expirou",
    ),
    "g_wc_session_expired": MessageLookupByLibrary.simpleMessage(
      "A sessão expirou",
    ),
    "g_wc_sessions": MessageLookupByLibrary.simpleMessage("DApps conectados"),
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
    "google_verification_message21": m94,
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
    "nicknameMessage": m95,
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
    "push_permission_btn_dismiss": MessageLookupByLibrary.simpleMessage(
      "Não lembrar mais",
    ),
    "push_permission_btn_later": MessageLookupByLibrary.simpleMessage(
      "Mais tarde",
    ),
    "push_permission_btn_settings": MessageLookupByLibrary.simpleMessage(
      "Ir para Definições",
    ),
    "push_permission_dialog_content": MessageLookupByLibrary.simpleMessage(
      "As notificações push estão desativadas. Pode perder mensagens de chat e alertas de transferência.\n\nActive as notificações para esta aplicação nas definições do sistema.",
    ),
    "push_permission_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Notificações desativadas",
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

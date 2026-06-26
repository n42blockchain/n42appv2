// ignore_for_file: invalid_use_of_protected_member
part of 'chat_page.dart';

/// 消息事件处理相关方法（消息点击、头像、红包、名片、位置、媒体查看等）
extension _ChatPageEventHandlersMethods on _ChatPageState {
  Future<void> _openChatHistorySearch({String initialQuery = ''}) async {
    final selectedMessageId = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => BlocProvider<SearchBloc>(
          create: (_) => getIt<SearchBloc>(),
          child: ChatSearchPage(
            roomId: widget.conversation.id,
            initialQuery: initialQuery,
            returnSelectedMessageId: true,
          ),
        ),
      ),
    );

    if (!mounted || selectedMessageId == null || selectedMessageId.isEmpty) {
      return;
    }

    await _scrollToMessage(selectedMessageId);
  }

  void _onMessageTap(MessageEntity message) {
    // 阅后即焚消息：接收方首次查看时触发销毁倒计时
    if (message.isSelfDestructing &&
        !message.isDestructionStarted &&
        !message.isFromMe) {
      context.read<ChatBloc>().add(StartMessageDestruction(message.id));
    }

    // 处理消息点击（如查看图片、播放视频、播放语音等）
    switch (message.type) {
      case MessageType.image:
        _viewImage(message);
        break;
      case MessageType.video:
        _playVideo(message);
        break;
      case MessageType.audio:
        // 语音消息在 MessageItem 内部处理
        break;
      case MessageType.file:
        _openFile(message);
        break;
      case MessageType.location:
        _viewLocation(message);
        break;
      case MessageType.music:
        _playMusic(message);
        break;
      case MessageType.transfer:
        _onTransferTap(message);
        break;
      case MessageType.paymentRequest:
        _onPaymentRequestTap(message);
        break;
      default:
        break;
    }
  }

  /// 播放音乐
  void _playMusic(MessageEntity message) {
    final url = message.metadata?.musicUrl;
    if (url != null && url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri == null) return;
      // 只允许 http/https scheme，防止恶意 URL
      if (uri.scheme != 'http' && uri.scheme != 'https') return;
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// 红包消息点击
  void _onRedPacketTap(MessageEntity message) {
    final metadata = message.metadata;
    final status = metadata?.transferStatus ?? 'pending';
    final greeting = message.content.isNotEmpty
        ? message.content
        : (S.of(context)?.chatRedPacketGreeting ?? 'Best wishes');
    final amount = metadata?.amount;
    final token = metadata?.token ?? 'CNY';
    final redPacketId = metadata?.redPacketId ?? message.id;

    // 获取发送者显示名称（优先使用备注名）
    final senderName = RemarkService.instance.getDisplayName(
      message.senderId,
      message.senderName,
    );

    // 判断红包状态
    OpenRedPacketStatus redPacketStatus;
    switch (status) {
      case 'opened':
        redPacketStatus = OpenRedPacketStatus.opened;
        break;
      case 'expired':
        redPacketStatus = OpenRedPacketStatus.expired;
        break;
      case 'empty':
        redPacketStatus = OpenRedPacketStatus.empty;
        break;
      default:
        redPacketStatus = OpenRedPacketStatus.canOpen;
    }

    // 如果已经领取，直接显示红包详情页
    if (redPacketStatus == OpenRedPacketStatus.opened) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => RedPacketDetailPage(
            senderName: senderName,
            senderAvatar: message.senderAvatarUrl,
            greeting: greeting,
            claimedAmount: amount,
            token: token,
            isClaimed: true,
            claimers: [
              // 当前用户作为领取者
              RedPacketClaimer(
                name: _getDisplayName(),
                amount: amount ?? '0',
                claimTime: _formatTime(DateTime.now()),
              ),
            ],
          ),
        ),
      );
      return;
    }

    // 显示开红包弹窗
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => OpenRedPacketDialog(
        senderName: senderName,
        senderAvatar: message.senderAvatarUrl,
        greeting: greeting,
        status: redPacketStatus,
        claimedAmount: amount,
        token: token,
        onOpen: () async {
          try {
            final redPacketService = getIt<IRedPacketService>();
            final currentUserId =
                await getIt<IMessageRepository>().getCurrentUserId() ?? '';
            final claim = await redPacketService.claimRedPacket(
              redPacketId: redPacketId,
              userId: currentUserId,
              userName: _getDisplayName(),
            );
            if (claim != null && mounted && ctx.mounted) {
              Navigator.of(ctx).pop();
              if (!mounted) return;
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => RedPacketDetailPage(
                    senderName: senderName,
                    senderAvatar: message.senderAvatarUrl,
                    greeting: greeting,
                    claimedAmount: claim.amount.toStringAsFixed(2),
                    token: token,
                    isClaimed: true,
                    claimers: [
                      RedPacketClaimer(
                        name: _getDisplayName(),
                        amount: claim.amount.toStringAsFixed(2),
                        claimTime: _formatTime(claim.claimedAt),
                      ),
                    ],
                  ),
                ),
              );
            }
          } catch (e) {
            debugLog('Red packet claim error: $e');
          }
        },
        onViewDetails: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => RedPacketDetailPage(
                senderName: senderName,
                senderAvatar: message.senderAvatarUrl,
                greeting: greeting,
                claimedAmount: amount,
                token: token,
                isClaimed: true,
                claimers: [
                  RedPacketClaimer(
                    name: _getDisplayName(),
                    amount: amount ?? '0',
                    claimTime: _formatTime(DateTime.now()),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onPaymentRequestTap(MessageEntity message) async {
    final metadata = message.metadata;
    final requestId = metadata?.paymentRequestId;
    final receiverAddress = metadata?.paymentReceiverAddress;
    final amount = metadata?.amount;
    final token = metadata?.token;
    final paymentStatus = resolvePaymentRequestStatus(metadata);

    if (requestId == null ||
        requestId.isEmpty ||
        receiverAddress == null ||
        receiverAddress.isEmpty ||
        amount == null ||
        amount.isEmpty ||
        token == null ||
        token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment request is unavailable'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (paymentStatus == PaymentRequestLifecycleStatus.paid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment already sent')));
      return;
    }

    if (paymentStatus == PaymentRequestLifecycleStatus.expired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context)?.commonExpired ?? 'Expired'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (message.isFromMe) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.commonWaitingToReceive ?? 'Waiting to receive',
          ),
        ),
      );
      return;
    }

    final roomTransfers = await getIt<ITransferRepository>().getTransfersByRoom(
      widget.conversation.id,
    );
    final existingFulfillment = roomTransfers.where((transfer) {
      if (transfer.memo != '支付请求: $requestId') {
        return false;
      }
      return transfer.status == TransferStatus.pending ||
          transfer.status == TransferStatus.completed;
    }).toList();

    if (!mounted) return;

    if (existingFulfillment.isNotEmpty) {
      final hasCompleted = existingFulfillment.any(
        (transfer) => transfer.status == TransferStatus.completed,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasCompleted ? 'Payment already sent' : 'Payment is processing',
          ),
        ),
      );
      return;
    }

    final paymentRequest = PaymentRequest(
      requestId: requestId,
      amount: amount,
      token: token,
      receiverAddress: receiverAddress,
      memo: message.content.isNotEmpty ? message.content : null,
      qrCodeData: receiverAddress,
      createdAt: message.timestamp,
      expiresAt: metadata?.paymentRequestExpiresAt,
    );

    if (!mounted) return;

    await Navigator.of(context).push<TransferEntity>(
      MaterialPageRoute<TransferEntity>(
        builder: (_) => BlocProvider(
          create: (_) => getIt<TransferBloc>(),
          child: TransferPage(
            roomId: widget.conversation.id,
            recipientAddress: receiverAddress,
            recipientName: RemarkService.instance.getDisplayName(
              message.senderId,
              message.senderName,
            ),
            paymentRequest: paymentRequest,
          ),
        ),
      ),
    );
  }

  Future<void> _onTransferTap(MessageEntity message) async {
    final metadata = message.metadata;
    final amount = metadata?.amount ?? '--';
    final token = metadata?.token ?? '--';
    final status = metadata?.transferStatus ?? 'pending';
    final txHash = metadata?.txHash;

    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context)?.commonTransfer ?? 'Transfer',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$amount $token',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Status: $status',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (txHash?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                SelectableText(txHash!),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: txHash));
                    if (!ctx.mounted || !mounted) return;
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(S.of(context)?.chatCopied ?? 'Copied'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: Text(S.of(context)?.chatCopied ?? 'Copy tx hash'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 名片消息点击 - 跳转到用户资料页添加好友
  void _onContactCardTap(
    String contactId,
    String contactName,
    String? avatarUrl,
  ) {
    debugLog(
      'Contact card tapped: $contactName ($contactId), avatar: $avatarUrl',
    );

    // 获取当前的 ContactBloc
    ContactBloc? contactBloc;
    try {
      contactBloc = context.read<ContactBloc>();
    } catch (e) {
      // ContactBloc 可能不可用
      debugLog('Error: $e');
    }

    // 跳转到联系人详情页面
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) {
          final page = ContactDetailPage(
            userId: contactId,
            displayName: contactName,
            avatarUrl: avatarUrl,
            onSendMessage: () {
              Navigator.of(ctx).pop();
            },
          );

          // 如果有 ContactBloc，传递它
          if (contactBloc != null) {
            return BlocProvider.value(value: contactBloc, child: page);
          }
          return page;
        },
      ),
    );
  }

  /// 查看图片
  void _viewImage(MessageEntity message) {
    String? imageUrl = message.metadata?.httpUrl;

    // 如果 httpUrl 为空，尝试从 mediaUrl 转换
    if (imageUrl == null || imageUrl.isEmpty) {
      final mxcUrl = message.metadata?.mediaUrl;
      if (mxcUrl != null && mxcUrl.startsWith('mxc://')) {
        imageUrl = _convertMxcToHttpUrl(mxcUrl);
      }
    }

    if (imageUrl == null || imageUrl.isEmpty) {
      debugLog('_viewImage: No valid URL found for image');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            ImageViewerPage(imageUrl: imageUrl!, heroTag: message.id),
      ),
    );
  }

  /// 播放视频
  void _playVideo(MessageEntity message) {
    debugLog('=== _playVideo called ===');
    debugLog('Message ID: ${message.id}');
    debugLog('Message type: ${message.type}');
    debugLog('Metadata httpUrl: ${message.metadata?.httpUrl}');
    debugLog('Metadata mediaUrl: ${message.metadata?.mediaUrl}');
    debugLog('Metadata thumbnailUrl: ${message.metadata?.thumbnailUrl}');

    String? videoUrl = message.metadata?.httpUrl;

    // 如果 httpUrl 为空，尝试从 mediaUrl 转换
    if (videoUrl == null || videoUrl.isEmpty) {
      final mxcUrl = message.metadata?.mediaUrl;
      debugLog('httpUrl is empty, trying to convert from mxcUrl: $mxcUrl');
      if (mxcUrl != null && mxcUrl.startsWith('mxc://')) {
        videoUrl = _convertMxcToHttpUrl(mxcUrl);
        debugLog('Converted to httpUrl: $videoUrl');
      }
    }

    if (videoUrl == null || videoUrl.isEmpty) {
      debugLog('ERROR: Video URL is still empty after conversion attempt');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.chatInvalidVideoUrl ?? 'Invalid video URL',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // 也转换缩略图 URL
    String? thumbnailUrl = message.metadata?.thumbnailUrl;
    if (thumbnailUrl != null && thumbnailUrl.startsWith('mxc://')) {
      thumbnailUrl = _convertMxcToHttpUrl(thumbnailUrl);
    }
    debugLog('Final videoUrl: $videoUrl');
    debugLog('Final thumbnailUrl: $thumbnailUrl');

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            VideoPlayerPage(videoUrl: videoUrl!, thumbnailUrl: thumbnailUrl),
      ),
    );
  }

  /// 打开文件
  void _openFile(MessageEntity message) {
    String? fileUrl = message.metadata?.httpUrl;

    // 如果 httpUrl 为空，尝试从 mediaUrl 转换
    if (fileUrl == null || fileUrl.isEmpty) {
      final mxcUrl = message.metadata?.mediaUrl;
      if (mxcUrl != null && mxcUrl.startsWith('mxc://')) {
        fileUrl = _convertMxcToHttpUrl(mxcUrl);
      }
    }

    final fileName =
        message.metadata?.fileName ??
        (S.of(context)?.chatUnknownFile ?? 'Unknown file');
    final mimeType = message.metadata?.mimeType ?? '';

    // PDF 文件使用内置预览器（检查文件名后缀和 MIME 类型）
    final isPdf =
        fileName.toLowerCase().endsWith('.pdf') ||
        mimeType == 'application/pdf';
    if (isPdf && fileUrl != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PdfViewerPage(
            fileName: fileName,
            url: fileUrl,
            headers: _buildAuthHeaders(fileUrl),
          ),
        ),
      );
      return;
    }

    final isTextDocument = _isPreviewableTextDocument(
      fileName: fileName,
      mimeType: mimeType,
    );
    if (isTextDocument && fileUrl != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TextDocumentPreviewPage(
            fileName: fileName,
            url: fileUrl!,
            headers: _buildAuthHeaders(fileUrl),
          ),
        ),
      );
      return;
    }

    if (fileUrl == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${S.of(context)?.chatDownloadFile ?? 'Download file'}: $fileName',
        ),
        action: SnackBarAction(
          label: S.of(context)?.chatDownload ?? 'Download',
          onPressed: () async {
            try {
              final downloadService = getIt<DownloadService>();
              final downloadDir = await DownloadService.getDownloadDirectory();
              final savePath = '$downloadDir/$fileName';

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context)?.downloading ?? 'Downloading...'),
                  duration: const Duration(seconds: 1),
                ),
              );

              final taskId = await downloadService.download(
                url: fileUrl!,
                savePath: savePath,
                fileName: fileName,
                headers: _buildAuthHeaders(fileUrl),
              );
              final task = await downloadService.waitForTaskCompletion(taskId);
              if (task.status != DownloadStatus.completed) {
                throw Exception(task.error ?? 'Download failed');
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      S.of(context)?.downloadComplete ?? 'Download complete',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${S.of(context)?.downloadFailed ?? 'Download failed'}: $e',
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  bool _isPreviewableTextDocument({
    required String fileName,
    required String mimeType,
  }) {
    final lowerName = fileName.toLowerCase();
    const previewableExtensions = {
      '.txt',
      '.md',
      '.markdown',
      '.json',
      '.log',
      '.csv',
      '.yaml',
      '.yml',
      '.xml',
      '.html',
      '.htm',
      '.js',
      '.ts',
      '.dart',
      '.java',
      '.kt',
      '.swift',
      '.go',
      '.rs',
      '.py',
      '.sql',
    };

    if (mimeType.startsWith('text/')) {
      return true;
    }
    if (mimeType.contains('json') ||
        mimeType.contains('xml') ||
        mimeType.contains('yaml')) {
      return true;
    }
    return previewableExtensions.any(lowerName.endsWith);
  }

  Map<String, String> _buildAuthHeaders(String? url) {
    return mx_utils.MatrixUtils.buildAuthenticatedMediaHeaders(
      url,
      client: MatrixClientManager.instance.client,
    );
  }

  /// 查看位置
  void _viewLocation(MessageEntity message) {
    final metadata = message.metadata;
    final lat = metadata?.latitude;
    final lng = metadata?.longitude;

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.chatInvalidLocation ?? 'Invalid location',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // 解析位置名称
    String locationName = message.content;
    if (locationName.isEmpty ||
        locationName.startsWith('geo:') ||
        locationName.contains('Location was shared')) {
      locationName = S.of(context)?.chatMyLocation ?? 'My Location';
    }

    // 打开微信风格的位置详情页面
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (ctx) => ChatLocationDetailPage(
          latitude: lat,
          longitude: lng,
          locationName: locationName,
        ),
      ),
    );
  }

  void _onAvatarTap(MessageEntity message) {
    // 点击头像查看用户资料
    if (message.isFromMe) {
      // 点击自己的头像，可以跳转到个人资料页
      return;
    }

    // 获取当前的 ContactBloc
    ContactBloc? contactBloc;
    try {
      contactBloc = context.read<ContactBloc>();
    } catch (e) {
      // ContactBloc 可能不可用
      debugLog('Error: $e');
    }

    // 获取备注名
    String displayName = message.senderName;
    if (contactBloc != null) {
      final state = contactBloc.state;
      if (state.isLoaded) {
        final contact = state.contacts.cast<ContactEntity?>().firstWhere(
          (c) => c?.userId == message.senderId,
          orElse: () => null,
        );
        if (contact != null) {
          displayName = contact.effectiveDisplayName;
        }
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) {
          final page = ContactDetailPage(
            userId: message.senderId,
            displayName: displayName,
            avatarUrl: message.senderAvatarUrl,
            onSendMessage: () {
              Navigator.of(ctx).pop();
            },
          );

          // 如果有 ContactBloc，传递它
          if (contactBloc != null) {
            return BlocProvider.value(value: contactBloc, child: page);
          }
          return page;
        },
      ),
    );
  }

  /// 双击头像拍一拍
  void _onAvatarDoubleTap(MessageEntity message) async {
    try {
      String myDisplayName = S.of(context)?.commonMe ?? 'Me';
      String? myPokeText;
      String? myUserId;

      // 直接从仓库获取用户资料（更可靠，不依赖 AuthBloc Provider）
      try {
        final authRepository = getIt<IAuthRepository>();

        // 获取当前用户基本信息
        final currentUser = authRepository.currentUser;
        myDisplayName =
            currentUser?.displayName ?? (S.of(context)?.commonMe ?? 'Me');
        myUserId = currentUser?.userId;

        debugLog(
          'Poke: currentUser.displayName=$myDisplayName, userId=$myUserId',
        );

        // 从仓库获取 pokeText
        final profileData = await authRepository.getUserProfileData();
        myPokeText = profileData?['pokeText'] as String?;
        debugLog(
          'Poke from repository: pokeText=$myPokeText, fullData=$profileData',
        );
      } catch (e) {
        debugLog('Poke: Failed to get user info: $e');
      }

      // 获取被拍用户的显示名（优先使用备注名）
      final targetName = RemarkService.instance.getDisplayName(
        message.senderId,
        message.senderName,
      );
      final targetUserId = message.senderId;

      debugLog(
        'Poke: targetName=$targetName, targetUserId=$targetUserId, finalPokeText=$myPokeText',
      );

      // 微信风格的拍一拍效果
      // 1. 触发震动反馈
      unawaited(HapticFeedback.mediumImpact());

      // 2. 发送拍一拍系统消息
      // 微信规则：使用拍人者自己设置的后缀
      // 例如：我设置了"的头"，我拍星驰，显示"我 拍了拍 星驰的头"
      _sendPokeMessage(
        pokerName: myDisplayName,
        targetName: targetName,
        targetUserId: targetUserId,
        pokeText: myPokeText,
      );

      // 3. 显示拍一拍动画效果（SnackBar）
      _showPokeAnimation(message, myPokeText: myPokeText);
    } catch (e) {
      debugLog('Poke error: $e');
    }
  }

  /// 发送拍一拍消息
  void _sendPokeMessage({
    required String pokerName,
    required String targetName,
    required String targetUserId,
    String? pokeText,
  }) {
    debugLog(
      'Sending poke message: pokerName=$pokerName, targetName=$targetName, pokeText=$pokeText',
    );

    // 使用新的 SendPokeMessage 事件，让 ChatBloc 处理 pokeText 的获取
    context.read<ChatBloc>().add(
      SendPokeMessage(
        pokerName: pokerName,
        targetUserId: targetUserId,
        targetName: targetName,
        pokerPokeText: pokeText,
      ),
    );
  }

  /// 显示拍一拍动画效果
  void _showPokeAnimation(MessageEntity message, {String? myPokeText}) {
    // 显示一个简短的提示（使用自己设置的后缀）
    // 格式：拍了拍「星驰」的头（如果设置了后缀"的头"）
    // 优先使用备注名
    final targetDisplayName = RemarkService.instance.getDisplayName(
      message.senderId,
      message.senderName,
    );
    debugLog(
      'ShowPokeAnimation: targetName=$targetDisplayName, myPokeText=$myPokeText',
    );

    final displayText =
        S.of(context)?.chatPokedSomeone(targetDisplayName, myPokeText ?? '') ??
        'poked $targetDisplayName${myPokeText ?? ''}';

    debugLog('ShowPokeAnimation: displayText=$displayText');

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.touch_app, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Flexible(child: Text(displayText)),
          ],
        ),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
      ),
    );
  }

  void _onResend(MessageEntity message) {
    context.read<ChatBloc>().add(ResendMessage(message.id));
  }

  /// 导航到线程详情页
  void _navigateToThread(MessageEntity message) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ThreadDetailPage(
          roomId: widget.conversation.id,
          threadRootEventId: message.id,
        ),
      ),
    );
  }

  /// 打开聊天设置页面
  void _openChatSettings() async {
    // 获取当前的 ContactBloc
    ContactBloc? contactBloc;
    try {
      contactBloc = context.read<ContactBloc>();
    } catch (e) {
      // ContactBloc 可能不可用
      debugLog('Error: $e');
    }

    // 检查是否可以踢人和修改群设置（群主/管理员）
    bool canKickMembers = false;
    bool canChangeSettings = false;
    if (widget.conversation.isGroup) {
      try {
        final groupRepository = getIt<IGroupRepository>();
        final group = await groupRepository.getGroup(widget.conversation.id);
        canKickMembers = group?.canKick ?? false;
        canChangeSettings = group?.canChangeSettings ?? false;
        debugLog(
          'ChatPage: Group permissions - canKick=$canKickMembers, canChangeSettings=$canChangeSettings',
        );
      } catch (e) {
        debugLog('Failed to get group info: $e');
      }
    }

    if (!mounted) return;

    final result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute<Object?>(
        builder: (ctx) {
          final page = ChatDetailPage(
            conversation: widget.conversation,
            canKickMembers: canKickMembers,
            canChangeSettings: canChangeSettings,
            onAddMember: () => _showAddMemberDialog(ctx),
            onRemoveMember: (userId) => _removeMemberFromGroup(userId),
            onMemberTap: (userId, displayName, avatarUrl) {
              _openMemberProfile(ctx, userId, displayName, avatarUrl);
            },
            onClearHistory: () {
              context.read<ChatBloc>().add(const ClearChatHistory());
            },
          );

          if (contactBloc != null) {
            return BlocProvider.value(value: contactBloc, child: page);
          }
          return page;
        },
      ),
    );

    await _loadBackground();
    if (!mounted) {
      return;
    }

    if (result is Map && result['action'] == 'search') {
      final initialQuery = result['query'] is String
          ? result['query'] as String
          : '';
      await _openChatHistorySearch(initialQuery: initialQuery);
    }
  }

  /// 显示添加成员对话框
  void _showAddMemberDialog(BuildContext ctx) async {
    // 获取联系人列表
    List<ContactEntity> contacts = [];
    try {
      final contactState = context.read<ContactBloc>().state;
      if (contactState.isLoaded) {
        contacts = contactState.contacts;
      }
    } catch (e) {
      debugLog('Failed to get contacts: $e');
    }

    if (contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.chatNoContactsToAdd ??
                'No contacts available to add',
          ),
        ),
      );
      return;
    }

    // 显示联系人选择对话框
    final selectedIds = await showDialog<List<String>>(
      context: context,
      builder: (dialogCtx) => ContactSelectDialog(
        contacts: contacts,
        title: S.of(context)?.chatAddMembers ?? 'Add Members',
      ),
    );

    if (selectedIds != null && selectedIds.isNotEmpty) {
      try {
        final groupRepository = getIt<IGroupRepository>();
        await groupRepository.inviteUsers(widget.conversation.id, selectedIds);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context)?.chatInvitedMembers(selectedIds.length) ??
                    'Invited ${selectedIds.length} members',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context)?.chatInviteFailed(e.toString()) ??
                    'Invite failed: $e',
              ),
            ),
          );
        }
      }
    }
  }

  /// 从群中移除成员
  void _removeMemberFromGroup(String userId) async {
    try {
      final groupRepository = getIt<IGroupRepository>();
      await groupRepository.kickMember(widget.conversation.id, userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context)?.chatMemberRemoved ?? 'Member removed'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.chatRemoveFailed(e.toString()) ??
                  'Remove failed: $e',
            ),
          ),
        );
      }
    }
  }

  /// 打开成员资料页
  void _openMemberProfile(
    BuildContext ctx,
    String userId,
    String displayName,
    String? avatarUrl,
  ) {
    // 获取当前的 ContactBloc
    ContactBloc? contactBloc;
    try {
      contactBloc = context.read<ContactBloc>();
    } catch (e) {
      // ContactBloc 可能不可用
      debugLog('Error: $e');
    }

    Navigator.of(ctx).push(
      MaterialPageRoute<void>(
        builder: (navCtx) {
          final page = ContactDetailPage(
            userId: userId,
            displayName: displayName,
            avatarUrl: avatarUrl,
            onSendMessage: () {
              Navigator.of(navCtx).pop();
              Navigator.of(ctx).pop();
            },
          );

          if (contactBloc != null) {
            return BlocProvider.value(value: contactBloc, child: page);
          }
          return page;
        },
      ),
    );
  }
}

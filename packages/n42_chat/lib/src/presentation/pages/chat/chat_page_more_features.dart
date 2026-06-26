// ignore_for_file: invalid_use_of_protected_member
part of 'chat_page.dart';

/// 更多功能相关方法（红包、转账、位置、名片、音乐、投票、GIF、贴纸、通话等）
extension _ChatPageMoreFeaturesMethods on _ChatPageState {
  /// 显示位置选项菜单（微信风格）
  Future<void> _sendLocation() async {
    final isDark = context.isDarkMode;
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 发送位置
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    S.of(context)?.chatSendLocation ?? 'Send Location',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.3,
                      color: context.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    S.of(context)?.chatSelectLocationAndSend ??
                        'Select location and send',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: context.textSecondary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _openLocationPicker();
                  },
                ),
                Divider(
                  height: 1,
                  color: context.dividerColor,
                ),
                // 共享实时位置
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.share_location,
                      color: AppColors.success,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    S.of(context)?.chatShareRealTimeLocation ??
                        'Share Real-time Location',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.3,
                      color: context.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    S.of(context)?.chatShareLocationForOneHour ??
                        'Share real-time location with friend for 1 hour',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: context.textSecondary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _shareRealTimeLocation();
                  },
                ),
                const SizedBox(height: 8),
                // 取消按钮
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.backgroundDark
                          : AppColors.inputBackground,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      S.of(context)?.commonCancel ?? 'Cancel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 16,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 打开位置选择页面
  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute<Map<String, dynamic>>(
        builder: (context) => const ChatLocationPickerPage(),
      ),
    );

    if (result != null && mounted) {
      final latitude = result['latitude'] as double;
      final longitude = result['longitude'] as double;
      final address =
          result['address'] as String? ??
          (S.of(context)?.chatMyLocation ?? 'My location');
      final name = result['name'] as String?;

      // 发送位置消息
      context.read<ChatBloc>().add(
        SendLocationMessage(
          latitude: latitude,
          longitude: longitude,
          description: name ?? address,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context)?.chatLocationSent ?? 'Location sent'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  /// 共享实时位置
  Future<void> _shareRealTimeLocation() async {
    // 检查位置服务和权限
    if (!await _checkLocationPermission()) return;

    if (!mounted) return;
    // 显示共享确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          S.of(context)?.chatShareRealTimeLocation ??
              'Share Real-time Location',
        ),
        content: Text(
          S.of(context)?.chatRealTimeLocationShareMessage ??
              'After sharing, the other party can see your real-time location for 1 hour.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(S.of(context)?.chatStartSharing ?? 'Start Sharing'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // 导航到实时位置共享页面
      unawaited(
        Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) => LiveLocationPage(roomId: widget.conversation.id),
          ),
        ),
      );
    }
  }

  void _sendRedPacket() {
    showDialog<void>(
      context: context,
      builder: (context) => SendRedPacketDialog(
        receiverName: _getDisplayName(),
        isGroup: widget.conversation.isGroup,
        memberCount: widget.conversation.memberCount,
        onSend: (amount, token, greeting, count, isLucky) async {
          return _doSendRedPacket(amount, token, greeting, count, isLucky);
        },
      ),
    );
  }

  Future<bool> _doSendRedPacket(
    String amount,
    String token,
    String greeting,
    int count,
    bool isLucky,
  ) async {
    final l10n = S.of(context);
    final chatBloc = context.read<ChatBloc>();
    final roomId = chatBloc.state.roomId ?? '';
    final walletBridge = getIt<IWalletBridge>();

    // 余额校验
    try {
      final balance = await walletBridge.getBalance(token);
      final balanceNum = double.tryParse(balance) ?? 0;
      final amountNum = double.tryParse(amount) ?? 0;
      if (balanceNum < amountNum) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.redPacketInsufficientBalance ?? 'Insufficient balance',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      debugLog('Red packet balance check failed: $e');
    }

    // 创建红包
    late final RedPacketEntity redPacket;
    try {
      final redPacketService = getIt<IRedPacketService>();
      final currentUserId =
          await getIt<IMessageRepository>().getCurrentUserId() ?? '';
      redPacket = await redPacketService.createRedPacket(
        roomId: roomId,
        totalAmount: double.tryParse(amount) ?? 0,
        totalCount: count,
        token: token,
        type: isLucky ? RedPacketType.lucky : RedPacketType.normal,
        greeting: greeting,
        senderId: currentUserId,
        senderName: _getDisplayName(),
      );
    } catch (e) {
      debugLog('Red packet creation failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create red packet'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }

    // 发送红包消息
    final metadata = MessageMetadata(
      amount: amount,
      token: token,
      transferStatus: 'pending',
      redPacketId: redPacket.id,
    );

    if (!mounted) return false;
    chatBloc.add(
      SendCustomMessage(
        content: greeting,
        type: MessageType.redPacket,
        metadata: metadata,
      ),
    );

    // 显示发送成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n?.chatRedPacketSent(amount, token) ??
              'Sent $amount $token red packet',
        ),
        backgroundColor: AppColors.success,
      ),
    );
    return true;
  }

  Future<void> _sendTransfer() async {
    String? recipientAddress;
    String? recipientName;

    if (widget.conversation.isDirect &&
        widget.conversation.directUserId != null) {
      try {
        final contact = await getIt<IContactRepository>().getContactById(
          widget.conversation.directUserId!,
        );
        recipientAddress = contact?.walletAddress;
        recipientName = contact?.effectiveDisplayName;
      } catch (e) {
        debugLog('Transfer recipient lookup failed: $e');
      }
    }

    if (!mounted) return;

    final transfer = await Navigator.of(context).push<TransferEntity>(
      MaterialPageRoute<TransferEntity>(
        builder: (_) => BlocProvider(
          create: (_) => getIt<TransferBloc>(),
          child: TransferPage(
            roomId: widget.conversation.id,
            recipientAddress: recipientAddress,
            recipientName: recipientName ?? _getDisplayName(),
          ),
        ),
      ),
    );

    if (!mounted || transfer == null || !transfer.isSuccess) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          S.of(context)?.chatTransferSent(transfer.amount, transfer.token) ??
              'Sent ${transfer.amount} ${transfer.token} transfer',
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _openReceive() async {
    await Navigator.of(context).push<PaymentRequest>(
      MaterialPageRoute<PaymentRequest>(
        builder: (_) => BlocProvider(
          create: (_) => getIt<TransferBloc>(),
          child: ReceivePage(roomId: widget.conversation.id),
        ),
      ),
    );
  }

  Future<void> _openCommerceHub() async {
    final quickLaunchApps = MiniAppLauncherHelper.commerceQuickLaunchApps();
    final actions = <PaymentCommerceAction>[
      for (final app in quickLaunchApps)
        PaymentCommerceAction(
          icon: _commerceMiniAppIcon(app.id),
          color: _commerceMiniAppColor(app.id),
          title: app.name,
          subtitle: app.description,
          onTap: () => _openBuiltInMiniApp(app.id),
        ),
      PaymentCommerceAction(
        icon: Icons.apps_rounded,
        color: AppColors.primary,
        title: S.of(context)?.miniAppMarketTitle ?? 'Mini Apps',
        onTap: () => _openMiniApps(initialCategory: MiniAppCategory.commerce),
      ),
    ];

    await PaymentCommerceSheet.show(context, actions: actions);
  }

  Future<void> _openBuiltInMiniApp(String appId) async {
    final opened = await MiniAppLauncherHelper.openBuiltInAppById(
      context,
      appId: appId,
      roomId: widget.conversation.id,
    );

    if (!mounted || opened) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mini app is not available')));
  }

  IconData _commerceMiniAppIcon(String appId) {
    switch (appId) {
      case MiniAppLauncherHelper.shopAppId:
        return Icons.storefront_outlined;
      case MiniAppLauncherHelper.creatorPassAppId:
        return Icons.workspace_premium_outlined;
      default:
        return Icons.apps_rounded;
    }
  }

  Color _commerceMiniAppColor(String appId) {
    switch (appId) {
      case MiniAppLauncherHelper.shopAppId:
        return AppColors.warning;
      case MiniAppLauncherHelper.creatorPassAppId:
        return Colors.deepPurple;
      default:
        return AppColors.primary;
    }
  }

  /// 发送名片
  Future<void> _sendContactCard() async {
    debugLog('Send contact card');

    // 预先获取本地化字符串，确保使用正确的语言
    final l10n = S.of(context);
    final selectContactText = l10n?.chatSelectContact ?? 'Select Contact';
    final searchContactHintText =
        l10n?.chatSearchContactHint ?? 'Search contacts';
    final noContactsFoundText =
        l10n?.contactNoContactsFound ?? 'No contacts found';
    final isDark = context.isDarkMode;

    // 显示联系人选择对话框
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ContactCardSelectSheet(
        isDark: isDark,
        selectContactText: selectContactText,
        searchContactHintText: searchContactHintText,
        noContactsFoundText: noContactsFoundText,
      ),
    );

    if (result != null && mounted) {
      final contactId = result['id'] as String;
      final contactName = result['name'] as String;
      final contactAvatar = result['avatar'] as String?;

      context.read<ChatBloc>().add(
        SendContactCardMessage(
          userId: contactId,
          displayName: contactName,
          avatarUrl: contactAvatar,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.chatContactCardSent(contactName) ??
                'Sent $contactName\'s contact card',
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _startVideoCall() async {
    await _startCall(isVideo: true);
  }

  Future<void> _startVoiceCall() async {
    await _startCall(isVideo: false);
  }

  Future<void> _startCall({required bool isVideo}) async {
    final callManager = N42Chat.callManager;

    if (callManager == null || !callManager.isInitialized) {
      // 尝试初始化
      await N42Chat.initializeCallManager();
      if (N42Chat.callManager == null) {
        if (mounted) {
          WeChatToast.warning(
            context,
            S.of(context)?.chatCallServiceNotInitialized ??
                'Call service not available',
          );
        }
        return;
      }
    }

    // 设置错误回调（确保在发起通话前设置）
    N42Chat.callManager?.onError = _handleCallError;

    // 获取对方信息（私聊）
    if (!widget.conversation.isGroup) {
      final peerId = widget.conversation.directUserId;
      if (peerId == null) {
        if (mounted) {
          WeChatToast.warning(
            context,
            S.of(context)?.chatError ?? 'Cannot start call',
          );
        }
        return;
      }

      // 发起通话，错误会通过 onError 回调处理
      if (isVideo) {
        await N42Chat.callManager!.startVideoCall(
          roomId: widget.conversation.id,
          peerId: peerId,
          peerName: widget.conversation.name,
          peerAvatarUrl: widget.conversation.avatarUrl,
        );
      } else {
        await N42Chat.callManager!.startVoiceCall(
          roomId: widget.conversation.id,
          peerId: peerId,
          peerName: widget.conversation.name,
          peerAvatarUrl: widget.conversation.avatarUrl,
        );
      }
    } else {
      final currentUser = N42Chat.currentUser;
      final displayName = currentUser?.displayName.trim();
      final participantName = displayName != null && displayName.isNotEmpty
          ? displayName
          : (currentUser?.userId ?? 'You');

      if (isVideo) {
        await N42Chat.callManager!.startGroupVideoCall(
          conversationId: widget.conversation.id,
          roomDisplayName: widget.conversation.name,
          participantName: participantName,
          participantAvatarUrl: currentUser?.avatarUrl,
        );
      } else {
        await N42Chat.callManager!.startGroupVoiceCall(
          conversationId: widget.conversation.id,
          roomDisplayName: widget.conversation.name,
          participantName: participantName,
          participantAvatarUrl: currentUser?.avatarUrl,
        );
      }
    }
  }

  void _openFavorites() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const FavoriteListPage()),
    );
  }

  /// 分享音乐
  Future<void> _shareMusic() async {
    debugLog('Share music');

    // 显示音乐选择对话框
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MusicSelectSheet(isDark: context.isDarkMode),
    );

    if (result != null && mounted) {
      final songName = result['name'] as String;
      final artist = result['artist'] as String;
      final url = result['url'] as String?;
      final cover = result['cover'] as String?;
      final isLocal = result['isLocal'] == true;

      if (isLocal && url != null && url.isNotEmpty) {
        // 本地音频文件 - 作为文件发送，同时发送音乐卡片
        try {
          final file = File(url);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final mimeType = lookupMimeType(url) ?? 'audio/mpeg';
            final filename = url.split('/').last.split('\\').last;

            if (!mounted) return;
            await _queueFileMessage(
              filename: filename,
              mimeType: mimeType,
              fileSize: bytes.length,
              fileBytes: bytes,
            );

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  S.of(context)?.chatSharedMusic(songName) ??
                      'Shared $songName',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  S.of(context)?.chatFileNotExist ?? 'File does not exist',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        } catch (e) {
          debugLog('Error sending local music: $e');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context)?.chatSendFailed(e.toString()) ??
                    'Send failed: $e',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } else {
        // 网络链接或推荐歌曲 - 发送音乐卡片消息
        context.read<ChatBloc>().add(
          SendCustomMessage(
            type: MessageType.music,
            content: '🎵 $songName - $artist',
            metadata: MessageMetadata(
              musicTitle: songName,
              musicArtist: artist,
              musicUrl: url,
              musicCover: cover,
            ),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.chatSharedMusic(songName) ?? 'Shared $songName',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _queueScheduledRichDraft({
    required String text,
    required MessageType type,
    required DateTime scheduledAt,
    Map<String, dynamic> payload = const {},
  }) {
    context.read<ChatBloc>().add(
      SendScheduledMessage(
        text: text,
        type: type,
        payload: payload,
        scheduledAt: scheduledAt,
      ),
    );
  }

  Future<void> _pickAndQueueScheduledRichDraft({
    required String text,
    required MessageType type,
    Map<String, dynamic> payload = const {},
  }) async {
    final scheduledAt = await showScheduledSendPicker(context);
    if (!mounted || scheduledAt == null) {
      return;
    }

    _queueScheduledRichDraft(
      text: text,
      type: type,
      payload: payload,
      scheduledAt: scheduledAt,
    );
  }

  Map<String, dynamic> _buildStickerPayload(Sticker sticker, String packId) => {
    'stickerId': sticker.id,
    'packId': packId,
    'url': sticker.url,
    'httpUrl': sticker.httpUrl,
    'name': sticker.name,
    'emoji': sticker.emoji,
    'width': sticker.width,
    'height': sticker.height,
    'mimeType': sticker.mimeType,
    'size': sticker.size,
  };

  void _hideStickerPicker() {
    if (!mounted) {
      return;
    }
    setState(() {
      _showStickerPicker = false;
    });
  }

  /// 创建投票
  void _createPoll() async {
    final result = await showModalBottomSheet<PollComposerResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PollCreateSheet(),
    );

    if (result != null && mounted) {
      if (result.action == PollComposerAction.schedule) {
        await _pickAndQueueScheduledRichDraft(
          text: result.question,
          type: MessageType.poll,
          payload: {
            'options': result.options,
            'maxSelections': result.maxSelections,
            'isAnonymous': result.isAnonymous,
          },
        );
        return;
      }

      debugLog(
        'ChatPage: Creating poll - question: ${result.question}, options: ${result.options}, maxSelections: ${result.maxSelections}',
      );

      context.read<ChatBloc>().add(
        SendPollMessage(
          question: result.question,
          options: result.options,
          maxSelections: result.maxSelections,
          isAnonymous: result.isAnonymous,
        ),
      );
    }
  }

  /// 显示 GIF 选择器
  Future<void> _showGifPicker() async {
    final selection = await showGifPicker(context);
    if (selection != null && mounted) {
      final payload = selection.scheduledPayload;

      if (selection.scheduledAt != null) {
        _queueScheduledRichDraft(
          text: selection.title.trim().isEmpty ? 'GIF' : selection.title,
          type: MessageType.image,
          payload: payload,
          scheduledAt: selection.scheduledAt!,
        );
        return;
      }

      debugLog('ChatPage: Sending GIF - ${selection.title}');
      context.read<ChatBloc>().add(
        SendGifMessage(
          gifUrl: payload['gifUrl'] as String,
          previewUrl: payload['previewUrl'] as String?,
          width: payload['width'] as int?,
          height: payload['height'] as int?,
          title: selection.title,
        ),
      );
    }
  }

  /// 显示/隐藏贴纸选择器面板
  void _toggleStickerPicker() {
    setState(() {
      _showStickerPicker = !_showStickerPicker;
      _showMorePanel = false;
      _showEmojiPicker = false;
      if (_showStickerPicker) {
        _inputFocusNode.unfocus();
      }
    });
  }

  /// 发送贴纸消息
  void _onStickerSelected(Sticker sticker, String packId) {
    debugLog('ChatPage: Sending sticker ${sticker.id} from pack $packId');
    final payload = _buildStickerPayload(sticker, packId);
    context.read<ChatBloc>().add(
      SendStickerMessage(
        stickerId: payload['stickerId'] as String,
        packId: payload['packId'] as String,
        url: payload['url'] as String,
        httpUrl: payload['httpUrl'] as String?,
        name: payload['name'] as String?,
        emoji: payload['emoji'] as String?,
        width: payload['width'] as int?,
        height: payload['height'] as int?,
        mimeType: payload['mimeType'] as String?,
        size: payload['size'] as int?,
      ),
    );

    _hideStickerPicker();
  }

  Future<void> _onStickerLongPressed(Sticker sticker, String packId) async {
    await _pickAndQueueScheduledRichDraft(
      text: sticker.name ?? sticker.emoji ?? 'Sticker',
      type: MessageType.sticker,
      payload: _buildStickerPayload(sticker, packId),
    );
    _hideStickerPicker();
  }

  /// 打开贴纸商店
  void _openStickerStore() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => const StickerStorePage()),
    );
  }

  /// 投票选项点击
  void _onPollVote(
    String pollEventId,
    String optionId,
    List<String> currentVotes,
    int maxSelections,
  ) {
    // 防止重复投票 - 如果正在处理投票，忽略新的点击
    if (_votingPollIds.contains(pollEventId)) {
      debugLog('ChatPage: Ignoring duplicate vote on poll $pollEventId');
      return;
    }

    // 计算新的投票选项列表
    List<String> newVotes;
    String actionMessage;
    final s = S.of(context);

    if (currentVotes.contains(optionId)) {
      // 点击已选选项 -> 取消投票
      newVotes = currentVotes.where((id) => id != optionId).toList();
      actionMessage = s?.chatVoteRemoved ?? 'Vote removed';
    } else if (maxSelections == 1) {
      // 单选 -> 直接替换为新选项
      newVotes = [optionId];
      actionMessage = s?.chatVoteChanged ?? 'Vote changed';
    } else {
      // 多选 -> 添加新选项
      newVotes = [...currentVotes, optionId];
      actionMessage = s?.chatVoted ?? 'Voted';
    }

    debugLog('ChatPage: Voting on poll $pollEventId, new votes: $newVotes');

    // 标记正在投票
    setState(() {
      _votingPollIds.add(pollEventId);
    });

    context.read<ChatBloc>().add(
      VoteOnPoll(pollEventId: pollEventId, selectedOptionIds: newVotes),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(actionMessage),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // 延迟后解除投票锁定
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _votingPollIds.remove(pollEventId);
        });
      }
    });
  }

  /// 结束投票
  void _onEndPoll(String pollEventId) async {
    debugLog('ChatPage: Ending poll $pollEventId');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.chatEndPollTitle ?? 'End Poll'),
        content: Text(
          S.of(context)?.chatEndPollConfirmMessage ??
              'Are you sure you want to end this poll? Voting will be closed after ending.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              S.of(context)?.commonConfirm ?? 'Confirm',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // 调用 Bloc 结束投票
      context.read<ChatBloc>().add(EndPoll(pollEventId: pollEventId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context)?.chatPollEndedMessage ?? 'Poll ended'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/debug_log.dart';

class MusicSelectSheet extends StatefulWidget {
  final bool isDark;
  
  const MusicSelectSheet({super.key, required this.isDark});
  
  @override
  State<MusicSelectSheet> createState() => _MusicSelectSheetState();
}

class _MusicSelectSheetState extends State<MusicSelectSheet> {
  String _searchQuery = '';
  int _selectedTab = 0; // 0: 最近播放, 1: 我喜欢, 2: 网络链接, 3: 本地文件
  
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  
  // 模拟音乐列表
  final List<Map<String, dynamic>> _recentSongs = [
    {'name': '晴天', 'artist': '周杰伦', 'url': 'https://music.163.com/#/song?id=186016'},
    {'name': '稻香', 'artist': '周杰伦', 'url': 'https://music.163.com/#/song?id=185813'},
    {'name': '青花瓷', 'artist': '周杰伦', 'url': 'https://music.163.com/#/song?id=185805'},
    {'name': '七里香', 'artist': '周杰伦', 'url': 'https://music.163.com/#/song?id=186001'},
    {'name': '告白气球', 'artist': '周杰伦', 'url': 'https://music.163.com/#/song?id=418603077'},
  ];
  
  final List<Map<String, dynamic>> _favoriteSongs = [
    {'name': '起风了', 'artist': '买辣椒也用券', 'url': 'https://music.163.com/#/song?id=1330348068'},
    {'name': '年少有为', 'artist': '李荣浩', 'url': 'https://music.163.com/#/song?id=1293886117'},
    {'name': '光年之外', 'artist': 'G.E.M.邓紫棋', 'url': 'https://music.163.com/#/song?id=449818741'},
  ];
  
  List<Map<String, dynamic>> get _currentSongs {
    final songs = _selectedTab == 0 ? _recentSongs : _favoriteSongs;
    if (_searchQuery.isEmpty) return songs;
    return songs.where((s) => 
      (s['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
      (s['artist'] as String).toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }
  
  @override
  void dispose() {
    _linkController.dispose();
    _titleController.dispose();
    _artistController.dispose();
    super.dispose();
  }
  
  /// 选择本地音频文件
  Future<void> _pickLocalAudio() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileName = file.name;
        // 从文件名中提取歌曲名和歌手（假设格式为 "歌手 - 歌曲名.mp3"）
        String songName = fileName;
        String artist = '未知歌手';

        // 去掉扩展名
        if (fileName.contains('.')) {
          songName = fileName.substring(0, fileName.lastIndexOf('.'));
        }

        // 尝试分离歌手和歌曲名
        if (songName.contains(' - ')) {
          final parts = songName.split(' - ');
          artist = parts[0].trim();
          songName = parts[1].trim();
        }

        if (!mounted) return;
        // 返回结果，包含文件路径
        Navigator.pop(context, {
          'name': songName,
          'artist': artist,
          'url': file.path ?? '',
          'isLocal': true,
        });
      }
    } catch (e) {
      debugLog('Error picking audio file: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)?.chatSelectFileFailed(e.toString()) ?? 'Failed to select file: $e')),
      );
    }
  }
  
  /// 分享网络链接
  void _shareNetworkLink() {
    final link = _linkController.text.trim();
    final title = _titleController.text.trim();
    final artist = _artistController.text.trim();
    
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)?.chatPleaseEnterMusicLink ?? 'Please enter music link')),
      );
      return;
    }
    
    // 验证链接格式
    if (!link.startsWith('http://') && !link.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)?.chatPleaseEnterValidLink ?? 'Please enter a valid URL')),
      );
      return;
    }
    
    Navigator.pop(context, {
      'name': title.isNotEmpty ? title : (S.of(context)?.chatSharedSong ?? 'Shared Song'),
      'artist': artist.isNotEmpty ? artist : (S.of(context)?.chatUnknownArtist ?? 'Unknown Artist'),
      'url': link,
      'isNetwork': true,
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(widget.isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 顶部标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.dividerOf(widget.isDark),
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  S.of(context)?.chatShareMusic ?? 'Share Music',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryOf(widget.isDark),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: AppColors.textPrimaryOf(widget.isDark),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Tab 切换
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTab(0, S.of(context)?.chatRecentPlayed ?? 'Recent', Icons.history),
                _buildTab(1, S.of(context)?.chatMyFavorites ?? 'Favorites', Icons.favorite),
                _buildTab(2, S.of(context)?.chatNetworkLink ?? 'Link', Icons.link),
                _buildTab(3, S.of(context)?.chatLocalFile ?? 'Local', Icons.folder),
              ],
            ),
          ),
          // 内容区域
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected 
                  ? AppColors.primary 
                  : (AppColors.textSecondaryOf(widget.isDark)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? AppColors.primary 
                    : (AppColors.textSecondaryOf(widget.isDark)),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
      case 1:
        return _buildMusicList();
      case 2:
        return _buildNetworkLinkInput();
      case 3:
        return _buildLocalFilePicker();
      default:
        return _buildMusicList();
    }
  }
  
  Widget _buildMusicList() {
    return Column(
      children: [
        // 搜索框
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              hintText: S.of(context)?.chatSearchSongOrArtist ?? 'Search song or artist',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.inputBgOf(widget.isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        // 音乐列表
        Expanded(
          child: _currentSongs.isEmpty
              ? Center(
                  child: Text(
                    S.of(context)?.chatNoSongsFound ?? 'No songs found',
                    style: TextStyle(
                      color: AppColors.textSecondaryOf(widget.isDark),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _currentSongs.length,
                  itemBuilder: (context, index) {
                    final song = _currentSongs[index];
                    return ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.music_note,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        song['name'] as String,
                        style: TextStyle(
                          color: AppColors.textPrimaryOf(widget.isDark),
                        ),
                      ),
                      subtitle: Text(
                        song['artist'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryOf(widget.isDark),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.send,
                        color: AppColors.primary,
                      ),
                      onTap: () => Navigator.pop(context, song),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildNetworkLinkInput() {
    final textColor = AppColors.textPrimaryOf(widget.isDark);
    final hintColor = AppColors.textSecondaryOf(widget.isDark);
    final fillColor = AppColors.inputBgOf(widget.isDark);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 提示
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '支持网易云、QQ音乐、酷狗、酷我等平台的歌曲链接',
                    style: TextStyle(fontSize: 13, color: textColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 音乐链接
          Text('${S.of(context)?.chatMusicLinkLabel ?? 'Music Link'} *', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 8),
          TextField(
            controller: _linkController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: S.of(context)?.chatPasteMusicLink ?? 'Paste music link',
              hintStyle: TextStyle(color: hintColor),
              prefixIcon: Icon(Icons.link, color: hintColor),
              filled: true,
              fillColor: fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 歌曲名称
          Text(S.of(context)?.chatSongNameOptional ?? 'Song Name (Optional)', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: S.of(context)?.chatEnterSongName ?? 'Enter song name',
              hintStyle: TextStyle(color: hintColor),
              prefixIcon: Icon(Icons.music_note, color: hintColor),
              filled: true,
              fillColor: fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 歌手名称
          Text(S.of(context)?.chatArtistNameOptional ?? 'Artist Name (Optional)', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 8),
          TextField(
            controller: _artistController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: S.of(context)?.chatEnterArtistName ?? 'Enter artist name',
              hintStyle: TextStyle(color: hintColor),
              prefixIcon: Icon(Icons.person, color: hintColor),
              filled: true,
              fillColor: fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 分享按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _shareNetworkLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(S.of(context)?.chatShareMusicButton ?? 'Share Music', style: const TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLocalFilePicker() {
    final textColor = AppColors.textPrimaryOf(widget.isDark);
    final subtextColor = AppColors.textSecondaryOf(widget.isDark);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.audio_file,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              S.of(context)?.chatSelectLocalAudio ?? 'Select Local Audio File',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context)?.chatSupportedAudioFormats ?? 'Supports MP3, M4A, WAV, FLAC, etc.',
              style: TextStyle(
                fontSize: 14,
                color: subtextColor,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _pickLocalAudio,
              icon: const Icon(Icons.folder_open),
              label: Text(S.of(context)?.chatSelectFileButton ?? 'Select File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 群成员选择器底部弹窗（用于@提醒）

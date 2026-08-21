import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/matrix_utils.dart' as mx_utils;
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/entities/story_entity.dart';
import '../../../domain/repositories/story_repository.dart';
import '../../widgets/common/common_widgets.dart';

/// WeChat-style social listening feed backed by music attached to Stories.
/// Likes are device-local preferences; the media itself remains sourced from
/// Matrix so another signed-in device can discover and play the same track.
class ListenPage extends StatefulWidget {
  final IStoryRepository? storyRepository;
  final AudioPlayer? audioPlayer;

  const ListenPage({super.key, this.storyRepository, this.audioPlayer});

  @override
  State<ListenPage> createState() => _ListenPageState();
}

class _ListenPageState extends State<ListenPage> {
  static const _favoriteKey = 'n42_listen_favorite_story_ids';

  late final AudioPlayer _player;
  StreamSubscription<List<UserStories>>? _storySubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<void>? _completionSubscription;
  final TextEditingController _searchController = TextEditingController();
  final List<File> _temporaryFiles = [];

  List<_ListenTrack> _tracks = const [];
  Set<String> _favorites = <String>{};
  _ListenTrack? _current;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;
  bool _loading = true;
  bool _favoritesOnly = false;
  String _query = '';
  String? _error;
  int _playGeneration = 0;

  IStoryRepository get _repository =>
      widget.storyRepository ?? getIt<IStoryRepository>();

  @override
  void initState() {
    super.initState();
    _player = widget.audioPlayer ?? AudioPlayer();
    _positionSubscription = _player.onPositionChanged.listen((value) {
      if (mounted) setState(() => _position = value);
    });
    _durationSubscription = _player.onDurationChanged.listen((value) {
      if (mounted) setState(() => _duration = value);
    });
    _completionSubscription = _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _playing = false;
        _position = Duration.zero;
      });
      unawaited(_playNext());
    });
    unawaited(_initialize());
  }

  @override
  void dispose() {
    _playGeneration++;
    _storySubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _completionSubscription?.cancel();
    _searchController.dispose();
    _player.dispose();
    for (final file in _temporaryFiles) {
      file.delete().ignore();
    }
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      _favorites = (preferences.getStringList(_favoriteKey) ?? const <String>[])
          .toSet();
      final stories = await _repository.getStories();
      _applyStories(stories);
      _storySubscription = _repository.watchStories().listen(
        _applyStories,
        onError: (Object error) {
          if (mounted && _tracks.isEmpty) {
            setState(() => _error = error.toString());
          }
        },
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = error.toString();
        });
      }
    }
  }

  void _applyStories(List<UserStories> groups) {
    final tracks = <_ListenTrack>[];
    for (final group in groups) {
      for (final story in group.stories) {
        if (story.hasMusic && !story.isExpired) {
          tracks.add(_ListenTrack(story));
        }
      }
    }
    tracks.sort((a, b) => b.story.createdAt.compareTo(a.story.createdAt));
    if (!mounted) return;
    setState(() {
      _tracks = tracks;
      _loading = false;
      _error = null;
    });
  }

  List<_ListenTrack> get _visibleTracks {
    final query = _query.toLowerCase().trim();
    return _tracks.where((track) {
      if (_favoritesOnly && !_favorites.contains(track.story.id)) return false;
      if (query.isEmpty) return true;
      return track.title.toLowerCase().contains(query) ||
          track.artist.toLowerCase().contains(query) ||
          track.story.userName.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _refresh() async {
    try {
      final stories = await _repository.getStories();
      _applyStories(stories);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  Future<void> _toggleFavorite(_ListenTrack track) async {
    setState(() {
      if (!_favorites.add(track.story.id)) {
        _favorites.remove(track.story.id);
      }
    });
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_favoriteKey, _favorites.toList()..sort());
  }

  Future<void> _play(_ListenTrack track) async {
    if (_current?.story.id == track.story.id) {
      if (_playing) {
        await _player.pause();
      } else {
        await _player.resume();
      }
      if (mounted) setState(() => _playing = !_playing);
      return;
    }

    final generation = ++_playGeneration;
    setState(() {
      _current = track;
      _playing = false;
      _position = Duration.zero;
      _duration = Duration.zero;
      _error = null;
    });

    try {
      final source = await _resolveSource(track.story.musicUrl!);
      if (!mounted || generation != _playGeneration) return;
      if (source == null) throw Exception('Music source is unavailable');
      await _player.stop();
      await _player.play(source);
      final startAt = track.story.musicStartAt;
      if (startAt != null && startAt > 0) {
        await _player.seek(Duration(seconds: startAt));
      }
      unawaited(_repository.recordView(track.story.id));
      if (mounted) setState(() => _playing = true);
    } catch (error) {
      if (mounted && generation == _playGeneration) {
        setState(() {
          _playing = false;
          _error = 'Unable to play ${track.title}: $error';
        });
      }
    }
  }

  Future<Source?> _resolveSource(String value) async {
    if (!value.startsWith('http') && !value.startsWith('mxc://')) {
      return File(value).existsSync() ? DeviceFileSource(value) : null;
    }

    final client = MatrixClientManager.instance.client;
    final resolved = value.startsWith('mxc://')
        ? mx_utils.MatrixUtils.getMediaDownloadUrl(value, client: client)
        : value;
    if (resolved == null || resolved.isEmpty) return null;
    final headers = mx_utils.MatrixUtils.buildAuthenticatedMediaHeaders(
      resolved,
      client: client,
    );
    if (headers.isEmpty) return UrlSource(resolved);

    final response = await http
        .get(Uri.parse(resolved), headers: headers)
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200 || response.bodyBytes.isEmpty) return null;
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/n42_listen_${DateTime.now().microsecondsSinceEpoch}.audio',
    );
    await file.writeAsBytes(response.bodyBytes, flush: true);
    _temporaryFiles.add(file);
    return DeviceFileSource(file.path);
  }

  Future<void> _playNext() async {
    final tracks = _visibleTracks;
    if (tracks.isEmpty) return;
    final index = _current == null
        ? -1
        : tracks.indexWhere((track) => track.story.id == _current!.story.id);
    await _play(tracks[(index + 1) % tracks.length]);
  }

  Future<void> _playPrevious() async {
    final tracks = _visibleTracks;
    if (tracks.isEmpty) return;
    final index = _current == null
        ? 0
        : tracks.indexWhere((track) => track.story.id == _current!.story.id);
    await _play(tracks[(index <= 0 ? tracks.length : index) - 1]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(title: S.of(context)?.discoverListen ?? 'Listen'),
      body: Column(
        children: [
          _buildControls(context),
          if (_error != null)
            MaterialBanner(
              content: Text(_error!),
              actions: [
                TextButton(onPressed: _refresh, child: const Text('Retry')),
              ],
            ),
          Expanded(child: _buildFeed(context)),
          if (_current != null) _buildNowPlaying(context),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Material(
      color: context.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search songs, artists, or friends',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: context.pageBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('For You')),
                ButtonSegment(
                  value: true,
                  label: Text('Liked'),
                  icon: Icon(Icons.favorite_outline, size: 18),
                ),
              ],
              selected: {_favoritesOnly},
              onSelectionChanged: (value) {
                setState(() => _favoritesOnly = value.first);
              },
              showSelectedIcon: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeed(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final tracks = _visibleTracks;
    if (tracks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.headphones, size: 60, color: context.textTertiary),
              const SizedBox(height: 14),
              Text(
                _favoritesOnly ? 'No liked music yet' : 'No music Stories yet',
                style: TextStyle(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _favoritesOnly
                    ? 'Tap the heart beside a song to keep it here.'
                    : 'Music shared in Stories will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: tracks.length,
        separatorBuilder: (_, _) =>
            Divider(height: 1, indent: 76, color: context.dividerColor),
        itemBuilder: (context, index) {
          final track = tracks[index];
          final selected = _current?.story.id == track.story.id;
          final liked = _favorites.contains(track.story.id);
          return ListTile(
            key: ValueKey('listen-${track.story.id}'),
            leading: Stack(
              alignment: Alignment.center,
              children: [
                N42Avatar(
                  name: track.story.userName,
                  imageUrl: track.story.userAvatarUrl,
                  size: 48,
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    selected && _playing ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            title: Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? AppColors.primary : context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${track.artist} · shared by ${track.story.userName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              key: ValueKey('listen-favorite-${track.story.id}'),
              tooltip: liked ? 'Unlike' : 'Like',
              onPressed: () => _toggleFavorite(track),
              icon: Icon(
                liked ? Icons.favorite : Icons.favorite_border,
                color: liked ? Colors.redAccent : context.textSecondary,
              ),
            ),
            onTap: () => _play(track),
          );
        },
      ),
    );
  }

  Widget _buildNowPlaying(BuildContext context) {
    final track = _current!;
    final max = _duration.inMilliseconds > 0
        ? _duration.inMilliseconds.toDouble()
        : 1.0;
    final value = _position.inMilliseconds.clamp(0, max.toInt()).toDouble();
    return Material(
      color: context.surfaceColor,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: value,
              max: max,
              onChanged: _duration == Duration.zero
                  ? null
                  : (milliseconds) => _player.seek(
                      Duration(milliseconds: milliseconds.round()),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          track.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _playPrevious,
                    icon: const Icon(Icons.skip_previous),
                  ),
                  IconButton.filled(
                    onPressed: () => _play(track),
                    icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
                  ),
                  IconButton(
                    onPressed: _playNext,
                    icon: const Icon(Icons.skip_next),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListenTrack {
  final StoryEntity story;

  const _ListenTrack(this.story);

  String get title => story.musicTitle?.trim().isNotEmpty == true
      ? story.musicTitle!.trim()
      : 'Shared music';

  String get artist => story.musicArtist?.trim().isNotEmpty == true
      ? story.musicArtist!.trim()
      : 'Unknown artist';
}

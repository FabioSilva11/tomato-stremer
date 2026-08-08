import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chrome_cast/discovery.dart';
import 'package:flutter_chrome_cast/entities.dart';
import 'package:flutter_chrome_cast/enums.dart';
import 'package:flutter_chrome_cast/media.dart';
import 'package:flutter_chrome_cast/session.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../core/api/tomato_api.dart';
import '../../core/models/anime_models.dart';
import '../../core/state/app_controller.dart';
import '../../theme/app_theme.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, required this.episodeId});

  final int episodeId;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  static const _pipChannel = MethodChannel('tomato.streaming/pip');
  Future<EpisodeStream>? _streamFuture;
  VideoPlayerController? _video;
  AppController? _appController;
  int? _currentEpisodeId;
  String? _quality;
  Duration _lastSavedPosition = Duration.zero;
  bool _showControls = true;
  bool _landscape = false;
  bool _castActive = false;
  bool _remotePlaying = false;
  bool _fullscreen = false;
  Timer? _controlsTimer;
  @override
  void initState() {
    super.initState();
    _pipChannel.setMethodCallHandler((call) async {
      if (call.method == 'pipChanged' && mounted) {
        final inPip = call.arguments is Map && call.arguments['inPip'] == true;
        setState(() => _showControls = !inPip);
      }
    });
    _pipChannel.invokeMethod<void>('setEnabled', {'enabled': true});
    _scheduleControlsHide();
    _load(widget.episodeId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appController = context.read<AppController>();
  }

  Future<void> _load(int episodeId) async {
    final api = context.read<TomatoApi>();
    await _persistPlayback();
    final old = _video;
    final future = api.fetchStream(episodeId);
    setState(() {
      _streamFuture = future;
      _video = null;
      _quality = null;
      _showControls = true;
    });
    old?.removeListener(_handleVideoTick);
    await old?.dispose();
    _currentEpisodeId = episodeId;
    _lastSavedPosition = Duration.zero;

    late final EpisodeStream stream;
    try {
      stream = await future;
    } catch (_) {
      return;
    }
    final controller = _appController;
    final resumeEntry = await controller?.loadHistoryForEpisode(episodeId);
    await controller?.addStreamHistory(stream);
    final quality = _bestQuality(stream);
    final url = quality == null ? null : stream.streams[quality];
    if (url == null || !mounted) return;
    setState(() => _quality = quality);
    await _playUrl(
      url,
      startPlaying: true,
      position: resumeEntry?.playbackPosition ?? Duration.zero,
    );
  }

  Future<void> _playUrl(
    String url, {
    required bool startPlaying,
    Duration position = Duration.zero,
  }) async {
    final old = _video;
    if (mounted) setState(() => _video = null);
    old?.removeListener(_handleVideoTick);
    await old?.dispose();
    if (!mounted) return;
    final video = VideoPlayerController.networkUrl(Uri.parse(url));
    setState(() => _video = video);
    await video.initialize();
    final canResume = position > const Duration(seconds: 5) &&
        position < video.value.duration - const Duration(seconds: 8);
    if (canResume) {
      await video.seekTo(position);
    }
    _lastSavedPosition = video.value.position;
    video.addListener(_handleVideoTick);
    if (startPlaying) {
      await video.play();
      if (mounted) {
        setState(() => _showControls = false);
        _scheduleControlsHide();
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _selectQuality(EpisodeStream stream, String quality) async {
    final url = stream.streams[quality];
    if (url == null || quality == _quality) return;
    final old = _video;
    final position = old?.value.position ?? Duration.zero;
    final wasPlaying = old?.value.isPlaying ?? true;
    await _persistPlayback();
    if (mounted) setState(() => _quality = quality);
    await _playUrl(url, startPlaying: wasPlaying, position: position);
  }

  @override
  void dispose() {
    _pipChannel.invokeMethod<void>('setEnabled', {'enabled': false});
    unawaited(_persistPlayback(notify: true));

    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _video?.dispose();
    _controlsTimer?.cancel();
    super.dispose();
  }

  void _handleVideoTick() {
    final video = _video;
    if (video == null || !video.value.isInitialized) return;
    final position = video.value.position;
    if ((position - _lastSavedPosition).abs() < const Duration(seconds: 5)) {
      return;
    }
    _lastSavedPosition = position;
    unawaited(_persistPlayback());
  }

  Future<void> _persistPlayback({bool notify = false}) async {
    final video = _video;
    final episodeId = _currentEpisodeId;
    if (video == null || episodeId == null || !video.value.isInitialized) {
      return;
    }
    await _appController?.savePlaybackProgress(
      episodeId: episodeId,
      position: video.value.position,
      duration: video.value.duration,
      notify: notify,
    );
  }

  Future<void> _toggleRotation() async {
    final landscape = !_landscape;
    await SystemChrome.setPreferredOrientations(
      landscape
          ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
          : [DeviceOrientation.portraitUp],
    );
    if (mounted) {
      setState(() => _landscape = landscape);
    }
  }

  Future<void> _loadNext(int nextEpisodeId) async {
    if (mounted) {
      await _load(nextEpisodeId);
    }
  }

  Future<void> _castCurrentVideo() async {
    final videoUrl = _video == null ? null : _currentStreamUrl;
    if (videoUrl == null) {
      debugPrint('[Chromecast] sem URL de vídeo disponível');
      return;
    }
    debugPrint(
        '[Chromecast] preparando envio: title=$_currentStreamTitle url=$videoUrl');
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: StreamBuilder<List<GoogleCastDevice>>(
          stream: GoogleCastDiscoveryManager.instance.devicesStream,
          builder: (context, snapshot) {
            final devices = snapshot.data ?? const <GoogleCastDevice>[];
            return Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Assistir na TV',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  if (devices.isEmpty)
                    const Text(
                        'Nenhuma TV encontrada. Xiaomi e TCL precisam estar no mesmo Wi-Fi.'),
                  for (final device in devices)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(LucideIcons.tv),
                      title: Text(device.friendlyName),
                      subtitle: Text(device.modelName ?? 'Google Cast'),
                      onTap: () async {
                        try {
                          debugPrint(
                              '[Chromecast] conectando: ${device.friendlyName} (${device.modelName})');
                          await GoogleCastSessionManager.instance
                              .startSessionWithDevice(device);
                          await _waitForCastReceiver();
                          final contentType = videoUrl.contains('.m3u8')
                              ? 'application/x-mpegURL'
                              : 'video/mp4';
                          debugPrint(
                              '[Chromecast] sessão conectada; enviando contentType=$contentType');
                          await GoogleCastRemoteMediaClient.instance.loadMedia(
                            GoogleCastMediaInformation(
                              contentId: videoUrl,
                              contentUrl: Uri.parse(videoUrl),
                              streamType: CastMediaStreamType.buffered,
                              contentType: contentType,
                              duration: _video?.value.duration,
                              metadata: GoogleCastMovieMediaMetadata(
                                  title: _currentStreamTitle),
                            ),
                          );
                          debugPrint('[Chromecast] mídia enviada com sucesso');
                          await _video?.pause();
                          if (mounted) {
                            setState(() {
                              _castActive = true;
                              _remotePlaying = true;
                              _showControls = false;
                            });
                          }
                          if (context.mounted) Navigator.pop(context);
                        } catch (error, stack) {
                          debugPrint('[Chromecast] ERRO ao reproduzir: $error');
                          debugPrint('$stack');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'A TV conectou, mas recusou o vídeo: $error')),
                            );
                          }
                        }
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String? get _currentStreamUrl =>
      _quality == null ? null : _loadedStream?.streams[_quality!];
  String get _currentStreamTitle => _loadedStream?.title ?? 'Tomato Streaming';
  EpisodeStream? _loadedStream;

  Future<void> _waitForCastReceiver() async {
    for (var attempt = 1; attempt <= 30; attempt++) {
      final state = GoogleCastSessionManager.instance.connectionState;
      debugPrint(
        '[Chromecast] aguardando receiver: tentativa=$attempt estado=$state',
      );
      if (state == GoogleCastConnectState.connected) {
        debugPrint('[Chromecast] receiver pronto');
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    throw StateError('A TV não concluiu a conexão Cast em 15 segundos.');
  }

  Future<void> _castPlayPause() async {
    final remote = GoogleCastRemoteMediaClient.instance;
    if (_castActive) {
      final shouldPause = _remotePlaying ||
          remote.mediaStatus?.playerState == CastMediaPlayerState.playing;
      if (mounted) setState(() => _remotePlaying = !shouldPause);
      if (shouldPause) {
        await remote.pause();
      } else {
        await remote.play();
      }
      return;
    }
    final video = _video;
    if (video == null) return;
    video.value.isPlaying ? await video.pause() : await video.play();
  }

  Future<void> _castSeekRelative(int seconds) async {
    if (_castActive) {
      await GoogleCastRemoteMediaClient.instance.seek(
        GoogleCastMediaSeekOption(
          position: Duration(seconds: seconds),
          relative: true,
        ),
      );
      return;
    }
    final video = _video;
    if (video == null) return;
    final target = video.value.position + Duration(seconds: seconds);
    await video.seekTo(target.isNegative ? Duration.zero : target);
  }

  Future<void> _toggleFullscreen() async {
    setState(() => _fullscreen = !_fullscreen);
    await SystemChrome.setEnabledSystemUIMode(
      _fullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  Future<void> _showVolumeDialog() async {
    if (!_castActive) return;
    final remote = GoogleCastRemoteMediaClient.instance;
    var volume = (remote.mediaStatus?.volume ?? 1).toDouble().clamp(0.0, 1.0);
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Volume da TV'),
          content: Slider(
            value: volume,
            min: 0,
            max: 1,
            onChanged: (value) {
              setDialogState(() => volume = value);
              GoogleCastSessionManager.instance.setDeviceVolume(value);
            },
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar')),
          ],
        ),
      ),
    );
  }

  void _scheduleControlsHide() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && (_video?.value.isPlaying ?? false)) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleControlsHide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<EpisodeStream>(
        future: _streamFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _PlayerError(error: snapshot.error.toString());
          }
          final stream = snapshot.data!;
          _loadedStream = stream;
          final video = _video;
          if (stream.bestUrl == null) {
            return const _PlayerError(error: TomatoApi.maintenanceMessage);
          }
          return GestureDetector(
            onTap: _toggleControls,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: video == null || !video.value.isInitialized
                      ? const CircularProgressIndicator()
                      : AspectRatio(
                          aspectRatio: video.value.aspectRatio,
                          child: VideoPlayer(video),
                        ),
                ),
                if (_showControls)
                  StreamBuilder<GoggleCastMediaStatus?>(
                    stream:
                        GoogleCastRemoteMediaClient.instance.mediaStatusStream,
                    builder: (context, statusSnapshot) =>
                        StreamBuilder<Duration>(
                      stream: GoogleCastRemoteMediaClient
                          .instance.playerPositionStream,
                      builder: (context, positionSnapshot) => _PlayerOverlay(
                        stream: stream,
                        controller: video,
                        selectedQuality: _quality,
                        isLandscape: _landscape,
                        onRotate: _toggleRotation,
                        onCast: _castCurrentVideo,
                        castActive: _castActive,
                        remotePlaying: _castActive
                            ? (statusSnapshot.hasData
                                ? statusSnapshot.data?.playerState ==
                                    CastMediaPlayerState.playing
                                : _remotePlaying)
                            : false,
                        remotePosition: positionSnapshot.data,
                        remoteDuration:
                            statusSnapshot.data?.mediaInformation?.duration,
                        remoteVolume:
                            statusSnapshot.data?.volume.toDouble() ?? 1,
                        onPlayPause: _castPlayPause,
                        onSeekRelative: _castSeekRelative,
                        onFullscreen: _toggleFullscreen,
                        onVolume: _showVolumeDialog,
                        onQualitySelected: (quality) =>
                            _selectQuality(stream, quality),
                        onNext: stream.nextEpisodeId == null
                            ? null
                            : () => _loadNext(stream.nextEpisodeId!),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PlayerOverlay extends StatelessWidget {
  const _PlayerOverlay({
    required this.stream,
    required this.controller,
    required this.selectedQuality,
    required this.isLandscape,
    required this.onRotate,
    required this.onCast,
    required this.castActive,
    required this.onPlayPause,
    required this.onSeekRelative,
    required this.remotePlaying,
    required this.remotePosition,
    required this.remoteDuration,
    required this.remoteVolume,
    required this.onFullscreen,
    required this.onVolume,
    required this.onQualitySelected,
    required this.onNext,
  });

  final EpisodeStream stream;
  final VideoPlayerController? controller;
  final String? selectedQuality;
  final bool isLandscape;
  final VoidCallback onRotate;
  final VoidCallback onCast;
  final bool castActive;
  final VoidCallback onPlayPause;
  final ValueChanged<int> onSeekRelative;
  final bool remotePlaying;
  final Duration? remotePosition;
  final Duration? remoteDuration;
  final double remoteVolume;
  final VoidCallback onFullscreen;
  final VoidCallback onVolume;
  final ValueChanged<String> onQualitySelected;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final video = controller;
    final ready = video != null && video.value.isInitialized;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.75),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.78),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(LucideIcons.arrowLeft),
                ),
                Expanded(
                  child: Text(
                    stream.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  tooltip: isLandscape ? 'Voltar para retrato' : 'Girar tela',
                  onPressed: onRotate,
                  icon: const Icon(LucideIcons.rotateCw),
                ),
                IconButton(
                  tooltip: 'Tela cheia',
                  onPressed: onFullscreen,
                  icon: const Icon(LucideIcons.maximize),
                ),
                IconButton(
                  tooltip: castActive ? 'Volume da TV' : 'Volume indisponível',
                  onPressed: castActive ? onVolume : null,
                  icon: Icon(
                    remoteVolume <= 0
                        ? LucideIcons.volumeX
                        : LucideIcons.volume2,
                  ),
                ),
                IconButton(
                  tooltip: 'Assistir na TV',
                  onPressed: onCast,
                  icon: Icon(
                    LucideIcons.cast,
                    color: castActive ? AppTheme.primary : null,
                  ),
                ),
                if (stream.streams.length > 1)
                  PopupMenuButton<String>(
                    tooltip: 'Qualidade',
                    initialValue: selectedQuality,
                    icon: const Icon(LucideIcons.settings2),
                    onSelected: onQualitySelected,
                    itemBuilder: (context) => [
                      for (final key in stream.streams.keys)
                        PopupMenuItem(
                          value: key,
                          child: Row(
                            children: [
                              if (key == selectedQuality)
                                const Icon(LucideIcons.check, size: 16)
                              else
                                const SizedBox(width: 16),
                              const SizedBox(width: 8),
                              Text(_qualityLabel(key)),
                            ],
                          ),
                        ),
                    ],
                  ),
                if (onNext != null)
                  IconButton(
                    tooltip: 'Proximo episodio',
                    onPressed: onNext,
                    icon: const Icon(LucideIcons.chevronRight),
                  ),
              ],
            ),
            const Spacer(),
            if (ready)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Botão voltar 10 segundos
                        IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          onPressed: () {
                            onSeekRelative(-10);
                          },
                          icon: const Icon(LucideIcons.rewind, size: 20),
                          tooltip: 'Voltar 10s',
                        ),
                        const SizedBox(width: 8),
                        // Botão play/pause
                        IconButton.filled(
                          onPressed: () {
                            onPlayPause();
                          },
                          icon: Icon(
                            (castActive ? remotePlaying : video.value.isPlaying)
                                ? LucideIcons.pause
                                : LucideIcons.play,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Botão avançar 10 segundos
                        IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          onPressed: () {
                            onSeekRelative(10);
                          },
                          icon: const Icon(LucideIcons.fastForward, size: 20),
                          tooltip: 'Avançar 10s',
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: castActive && remoteDuration != null
                              ? Column(
                                  children: [
                                    Slider(
                                      value: (remotePosition ?? Duration.zero)
                                          .inMilliseconds
                                          .clamp(
                                              0, remoteDuration!.inMilliseconds)
                                          .toDouble(),
                                      min: 0,
                                      max: remoteDuration!.inMilliseconds
                                          .toDouble(),
                                      onChanged: (value) {
                                        GoogleCastRemoteMediaClient.instance
                                            .seek(
                                          GoogleCastMediaSeekOption(
                                            position: Duration(
                                                milliseconds: value.round()),
                                          ),
                                        );
                                      },
                                      activeColor: AppTheme.primary,
                                      inactiveColor: Colors.white24,
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '${_formatDuration(remotePosition ?? Duration.zero)} / ${_formatDuration(remoteDuration!)}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white70),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    VideoProgressIndicator(
                                      video,
                                      allowScrubbing: true,
                                      colors: const VideoProgressColors(
                                        playedColor: AppTheme.primary,
                                        bufferedColor: Color(0x66FFFFFF),
                                        backgroundColor: Color(0x33FFFFFF),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '${_formatDuration(video.value.position)} / ${_formatDuration(video.value.duration)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                    if ((stream.nextEpisodeTitle ?? '').isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.sizeOf(context).width - 40,
                          ),
                          child: TextButton.icon(
                            onPressed: onNext,
                            icon: const Icon(
                              LucideIcons.chevronRight,
                              size: 18,
                            ),
                            label: Flexible(
                              child: Text(
                                stream.nextEpisodeTitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlayerError extends StatelessWidget {
  const _PlayerError({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.mutedOf(context)),
          ),
        ),
      ),
    );
  }
}

String _formatDuration(Duration value) {
  final hours = value.inHours;
  final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
}

String? _bestQuality(EpisodeStream stream) {
  for (final key in const ['fhd', 'mhd', 'shd']) {
    if (stream.streams[key] != null) return key;
  }
  return stream.streams.isEmpty ? null : stream.streams.keys.first;
}

String _qualityLabel(String key) {
  return switch (key) {
    'fhd' => '1080p',
    'mhd' => '720p',
    'shd' => '480p',
    _ => key.toUpperCase(),
  };
}

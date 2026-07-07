import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../core/ads/ad_manager.dart';
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
  Future<EpisodeStream>? _streamFuture;
  VideoPlayerController? _video;
  AppController? _appController;
  int? _currentEpisodeId;
  String? _quality;
  Duration _lastSavedPosition = Duration.zero;
  bool _showControls = true;
  bool _landscape = false;
  final AdManager _adManager = AdManager();

  @override
  void initState() {
    super.initState();
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
    final canResume =
        position > const Duration(seconds: 5) &&
        position < video.value.duration - const Duration(seconds: 8);
    if (canResume) {
      await video.seekTo(position);
    }
    _lastSavedPosition = video.value.position;
    video.addListener(_handleVideoTick);
    if (startPlaying) {
      await video.play();
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
    unawaited(_persistPlayback(notify: true));
    
    // Incrementar contador de vídeos assistidos
    _adManager.incrementVideoCount();
    
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _video?.dispose();
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

  /// Tenta mostrar anúncio antes de carregar próximo vídeo
  Future<void> _loadNextWithAd(int nextEpisodeId) async {
    // Verificar se deve mostrar anúncio
    if (_adManager.shouldShowAd()) {
      // Mostrar diálogo de preparação
      if (!mounted) return;
      
      final shouldContinue = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Anúncio'),
          content: const Text(
            'Assista a um pequeno anúncio para continuar assistindo gratuitamente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continuar'),
            ),
          ],
        ),
      );

      if (shouldContinue != true || !mounted) return;

      // Mostrar anúncio (com fallback automático entre plataformas)
      final adShown = await _adManager.showRewardedAd(
        onAdWatched: () {
          print('✅ Anúncio assistido, carregando próximo episódio');
        },
        onAdSkipped: () {
          print('⏭️ Anúncio pulado');
        },
      );

      if (adShown && !mounted) return;
      
      // Pequeno delay após anúncio
      if (adShown) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    // Carregar próximo episódio
    if (mounted) {
      await _load(nextEpisodeId);
    }
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
          final video = _video;
          if (stream.bestUrl == null) {
            return const _PlayerError(error: TomatoApi.maintenanceMessage);
          }
          return GestureDetector(
            onTap: () => setState(() => _showControls = !_showControls),
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
                  _PlayerOverlay(
                    stream: stream,
                    controller: video,
                    selectedQuality: _quality,
                    isLandscape: _landscape,
                    onRotate: _toggleRotation,
                    onQualitySelected: (quality) =>
                        _selectQuality(stream, quality),
                    onNext: stream.nextEpisodeId == null
                        ? null
                        : () => _loadNextWithAd(stream.nextEpisodeId!),
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
    required this.onQualitySelected,
    required this.onNext,
  });

  final EpisodeStream stream;
  final VideoPlayerController? controller;
  final String? selectedQuality;
  final bool isLandscape;
  final VoidCallback onRotate;
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
                            backgroundColor: Colors.black.withValues(alpha: 0.5),
                          ),
                          onPressed: () {
                            final current = video.value.position;
                            final newPosition = current - const Duration(seconds: 10);
                            video.seekTo(newPosition.isNegative ? Duration.zero : newPosition);
                          },
                          icon: const Icon(LucideIcons.rewind, size: 20),
                          tooltip: 'Voltar 10s',
                        ),
                        const SizedBox(width: 8),
                        // Botão play/pause
                        IconButton.filled(
                          onPressed: () {
                            video.value.isPlaying
                                ? video.pause()
                                : video.play();
                          },
                          icon: Icon(
                            video.value.isPlaying
                                ? LucideIcons.pause
                                : LucideIcons.play,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Botão avançar 10 segundos
                        IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withValues(alpha: 0.5),
                          ),
                          onPressed: () {
                            final current = video.value.position;
                            final duration = video.value.duration;
                            final newPosition = current + const Duration(seconds: 10);
                            video.seekTo(newPosition > duration ? duration : newPosition);
                          },
                          icon: const Icon(LucideIcons.fastForward, size: 20),
                          tooltip: 'Avançar 10s',
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: VideoProgressIndicator(
                            video,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: AppTheme.primary,
                              bufferedColor: Color(0x66FFFFFF),
                              backgroundColor: Color(0x33FFFFFF),
                            ),
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

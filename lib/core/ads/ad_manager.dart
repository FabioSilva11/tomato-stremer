import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';  // Temporariamente removido
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

/// Plataforma de anúncios disponível
enum AdPlatform {
  admob,
  unity,
}

/// Tipo de anúncio
enum AdType {
  rewarded,
  interstitial,
  banner,
}

/// Gerenciador unificado de anúncios com redundância
/// Implementa rotação entre AdMob e Unity Ads
class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  // ============= IDs DO ADMOB (PRODUÇÃO) =============
  // App ID: ca-app-pub-6598765502914364~1736433666
  static const String _admobRewardedId = 'ca-app-pub-6598765502914364/1896215768';
  static const String _admobBannerId = 'ca-app-pub-6598765502914364/2213698978';

  // ============= IDs DO UNITY ADS (PRODUÇÃO) =============
  static const String _unityGameIdAndroid = '5740617';
  static const String _unityRewardedId = 'Rewarded_Android';
  static const String _unityBannerId = 'Banner_Android';

  // Estado
  bool _initialized = false;
  bool _admobAvailable = false;
  bool _unityAvailable = false;
  AdPlatform _currentPlatform = AdPlatform.admob;
  
  // Controle de rotação
  int _admobSuccessCount = 0;
  int _unitySuccessCount = 0;
  int _admobFailCount = 0;
  int _unityFailCount = 0;
  
  // Cache de anúncios
  // RewardedAd? _admobRewardedAd;  // Temporariamente removido
  // BannerAd? _admobBannerAd;     // Temporariamente removido
  bool _isRewardedAdReady = false;

  // Políticas de exibição
  int _videosWatchedCount = 0;
  DateTime? _lastAdShown;
  static const int _minVideosBetweenAds = 2;
  static const int _minMinutesBetweenAds = 5;

  /// Inicializa ambas as plataformas de anúncios
  Future<void> initialize({bool useTestAds = false}) async {
    if (_initialized) return;

    print('🎯 Inicializando gerenciador de anúncios...');

    // Inicializar AdMob
    await _initializeAdMob(testMode: useTestAds);
    
    // Inicializar Unity Ads
    await _initializeUnityAds(testMode: useTestAds);

    _initialized = true;
    
    // Definir plataforma inicial baseada em disponibilidade
    _selectBestPlatform();
    
    print('✅ Gerenciador de anúncios inicializado');
    print('   - AdMob: ${_admobAvailable ? "✓" : "✗"}');
    print('   - Unity: ${_unityAvailable ? "✓" : "✗"}');
    print('   - Plataforma atual: ${_currentPlatform.name}');
  }

  /// Inicializa AdMob
  Future<void> _initializeAdMob({required bool testMode}) async {
    try {
      // Temporariamente desabilitado AdMob
      /*
      await MobileAds.instance.initialize();
      
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          maxAdContentRating: MaxAdContentRating.t,
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
          tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
          testDeviceIds: testMode ? ['TEST_DEVICE_ID_HERE'] : [],
        ),
      );

      _admobAvailable = true;
      await _loadAdMobRewardedAd();
      */
      _admobAvailable = false;  // Forçar false por enquanto
      print('⚠️ AdMob temporariamente desabilitado');
    } catch (e) {
      _admobAvailable = false;
      print('❌ Erro ao inicializar AdMob: $e');
    }
  }

  /// Inicializa Unity Ads
  Future<void> _initializeUnityAds({required bool testMode}) async {
    try {
      await UnityAds.init(
        gameId: _unityGameIdAndroid,
        testMode: testMode,
        onComplete: () {
          print('✅ Unity Ads inicializado com sucesso');
          _unityAvailable = true;
          _loadUnityRewardedAd();
        },
        onFailed: (error, message) {
          print('❌ Erro ao inicializar Unity Ads: $error - $message');
          _unityAvailable = false;
        },
      );
    } catch (e) {
      _unityAvailable = false;
      print('❌ Erro ao inicializar Unity Ads: $e');
    }
  }

  /// Carrega anúncio premiado do AdMob
  Future<void> _loadAdMobRewardedAd() async {
    // Temporariamente desabilitado
    /*
    if (_admobRewardedAd != null) return;

    try {
      await RewardedAd.load(
        adUnitId: _admobRewardedId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _admobRewardedAd = ad;
            _isRewardedAdReady = true;
            _admobSuccessCount++;
            print('✅ AdMob rewarded ad carregado');
            
            _admobRewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _admobRewardedAd = null;
                _isRewardedAdReady = false;
                _loadAdMobRewardedAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                print('❌ Erro ao exibir AdMob ad: $error');
                ad.dispose();
                _admobRewardedAd = null;
                _isRewardedAdReady = false;
                _admobFailCount++;
                _loadAdMobRewardedAd();
              },
            );
          },
          onAdFailedToLoad: (error) {
            print('❌ Erro ao carregar AdMob rewarded ad: $error');
            _isRewardedAdReady = false;
            _admobFailCount++;
            
            Future.delayed(const Duration(seconds: 30), () {
              _loadAdMobRewardedAd();
            });
          },
        ),
      );
    } catch (e) {
      print('❌ Exceção ao carregar AdMob ad: $e');
      _admobFailCount++;
    }
    */
    print('⚠️ AdMob ads temporariamente desabilitados');
  }

  /// Carrega anúncio premiado do Unity
  void _loadUnityRewardedAd() {
    if (!_unityAvailable) return;

    UnityAds.load(
      placementId: _unityRewardedId,
      onComplete: (placementId) {
        print('✅ Unity rewarded ad carregado: $placementId');
        _unitySuccessCount++;
      },
      onFailed: (placementId, error, message) {
        print('❌ Erro ao carregar Unity ad: $error - $message');
        _unityFailCount++;
        
        Future.delayed(const Duration(seconds: 30), () {
          _loadUnityRewardedAd();
        });
      },
    );
  }

  /// Carrega banner do AdMob
  Future<void> loadAdMobBanner() async {
    // Temporariamente desabilitado
    /*
    if (_admobBannerAd != null) return _admobBannerAd;

    try {
      final banner = BannerAd(
        adUnitId: _admobBannerId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print('✅ AdMob banner carregado');
            _admobBannerAd = ad as BannerAd;
          },
          onAdFailedToLoad: (ad, error) {
            print('❌ Erro ao carregar AdMob banner: $error');
            ad.dispose();
            _admobBannerAd = null;
          },
        ),
      );

      await banner.load();
      return banner;
    } catch (e) {
      print('❌ Exceção ao carregar AdMob banner: $e');
      return null;
    }
    */
    print('⚠️ AdMob banner temporariamente desabilitado');
  }

  /// Seleciona a melhor plataforma baseada em performance
  void _selectBestPlatform() {
    if (!_admobAvailable && !_unityAvailable) {
      print('⚠️ Nenhuma plataforma de anúncios disponível');
      return;
    }

    if (!_admobAvailable) {
      _currentPlatform = AdPlatform.unity;
      return;
    }

    if (!_unityAvailable) {
      _currentPlatform = AdPlatform.admob;
      return;
    }

    // Calcular taxa de sucesso
    final admobTotal = _admobSuccessCount + _admobFailCount;
    final unityTotal = _unitySuccessCount + _unityFailCount;
    
    final admobRate = admobTotal > 0 ? _admobSuccessCount / admobTotal : 0.5;
    final unityRate = unityTotal > 0 ? _unitySuccessCount / unityTotal : 0.5;

    // Rotação 50/50 com peso baseado em performance
    final random = Random().nextDouble();
    
    if (admobRate > unityRate) {
      _currentPlatform = random < 0.6 ? AdPlatform.admob : AdPlatform.unity;
    } else if (unityRate > admobRate) {
      _currentPlatform = random < 0.6 ? AdPlatform.unity : AdPlatform.admob;
    } else {
      _currentPlatform = random < 0.5 ? AdPlatform.admob : AdPlatform.unity;
    }

    print('🔄 Plataforma selecionada: ${_currentPlatform.name}');
  }

  /// Verifica se deve mostrar anúncio baseado em políticas
  bool shouldShowAd() {
    if (_videosWatchedCount < _minVideosBetweenAds) {
      return false;
    }

    if (_lastAdShown != null) {
      final minutesSinceLastAd = DateTime.now().difference(_lastAdShown!).inMinutes;
      if (minutesSinceLastAd < _minMinutesBetweenAds) {
        return false;
      }
    }

    return _admobAvailable || _unityAvailable;
  }

  /// Mostra anúncio premiado com fallback automático
  Future<bool> showRewardedAd({
    required Function() onAdWatched,
    Function()? onAdSkipped,
  }) async {
    if (!shouldShowAd()) {
      print('⚠️ Políticas não permitem exibir anúncio ainda');
      return false;
    }

    _selectBestPlatform(); // Atualizar plataforma antes de exibir

    bool success = false;

    // Tentar plataforma principal
    if (_currentPlatform == AdPlatform.admob && _admobAvailable) {
      // success = await _showAdMobRewardedAd(onAdWatched: onAdWatched);  // Temporariamente desabilitado
      success = false;  // Forçar falso para usar Unity como fallback
    } else if (_currentPlatform == AdPlatform.unity && _unityAvailable) {
      success = await _showUnityRewardedAd(onAdWatched: onAdWatched);
    }

    // Fallback para plataforma alternativa
    if (!success) {
      print('🔄 Tentando plataforma alternativa...');
      
      if (_currentPlatform == AdPlatform.admob && _unityAvailable) {
        success = await _showUnityRewardedAd(onAdWatched: onAdWatched);
      } else if (_currentPlatform == AdPlatform.unity && _admobAvailable) {
        // success = await _showAdMobRewardedAd(onAdWatched: onAdWatched);  // Temporariamente desabilitado
        success = false;
      }
    }

    if (!success && onAdSkipped != null) {
      onAdSkipped();
    }

    return success;
  }

  /// Mostra anúncio premiado do AdMob
  Future<bool> _showAdMobRewardedAd({required Function() onAdWatched}) async {
    // Temporariamente desabilitado
    /*
    final ad = _admobRewardedAd;
    if (ad == null || !_isRewardedAdReady) {
      print('❌ AdMob ad não está pronto');
      _admobFailCount++;
      return false;
    }

    try {
      await ad.show(
        onUserEarnedReward: (ad, reward) {
          print('✅ Usuário assistiu AdMob ad completo');
          _lastAdShown = DateTime.now();
          _videosWatchedCount = 0;
          _admobSuccessCount++;
          onAdWatched();
        },
      );
      return true;
    } catch (e) {
      print('❌ Erro ao exibir AdMob ad: $e');
      _admobFailCount++;
      return false;
    }
    */
    print('⚠️ AdMob ads temporariamente desabilitados');
    return false;
  }

  /// Mostra anúncio premiado do Unity
  Future<bool> _showUnityRewardedAd({required Function() onAdWatched}) async {
    if (!_unityAvailable) {
      print('❌ Unity Ads não disponível');
      return false;
    }

    final completer = Completer<bool>();

    try {
      UnityAds.showVideoAd(
        placementId: _unityRewardedId,
        onComplete: (placementId) {
          print('✅ Usuário assistiu Unity ad completo');
          _lastAdShown = DateTime.now();
          _videosWatchedCount = 0;
          _unitySuccessCount++;
          onAdWatched();
          _loadUnityRewardedAd(); // Recarregar
          completer.complete(true);
        },
        onFailed: (placementId, error, message) {
          print('❌ Erro ao exibir Unity ad: $error - $message');
          _unityFailCount++;
          completer.complete(false);
        },
        onStart: (placementId) {
          print('▶️ Unity ad iniciado');
        },
        onSkipped: (placementId) {
          print('⏭️ Unity ad pulado');
          completer.complete(false);
        },
      );

      return await completer.future;
    } catch (e) {
      print('❌ Exceção ao exibir Unity ad: $e');
      _unityFailCount++;
      return false;
    }
  }

  /// Incrementa contador de vídeos assistidos
  void incrementVideoCount() {
    _videosWatchedCount++;
    print('📊 Vídeos assistidos: $_videosWatchedCount');
  }

  /// Reseta contador de vídeos
  void resetVideoCount() {
    _videosWatchedCount = 0;
  }

  /// Verifica se algum anúncio está pronto
  bool get isAdReady => _isRewardedAdReady || _unityAvailable;

  /// Obtém estatísticas de performance
  Map<String, dynamic> getStats() {
    return {
      'admob_available': _admobAvailable,
      'unity_available': _unityAvailable,
      'current_platform': _currentPlatform.name,
      'admob_success': _admobSuccessCount,
      'admob_fail': _admobFailCount,
      'unity_success': _unitySuccessCount,
      'unity_fail': _unityFailCount,
      'videos_watched': _videosWatchedCount,
      'last_ad_shown': _lastAdShown?.toIso8601String(),
    };
  }

  /// Limpa recursos
  void dispose() {
    // Temporariamente comentado
    /*
    _admobRewardedAd?.dispose();
    _admobBannerAd?.dispose();
    _admobRewardedAd = null;
    _admobBannerAd = null;
    */
    _isRewardedAdReady = false;
  }
}

/// Widget para exibir banner do AdMob ou Unity
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  // BannerAd? _bannerAd;  // Temporariamente comentado
  bool _isLoaded = false;
  bool _showUnityBanner = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    // Temporariamente desabilitado AdMob - usar apenas Unity
    /*
    final banner = await AdManager().loadAdMobBanner();

    if (banner != null && mounted) {
      setState(() {
        _bannerAd = banner;
        _isLoaded = true;
      });
    } else {
      // Fallback para Unity Banner
      setState(() {
        _showUnityBanner = true;
      });
    }
    */
    
    // Por enquanto, usar apenas Unity Banner
    setState(() {
      _showUnityBanner = true;
    });
  }

  @override
  void dispose() {
    // _bannerAd?.dispose();  // Temporariamente comentado
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showUnityBanner) {
      return UnityBannerAd(
        placementId: AdManager._unityBannerId,
        onLoad: (placementId) => print('Unity banner carregado: $placementId'),
        onFailed: (placementId, error, message) =>
            print('Unity banner erro: $error - $message'),
      );
    }

    // Temporariamente apenas Unity ou loading
    return const SizedBox(
      height: 50,
      child: Center(child: CircularProgressIndicator()),
    );
    
    /*
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
    */
  }
}

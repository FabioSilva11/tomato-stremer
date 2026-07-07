// Temporariamente desabilitado - todo o arquivo comentado até resolvermos a compatibilidade
/*
import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Serviço para gerenciar anúncios do AdMob
/// Implementa políticas de conteúdo e anúncios premiados entre vídeos
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  // ID do bloco de anúncio premiado
  static const String _rewardedAdUnitId = 'ca-app-pub-6598765502914364/1896215768';
  
  // IDs de teste (use durante desenvolvimento)
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;
  int _videosWatchedCount = 0;
  DateTime? _lastAdShown;

  // Configurações de política
  static const int _minVideosBetweenAds = 2; // Mostrar anúncio após N vídeos
  static const int _minMinutesBetweenAds = 5; // Tempo mínimo entre anúncios

  /// Inicializa o SDK do AdMob
  Future<void> initialize({bool useTestAds = false}) async {
    try {
      await MobileAds.instance.initialize();
      
      // Configurar classificação de conteúdo (importante para políticas do AdMob)
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          // Definir classificação máxima de anúncios
          // G: Geral, PG: Orientação parental, T: Adolescente, MA: Adulto
          maxAdContentRating: MaxAdContentRating.t, // Teen (13+)
          
          // Tags de conteúdo para crianças (COPPA compliance)
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
          tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
          
          // IDs de teste (adicione seus dispositivos de teste aqui)
          testDeviceIds: useTestAds ? ['YOUR_TEST_DEVICE_ID'] : [],
        ),
      );

      // Pré-carregar primeiro anúncio
      await loadRewardedAd(useTestAds: useTestAds);
    } catch (e) {
      print('Erro ao inicializar AdMob: $e');
    }
  }

  /// Carrega um anúncio premiado
  Future<void> loadRewardedAd({bool useTestAds = false}) async {
    if (_rewardedAd != null) {
      return; // Já existe um anúncio carregado
    }

    final adUnitId = useTestAds ? _testRewardedAdUnitId : _rewardedAdUnitId;

    try {
      await RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedAdReady = true;
            
            // Configurar callbacks do anúncio
            _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                print('Anúncio premiado exibido');
              },
              onAdDismissedFullScreenContent: (ad) {
                print('Anúncio premiado fechado');
                ad.dispose();
                _rewardedAd = null;
                _isRewardedAdReady = false;
                // Carregar próximo anúncio
                loadRewardedAd(useTestAds: useTestAds);
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                print('Erro ao exibir anúncio premiado: $error');
                ad.dispose();
                _rewardedAd = null;
                _isRewardedAdReady = false;
                // Tentar carregar novamente
                loadRewardedAd(useTestAds: useTestAds);
              },
            );
          },
          onAdFailedToLoad: (error) {
            print('Erro ao carregar anúncio premiado: $error');
            _isRewardedAdReady = false;
            
            // Tentar novamente após delay
            Future.delayed(const Duration(seconds: 30), () {
              loadRewardedAd(useTestAds: useTestAds);
            });
          },
        ),
      );
    } catch (e) {
      print('Exceção ao carregar anúncio premiado: $e');
    }
  }

  /// Verifica se deve mostrar anúncio baseado em políticas
  bool shouldShowAd() {
    // Verificar se tem anúncio disponível
    if (!_isRewardedAdReady || _rewardedAd == null) {
      return false;
    }

    // Verificar se assistiu vídeos suficientes
    if (_videosWatchedCount < _minVideosBetweenAds) {
      return false;
    }

    // Verificar tempo desde último anúncio
    if (_lastAdShown != null) {
      final minutesSinceLastAd = DateTime.now().difference(_lastAdShown!).inMinutes;
      if (minutesSinceLastAd < _minMinutesBetweenAds) {
        return false;
      }
    }

    return true;
  }

  /// Mostra anúncio premiado se disponível e políticas permitirem
  /// Retorna true se o anúncio foi exibido
  Future<bool> showRewardedAdIfReady({
    required Function() onAdWatched,
    Function()? onAdSkipped,
  }) async {
    if (!shouldShowAd()) {
      print('Anúncio não deve ser exibido ainda');
      return false;
    }

    final ad = _rewardedAd;
    if (ad == null) {
      return false;
    }

    bool adWatched = false;

    try {
      await ad.show(
        onUserEarnedReward: (ad, reward) {
          print('Usuário assistiu anúncio completo: ${reward.amount} ${reward.type}');
          adWatched = true;
          _lastAdShown = DateTime.now();
          _videosWatchedCount = 0; // Resetar contador
          onAdWatched();
        },
      );
      return true;
    } catch (e) {
      print('Erro ao exibir anúncio: $e');
      if (!adWatched && onAdSkipped != null) {
        onAdSkipped();
      }
      return false;
    }
  }

  /// Incrementa contador de vídeos assistidos
  void incrementVideoCount() {
    _videosWatchedCount++;
    print('Vídeos assistidos desde último anúncio: $_videosWatchedCount');
  }

  /// Reseta contador de vídeos (usar quando necessário)
  void resetVideoCount() {
    _videosWatchedCount = 0;
  }

  /// Verifica se anúncio está pronto
  bool get isAdReady => _isRewardedAdReady;

  /// Libera recursos
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedAdReady = false;
  }
}

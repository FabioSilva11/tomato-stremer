import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import '../models/feed_models.dart';
import '../models/library_models.dart';
import '../storage/app_database.dart';

/// Serviço de notificações para novos episódios
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  static const String _channelId = 'new_episodes';
  static const String _channelName = 'Novos Episódios';
  static const String _channelDescription =
      'Notificações sobre novos episódios de animes favoritos';

  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Criar canal de notificação
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  /// Callback quando usuário toca na notificação
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final episodeId = data['episodeId'] as int?;
      final animeId = data['animeId'] as int?;

      // Aqui você pode navegar para o episódio/anime
      // Isso será implementado quando integrado com a navegação do app
      print('Notificação tocada: episodeId=$episodeId, animeId=$animeId');
    } catch (e) {
      print('Erro ao processar payload da notificação: $e');
    }
  }

  /// Mostra notificação de novo episódio
  Future<void> showNewEpisodeNotification({
    required int id,
    required String animeTitle,
    required String episodeTitle,
    required int episodeId,
    required int animeId,
  }) async {
    if (!_initialized) await initialize();

    final payload = jsonEncode({
      'episodeId': episodeId,
      'animeId': animeId,
    });

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Novo episódio disponível',
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      id,
      'Novo episódio: $animeTitle',
      episodeTitle,
      details,
      payload: payload,
    );
  }

  /// Solicita permissões de notificação (Android 13+)
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android == null) return false;

    // Android 13+ requer permissão explícita
    final granted = await android.requestNotificationsPermission();
    return granted ?? false;
  }

  /// Verifica se notificações estão ativas
  Future<bool> areNotificationsEnabled() async {
    if (!_initialized) await initialize();

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android == null) return false;

    final enabled = await android.areNotificationsEnabled();
    return enabled ?? false;
  }

  /// Cancela todas as notificações
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Cancela notificação específica
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}

/// Serviço de verificação em background para novos episódios
class EpisodeCheckService {
  static const String taskName = 'checkNewEpisodes';

  /// Inicializa o worker de background
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  /// Registra tarefa periódica para verificar novos episódios
  static Future<void> registerPeriodicCheck({
    Duration frequency = const Duration(hours: 6),
  }) async {
    await Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: frequency,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
    );
  }

  /// Cancela verificação periódica
  static Future<void> cancelPeriodicCheck() async {
    await Workmanager().cancelByUniqueName(taskName);
  }

  /// Executa verificação única agora
  static Future<void> checkNow() async {
    await Workmanager().registerOneOffTask(
      '${taskName}_once',
      taskName,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}

/// Callback do Workmanager (deve ser top-level function)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == EpisodeCheckService.taskName) {
        await _checkForNewEpisodes();
        return true;
      }
      return false;
    } catch (e) {
      print('Erro na tarefa de background: $e');
      return false;
    }
  });
}

/// Verifica por novos episódios (executado em background)
Future<void> _checkForNewEpisodes() async {
  try {
    // Aqui você faria a verificação com sua API
    // Por enquanto, vamos simular com o banco de dados local
    
    final database = AppDatabase();
    final notifications = await database.loadNotifications();
    
    // Filtrar apenas notificações não lidas
    final unread = notifications.where((n) => n.unread).toList();
    
    if (unread.isEmpty) return;

    final notificationService = NotificationService();
    await notificationService.initialize();

    // Mostrar notificações para episódios não lidos
    for (final notification in unread.take(5)) { // Limitar a 5 notificações
      await notificationService.showNewEpisodeNotification(
        id: notification.id,
        animeTitle: notification.animeName,
        episodeTitle: notification.episodeName,
        episodeId: notification.episodeId,
        animeId: notification.animeId,
      );
    }

    await database.close();
  } catch (e) {
    print('Erro ao verificar novos episódios: $e');
  }
}

/// Gerenciador de notificações de episódios favoritos
class FavoriteEpisodesNotifier {
  final AppDatabase _database;
  final NotificationService _notificationService;

  FavoriteEpisodesNotifier({
    required AppDatabase database,
    required NotificationService notificationService,
  })  : _database = database,
        _notificationService = notificationService;

  /// Verifica e notifica sobre novos episódios de animes favoritos
  Future<int> checkAndNotifyNewEpisodes(FeedResponse feed) async {
    // Sincronizar com banco de dados
    final newCount = await _database.syncNewEpisodes(feed);
    
    if (newCount == 0) return 0;

    // Carregar favoritos
    final favorites = await _database.loadFavorites();
    if (favorites.isEmpty) return 0;

    final favoriteIds = favorites.map((f) => f.animeId).toSet();

    // Carregar notificações não lidas
    final notifications = await _database.loadNotifications();
    final unreadNotifications = notifications
        .where((n) => n.unread && favoriteIds.contains(n.animeId))
        .toList();

    // Mostrar notificações
    for (final notification in unreadNotifications.take(3)) {
      await _notificationService.showNewEpisodeNotification(
        id: notification.id,
        animeTitle: notification.animeName,
        episodeTitle: notification.episodeName,
        episodeId: notification.episodeId,
        animeId: notification.animeId,
      );
    }

    return unreadNotifications.length;
  }

  /// Habilita notificações para novos episódios
  Future<bool> enableNotifications() async {
    final enabled = await _notificationService.areNotificationsEnabled();
    if (!enabled) {
      return await _notificationService.requestPermissions();
    }
    
    // Registrar verificação periódica
    await EpisodeCheckService.registerPeriodicCheck(
      frequency: const Duration(hours: 6),
    );
    
    return true;
  }

  /// Desabilita notificações
  Future<void> disableNotifications() async {
    await EpisodeCheckService.cancelPeriodicCheck();
  }
}

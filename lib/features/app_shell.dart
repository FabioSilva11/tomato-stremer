import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/state/app_controller.dart';
import 'home/home_page.dart';
import 'library/favorites_page.dart';
import 'library/history_page.dart';
import 'library/notifications_page.dart';
import 'search/search_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  static final _telegramGroupUri = Uri.parse('https://t.me/sketcware_ia');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _maybeShowTelegramInvite());
  }

  Future<void> _maybeShowTelegramInvite() async {
    if (!mounted) return;
    final controller = context.read<AppController>();
    final shouldShow = await controller.registerAppEntry();
    if (!shouldShow || !mounted) return;
    await FirebaseAnalytics.instance.logEvent(
      name: 'telegram_invite_shown',
      parameters: const {'group': 'sketchware_ia'},
    );
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Entre no nosso grupo'),
        content: const Text(
          'Faça parte do grupo Sketchware IA no Telegram e acompanhe novidades, dicas e atualizações.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              FirebaseAnalytics.instance.logEvent(
                name: 'telegram_invite_cancel',
                parameters: const {'group': 'sketchware_ia'},
              );
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final opened = await launchUrl(
                _telegramGroupUri,
                mode: LaunchMode.externalApplication,
              );
              await FirebaseAnalytics.instance.logEvent(
                name: 'telegram_invite_join',
                parameters: <String, Object>{
                  'group': 'sketchware_ia',
                  'opened': opened,
                },
              );
              if (context.mounted) Navigator.of(context).pop();
              if (!opened && mounted) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                      content: Text('Não foi possível abrir o Telegram.')),
                );
              }
            },
            child: const Text('Entrar no grupo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = context.select<AppController, int>(
      (controller) => controller.unreadNotifications,
    );
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomePage(onOpenSearch: () => _select(1)),
          const SearchPage(showBackButton: false),
          const FavoritesPage(),
          const HistoryPage(),
          const NotificationsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          const NavigationDestination(
            icon: Icon(LucideIcons.home),
            label: 'Inicio',
          ),
          const NavigationDestination(
            icon: Icon(LucideIcons.search),
            label: 'Busca',
          ),
          const NavigationDestination(
            icon: Icon(LucideIcons.heart),
            label: 'Salvos',
          ),
          const NavigationDestination(
            icon: Icon(LucideIcons.history),
            label: 'Hist.',
          ),
          NavigationDestination(
            icon: _NotificationIcon(unread: unread),
            selectedIcon: _NotificationIcon(unread: unread, selected: true),
            label: 'Avisos',
          ),
        ],
      ),
    );
  }

  void _select(int index) {
    setState(() => _index = index);
    if (index == 5) {
      context.read<AppController>().markNotificationsRead();
    }
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.unread, this.selected = false});

  final int unread;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: unread > 0,
      label: Text(unread > 99 ? '99+' : '$unread'),
      child: Icon(selected ? LucideIcons.bellRing : LucideIcons.bell),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

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
    if (index == 4) {
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

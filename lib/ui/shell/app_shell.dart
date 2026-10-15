import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../pages/gallery_page.dart';
import '../pages/generate_page.dart';
import '../pages/queue_page.dart';
import '../pages/settings_page.dart';
import '../pages/workflows_page.dart';
import 'side_nav.dart';
import 'title_bar.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 720;

    const pages = [
      GeneratePage(),
      GalleryPage(),
      QueuePage(),
      WorkflowsPage(),
      SettingsPage(),
    ];

    final destinations = <SideNavDestination>[
      (
        icon: Icons.auto_awesome_outlined,
        selectedIcon: Icons.auto_awesome,
        label: l10n.navGenerate,
      ),
      (
        icon: Icons.photo_library_outlined,
        selectedIcon: Icons.photo_library,
        label: l10n.navGallery,
      ),
      (
        icon: Icons.playlist_play_outlined,
        selectedIcon: Icons.playlist_play,
        label: l10n.navQueue,
      ),
      (
        icon: Icons.account_tree_outlined,
        selectedIcon: Icons.account_tree,
        label: l10n.navWorkflows,
      ),
      (
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: l10n.navSettings,
      ),
    ];

    return ListenableBuilder(
      listenable: Listenable.merge([state, state.settings]),
      builder: (context, _) {
        final index = state.tabIndex;
        final body = Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (context) => Material(
              type: MaterialType.transparency,
              child: IndexedStack(index: index, children: pages),
            ),
          ),
        );

        void onSelected(int i) => state.selectTab(i);

        if (wide) {
          final collapsed = state.settings.sidebarCollapsed;
          return Scaffold(
            body: Column(
              children: [
                if (isDesktopPlatform)
                  AppTitleBar(
                    title: l10n.appTitle,
                    windowActions: state.windowActions,
                  ),
                Expanded(
                  child: Row(
                    children: [
                      SideNav(
                        selectedIndex: index,
                        onSelected: onSelected,
                        destinations: destinations,
                        collapsed: collapsed,
                        onToggleCollapsed: () => state.settings
                            .setSidebarCollapsed(!collapsed, state.prefs),
                        toggleLabel: collapsed
                            ? l10n.expandSidebar
                            : l10n.collapseSidebar,
                      ),
                      Expanded(child: body),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          drawer: Drawer(
            child: SafeArea(
              child: ListView(
                children: [
                  for (var i = 0; i < destinations.length; i++)
                    ListTile(
                      leading: Icon(destinations[i].icon),
                      title: Text(destinations[i].label),
                      selected: i == index,
                      onTap: () {
                        Navigator.of(context).pop();
                        onSelected(i);
                      },
                    ),
                ],
              ),
            ),
          ),
          body: SafeArea(child: body),
          bottomNavigationBar: Builder(
            builder: (context) => NavigationBar(
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              selectedIndex: index < 4 ? index : 4,
              onDestinationSelected: (i) =>
                  i >= 4 ? Scaffold.of(context).openDrawer() : onSelected(i),
              destinations: [
                for (final d in destinations.take(4))
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ),
                NavigationDestination(
                  icon: const Icon(Icons.menu),
                  label: l10n.navMore,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

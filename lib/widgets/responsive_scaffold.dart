import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class ResponsiveScaffold extends StatelessWidget {
  final String title;
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final List<NavigationDestinationData> destinations;
  final List<Widget> pages;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const ResponsiveScaffold({
    super.key,
    required this.title,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.pages,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: actions,
        elevation: 0,
        centerTitle: !isDesktop,
      ),
      drawer: (!isDesktop && !isTablet) ? _buildDrawer(context) : null,
      body: Row(
        children: [
          if (isDesktop || isTablet)
            _buildNavigationRail(context, isDesktop),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1600),
                  child: KeyedSubtree(
                    key: ValueKey<int>(selectedIndex),
                    child: pages[selectedIndex],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: (!isDesktop && !isTablet)
          ? _buildBottomBar(context)
          : null,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildNavigationRail(BuildContext context, bool isDesktop) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: NavigationRail(
        extended: isDesktop,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: Colors.transparent,
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
        ),
        labelType: isDesktop ? NavigationRailLabelType.none : NavigationRailLabelType.all,
        destinations: destinations.map((d) => NavigationRailDestination(
          icon: Icon(d.icon),
          selectedIcon: Icon(d.selectedIcon ?? d.icon),
          label: Text(d.label),
        )).toList(),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations.map((d) => NavigationDestination(
        icon: Icon(d.icon),
        selectedIcon: Icon(d.selectedIcon ?? d.icon),
        label: d.label,
      )).toList(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                final d = destinations[index];
                return ListTile(
                  leading: Icon(
                    d.icon,
                    color: selectedIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(
                    d.label,
                    style: TextStyle(
                      fontWeight: selectedIndex == index
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: selectedIndex == index
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  selected: selectedIndex == index,
                  onTap: () {
                    onDestinationSelected(index);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationDestinationData {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const NavigationDestinationData({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

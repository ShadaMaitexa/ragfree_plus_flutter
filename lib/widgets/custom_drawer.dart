import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String role;
  final List<DrawerItem> menuItems;
  final Function(int) onSelect;
  final String? userName;
  final String? userEmail;
  final VoidCallback? onLogout;

  const CustomDrawer({
    super.key,
    required this.role,
    required this.menuItems,
    required this.onSelect,
    this.userName,
    this.userEmail,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildMenuItems(context)),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getRoleIcon(role), color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RagFree+',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      role,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (userName != null) ...[
            const SizedBox(height: 16),
            Text(
              userName!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (userEmail != null)
              Text(
                userEmail!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return ListTile(
          leading: Icon(
            item.icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            item.label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          onTap: () {
            Navigator.pop(context);
            onSelect(index);
          },
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              onLogout?.call();
            },
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return Icons.school;
      case 'parent':
        return Icons.family_restroom;
      case 'admin':
        return Icons.admin_panel_settings;
      case 'counsellor':
        return Icons.psychology;
      case 'warden':
        return Icons.house;
      case 'police':
        return Icons.local_police;
      default:
        return Icons.person;
    }
  }
}

class DrawerItem {
  final IconData icon;
  final String label;

  const DrawerItem({required this.icon, required this.label});
}

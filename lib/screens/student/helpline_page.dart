import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelplinePage extends StatelessWidget {
  const HelplinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Helpline & Resources'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [color.withValues(alpha: 0.05), Colors.transparent]
                : [Colors.grey.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, 'Emergency Helplines', Icons.phone),
              const SizedBox(height: 16),
              _buildHelplineCard(
                context,
                'National Anti-Ragging Helpline',
                '1800-180-5522',
                '24/7 Toll-free helpline',
                Colors.red,
                'tel:18001805522',
              ),
              const SizedBox(height: 12),
              _buildHelplineCard(
                context,
                'UGC Anti-Ragging Helpline',
                '1800-180-5522',
                'University Grants Commission',
                Colors.blue,
                'tel:18001805522',
              ),
              const SizedBox(height: 12),
              _buildHelplineCard(
                context,
                'Police Emergency',
                '100',
                'Emergency police assistance',
                Colors.orange,
                'tel:100',
              ),
              const SizedBox(height: 12),
              _buildHelplineCard(
                context,
                'Women Helpline',
                '1091',
                '24/7 Women support',
                Colors.purple,
                'tel:1091',
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'Campus Resources', Icons.school),
              const SizedBox(height: 16),
              _buildResourceCard(
                context,
                'Campus Security',
                'Contact campus security for immediate assistance',
                Icons.security,
                Colors.green,
                'tel:+911234567890',
              ),
              const SizedBox(height: 12),
              _buildResourceCard(
                context,
                'Student Counseling',
                'Mental health and support services',
                Icons.psychology,
                Colors.blue,
                null,
              ),
              const SizedBox(height: 12),
              _buildResourceCard(
                context,
                'Medical Emergency',
                'Campus medical center',
                Icons.local_hospital,
                Colors.red,
                'tel:+911234567891',
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'UGC Regulations', Icons.gavel),
              const SizedBox(height: 16),
              _buildUGCCard(
                context,
                'UGC Regulations on Curbing the Menace of Ragging in Higher Educational Institutions, 2009',
                'Comprehensive regulations against ragging',
              ),
              const SizedBox(height: 12),
              _buildUGCCard(
                context,
                'Legal Provisions',
                'Indian Penal Code sections applicable to ragging cases',
              ),
              const SizedBox(height: 12),
              _buildUGCCard(
                context,
                'Institutional Responsibilities',
                'Duties and responsibilities of educational institutions',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }

  Widget _buildHelplineCard(
    BuildContext context,
    String title,
    String number,
    String subtitle,
    Color color,
    String? phoneUrl,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: phoneUrl != null
            ? () => _makePhoneCall(phoneUrl)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.phone, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      number,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
              if (phoneUrl != null)
                Icon(Icons.call, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    String? actionUrl,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: actionUrl != null
            ? () => _makePhoneCall(actionUrl)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUGCCard(
    BuildContext context,
    String title,
    String description,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}


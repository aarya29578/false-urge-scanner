import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../widgets/profile_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notificationsEnabled = true;

  void _showPlaceholderDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Authentication is not connected yet. This is a prototype action.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              ProfileHeader(
                name: mockUserProfile.name,
                email: mockUserProfile.email,
              ),
              const SizedBox(height: 28),
              ProfileSection(
                title: 'Personal Information',
                children: [
                  ProfileInfoRow(
                    label: 'Name',
                    value: mockUserProfile.name,
                    icon: Icons.person_outline_rounded,
                  ),
                  const Divider(),
                  ProfileInfoRow(
                    label: 'Email',
                    value: mockUserProfile.email,
                    icon: Icons.mail_outline_rounded,
                  ),
                  const Divider(),
                  ProfileInfoRow(
                    label: 'Member since',
                    value: mockUserProfile.memberSince,
                    icon: Icons.calendar_today_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ProfileSection(
                title: 'Your Activity',
                children: [
                  Row(
                    children: [
                      ActivityStatCard(
                        title: 'Images Scanned',
                        value: mockActivitySummary.imagesScanned,
                      ),
                      const SizedBox(width: 12),
                      ActivityStatCard(
                        title: 'Genuine',
                        value: mockActivitySummary.genuineResults,
                      ),
                      const SizedBox(width: 12),
                      ActivityStatCard(
                        title: 'Suspicious',
                        value: mockActivitySummary.suspiciousResults,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ProfileSection(
                title: 'Settings',
                children: [
                  const SettingsTile(
                    title: 'Protection Mode',
                    subtitle: 'Active',
                    leadingIcon: Icons.shield_rounded,
                  ),
                  const Divider(),
                  SettingsTile(
                    title: 'Notifications',
                    subtitle: 'Receive Word Scanner alerts',
                    leadingIcon: Icons.notifications_active_outlined,
                    trailing: Switch(
                      value: notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          notificationsEnabled = value;
                        });
                      },
                    ),
                  ),
                  const Divider(),
                  const SettingsTile(
                    title: 'Appearance',
                    subtitle: 'System Default',
                    leadingIcon: Icons.palette_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ProfileSection(
                title: 'About',
                children: [
                  SettingsTile(
                    title: 'About Word Scanner',
                    subtitle: 'Prototype product information',
                    leadingIcon: Icons.info_outline_rounded,
                    onTap: () => _showPlaceholderDialog(
                      'About Word Scanner',
                      'Word Scanner helps users identify potentially suspicious words and content. Real detection capabilities will be added in a future version.',
                    ),
                  ),
                  const Divider(),
                  SettingsTile(
                    title: 'Privacy Policy',
                    subtitle: 'Placeholder prototype content',
                    leadingIcon: Icons.privacy_tip_outlined,
                    onTap: () => _showPlaceholderDialog(
                      'Privacy Policy',
                      'This is a placeholder policy page for the prototype. No personal data is collected or uploaded in this phase.',
                    ),
                  ),
                  const Divider(),
                  SettingsTile(
                    title: 'Terms of Service',
                    subtitle: 'Placeholder prototype content',
                    leadingIcon: Icons.description_outlined,
                    onTap: () => _showPlaceholderDialog(
                      'Terms of Service',
                      'This is a placeholder terms page for the prototype. Real product terms will be added later.',
                    ),
                  ),
                  const Divider(),
                  const SettingsTile(
                    title: 'App Version',
                    subtitle: '0.1.0 Prototype',
                    leadingIcon: Icons.apps_outage_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _showSignOutDialog,
                  child: const Text('Sign Out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: back button and title
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Account',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Profile section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(
                      'https://randomuser.me/api/portraits/men/32.jpg', // Placeholder image
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'DEVINDI',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Don't tell anyone, but I'm Obito Uchiha.",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _AccountTile(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    subtitle: 'Edit your profile',
                    onTap: () {},
                  ),
                  _AccountTile(
                    icon: Icons.chat_bubble_outline,
                    title: 'My Orders',
                    subtitle: 'In progress & completed orders',
                    onTap: () {},
                  ),
                  _AccountTile(
                    icon: Icons.message_outlined,
                    title: 'My',
                    subtitle: 'Message, group & call tones',
                    onTap: () {},
                  ),
                  _AccountTile(
                    icon: Icons.insert_drive_file_outlined,
                    title: 'FAQs',
                    subtitle: 'Set any kind of notification massage',
                    onTap: () {},
                  ),
                  _AccountTile(
                    icon: Icons.headset_mic_outlined,
                    title: 'Contact',
                    subtitle: 'Help cenre, contact us, privacy policy',
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  // Logout
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AccountTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black, size: 28),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      horizontalTitleGap: 12,
    );
  }
} 
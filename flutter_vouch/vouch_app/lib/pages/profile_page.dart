import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:animate_do/animate_do.dart'; // Animation package removed
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vouch_app/app_theme.dart';
import 'package:vouch_app/pages/login_page.dart';
import 'package:vouch_app/providers/reward_provider.dart';
import 'package:vouch_app/components/change_password_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

// Added AutomaticKeepAliveClientMixin to preserve state during navigation
class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin<ProfilePage> {
  // This ensures the page state is kept alive
  @override
  bool get wantKeepAlive => true;

  File? _imageFile;
  final String _userName = 'Mog';
  final String _userEmail = 'mog@example.com';
  final String _userPhone = '+1 (555) 123-4567';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _handleSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
              );
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This is required by the AutomaticKeepAliveClientMixin
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        backgroundColor: AppTheme.surface,
      ),
      body: Consumer<RewardProvider>(
        builder: (context, rewardProvider, _) {
          final totalRewards = rewardProvider.claimedRewards.length;
          final pendingRewards = rewardProvider.pendingNotifications.length;
          final totalConnections = 12; // Mock data

          return ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              // FadeInDown removed
              _buildProfileHeader(),
              const SizedBox(height: 32),

              // FadeInUp removed
              _buildStatsSection(totalRewards, pendingRewards, totalConnections),
              const SizedBox(height: 32),

              // FadeInUp removed
              _buildSectionTitle('Account Settings'),
              // FadeInUp removed
              _buildAccountSettingsCard(),
              const SizedBox(height: 24),

              // FadeInUp removed
              _buildSectionTitle('Security'),
              // FadeInUp removed
              _buildSecurityCard(),
              const SizedBox(height: 32),

              // FadeInUp removed
              ElevatedButton(
                onPressed: _handleSignOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[900]!.withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Sign Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: AppTheme.surface,
                backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null
                    ? const Icon(Icons.person, size: 70, color: AppTheme.primary)
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          _userName,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          _userEmail,
          style: TextStyle(fontSize: 14, color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildStatsSection(int totalRewards, int pendingRewards, int connections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.text),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.card_giftcard,
                title: 'Claimed',
                value: totalRewards.toString(),
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.pending_actions,
                title: 'Pending',
                value: pendingRewards.toString(),
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.people,
                title: 'Connections',
                value: connections.toString(),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                title: 'Total Value',
                value: '\$${(totalRewards * 15).toString()}',
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.text),
    );
  }

  Widget _buildAccountSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Full Name',
            subtitle: _userName,
            onTap: () => _showEditDialog('Full Name', _userName),
          ),
          Divider(color: Colors.grey[800], height: 1),
          _buildSettingsTile(
            icon: Icons.email_outlined,
            title: 'Email Address',
            subtitle: _userEmail,
            onTap: () => _showEditDialog('Email', _userEmail),
          ),
          Divider(color: Colors.grey[800], height: 1),
          _buildSettingsTile(
            icon: Icons.phone_outlined,
            title: 'Phone Number',
            subtitle: _userPhone,
            onTap: () => _showEditDialog('Phone', _userPhone),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 1),
      ),
      child: _buildSettingsTile(
        icon: Icons.lock_outline,
        title: 'Change Password',
        subtitle: 'Update your password',
        onTap: () => showDialog(
          context: context,
          builder: (context) => const ChangePasswordDialog(),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey[400]),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
      onTap: onTap,
    );
  }

  void _showEditDialog(String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Edit $field', style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter new $field',
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$field updated successfully!'),
                  backgroundColor: AppTheme.primary,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Save', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }
}

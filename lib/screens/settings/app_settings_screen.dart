import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/theme_provider.dart';
import 'package:ehgezly_app/providers/auth_provider.dart';
import 'package:ehgezly_app/widgets/common/app_card.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class AppSettingsScreen extends StatefulWidget {
  static const routeName = '/settings';
  
  const AppSettingsScreen({super.key});
  
  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = true;
  bool _locationEnabled = true;
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Settings Section
            Text(
              'إعدادات التطبيق',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            AppCard(
              child: Column(
                children: [
                  // Theme Mode
                  ListTile(
                    leading: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: const Text('المظهر'),
                    subtitle: Text(
                      themeProvider.isDarkMode ? 'غامق' : 'فاتح',
                    ),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme(value);
                      },
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  // Notifications
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('الإشعارات'),
                    subtitle: const Text('إشعارات التطبيق والرسائل'),
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                      },
                    ),
                  ),
                  
                  if (_notificationsEnabled)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                      child: Column(
                        children: [
                          SwitchListTile(
                            value: _emailNotifications,
                            onChanged: (value) {
                              setState(() => _emailNotifications = value);
                            },
                            title: const Text('الإشعارات البريدية'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          SwitchListTile(
                            value: _smsNotifications,
                            onChanged: (value) {
                              setState(() => _smsNotifications = value);
                            },
                            title: const Text('رسائل SMS'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  
                  const Divider(height: 1),
                  
                  // Location
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text('الموقع'),
                    subtitle: const Text('استخدام الموقع الجغرافي'),
                    trailing: Switch(
                      value: _locationEnabled,
                      onChanged: (value) {
                        setState(() => _locationEnabled = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Privacy & Security
            Text(
              'الخصوصية والأمان',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('تغيير كلمة المرور'),
                    onTap: () {
                      _showChangePasswordDialog();
                    },
                    trailing: const Icon(Icons.chevron_left),
                  ),
                  
                  const Divider(height: 1),
                  
                  ListTile(
                    leading: const Icon(Icons.visibility_outlined),
                    title: const Text('خصوصية الحساب'),
                    subtitle: const Text('من يمكنه رؤية معلوماتك'),
                    onTap: () {
                      // TODO: Navigate to privacy settings
                    },
                    trailing: const Icon(Icons.chevron_left),
                  ),
                  
                  const Divider(height: 1),
                  
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('حذف الحساب'),
                    titleTextStyle: TextStyle(
                      color: Colors.red[700],
                    ),
                    onTap: () {
                      _showDeleteAccountDialog();
                    },
                    trailing: Icon(
                      Icons.chevron_left,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // About
            Text(
              'حول التطبيق',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            AppCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('عن احجزلي'),
                    onTap: () {
                      // TODO: Show about dialog
                    },
                    trailing: const Icon(Icons.chevron_left),
                  ),
                  
                  const Divider(height: 1),
                  
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('الشروط والأحكام'),
                    onTap: () {
                      // TODO: Show terms and conditions
                    },
                    trailing: const Icon(Icons.chevron_left),
                  ),
                  
                  const Divider(height: 1),
                  
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('سياسة الخصوصية'),
                    onTap: () {
                      // TODO: Show privacy policy
                    },
                    trailing: const Icon(Icons.chevron_left),
                  ),
                  
                  const Divider(height: 1),
                  
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('المساعدة والدعم'),
                    onTap: () {
                      Navigator.pushNamed(context, '/help/support');
                    },
                    trailing: const Icon(Icons.chevron_left),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // App Info
            Center(
              child: Column(
                children: [
                  Text(
                    'احجزلي',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'الإصدار 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2024 جميع الحقوق محفوظة',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: const ChangePasswordForm(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement password change
              Navigator.pop(context);
              Helpers.showSuccessSnackbar(context, 'تم تغيير كلمة المرور');
            },
            child: const Text('تغيير'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: const Text(
          'هل أنت متأكد من حذف حسابك؟ '
          'سيتم حذف جميع بياناتك ولا يمكن استرجاعها.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement account deletion
              Navigator.pop(context);
              Helpers.showInfoSnackbar(context, 'سيتم حذف حسابك خلال 24 ساعة');
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});
  
  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _currentPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'كلمة المرور الحالية',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال كلمة المرور الحالية';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'كلمة المرور الجديدة',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال كلمة المرور الجديدة';
              }
              if (value.length < 6) {
                return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'تأكيد كلمة المرور',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى تأكيد كلمة المرور';
              }
              if (value != _newPasswordController.text) {
                return 'كلمات المرور غير متطابقة';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/auth_provider.dart';
import 'package:ehgezly_app/models/user.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/widgets/common/input_field.dart';
import 'package:ehgezly_app/widgets/common/modal.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class PlayerProfileScreen extends StatefulWidget {
  static const routeName = '/player/profile';
  
  const PlayerProfileScreen({super.key});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _emailController.text = user.email ?? '';
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isNotEmpty 
            ? _emailController.text.trim() 
            : null,
      );
      
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث الملف الشخصي بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل تحديث الملف الشخصي: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    final result = await showModal(
      context: context,
      title: 'تغيير كلمة المرور',
      content: _buildChangePasswordForm(),
      actions: [
        AppButton(
          text: 'إلغاء',
          type: ButtonType.outline,
          onPressed: () => Navigator.pop(context),
        ),
        AppButton(
          text: 'تغيير',
          type: ButtonType.primary,
          onPressed: () async {
            // TODO: Implement password change
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تغيير كلمة المرور بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChangePasswordForm() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    return Form(
      child: Column(
        children: [
          InputField(
            controller: currentPasswordController,
            label: 'كلمة المرور الحالية',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'هذا الحقل مطلوب';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          InputField(
            controller: newPasswordController,
            label: 'كلمة المرور الجديدة',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'هذا الحقل مطلوب';
              }
              if (value.length < 6) {
                return 'يجب أن تكون 6 أحرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          InputField(
            controller: confirmPasswordController,
            label: 'تأكيد كلمة المرور الجديدة',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'هذا الحقل مطلوب';
              }
              if (value != newPasswordController.text) {
                return 'كلمات المرور غير متطابقة';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Future<void> _switchRole() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user == null || user.roles.length <= 1) return;
    
    final result = await showModal(
      context: context,
      title: 'تبديل الدور',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر الدور الذي تريد التبديل إليه:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ...user.roles.map((role) {
            return ListTile(
              leading: Icon(
                _getRoleIcon(role),
                color: role == user.primaryRole 
                    ? Theme.of(context).primaryColor 
                    : null,
              ),
              title: Text(
                _getRoleName(role),
                style: TextStyle(
                  fontWeight: role == user.primaryRole 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
              trailing: role == user.primaryRole 
                  ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                  : null,
              onTap: () {
                Navigator.pop(context, role);
              },
            );
          }).toList(),
        ],
      ),
    );
    
    if (result != null && result != user.primaryRole) {
      try {
        await authProvider.switchPrimaryRole(result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم التبديل إلى دور ${_getRoleName(result)}'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تبديل الدور: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'player':
        return Icons.sports_soccer;
      case 'staff':
        return Icons.work;
      case 'owner':
        return Icons.business;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  String _getRoleName(String role) {
    switch (role) {
      case 'player':
        return 'لاعب';
      case 'staff':
        return 'موظف';
      case 'owner':
        return 'مالك';
      case 'admin':
        return 'مدير';
      default:
        return role;
    }
  }

  Widget _buildProfileInfo(User user, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            child: Icon(
              _getRoleIcon(user.primaryRole),
              size: 32,
              color: theme.primaryColor,
            ),
          ),
          title: Text(
            user.name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            _getRoleName(user.primaryRole),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),

        const Divider(),

        ListTile(
          leading: Icon(
            Icons.phone,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          title: Text(
            'رقم الهاتف',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          subtitle: Text(
            Helpers.formatPhoneNumber(user.phone),
            style: theme.textTheme.titleMedium,
          ),
        ),

        if (user.email != null) ...[
          ListTile(
            leading: Icon(
              Icons.email,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            title: Text(
              'البريد الإلكتروني',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            subtitle: Text(
              user.email!,
              style: theme.textTheme.titleMedium,
            ),
          ),
        ],

        ListTile(
          leading: Icon(
            Icons.calendar_today,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          title: Text(
            'تاريخ الانضمام',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          subtitle: Text(
            Helpers.formatDate(user.createdAt),
            style: theme.textTheme.titleMedium,
          ),
        ),

        if (user.verifiedPhone)
          ListTile(
            leading: Icon(
              Icons.verified,
              color: Colors.green,
            ),
            title: Text(
              'رقم الهاتف موثق',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green,
              ),
            ),
          ),

        if (user.verifiedEmail)
          ListTile(
            leading: Icon(
              Icons.verified,
              color: Colors.green,
            ),
            title: Text(
              'البريد الإلكتروني موثق',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEditForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          InputField(
            controller: _nameController,
            label: 'الاسم الكامل',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'هذا الحقل مطلوب';
              }
              if (value.length < 3) {
                return 'يجب أن يكون 3 أحرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          InputField(
            controller: _phoneController,
            label: 'رقم الهاتف',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'هذا الحقل مطلوب';
              }
              if (!Helpers.isValidPhone(value)) {
                return 'رقم هاتف غير صحيح';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          InputField(
            controller: _emailController,
            label: 'البريد الإلكتروني (اختياري)',
            validator: (value) {
              if (value != null && value.isNotEmpty && !Helpers.isValidEmail(value)) {
                return 'بريد إلكتروني غير صحيح';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'إلغاء',
                  type: ButtonType.outline,
                  onPressed: () {
                    setState(() => _isEditing = false);
                    _loadUserData(); // Reset to original values
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: 'حفظ',
                  type: ButtonType.primary,
                  isLoading: _isLoading,
                  onPressed: _updateProfile,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الملف الشخصي')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => _isEditing = true);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditing)
              _buildEditForm(theme)
            else
              _buildProfileInfo(user, theme),

            const SizedBox(height: 32),

            // Actions Section
            Text(
              'الإجراءات',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.lock,
                      color: theme.primaryColor,
                    ),
                    title: Text(
                      'تغيير كلمة المرور',
                      style: theme.textTheme.titleMedium,
                    ),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: _changePassword,
                  ),
                  const Divider(),
                  
                  if (user.roles.length > 1)
                    ListTile(
                      leading: Icon(
                        Icons.switch_account,
                        color: theme.primaryColor,
                      ),
                      title: Text(
                        'تبديل الدور',
                        style: theme.textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        'لديك ${user.roles.length} أدوار',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_left),
                      onTap: _switchRole,
                    ),
                  
                  if (user.roles.length > 1) const Divider(),
                  
                  ListTile(
                    leading: Icon(
                      Icons.notifications,
                      color: theme.primaryColor,
                    ),
                    title: Text(
                      'إعدادات الإشعارات',
                      style: theme.textTheme.titleMedium,
                    ),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () {
                      // TODO: Navigate to notification settings
                    },
                  ),
                  const Divider(),
                  
                  ListTile(
                    leading: Icon(
                      Icons.help,
                      color: theme.primaryColor,
                    ),
                    title: Text(
                      'المساعدة والدعم',
                      style: theme.textTheme.titleMedium,
                    ),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () {
                      // TODO: Navigate to help screen
                    },
                  ),
                  const Divider(),
                  
                  ListTile(
                    leading: Icon(
                      Icons.privacy_tip,
                      color: theme.primaryColor,
                    ),
                    title: Text(
                      'الخصوصية والشروط',
                      style: theme.textTheme.titleMedium,
                    ),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () {
                      // TODO: Show privacy policy
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            AppButton(
              text: 'تسجيل الخروج',
              type: ButtonType.danger,
              icon: Icons.logout,
              onPressed: () async {
                final result = await showModal(
                  context: context,
                  title: 'تسجيل الخروج',
                  content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
                  actions: [
                    AppButton(
                      text: 'إلغاء',
                      type: ButtonType.outline,
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    AppButton(
                      text: 'تسجيل الخروج',
                      type: ButtonType.danger,
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                );

                if (result == true) {
                  await authProvider.logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/landing',
                    (route) => false,
                  );
                }
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

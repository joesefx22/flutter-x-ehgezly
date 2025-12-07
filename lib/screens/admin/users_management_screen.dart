import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/auth_provider.dart';
import 'package:ehgezly_app/providers/user_provider.dart';
import 'package:ehgezly_app/models/user.dart';
import 'package:ehgezly_app/widgets/common/card.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/widgets/common/input_field.dart';
import 'package:ehgezly_app/widgets/common/modal.dart';
import 'package:ehgezly_app/widgets/admin/user_edit_modal.dart';
import 'package:ehgezly_app/utils/helpers.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'dart:async';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({Key? key}) : super(key: key);

  @override
  _UsersManagementScreenState createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  bool _isExporting = false;
  String _searchQuery = '';
  String _selectedRole = 'الكل';
  String _selectedStatus = 'الكل';
  int _currentPage = 1;
  int _totalPages = 1;
  int _pageSize = 20;
  int _totalUsers = 0;
  
  // الحقول التي يمكن البحث فيها
  final List<String> _searchFields = ['الاسم', 'الهاتف', 'البريد'];
  String _selectedSearchField = 'الاسم';
  
  // للتحكم في DataGrid
  late UserDataSource _userDataSource;
  late DataGridController _dataGridController;
  
  // للتحديث التلقائي
  Timer? _autoRefreshTimer;
  
  @override
  void initState() {
    super.initState();
    _dataGridController = DataGridController();
    _loadUsers();
    _startAutoRefresh();
  }
  
  @override
  void dispose() {
    _stopAutoRefresh();
    _dataGridController.dispose();
    super.dispose();
  }
  
  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (mounted) {
        _loadUsers(showLoading: false);
      }
    });
  }
  
  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }
  
  Future<void> _loadUsers({bool showLoading = true}) async {
    try {
      if (showLoading) {
        setState(() => _isLoading = true);
      }
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // التحقق من صلاحية المدير
      if (!authProvider.user!.roles.contains('admin')) {
        throw Exception('ليس لديك صلاحية الوصول');
      }
      
      // جلب بيانات المستخدمين
      final result = await userProvider.getUsers(
        page: _currentPage,
        limit: _pageSize,
        search: _searchQuery,
        role: _selectedRole != 'الكل' ? _selectedRole : null,
        status: _selectedStatus != 'الكل' ? _selectedStatus : null,
        searchField: _selectedSearchField,
      );
      
      if (mounted) {
        setState(() {
          _users = result['users'] as List<User>;
          _filteredUsers = _applyFilters(_users);
          _totalUsers = result['total'] as int;
          _totalPages = (_totalUsers / _pageSize).ceil();
          _userDataSource = UserDataSource(_filteredUsers, _onUserAction);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading users: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        Helpers.showErrorSnackbar(context, 'فشل في تحميل المستخدمين');
      }
    }
  }
  
  List<User> _applyFilters(List<User> users) {
    List<User> filtered = List.from(users);
    
    // فلترة حسب الدور
    if (_selectedRole != 'الكل') {
      filtered = filtered.where((user) => 
        user.roles.contains(_selectedRole) || user.primaryRole == _selectedRole
      ).toList();
    }
    
    // فلترة حسب الحالة
    if (_selectedStatus != 'الكل') {
      filtered = filtered.where((user) {
        if (_selectedStatus == 'نشط') return user.isActive;
        if (_selectedStatus == 'غير نشط') return !user.isActive;
        if (_selectedStatus == 'موثق') return user.isVerified;
        if (_selectedStatus == 'غير موثق') return !user.isVerified;
        return true;
      }).toList();
    }
    
    // البحث
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        switch (_selectedSearchField) {
          case 'الاسم':
            return user.name.toLowerCase().contains(_searchQuery.toLowerCase());
          case 'الهاتف':
            return user.phone.contains(_searchQuery);
          case 'البريد':
            return user.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
          default:
            return true;
        }
      }).toList();
    }
    
    return filtered;
  }
  
  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1; // العودة للصفحة الأولى
    });
    _loadUsers(showLoading: false);
  }
  
  void _onFilterChanged() {
    setState(() => _currentPage = 1);
    _loadUsers(showLoading: false);
  }
  
  Future<void> _onUserAction(UserAction action, User user) async {
    switch (action) {
      case UserAction.edit:
        await _editUser(user);
        break;
      case UserAction.delete:
        await _deleteUser(user);
        break;
      case UserAction.activate:
        await _toggleUserStatus(user, activate: true);
        break;
      case UserAction.deactivate:
        await _toggleUserStatus(user, activate: false);
        break;
      case UserAction.impersonate:
        await _impersonateUser(user);
        break;
      case UserAction.viewDetails:
        await _viewUserDetails(user);
        break;
    }
  }
  
  Future<void> _editUser(User user) async {
    AppModal.show(
      context: context,
      title: 'تعديل المستخدم',
      content: UserEditModal(
        user: user,
        onSuccess: (updatedUser) {
          // تحديث القائمة
          final index = _users.indexWhere((u) => u.id == user.id);
          if (index != -1) {
            setState(() => _users[index] = updatedUser);
          }
          Navigator.pop(context);
          Helpers.showSuccessSnackbar(context, 'تم تعديل المستخدم بنجاح');
        },
      ),
    );
  }
  
  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المستخدم'),
        content: Text('هل أنت متأكد من حذف المستخدم "${user.name}"؟\n\nهذا الإجراء لا يمكن التراجع عنه.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.deleteUser(user.id);
        
        // إزالة المستخدم من القائمة
        setState(() {
          _users.removeWhere((u) => u.id == user.id);
          _totalUsers--;
          _isLoading = false;
        });
        
        Helpers.showSuccessSnackbar(context, 'تم حذف المستخدم بنجاح');
      } catch (e) {
        setState(() => _isLoading = false);
        Helpers.showErrorSnackbar(context, 'فشل في حذف المستخدم');
      }
    }
  }
  
  Future<void> _toggleUserStatus(User user, {required bool activate}) async {
    final action = activate ? 'تفعيل' : 'تعطيل';
    final message = activate
        ? 'هل تريد تفعيل حساب "${user.name}"؟'
        : 'هل تريد تعطيل حساب "${user.name}"؟';
    
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action المستخدم'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
            style: TextButton.styleFrom(
              foregroundColor: activate ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final updatedUser = user.copyWith(isActive: activate);
        
        await userProvider.updateUser(updatedUser);
        
        // تحديث القائمة
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          setState(() => _users[index] = updatedUser);
        }
        
        Helpers.showSuccessSnackbar(context, 'تم $action المستخدم بنجاح');
      } catch (e) {
        Helpers.showErrorSnackbar(context, 'فشل في $action المستخدم');
      }
    }
  }
  
  Future<void> _impersonateUser(User user) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الدخول كمستخدم آخر'),
        content: Text('هل تريد الدخول كـ "${user.name}"؟\n\nسيتم تسجيل خروجك من حسابك الحالي.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('متابعة'),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.impersonateUser(user.id);
        
        Helpers.showSuccessSnackbar(context, 'تم الدخول كـ ${user.name}');
        
        // TODO: Navigate to appropriate dashboard based on user role
      } catch (e) {
        Helpers.showErrorSnackbar(context, 'فشل في الدخول كمستخدم آخر');
      }
    }
  }
  
  Future<void> _viewUserDetails(User user) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل المستخدم: ${user.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUserDetailItem('الاسم الكامل', user.name),
              _buildUserDetailItem('رقم الهاتف', user.phone),
              if (user.email != null) _buildUserDetailItem('البريد الإلكتروني', user.email!),
              _buildUserDetailItem('الدور الرئيسي', user.primaryRole),
              _buildUserDetailItem('الأدوار', user.roles.join(', ')),
              _buildUserDetailItem('تاريخ الإنشاء', Helpers.formatDate(user.createdAt)),
              if (user.lastLogin != null) _buildUserDetailItem('آخر دخول', Helpers.formatTimeAgo(user.lastLogin!)),
              _buildUserDetailItem('الحالة', user.isActive ? 'نشط' : 'غير نشط'),
              _buildUserDetailItem('التوثيق', user.isVerified ? 'موثق' : 'غير موثق'),
              if (user.stadiums.isNotEmpty) _buildUserDetailItem('الملاعب', '${user.stadiums.length} ملعب'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _exportUsers() async {
    if (_isExporting) return;
    
    final format = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصدير البيانات'),
        content: const Text('اختر صيغة التصدير:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'csv'),
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'excel'),
            child: const Text('Excel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'pdf'),
            child: const Text('PDF'),
          ),
        ],
      ),
    );
    
    if (format != null) {
      try {
        setState(() => _isExporting = true);
        
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.exportUsers(
          users: _filteredUsers,
          format: format,
        );
        
        setState(() => _isExporting = false);
        Helpers.showSuccessSnackbar(context, 'تم تصدير البيانات بنجاح');
      } catch (e) {
        setState(() => _isExporting = false);
        Helpers.showErrorSnackbar(context, 'فشل في تصدير البيانات');
      }
    }
  }
  
  Future<void> _addNewUser() async {
    AppModal.show(
      context: context,
      title: 'إضافة مستخدم جديد',
      content: UserEditModal(
        onSuccess: (newUser) {
          // إضافة المستخدم الجديد للقائمة
          setState(() {
            _users.insert(0, newUser);
            _totalUsers++;
          });
          Navigator.pop(context);
          Helpers.showSuccessSnackbar(context, 'تم إضافة المستخدم بنجاح');
        },
      ),
    );
  }
  
  Widget _buildFiltersSection() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تصفية المستخدمين',
              style: Theme.of(context).textTheme.subtitle1?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // حقل البحث مع اختيار المجال
            Row(
              children: [
                Expanded(
                  child: InputField(
                    label: 'بحث',
                    hintText: 'ابحث عن مستخدم...',
                    prefixIcon: Icons.search,
                    onChanged: _onSearch,
                    onSubmitted: _onSearch,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedSearchField,
                  items: _searchFields.map((field) {
                    return DropdownMenuItem(
                      value: field,
                      child: Text(field),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedSearchField = value!);
                    _onFilterChanged();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // فلترة الدور والحالة
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الدور', style: Theme.of(context).textTheme.caption),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        items: ['الكل', 'admin', 'owner', 'staff', 'player']
                            .map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role == 'الكل' ? 'الكل' : _getRoleName(role)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedRole = value!);
                          _onFilterChanged();
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الحالة', style: Theme.of(context).textTheme.caption),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        items: ['الكل', 'نشط', 'غير نشط', 'موثق', 'غير موثق']
                            .map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedStatus = value!);
                          _onFilterChanged();
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // إحصائيات سريعة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterStat('الإجمالي', '$_totalUsers'),
                _buildFilterStat('النشطين', _users.where((u) => u.isActive).length.toString()),
                _buildFilterStat('الموثقين', _users.where((u) => u.isVerified).length.toString()),
                _buildFilterStat('المدراء', _users.where((u) => u.roles.contains('admin')).length.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.subtitle1?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }
  
  Widget _buildUsersTable() {
    return Expanded(
      child: _filteredUsers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد مستخدمين',
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_searchQuery.isNotEmpty || _selectedRole != 'الكل' || _selectedStatus != 'الكل')
                    Text(
                      'جرب تغيير معايير البحث',
                      style: Theme.of(context).textTheme.caption,
                    ),
                  if (_searchQuery.isEmpty && _selectedRole == 'الكل' && _selectedStatus == 'الكل') ...[
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'إضافة أول مستخدم',
                      onPressed: _addNewUser,
                      size: ButtonSize.medium,
                    ),
                  ],
                ],
              ),
            )
          : SfDataGridTheme(
              data: SfDataGridThemeData(
                headerColor: Colors.grey[100],
                gridLineColor: Colors.grey[300],
              ),
              child: SfDataGrid(
                source: _userDataSource,
                controller: _dataGridController,
                columnWidthMode: ColumnWidthMode.fill,
                gridLinesVisibility: GridLinesVisibility.horizontal,
                headerGridLinesVisibility: GridLinesVisibility.horizontal,
                allowSorting: true,
                allowFiltering: true,
                allowMultiColumnSorting: true,
                selectionMode: SelectionMode.multiple,
                navigationMode: GridNavigationMode.cell,
                columns: [
                  GridColumn(
                    columnName: 'name',
                    label: Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.centerRight,
                      child: const Text('الاسم'),
                    ),
                  ),
                  GridColumn(
                    columnName: 'phone',
                    label: Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.centerRight,
                      child: const Text('الهاتف'),
                    ),
                  ),
                  GridColumn(
                    columnName: 'role',
                    label: Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.centerRight,
                      child: const Text('الدور'),
                    ),
                  ),
                  GridColumn(
                    columnName: 'status',
                    label: Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.centerRight,
                      child: const Text('الحالة'),
                    ),
                  ),
                  GridColumn(
                    columnName: 'createdAt',
                    label: Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.centerRight,
                      child: const Text('تاريخ الإنشاء'),
                    ),
                  ),
                  GridColumn(
                    columnName: 'actions',
                    label: Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.centerRight,
                      child: const Text('الإجراءات'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildPaginationControls() {
    if (_totalPages <= 1) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage > 1
                ? () {
                    setState(() => _currentPage--);
                    _loadUsers();
                  }
                : null,
          ),
          
          Text(
            'صفحة $_currentPage من $_totalPages',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _loadUsers();
                  }
                : null,
          ),
          
          const SizedBox(width: 16),
          
          DropdownButton<int>(
            value: _pageSize,
            items: [10, 20, 50, 100].map((size) {
              return DropdownMenuItem(
                value: size,
                child: Text('$size لكل صفحة'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _pageSize = value!;
                _currentPage = 1;
              });
              _loadUsers();
            },
          ),
        ],
      ),
    );
  }
  
  String _getRoleName(String role) {
    switch (role) {
      case 'admin': return 'مدير';
      case 'owner': return 'مالك';
      case 'staff': return 'موظف';
      case 'player': return 'لاعب';
      default: return role;
    }
  }
  
  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin': return Colors.red;
      case 'owner': return Colors.orange;
      case 'staff': return Colors.blue;
      case 'player': return Colors.green;
      default: return Colors.grey;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // التحقق من صلاحية المدير
    if (!authProvider.user!.roles.contains('admin')) {
      return const Scaffold(
        body: Center(
          child: Text('ليس لديك صلاحية الوصول'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadUsers(),
            tooltip: 'تحديث',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportUsers();
                  break;
                case 'bulk_actions':
                  _showBulkActions();
                  break;
                case 'settings':
                  // TODO: Open user management settings
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('تصدير'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'bulk_actions',
                child: Row(
                  children: [
                    Icon(Icons.playlist_add_check, size: 20),
                    SizedBox(width: 8),
                    Text('إجراءات جماعية'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('الإعدادات'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewUser,
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة مستخدم'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // قسم الفلاتر
                _buildFiltersSection(),
                const SizedBox(height: 16),
                
                // جدول المستخدمين
                _buildUsersTable(),
                const SizedBox(height: 16),
                
                // عناصر التحكم في الصفحات
                _buildPaginationControls(),
              ],
            ),
    );
  }
  
  Future<void> _showBulkActions() async {
    final selectedRows = _dataGridController.selectedRows;
    if (selectedRows.isEmpty) {
      Helpers.showErrorSnackbar(context, 'لم تقم باختيار أي مستخدمين');
      return;
    }
    
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إجراءات جماعية (${selectedRows.length})'),
        content: const Text('اختر الإجراء الذي تريد تطبيقه على المستخدمين المختارين:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'activate'),
            child: const Text('تفعيل'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'deactivate'),
            child: const Text('تعطيل'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'delete'),
            child: const Text('حذف'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
    
    if (action != null) {
      final userIds = selectedRows.map((row) {
        return _filteredUsers[row.getVisibleRange().startIndex].id;
      }).toList();
      
      await _performBulkAction(action, userIds);
    }
  }
  
  Future<void> _performBulkAction(String action, List<String> userIds) async {
    try {
      setState(() => _isLoading = true);
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.performBulkAction(action, userIds);
      
      // إعادة تحميل البيانات
      await _loadUsers();
      
      Helpers.showSuccessSnackbar(
        context,
        'تم تطبيق الإجراء على ${userIds.length} مستخدم',
      );
    } catch (e) {
      setState(() => _isLoading = false);
      Helpers.showErrorSnackbar(context, 'فشل في تطبيق الإجراء الجماعي');
    }
  }
}

// Data Source for Users Grid
class UserDataSource extends DataGridSource {
  UserDataSource(this.users, this.onAction);
  
  final List<User> users;
  final Function(UserAction, User) onAction;
  
  @override
  List<DataGridRow> get rows => users
      .map<DataGridRow>((user) => DataGridRow(cells: [
            DataGridCell<User>(columnName: 'name', value: user),
            DataGridCell<String>(columnName: 'phone', value: user.phone),
            DataGridCell<String>(
              columnName: 'role',
              value: user.primaryRole,
            ),
            DataGridCell<String>(
              columnName: 'status',
              value: user.isActive ? 'نشط' : 'غير نشط',
            ),
            DataGridCell<String>(
              columnName: 'createdAt',
              value: Helpers.formatDate(user.createdAt),
            ),
            DataGridCell<User>(columnName: 'actions', value: user),
          ]))
      .toList();

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      if (dataGridCell.columnName == 'name') {
        final user = dataGridCell.value as User;
        return Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.centerRight,
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _getRoleColor(user.primaryRole).withOpacity(0.1),
                child: Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: _getRoleColor(user.primaryRole),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user.email != null)
                      Text(
                        user.email!,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      
      if (dataGridCell.columnName == 'role') {
        final role = dataGridCell.value as String;
        return Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.centerRight,
          child: Chip(
            label: Text(
              _getRoleName(role),
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
            backgroundColor: _getRoleColor(role),
            padding: const EdgeInsets.symmetric(horizontal: 6),
          ),
        );
      }
      
      if (dataGridCell.columnName == 'status') {
        final status = dataGridCell.value as String;
        return Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: status == 'نشط' ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }
      
      if (dataGridCell.columnName == 'actions') {
        final user = dataGridCell.value as User;
        return Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.centerRight,
          child: PopupMenuButton<UserAction>(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: UserAction.viewDetails,
                child: Row(
                  children: [
                    Icon(Icons.info, size: 16),
                    SizedBox(width: 8),
                    Text('التفاصيل'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: UserAction.edit,
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('تعديل'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: user.isActive ? UserAction.deactivate : UserAction.activate,
                child: Row(
                  children: [
                    Icon(
                      user.isActive ? Icons.person_off : Icons.person_add,
                      size: 16,
                      color: user.isActive ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(user.isActive ? 'تعطيل' : 'تفعيل'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: UserAction.impersonate,
                child: Row(
                  children: [
                    Icon(Icons.switch_account, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('الدخول كـ'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: UserAction.delete,
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('حذف'),
                  ],
                ),
              ),
            ],
            onSelected: (action) => onAction(action, user),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.more_vert, size: 16),
            ),
          ),
        );
      }
      
      return Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.centerRight,
        child: Text(
          dataGridCell.value.toString(),
          style: const TextStyle(fontSize: 12),
        ),
      );
    }).toList());
  }
  
  String _getRoleName(String role) {
    switch (role) {
      case 'admin': return 'مدير';
      case 'owner': return 'مالك';
      case 'staff': return 'موظف';
      case 'player': return 'لاعب';
      default: return role;
    }
  }
  
  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin': return Colors.red;
      case 'owner': return Colors.orange;
      case 'staff': return Colors.blue;
      case 'player': return Colors.green;
      default: return Colors.grey;
    }
  }
}

// Actions Enum
enum UserAction {
  edit,
  delete,
  activate,
  deactivate,
  impersonate,
  viewDetails,
}

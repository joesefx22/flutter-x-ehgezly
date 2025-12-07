import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/auth_provider.dart';
import 'package:ehgezly_app/widgets/common/app_card.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/widgets/common/modal.dart';
import 'package:ehgezly_app/widgets/admin/create_code_modal.dart';
import 'package:ehgezly_app/utils/helpers.dart';
import 'package:intl/intl.dart';

class AdminCodesScreen extends StatefulWidget {
  static const routeName = '/admin/codes';
  
  const AdminCodesScreen({super.key});
  
  @override
  State<AdminCodesScreen> createState() => _AdminCodesScreenState();
}

class _AdminCodesScreenState extends State<AdminCodesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Voucher> _vouchers = [];
  List<Voucher> _filteredVouchers = [];
  bool _isLoading = true;
  Timer? _searchDebounceTimer;
  
  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }
  
  Future<void> _loadVouchers() async {
    try {
      // TODO: Replace with API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data for testing
      setState(() {
        _vouchers = [
          Voucher(
            id: '1',
            code: 'WELCOME20',
            type: 'percentage',
            value: 20,
            usesLeft: 100,
            maxUses: 100,
            expiryDate: DateTime.now().add(const Duration(days: 30)),
            isActive: true,
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
            createdBy: 'Admin',
          ),
          Voucher(
            id: '2',
            code: 'FIRSTBOOK',
            type: 'fixed',
            value: 50,
            usesLeft: 50,
            maxUses: 50,
            expiryDate: DateTime.now().add(const Duration(days: 15)),
            isActive: true,
            createdAt: DateTime.now().subtract(const Duration(days: 10)),
            createdBy: 'Admin',
          ),
          Voucher(
            id: '3',
            code: 'SUMMER50',
            type: 'percentage',
            value: 50,
            usesLeft: 0,
            maxUses: 10,
            expiryDate: DateTime.now().subtract(const Duration(days: 1)),
            isActive: false,
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
            createdBy: 'Admin',
          ),
          Voucher(
            id: '4',
            code: 'FREEBOOK',
            type: 'free',
            value: 100,
            usesLeft: 5,
            maxUses: 5,
            expiryDate: DateTime.now().add(const Duration(days: 7)),
            isActive: true,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            createdBy: 'Admin',
          ),
        ];
        _filteredVouchers = _vouchers;
      });
    } catch (e) {
      Helpers.showErrorSnackbar(context, 'فشل في تحميل الأكواد');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _onSearchChanged(String value) {
    if (_searchDebounceTimer?.isActive ?? false) {
      _searchDebounceTimer?.cancel();
    }
    
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _filterVouchers();
    });
  }
  
  void _filterVouchers() {
    final query = _searchController.text.toLowerCase().trim();
    
    if (query.isEmpty) {
      setState(() => _filteredVouchers = _vouchers);
      return;
    }
    
    setState(() {
      _filteredVouchers = _vouchers.where((voucher) {
        return voucher.code.toLowerCase().contains(query) ||
            voucher.type.contains(query);
      }).toList();
    });
  }
  
  Future<void> _showCreateCodeModal() async {
    await showModal(
      context: context,
      title: 'إنشاء كود خصم',
      content: CreateCodeModal(
        onCreate: (voucher) async {
          Navigator.pop(context);
          await _addVoucher(voucher);
        },
      ),
    );
  }
  
  Future<void> _addVoucher(Voucher voucher) async {
    try {
      // TODO: Replace with API call
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _vouchers.insert(0, voucher);
        _filterVouchers();
      });
      
      Helpers.showSuccessSnackbar(context, 'تم إنشاء الكود بنجاح');
    } catch (e) {
      Helpers.showErrorSnackbar(context, 'فشل في إنشاء الكود');
    }
  }
  
  Future<void> _toggleVoucherStatus(String voucherId) async {
    try {
      // TODO: Replace with API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        final index = _vouchers.indexWhere((v) => v.id == voucherId);
        if (index != -1) {
          _vouchers[index] = _vouchers[index].copyWith(
            isActive: !_vouchers[index].isActive,
          );
          _filterVouchers();
        }
      });
      
      Helpers.showSuccessSnackbar(context, 'تم تحديث حالة الكود');
    } catch (e) {
      Helpers.showErrorSnackbar(context, 'فشل في تحديث حالة الكود');
    }
  }
  
  Future<void> _deleteVoucher(String voucherId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الكود'),
        content: const Text('هل أنت متأكد من حذف هذا الكود؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      // TODO: Replace with API call
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _vouchers.removeWhere((v) => v.id == voucherId);
        _filterVouchers();
      });
      
      Helpers.showSuccessSnackbar(context, 'تم حذف الكود بنجاح');
    } catch (e) {
      Helpers.showErrorSnackbar(context, 'فشل في حذف الكود');
    }
  }
  
  Widget _buildSearchBar() {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'ابحث عن كود...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _filterVouchers();
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateCodeModal,
            tooltip: 'إنشاء كود جديد',
          ),
        ],
      ),
    );
  }
  
  Widget _buildStats() {
    final totalVouchers = _vouchers.length;
    final activeVouchers = _vouchers.where((v) => v.isActive).length;
    final expiredVouchers = _vouchers.where((v) => v.isExpired).length;
    
    return Row(
      children: [
        _buildStatCard('إجمالي الأكواد', totalVouchers.toString(), Colors.blue),
        const SizedBox(width: 8),
        _buildStatCard('نشطة', activeVouchers.toString(), Colors.green),
        const SizedBox(width: 8),
        _buildStatCard('منتهية', expiredVouchers.toString(), Colors.grey),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVoucherCard(Voucher voucher) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: voucher.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  voucher.statusText,
                  style: TextStyle(
                    color: voucher.statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                voucher.typeText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Text(
                voucher.code,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () {
                  // TODO: Copy to clipboard
                  Helpers.showInfoSnackbar(context, 'تم نسخ الكود');
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              _buildVoucherInfo(
                'القيمة',
                voucher.type == 'percentage'
                    ? '${voucher.value}%'
                    : voucher.type == 'free'
                      ? 'مجاني'
                      : '${Helpers.formatCurrency(voucher.value)}',
              ),
              const SizedBox(width: 16),
              _buildVoucherInfo(
                'المستخدم',
                '${voucher.maxUses - voucher.usesLeft}/${voucher.maxUses}',
              ),
              const SizedBox(width: 16),
              _buildVoucherInfo(
                'ينتهي في',
                Helpers.formatDate(voucher.expiryDate),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: AppButton(
                  onPressed: () => _toggleVoucherStatus(voucher.id),
                  text: voucher.isActive ? 'تعطيل' : 'تفعيل',
                  type: voucher.isActive
                      ? ButtonType.outline
                      : ButtonType.success,
                  size: ButtonSize.small,
                  fullWidth: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  onPressed: () => _deleteVoucher(voucher.id),
                  text: 'حذف',
                  type: ButtonType.danger,
                  size: ButtonSize.small,
                  fullWidth: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildVoucherInfo(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد أكواد',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'قم بإنشاء كود خصم جديد لتبدأ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            onPressed: _showCreateCodeModal,
            text: 'إنشاء كود جديد',
            icon: Icons.add,
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Check if user is admin
    if (!authProvider.user!.roles.contains('admin')) {
      return Scaffold(
        body: Center(
          child: Text(
            'ليس لديك صلاحية الوصول',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأكواد'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildStats(),
                  const SizedBox(height: 20),
                  
                  if (_filteredVouchers.isEmpty)
                    _buildEmptyState()
                  else
                    ..._filteredVouchers.map(_buildVoucherCard).toList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateCodeModal,
        icon: const Icon(Icons.add),
        label: const Text('كود جديد'),
      ),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }
}

// Model for Voucher (should be in models/voucher.dart)
class Voucher {
  final String id;
  final String code;
  final String type; // 'percentage', 'fixed', 'free'
  final double value;
  final int usesLeft;
  final int maxUses;
  final DateTime expiryDate;
  final bool isActive;
  final DateTime createdAt;
  final String createdBy;
  
  Voucher({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.usesLeft,
    required this.maxUses,
    required this.expiryDate,
    required this.isActive,
    required this.createdAt,
    required this.createdBy,
  });
  
  bool get isExpired => expiryDate.isBefore(DateTime.now());
  
  Color get statusColor {
    if (!isActive) return Colors.grey;
    if (isExpired) return Colors.orange;
    if (usesLeft <= 0) return Colors.red;
    return Colors.green;
  }
  
  String get statusText {
    if (!isActive) return 'غير نشط';
    if (isExpired) return 'منتهي';
    if (usesLeft <= 0) return 'مستنفد';
    return 'نشط';
  }
  
  String get typeText {
    switch (type) {
      case 'percentage':
        return 'نسبة مئوية';
      case 'fixed':
        return 'قيمة ثابتة';
      case 'free':
        return 'مجاني';
      default:
        return type;
    }
  }
  
  Voucher copyWith({
    String? id,
    String? code,
    String? type,
    double? value,
    int? usesLeft,
    int? maxUses,
    DateTime? expiryDate,
    bool? isActive,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return Voucher(
      id: id ?? this.id,
      code: code ?? this.code,
      type: type ?? this.type,
      value: value ?? this.value,
      usesLeft: usesLeft ?? this.usesLeft,
      maxUses: maxUses ?? this.maxUses,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

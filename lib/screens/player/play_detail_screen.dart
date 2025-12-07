import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/play_request_provider.dart';
import 'package:ehgezly_app/providers/auth_provider.dart';
import 'package:ehgezly_app/widgets/common/app_card.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/widgets/common/modal.dart';
import 'package:ehgezly_app/widgets/player/request_card.dart';
import 'package:ehgezly_app/widgets/player/join_modal.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class PlayDetailScreen extends StatefulWidget {
  static const routeName = '/player/play-detail';
  
  final String? playRequestId;
  
  const PlayDetailScreen({super.key, this.playRequestId});
  
  @override
  State<PlayDetailScreen> createState() => _PlayDetailScreenState();
}

class _PlayDetailScreenState extends State<PlayDetailScreen> {
  late PlayRequestProvider _playRequestProvider;
  late AuthProvider _authProvider;
  bool _isLoading = true;
  bool _isJoining = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlayRequest();
    });
  }
  
  Future<void> _loadPlayRequest() async {
    try {
      if (widget.playRequestId != null) {
        await _playRequestProvider.loadPlayRequestDetails(widget.playRequestId!);
      }
    } catch (e) {
      Helpers.showErrorSnackbar(context, 'فشل في تحميل تفاصيل الطلب');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _handleJoin() async {
    final request = _playRequestProvider.selectedPlayRequest;
    if (request == null) return;
    
    // Check if already joined
    final userId = _authProvider.user?.id;
    if (userId != null && request.isUserJoined(userId)) {
      Helpers.showInfoSnackbar(context, 'أنت منضم بالفعل لهذا الطلب');
      return;
    }
    
    // Check if full
    if (request.isFull) {
      Helpers.showErrorSnackbar(context, 'الطلب ممتلئ بالفعل');
      return;
    }
    
    // Show join modal
    await showModal(
      context: context,
      title: 'الانضمام للطلب',
      content: JoinModal(
        playRequest: request,
        onJoin: (additionalPlayers, notes) async {
          Navigator.pop(context); // Close modal
          await _joinRequest(additionalPlayers, notes);
        },
      ),
    );
  }
  
  Future<void> _joinRequest(int additionalPlayers, String? notes) async {
    try {
      setState(() => _isJoining = true);
      await _playRequestProvider.joinPlayRequest(
        widget.playRequestId!,
        additionalPlayers: additionalPlayers,
        notes: notes,
      );
      Helpers.showSuccessSnackbar(context, 'تم الانضمام للطلب بنجاح');
    } catch (e) {
      Helpers.showErrorSnackbar(context, 'فشل في الانضمام: ${e.toString()}');
    } finally {
      setState(() => _isJoining = false);
    }
  }
  
  Future<void> _handleLeave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مغادرة الطلب'),
        content: const Text('هل أنت متأكد من مغادرة هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('مغادرة', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      setState(() => _isJoining = true);
      await _playRequestProvider.leavePlayRequest(widget.playRequestId!);
      Helpers.showSuccessSnackbar(context, 'تم مغادرة الطلب بنجاح');
    } catch (e) {
      Helpers.showErrorSnackbar(context, 'فشل في مغادرة الطلب: ${e.toString()}');
    } finally {
      setState(() => _isJoining = false);
    }
  }
  
  Widget _buildHeader() {
    final request = _playRequestProvider.selectedPlayRequest;
    if (request == null) return Container();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طلب لاعبين',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          request.stadiumId != null ? 'في ملعب محدد' : 'ملعب مرن',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildDetailsCard() {
    final request = _playRequestProvider.selectedPlayRequest;
    if (request == null) return Container();
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and completion
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: request.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  request.statusLabel,
                  style: TextStyle(
                    color: request.statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${request.joinedCount}/${request.requiredPlayers} لاعب',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Age group and level
          Row(
            children: [
              _buildDetailItem(
                icon: Icons.person_outline,
                label: 'الفئة العمرية',
                value: request.ageGroupLabel,
              ),
              const SizedBox(width: 16),
              _buildDetailItem(
                icon: Icons.star_outline,
                label: 'المستوى',
                value: request.levelLabel,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Date and time
          if (request.date != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'التاريخ',
                  value: Helpers.formatDate(request.date!),
                ),
                const SizedBox(height: 8),
                if (request.time != null)
                  _buildDetailItem(
                    icon: Icons.access_time_outlined,
                    label: 'الوقت',
                    value: Helpers.formatTime(request.time!),
                  ),
              ],
            ),
          
          // Notes
          if (request.notes != null && request.notes!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'ملاحظات:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  request.notes!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
  
  Widget _buildJoinersList() {
    final request = _playRequestProvider.selectedPlayRequest;
    if (request == null || request.joiners.isEmpty) return Container();
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اللاعبون المنضمون (${request.joiners.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Column(
            children: request.joiners.map((joiner) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Text(
                    joiner.userName[0],
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(joiner.userName),
                subtitle: joiner.notes != null
                    ? Text(joiner.notes!)
                    : null,
                trailing: joiner.additionalPlayers > 1
                    ? Chip(
                        label: Text('+${joiner.additionalPlayers}'),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      )
                    : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    final request = _playRequestProvider.selectedPlayRequest;
    if (request == null) return Container();
    
    final userId = _authProvider.user?.id;
    final isCreator = request.creatorId == userId;
    final isJoined = userId != null && request.isUserJoined(userId);
    final canJoin = !isJoined && !request.isFull && request.status == 'open';
    final canLeave = isJoined && !isCreator && request.status == 'open';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          if (canJoin)
            AppButton(
              onPressed: _isJoining ? null : _handleJoin,
              text: 'انضم للطلب',
              isLoading: _isJoining,
              size: ButtonSize.large,
              type: ButtonType.primary,
              icon: Icons.group_add_outlined,
              fullWidth: true,
            ),
          
          if (canLeave)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AppButton(
                onPressed: _isJoining ? null : _handleLeave,
                text: 'مغادرة الطلب',
                isLoading: _isJoining,
                size: ButtonSize.large,
                type: ButtonType.outline,
                fullWidth: true,
              ),
            ),
          
          if (isCreator && request.status == 'open')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AppButton(
                onPressed: _handleCloseRequest,
                text: 'إغلاق الطلب',
                isLoading: _isJoining,
                size: ButtonSize.large,
                type: ButtonType.success,
                fullWidth: true,
              ),
            ),
        ],
      ),
    );
  }
  
  Future<void> _handleCloseRequest() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إغلاق الطلب'),
        content: const Text('هل أنت متأكد من إغلاق هذا الطلب؟ هذا يعني عدم قبول المزيد من اللاعبين.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      setState(() => _isJoining = true);
      await _playRequestProvider.updatePlayRequestStatus(
        widget.playRequestId!,
        'closed',
      );
      Helpers.showSuccessSnackbar(context, 'تم إغلاق الطلب بنجاح');
    } catch (e) {
      Helpers.showErrorSnackbar(context, 'فشل في إغلاق الطلب: ${e.toString()}');
    } finally {
      setState(() => _isJoining = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    _playRequestProvider = Provider.of<PlayRequestProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);
    
    final request = _playRequestProvider.selectedPlayRequest;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الطلب'),
        actions: [
          if (request != null)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: _shareRequest,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : request == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group_off_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text('الطلب غير موجود'),
                      const SizedBox(height: 8),
                      AppButton(
                        onPressed: () => Navigator.pop(context),
                        text: 'العودة',
                        type: ButtonType.outline,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPlayRequest,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildDetailsCard(),
                        const SizedBox(height: 16),
                        _buildJoinersList(),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
    );
  }
  
  void _shareRequest() {
    final request = _playRequestProvider.selectedPlayRequest;
    if (request == null) return;
    
    // TODO: Implement share functionality
    Helpers.showInfoSnackbar(context, 'ميزة المشاركة قريباً');
  }
}

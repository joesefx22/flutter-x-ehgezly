import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/play_request_provider.dart';
import 'package:ehgezly_app/providers/stadium_provider.dart';
import 'package:ehgezly_app/models/play_request.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/widgets/common/input_field.dart';
import 'package:ehgezly_app/widgets/common/modal.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class PlayerCreateRequestScreen extends StatefulWidget {
  static const routeName = '/player/create-request';
  
  const PlayerCreateRequestScreen({super.key});

  @override
  State<PlayerCreateRequestScreen> createState() => _PlayerCreateRequestScreenState();
}

class _PlayerCreateRequestScreenState extends State<PlayerCreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Controllers
  final _playersCountController = TextEditingController(text: '2');
  final _notesController = TextEditingController();
  
  // Form State
  String? _selectedStadiumId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  AgeGroup? _selectedAgeGroup;
  PlayerLevel? _selectedLevel;
  
  bool _isFlexibleDate = false;
  bool _isFlexibleTime = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStadiums();
  }

  @override
  void dispose() {
    _playersCountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadStadiums() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stadiumProvider = Provider.of<StadiumProvider>(context, listen: false);
      stadiumProvider.loadStadiums();
    });
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    
    if (selected != null) {
      setState(() {
        _selectedDate = selected;
      });
    }
  }

  Future<void> _selectTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (selected != null) {
      setState(() {
        _selectedTime = selected;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validate flexible options
    if (!_isFlexibleDate && _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار تاريخ أو تفعيل المرونة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (!_isFlexibleTime && _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار وقت أو تفعيل المرونة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_selectedAgeGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار الفئة العمرية'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار مستوى اللعب'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final playRequestProvider = Provider.of<PlayRequestProvider>(context, listen: false);
      
      // Combine date and time if both selected
      DateTime? combinedDateTime;
      if (_selectedDate != null && _selectedTime != null) {
        combinedDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
      }
      
      await playRequestProvider.createPlayRequest(
        stadiumId: _selectedStadiumId,
        dateTime: combinedDateTime,
        isFlexibleDate: _isFlexibleDate,
        isFlexibleTime: _isFlexibleTime,
        requiredPlayers: int.parse(_playersCountController.text),
        ageGroup: _selectedAgeGroup!,
        level: _selectedLevel!,
        notes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
      );
      
      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء الطلب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back or to requests list
      Navigator.pop(context);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل إنشاء الطلب: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildStadiumSelector(ThemeData theme, StadiumProvider stadiumProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر ملعب (اختياري)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        if (_selectedStadiumId == null)
          AppButton(
            text: 'اختر ملعب',
            type: ButtonType.outline,
            icon: Icons.sports_soccer,
            onPressed: () {
              _showStadiumSelection(stadiumProvider);
            },
          )
        else
          AppCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.sports_soccer, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stadiumProvider.stadiums
                            .firstWhere((s) => s.id == _selectedStadiumId)
                            .name,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        'ملعب محدد',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _selectedStadiumId = null;
                    });
                  },
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 8),
        Text(
          'يمكنك ترك هذا الحقل فارغاً إذا لم تحدد ملعباً',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  void _showStadiumSelection(StadiumProvider stadiumProvider) {
    showModal(
      context: context,
      title: 'اختر ملعب',
      content: SizedBox(
        height: 300,
        child: stadiumProvider.stadiums.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: stadiumProvider.stadiums.length,
                itemBuilder: (context, index) {
                  final stadium = stadiumProvider.stadiums[index];
                  return ListTile(
                    leading: const Icon(Icons.sports_soccer),
                    title: Text(stadium.name),
                    subtitle: Text(stadium.address.split(',').first),
                    trailing: _selectedStadiumId == stadium.id
                        ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedStadiumId = stadium.id;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
      ),
      actions: [
        AppButton(
          text: 'إلغاء',
          type: ButtonType.outline,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التاريخ والوقت',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Date Selection
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: _selectedDate != null
                    ? Helpers.formatDate(_selectedDate!)
                    : 'اختر تاريخ',
                type: ButtonType.outline,
                icon: Icons.calendar_today,
                onPressed: _selectDate,
              ),
            ),
            const SizedBox(width: 12),
            Checkbox(
              value: _isFlexibleDate,
              onChanged: (value) {
                setState(() {
                  _isFlexibleDate = value ?? false;
                  if (_isFlexibleDate) {
                    _selectedDate = null;
                  }
                });
              },
            ),
            const Text('مرن'),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Time Selection
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: _selectedTime != null
                    ? '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                    : 'اختر وقت',
                type: ButtonType.outline,
                icon: Icons.access_time,
                onPressed: _selectTime,
              ),
            ),
            const SizedBox(width: 12),
            Checkbox(
              value: _isFlexibleTime,
              onChanged: (value) {
                setState(() {
                  _isFlexibleTime = value ?? false;
                  if (_isFlexibleTime) {
                    _selectedTime = null;
                  }
                });
              },
            ),
            const Text('مرن'),
          ],
        ),
        
        const SizedBox(height: 8),
        Text(
          'المرونة تسمح للاعبين الآخرين باقتراح تواريخ وأوقات',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayersCount(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'عدد اللاعبين المطلوبين',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InputField(
          controller: _playersCountController,
          label: 'بما فيك أنت',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'هذا الحقل مطلوب';
            }
            final count = int.tryParse(value);
            if (count == null || count < 2 || count > 20) {
              return 'يجب أن يكون بين 2 و 20 لاعب';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          'ادخل العدد الإجمالي المطلوب (من 2 إلى 20)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeGroupSelector(ThemeData theme) {
    final ageGroups = AgeGroup.values;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الفئة العمرية',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ageGroups.map((ageGroup) {
            final isSelected = _selectedAgeGroup == ageGroup;
            return ChoiceChip(
              label: Text(PlayRequest.getAgeGroupLabel(ageGroup)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedAgeGroup = selected ? ageGroup : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLevelSelector(ThemeData theme) {
    final levels = PlayerLevel.values;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مستوى اللعب',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: levels.map((level) {
            final isSelected = _selectedLevel == level;
            return ChoiceChip(
              label: Text(PlayRequest.getLevelLabel(level)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedLevel = selected ? level : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملاحظات إضافية',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InputField(
          controller: _notesController,
          label: 'مثلاً: حجز مسبق، معدات خاصة، الخ',
          maxLines: 3,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final stadiumProvider = Provider.of<StadiumProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء طلب لاعبين'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.group_add,
                      size: 40,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'اطلب لاعبين',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'أنشئ طلباً للبحث عن لاعبين ينضمون معك',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stadium Selector
              _buildStadiumSelector(theme, stadiumProvider),

              const SizedBox(height: 24),
              const Divider(),

              // Date & Time
              _buildDateTimeSelector(theme),

              const SizedBox(height: 24),
              const Divider(),

              // Players Count
              _buildPlayersCount(theme),

              const SizedBox(height: 24),
              const Divider(),

              // Age Group
              _buildAgeGroupSelector(theme),

              const SizedBox(height: 24),
              const Divider(),

              // Level
              _buildLevelSelector(theme),

              const SizedBox(height: 24),
              const Divider(),

              // Notes
              _buildNotesField(theme),

              const SizedBox(height: 32),

              // Submit Button
              AppButton(
                text: 'إنشاء الطلب',
                type: ButtonType.primary,
                isLoading: _isLoading,
                icon: Icons.send,
                onPressed: _submitRequest,
                fullWidth: true,
              ),

              const SizedBox(height: 16),

              // Tips Card
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نصائح لطلب ناجح:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• حدد ملعباً لزيادة فرص الانضمام\n'
                      '• اختر فئة عمرية ومستوى مناسبين\n'
                      '• المرونة في الوقت تزيد من الخيارات\n'
                      '• اكتب ملاحظات واضحة عن اللعبة',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

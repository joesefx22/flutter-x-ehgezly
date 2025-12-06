import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../models/stadium.dart';
import '../../utils/helpers.dart';
import '../common/card.dart';
import '../common/button.dart';

class StadiumCard extends StatelessWidget {
  final Stadium stadium;
  final VoidCallback? onTap;
  final bool showDistance;
  final bool showBookingButton;
  final bool compactMode;

  const StadiumCard({
    super.key,
    required this.stadium,
    this.onTap,
    this.showDistance = true,
    this.showBookingButton = false,
    this.compactMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAvailable = stadium.hasAvailableSlots();
    final isFullyBooked = stadium.isFullyBooked();

    return AppCard(
      onTap: onTap,
      padding: compactMode ? EdgeInsets.all(8) : EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصورة الرئيسية
          _buildImageSection(context),
          
          SizedBox(height: compactMode ? 8 : 12),
          
          // المعلومات الأساسية
          _buildInfoSection(context),
          
          if (!compactMode) SizedBox(height: 8),
          
          // المميزات
          if (!compactMode) _buildFeaturesSection(),
          
          if (!compactMode) SizedBox(height: 8),
          
          // السعر والتقييم
          _buildPriceRatingSection(context),
          
          if (showBookingButton) SizedBox(height: compactMode ? 8 : 12),
          
          // زر الحجز السريع
          if (showBookingButton && isAvailable) 
            _buildBookingButton(context),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        // صورة الملعب
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: stadium.mainImage ?? stadium.images.firstOrNull ?? '',
            height: compactMode ? 120 : 160,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: Icon(Icons.sports_soccer, size: 40, color: Colors.grey[400]),
            ),
          ),
        ),
        
        // شارة النوع
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: stadium.type == 'football' 
                ? Colors.green.withOpacity(0.9)
                : Colors.blue.withOpacity(0.9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              stadium.type == 'football' ? 'كرة قدم' : 'بادل',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        // شارة حالة التوفر
        if (stadium.isFullyBooked())
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'ممتلئ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // اسم الملعب
        Text(
          stadium.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        SizedBox(height: 4),
        
        // العنوان
        Row(
          children: [
            Icon(Icons.location_on, size: 14, color: theme.hintColor),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                stadium.address ?? 'لا يوجد عنوان',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        // المسافة (إذا كان GPS مفعلاً)
        if (showDistance && stadium.distance != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${Helpers.formatDistance(stadium.distance!)} كم',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: stadium.features.take(3).map((feature) {
        final icon = _getFeatureIcon(feature);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon.icon, size: 12, color: icon.color),
            SizedBox(width: 2),
            Text(
              feature,
              style: TextStyle(fontSize: 10),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPriceRatingSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // السعر
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'سعر الساعة',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
            Text(
              '${Helpers.formatCurrency(stadium.pricePerHour)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        // التقييم
        if (stadium.rating > 0)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RatingBar.builder(
                initialRating: stadium.rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 16,
                itemPadding: EdgeInsets.symmetric(horizontal: 1),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {},
                ignoreGestures: true,
              ),
              SizedBox(height: 2),
              Text(
                '(${stadium.reviewCount})',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildBookingButton(BuildContext context) {
    return AppButton(
      text: 'حجز سريع',
      onPressed: onTap,
      type: ButtonType.primary,
      size: ButtonSize.medium,
      isFullWidth: true,
      icon: Icons.event_available,
    );
  }

  _FeatureIcon _getFeatureIcon(String feature) {
    switch (feature) {
      case 'إضاءة':
        return _FeatureIcon(Icons.lightbulb, Colors.amber);
      case 'خلع':
        return _FeatureIcon(Icons.shower, Colors.blue);
      case 'مقهى':
        return _FeatureIcon(Icons.coffee, Colors.brown);
      case 'تأمين':
        return _FeatureIcon(Icons.security, Colors.green);
      case 'مواقف':
        return _FeatureIcon(Icons.local_parking, Colors.grey);
      default:
        return _FeatureIcon(Icons.check, Colors.green);
    }
  }
}

class _FeatureIcon {
  final IconData icon;
  final Color color;

  _FeatureIcon(this.icon, this.color);
}

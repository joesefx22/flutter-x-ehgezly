import 'package:flutter/material.dart';
import 'package:ehgezly_app/widgets/reviews/rating_stars.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final bool showStadiumInfo;
  final VoidCallback? onReport;
  
  const ReviewCard({
    super.key,
    required this.review,
    this.showStadiumInfo = false,
    this.onReport,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info and rating
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[200],
                child: Text(
                  review.userName[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.timeAgo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              RatingStars(rating: review.rating, starSize: 16),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Review content
          if (review.comment != null && review.comment!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                review.comment!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          
          // Stadium info (if needed)
          if (showStadiumInfo && review.stadiumName != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.stadium_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      review.stadiumName!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 12),
          
          // Actions row
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.thumb_up_outlined,
                  size: 18,
                  color: Colors.grey[500],
                ),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(
                review.likesCount > 0 ? review.likesCount.toString() : '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(
                  Icons.thumb_down_outlined,
                  size: 18,
                  color: Colors.grey[500],
                ),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              if (onReport != null)
                TextButton(
                  onPressed: onReport,
                  child: Text(
                    'إبلاغ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// Model for Review
class Review {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final int likesCount;
  final int dislikesCount;
  final String? stadiumId;
  final String? stadiumName;
  final String? bookingId;
  
  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.likesCount = 0,
    this.dislikesCount = 0,
    this.stadiumId,
    this.stadiumName,
    this.bookingId,
  });
  
  String get timeAgo {
    return Helpers.getTimeAgo(createdAt);
  }
  
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'مستخدم',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      likesCount: json['likesCount'] ?? 0,
      dislikesCount: json['dislikesCount'] ?? 0,
      stadiumId: json['stadiumId'],
      stadiumName: json['stadiumName'],
      bookingId: json['bookingId'],
    );
  }
}

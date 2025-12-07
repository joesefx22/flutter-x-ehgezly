import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double starSize;
  final Color color;
  final bool showRatingNumber;
  final int totalStars;
  
  const RatingStars({
    super.key,
    required this.rating,
    this.starSize = 16,
    this.color = Colors.amber,
    this.showRatingNumber = true,
    this.totalStars = 5,
  });
  
  @override
  Widget build(BuildContext context) {
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;
    final emptyStars = totalStars - fullStars - (hasHalfStar ? 1 : 0);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Full stars
        for (int i = 0; i < fullStars; i++)
          Icon(Icons.star, size: starSize, color: color),
        
        // Half star
        if (hasHalfStar)
          Icon(Icons.star_half, size: starSize, color: color),
        
        // Empty stars
        for (int i = 0; i < emptyStars; i++)
          Icon(Icons.star_border, size: starSize, color: color),
        
        // Rating number
        if (showRatingNumber)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              rating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: starSize * 0.8,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

class EditableRatingStars extends StatefulWidget {
  final double initialRating;
  final double starSize;
  final Color color;
  final ValueChanged<double> onRatingChanged;
  
  const EditableRatingStars({
    super.key,
    this.initialRating = 0,
    this.starSize = 32,
    this.color = Colors.amber,
    required this.onRatingChanged,
  });
  
  @override
  State<EditableRatingStars> createState() => _EditableRatingStarsState();
}

class _EditableRatingStarsState extends State<EditableRatingStars> {
  late double _currentRating;
  
  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }
  
  void _updateRating(double rating) {
    setState(() => _currentRating = rating);
    widget.onRatingChanged(rating);
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starRating = index + 1.0;
        return GestureDetector(
          onTap: () => _updateRating(starRating),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Icon(
              starRating <= _currentRating
                  ? Icons.star
                  : starRating - 0.5 <= _currentRating
                      ? Icons.star_half
                      : Icons.star_border,
              size: widget.starSize,
              color: widget.color,
            ),
          ),
        );
      }),
    );
  }
}

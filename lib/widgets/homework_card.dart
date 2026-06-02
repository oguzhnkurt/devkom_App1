import 'package:flutter/material.dart';
import '../models/homework_model.dart';

class HomeworkCard extends StatelessWidget {
  final HomeworkModel homework;
  final HomeworkSubmission? submission;
  final VoidCallback onSubmit;
  final VoidCallback onViewDetails;

  const HomeworkCard({
    Key? key,
    required this.homework,
    this.submission,
    required this.onSubmit,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSubmitted = submission != null;
    final bool isLate = homework.isLate && !isSubmitted;
    final bool isUrgent = homework.isUrgent && !isSubmitted;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getBorderColor(isSubmitted, isLate, isUrgent),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Status Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(isSubmitted, isLate, isUrgent)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getStatusIcon(isSubmitted, isLate),
                        color: _getStatusColor(isSubmitted, isLate, isUrgent),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            homework.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getAgeGroupLabel(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    _buildStatusBadge(isSubmitted, isLate, isUrgent),
                  ],
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  homework.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Due Date Row
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Teslim: ${_formatDate(homework.dueDate)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: _getUrgencyColor(isSubmitted, isLate, isUrgent),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getRemainingTime(),
                      style: TextStyle(
                        fontSize: 13,
                        color: _getUrgencyColor(isSubmitted, isLate, isUrgent),
                        fontWeight: isUrgent || isLate
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),

                // Score Section (if graded)
                if (submission?.status == HomeworkStatus.graded) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Puan: ${submission!.score}/${homework.maxScore}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        if (submission!.feedback != null) ...[
                          const Spacer(),
                          Icon(
                            Icons.comment,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Details Button
                    TextButton.icon(
                      onPressed: onViewDetails,
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Detay'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Submit Button
                    if (!isSubmitted)
                      ElevatedButton.icon(
                        onPressed: onSubmit,
                        icon: const Icon(Icons.upload, size: 18),
                        label: const Text('Teslim Et'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: onViewDetails,
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Görüntüle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isSubmitted, bool isLate, bool isUrgent) {
    if (isSubmitted) {
      if (submission!.status == HomeworkStatus.graded) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '⭐ Puanlandı',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '✅ Teslim Edildi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
    } else if (isLate) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '🔴 Gecikmiş',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (isUrgent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '🟡 Yaklaşıyor',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '🟢 Zamanında',
          style: TextStyle(
            color: Colors.green,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  Color _getBorderColor(bool isSubmitted, bool isLate, bool isUrgent) {
    if (isSubmitted) return Colors.blue.shade200;
    if (isLate) return Colors.red.shade200;
    if (isUrgent) return Colors.orange.shade200;
    return Colors.green.shade200;
  }

  Color _getStatusColor(bool isSubmitted, bool isLate, bool isUrgent) {
    if (isSubmitted) return Colors.blue;
    if (isLate) return Colors.red;
    if (isUrgent) return Colors.orange;
    return Colors.green;
  }

  Color _getUrgencyColor(bool isSubmitted, bool isLate, bool isUrgent) {
    if (isSubmitted) return Colors.grey.shade600;
    if (isLate) return Colors.red;
    if (isUrgent) return Colors.orange;
    return Colors.grey.shade600;
  }

  IconData _getStatusIcon(bool isSubmitted, bool isLate) {
    if (isSubmitted) return Icons.check_circle;
    if (isLate) return Icons.warning;
    return Icons.assignment;
  }

  String _getAgeGroupLabel() {
    switch (homework.ageGroup) {
      case AgeGroup.age4to6:
        return '4-6 Yaş';
      case AgeGroup.age7to9:
        return '7-9 Yaş';
      case AgeGroup.age10to12:
        return '10-12 Yaş';
      case AgeGroup.age13plus:
        return '13+ Yaş';
      case AgeGroup.all:
        return 'Tüm Yaşlar';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getRemainingTime() {
    if (submission != null) {
      return 'Teslim edildi';
    }

    final now = DateTime.now();
    final difference = homework.dueDate.difference(now);

    if (difference.isNegative) {
      return 'Geçti';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün kaldı';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat kaldı';
    } else {
      return '${difference.inMinutes} dakika kaldı';
    }
  }
}

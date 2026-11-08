import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final IncidentStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final statusColors = Theme.of(context).extension<StatusColors>()!;
    
    Color bgColor;
    Color textColor;
    
    switch (status) {
      case IncidentStatus.submitted:
        bgColor = statusColors.submittedBg;
        textColor = statusColors.submittedText;
        break;
      case IncidentStatus.inProgress:
        bgColor = statusColors.inProgressBg;
        textColor = statusColors.inProgressText;
        break;
      case IncidentStatus.resolved:
        bgColor = statusColors.resolvedBg;
        textColor = statusColors.resolvedText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

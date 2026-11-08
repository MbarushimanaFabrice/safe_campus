import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AvatarWithFallback extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;

  const AvatarWithFallback({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40,
  });

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: size / 2,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: size / 2,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) => _buildFallback(context),
      );
    }
    
    return _buildFallback(context);
  }

  Widget _buildFallback(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.primary,
      child: Text(
        _getInitials(name),
        style: TextStyle(
          color: Colors.white,
          fontSize: size / 2.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

enum WsButtonType { primary, secondary, outlined, text }

class WsButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final WsButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const WsButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = WsButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = isLoading
        ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );

    Widget button;
    switch (type) {
      case WsButtonType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: content,
        );
        break;
      case WsButtonType.secondary:
        button = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
          ),
          onPressed: isLoading ? null : onPressed,
          child: content,
        );
        break;
      case WsButtonType.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: content,
        );
        break;
      case WsButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          child: content,
        );
        break;
    }

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    
    return button;
  }
}

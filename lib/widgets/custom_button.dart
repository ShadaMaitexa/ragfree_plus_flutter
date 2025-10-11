import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.padding,
    this.isLoading = false,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = isOutlined
        ? OutlinedButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        foregroundColor ??
                            Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : Icon(icon),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              foregroundColor: foregroundColor,
              side: BorderSide(
                color: backgroundColor ?? Theme.of(context).colorScheme.primary,
              ),
              padding:
                  padding ??
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: Size(width ?? 0, height ?? 48),
            ),
          )
        : FilledButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        foregroundColor ?? Colors.white,
                      ),
                    ),
                  )
                : Icon(icon),
            label: Text(label),
            style: FilledButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              padding:
                  padding ??
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: Size(width ?? 0, height ?? 48),
            ),
          );

    return button;
  }
}

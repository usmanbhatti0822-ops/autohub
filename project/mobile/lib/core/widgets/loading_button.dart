import 'package:flutter/material.dart';

/// Full-width primary button that swaps its label for a spinner while
/// [loading] is true — the same pattern every form in the app needs,
/// written once instead of re-implemented per screen.
class LoadingButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;
  final bool outlined;

  const LoadingButton({
    super.key,
    required this.loading,
    required this.onPressed,
    required this.child,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: outlined ? Theme.of(context).colorScheme.primary : Colors.white,
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(icon, size: 18), const SizedBox(width: 8), child],
              )
            : child;

    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton(onPressed: loading ? null : onPressed, child: content)
          : ElevatedButton(onPressed: loading ? null : onPressed, child: content),
    );
  }
}

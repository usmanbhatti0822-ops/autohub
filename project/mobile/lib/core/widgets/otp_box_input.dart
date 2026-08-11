import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Segmented OTP entry — N single-digit boxes that auto-advance focus,
/// instead of one plain numeric text field.
class OtpBoxInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool hasError;
  final String? initialValue;

  const OtpBoxInput({
    super.key,
    this.length = 4,
    required this.onChanged,
    this.onCompleted,
    this.hasError = false,
    this.initialValue,
  });

  @override
  State<OtpBoxInput> createState() => OtpBoxInputState();
}

class OtpBoxInputState extends State<OtpBoxInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (i) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
    final initial = widget.initialValue ?? '';
    for (var i = 0; i < initial.length && i < widget.length; i++) {
      _controllers[i].text = initial[i];
    }
  }

  /// Replaces the current value, e.g. when a dev/demo code is prefilled.
  void setValue(String value) {
    for (var i = 0; i < widget.length; i++) {
      _controllers[i].text = i < value.length ? value[i] : '';
    }
    setState(() {});
    _emit();
  }

  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _nodes.first.requestFocus();
    setState(() {});
  }

  void _emit() {
    final value = _controllers.map((c) => c.text).join();
    widget.onChanged(value);
    if (value.length == widget.length) widget.onCompleted?.call(value);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (i) {
        return SizedBox(
          width: 56,
          height: 60,
          child: TextField(
            controller: _controllers[i],
            focusNode: _nodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: Theme.of(context).textTheme.headlineSmall,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                borderSide: BorderSide(
                  color: widget.hasError ? AppColors.danger : AppColors.outline,
                  width: 1.4,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                borderSide: BorderSide(
                  color: widget.hasError ? AppColors.danger : AppColors.primary,
                  width: 1.8,
                ),
              ),
            ),
            onChanged: (val) {
              if (val.isNotEmpty && i < widget.length - 1) {
                _nodes[i + 1].requestFocus();
              } else if (val.isEmpty && i > 0) {
                _nodes[i - 1].requestFocus();
              }
              _emit();
            },
          ),
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hisabi/config/theme.dart';

Future<bool?> showConfirmationSheet(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required VoidCallback onConfirm,
  bool isDangerous = false,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _ConfirmationSheet(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      onConfirm: onConfirm,
      isDangerous: isDangerous,
    ),
  );
}

class _ConfirmationSheet extends StatelessWidget {
  const _ConfirmationSheet({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    required this.isDangerous,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final bool isDangerous;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle indicator
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Message
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: colors.textSec,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              // Cancel button
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: colors.cardAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textSec,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Confirm button
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context, true);
                    onConfirm();
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: isDangerous
                          ? null
                          : const LinearGradient(
                              colors: [kPrimaryLight, kPrimary],
                            ),
                      color: isDangerous ? kDanger : null,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
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

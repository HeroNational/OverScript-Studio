import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class RecordBadge extends StatelessWidget {
  final bool isRecording;
  final int seconds;
  final VoidCallback onTap;

  const RecordBadge({
    super.key,
    required this.isRecording,
    required this.seconds,
    required this.onTap,
  });

  String _format(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRecording ? Colors.redAccent : Colors.white24,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isRecording ? LucideIcons.circle : LucideIcons.circle_dashed,
              color: isRecording ? Colors.redAccent : Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              isRecording ? _format(seconds) : 'REC',
              style: TextStyle(
                color: isRecording ? Colors.redAccent : Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

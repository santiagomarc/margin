import 'package:flutter/material.dart';

import '../state/feedback_controller.dart';

/// Briefly shows what an invisible gesture did ("Undo", "Redo").
class FeedbackPill extends StatelessWidget {
  const FeedbackPill({super.key, required this.controller});

  final FeedbackController controller;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final message = controller.message;
          return AnimatedOpacity(
            opacity: message == null ? 0 : 1,
            duration: const Duration(milliseconds: 120),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xE61B1F24),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          );
        },
      ),
    );
  }
}

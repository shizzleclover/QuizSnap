import 'package:flutter/material.dart';

/// Multiplayer quiz placeholder. Live gameplay & scoreboard later.
/// Referenced by `AppRoutes.multiplayerQuiz`.
class MultiplayerQuizScreen extends StatelessWidget {
  const MultiplayerQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multiplayer Quiz')),
      body: const Center(child: Text('Live quiz UI coming soon')),
    );
  }
}


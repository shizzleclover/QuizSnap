import 'package:flutter/material.dart';
import 'package:quizsnap/core/widgets/index.dart';
import 'package:quizsnap/core/routes/routes.dart';

/// Multiplayer lobby placeholder. Realtime rooms with Supabase later.
/// Referenced by `AppRoutes.multiplayerLobby`.
class MultiplayerLobbyScreen extends StatelessWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithNav(
      currentRoute: AppRoutes.multiplayerLobby,
      appBar: AppBar(title: const Text('Multiplayer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BrutCard(
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Multiplayer Lobby',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Challenge friends in real-time quiz battles'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            PrimaryButton(
              label: 'Create Room',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Realtime rooms coming soon!')),
                );
              },
            ),
            const SizedBox(height: 12),
            
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Room joining coming soon!')),
                );
              },
              child: const Text('Join Room'),
            ),
            
            const SizedBox(height: 24),
            
            const BrutCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Coming Soon:'),
                  SizedBox(height: 8),
                  Text('• Real-time quiz rooms'),
                  Text('• Live scoreboard'),
                  Text('• Friend challenges'),
                  Text('• Team battles'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


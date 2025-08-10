import 'package:flutter/material.dart';
import 'package:quizsnap/core/widgets/index.dart';
import 'package:quizsnap/core/Routes/routes.dart';

/// Home/Dashboard screen. Quick links to upload and play modes.
/// Referenced by `AppRoutes.home`.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithNav(
      currentRoute: AppRoutes.home,
      hasDrawer: true,
      appBar: AppBar(
        title: const Text('QuizSnap'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: ThemeToggle(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BrutCard(
              child: Column(
                children: [
                  Text(
                    'Welcome to QuizSnap!',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Upload documents to generate AI-powered MCQs and start learning'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Upload Doc',
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.upload),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.soloQuiz),
                    child: const Text('Start Quiz'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            OutlinedButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.multiplayerLobby),
              child: const Text('Join Multiplayer Room'),
            ),
            
            const SizedBox(height: 24),
            
            // Recent activity placeholder
            const BrutCard(
              child: Column(
                children: [
                  Text('Recent Activity'),
                  SizedBox(height: 8),
                  Text('No recent quizzes yet. Upload a document to get started!'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


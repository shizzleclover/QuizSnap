import 'package:flutter/material.dart';
import 'package:quizsnap/core/widgets/index.dart';
import 'package:quizsnap/core/Routes/routes.dart';

/// Solo quiz gameplay placeholder. Hook up question engine later.
/// Referenced by `AppRoutes.soloQuiz`.
class SoloQuizScreen extends StatelessWidget {
  const SoloQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithNav(
      currentRoute: AppRoutes.soloQuiz,
      appBar: AppBar(title: const Text('Solo Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BrutCard(
              child: Column(
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Solo Quiz Mode',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Test your knowledge with AI-generated questions'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const BrutCard(
              child: Text('Quiz engine coming soon! Upload a document first to generate questions.'),
            ),
          ],
        ),
      ),
    );
  }
}


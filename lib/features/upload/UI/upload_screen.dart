import 'package:flutter/material.dart';
import 'package:quizsnap/core/widgets/index.dart';
import 'package:quizsnap/core/routes/routes.dart';

/// Upload & Generate screen. Integrate file_picker and Supabase Storage later.
/// Referenced by `AppRoutes.upload`.
class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithNav(
      currentRoute: AppRoutes.upload,
      appBar: AppBar(title: const Text('Upload & Generate')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BrutCard(
              child: Column(
                children: [
                  Icon(
                    Icons.upload_file_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Upload Document',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Upload PDFs, Word docs, or images to generate MCQs'),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Choose File',
                    onPressed: () {
                      // TODO: Implement file picker
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('File picker coming soon!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const BrutCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Supported Formats:'),
                  SizedBox(height: 8),
                  Text('• PDF files'),
                  Text('• Word documents (.docx)'),
                  Text('• Images with text (OCR)'),
                  Text('• Plain text files'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


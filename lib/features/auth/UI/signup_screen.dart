import 'package:flutter/material.dart';
import 'package:quizsnap/core/Routes/routes.dart';
import 'package:quizsnap/core/widgets/progress_pill.dart';

/// Signup screen redesigned with dark layout and progress pill.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  DateTime? _dob;
  final TextEditingController _phone = TextEditingController();
  String? _country;
  int? _age;
  bool _submitting = false;

  double get _progress {
    int filled = 0;
    if (_name.text.trim().isNotEmpty) filled++;
    if (_dob != null) filled++;
    if (_phone.text.trim().isNotEmpty) filled++;
    if (_country != null && _country!.isNotEmpty) filled++;
    if (_age != null) filled++;
    return filled / 5;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
        ),
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: ProgressPill(value: _progress),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Create an account ✏️',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Please complete your profile.\nDon\'t worry, your data will remain private and only you can see it.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),

                const SizedBox(height: 24),
                _label(context, 'Full Name'),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    hintText: 'Andrew Ainsley',
                    border: UnderlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),

                const SizedBox(height: 16),
                _label(context, 'Date of Birth'),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'MM/DD/YYYY',
                        suffixIcon: Icon(Icons.calendar_today_outlined, color: theme.colorScheme.primary),
                        border: const UnderlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: _dob == null ? '' : _formatDate(_dob!),
                      ),
                      validator: (_) => _dob == null ? 'Required' : null,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                _label(context, 'Phone Number'),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '+1-300-555-0399',
                    border: UnderlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),

                const SizedBox(height: 16),
                _label(context, 'Country'),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(border: UnderlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'United States', child: Text('United States')),
                    DropdownMenuItem(value: 'Canada', child: Text('Canada')),
                    DropdownMenuItem(value: 'United Kingdom', child: Text('United Kingdom')),
                  ],
                  value: _country,
                  onChanged: (v) => setState(() => _country = v),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),

                const SizedBox(height: 16),
                _label(context, 'Age'),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(border: UnderlineInputBorder()),
                  items: List.generate(83, (i) => i + 18)
                      .map((a) => DropdownMenuItem(value: a, child: Text('$a')))
                      .toList(),
                  value: _age,
                  onChanged: (v) => setState(() => _age = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.dividerColor, width: 1)),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: _submitting ? null : _continue,
          child: const Text('Continue'),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 10),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  String _formatDate(DateTime d) => '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _continue() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.of(context).pushReplacementNamed(AppRoutes.profileSetup);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }
}
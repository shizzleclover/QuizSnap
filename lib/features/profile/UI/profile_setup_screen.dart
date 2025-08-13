import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quizsnap/core/routes/routes.dart';
import 'package:quizsnap/core/widgets/index.dart';
import '../provider/profile_provider.dart';
import '../../auth/provider/auth_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/token_manager.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String? _selectedGender;
  DateTime? _selectedDate;
  File? _profileImage;
  bool _usernameChecked = false;
  bool _usernameAvailable = false;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _ensureTokenIsAvailable();
    _prefillFromAuth();
  }

  /// Ensure auth token is available when profile setup screen loads
  Future<void> _ensureTokenIsAvailable() async {
    if (kDebugMode) {
      print('=== Profile Setup Screen - Token Check ===');
      await TokenManager.debugTokenState('Profile Setup Screen Init');
    }
    
    // Synchronize tokens between storage and memory
    final hasTokens = await TokenManager.synchronizeTokens();
    
    if (kDebugMode) {
      print('Tokens synchronized: $hasTokens');
      await TokenManager.debugTokenState('After synchronization');
    }
    
    if (!hasTokens) {
      if (kDebugMode) {
        print('No tokens available - user needs to authenticate');
      }
      
      // Show error and redirect to login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication expired. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login, 
          (route) => false
        );
      }
    }
  }

  void _prefillFromAuth() {
    final authState = ref.read(authProvider);
    if (authState.user != null) {
      _firstNameController.text = authState.user!.firstName ?? '';
      _lastNameController.text = authState.user!.lastName ?? '';
      _phoneController.text = authState.user!.phoneNumber ?? '';
      _displayNameController.text = authState.user!.fullName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileState = ref.watch(profileProvider);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Complete Your Profile', 
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            )),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          // Debug button to navigate to login
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login, 
                (route) => false
              );
            },
            icon: const Icon(Icons.login),
            tooltip: 'Debug: Go to Login',
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Progress indicator
              Container(
                padding: const EdgeInsets.all(20),
                child: ProgressPill(value: _calculateProgress()),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Let\'s set up your profile! 🎯',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete your profile to unlock all features and connect with other users.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Profile Picture Section
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.primary,
                                width: 3,
                              ),
                              color: theme.colorScheme.surface,
                            ),
                            child: _profileImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Image.file(
                                      _profileImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.camera_alt_outlined,
                                    size: 40,
                                    color: theme.colorScheme.primary,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Tap to add photo',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Personal Information
                      Text(
                        'Personal Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _firstNameController,
                              label: 'First Name',
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'First name is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              controller: _lastNameController,
                              label: 'Last Name',
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Last name is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      AppTextField(
                        controller: _usernameController,
                        label: 'Username',
                        onChanged: _checkUsername,
                        suffix: _usernameChecked
                            ? Icon(
                                _usernameAvailable ? Icons.check_circle : Icons.error,
                                color: _usernameAvailable ? Colors.green : Colors.red,
                              )
                            : null,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Username is required';
                          }
                          if (!_usernameChecked || !_usernameAvailable) {
                            return 'Please choose an available username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      AppTextField(
                        controller: _displayNameController,
                        label: 'Display Name',
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Display name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      AppTextField(
                        controller: _bioController,
                        label: 'Bio (Optional)',
                        maxLines: 3,
                        maxLength: 150,
                      ),
                      const SizedBox(height: 24),
                      
                      // Additional Information
                      Text(
                        'Additional Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      AppTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      
                      // Date of Birth
                      GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.colorScheme.outline),
                            borderRadius: BorderRadius.circular(8),
                            color: theme.colorScheme.surface,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate != null
                                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                    : 'Date of Birth (Optional)',
                                style: TextStyle(
                                  color: _selectedDate != null
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Gender Selection
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          labelText: 'Gender (Optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: ['Male', 'Female', 'Other', 'Prefer not to say']
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      if (profileState.error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            profileState.error!,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Bottom Button
              Container(
                padding: const EdgeInsets.all(20),
                child: PrimaryButton(
                  text: profileState.isLoading ? 'Setting up...' : 'Complete Setup',
                  onPressed: profileState.isLoading ? null : _completeSetup,
                  isLoading: profileState.isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateProgress() {
    int completed = 0;
    const int total = 4; // Required fields: firstName, lastName, username, displayName
    
    if (_firstNameController.text.isNotEmpty) completed++;
    if (_lastNameController.text.isNotEmpty) completed++;
    if (_usernameController.text.isNotEmpty && _usernameAvailable) completed++;
    if (_displayNameController.text.isNotEmpty) completed++;
    
    return completed / total;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  void _checkUsername(String username) async {
    if (username.trim().length < 3) {
      setState(() {
        _usernameChecked = false;
        _usernameAvailable = false;
      });
      return;
    }
    // Debounce minimal: avoid spamming backend
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    final isAvailable = await ref.read(profileProvider.notifier).checkUsernameAvailability(username);
    setState(() {
      _usernameChecked = true;
      _usernameAvailable = isAvailable;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (kDebugMode) {
      print('=== Profile Setup - Starting ===');
      await TokenManager.debugTokenState('Profile Setup - Before');
    }
    
    // Ensure tokens are available before making the call
    final hasTokens = await TokenManager.synchronizeTokens();
    if (!hasTokens) {
      if (kDebugMode) {
        print('No tokens available for profile setup!');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication required. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    final success = await ref.read(profileProvider.notifier).setupProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      username: _usernameController.text.trim(),
      displayName: _displayNameController.text.trim(),
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      profilePicturePath: _profileImage?.path,
      phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      dateOfBirth: _selectedDate != null
          ? '${_selectedDate!.year.toString().padLeft(4, '0')}-'
            '${_selectedDate!.month.toString().padLeft(2, '0')}-'
            '${_selectedDate!.day.toString().padLeft(2, '0')}'
          : null,
      gender: _selectedGender,
    );
    
    if (kDebugMode) {
      print('Profile Setup - Success: $success');
    }
    
    if (success) {
      // Profile setup was successful - refresh auth status and navigate
      if (kDebugMode) {
        print('Profile Setup - Success! Refreshing auth status...');
      }
      
      // Force refresh auth status from source
      await ref.read(authProvider.notifier).checkAuthStatus();
      if (!mounted) return;

      final authState = ref.read(authProvider);
      if (kDebugMode) {
        print('Profile Setup - Auth status after refresh: ${authState.authStatus}');
        print('Profile Setup - Profile complete: ${authState.isProfileComplete}');
      }
      
      final next = authState.authStatus == AuthMeStatus.complete
          ? AppRoutes.home
          : AppRoutes.profileSetup;
      Navigator.of(context).pushNamedAndRemoveUntil(next, (route) => false);
    } else {
      // Profile setup failed - check if it's a token issue and try to recover
      if (kDebugMode) {
        print('Profile Setup - Failed! Checking if token is missing...');
      }
      
      final token = ApiService.authToken;
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          print('Profile Setup - No token found, attempting recovery from storage');
        }
        
        try {
          final storage = const FlutterSecureStorage();
          final storedToken = await storage.read(key: 'access_token');
          if (storedToken != null && storedToken.isNotEmpty) {
            ApiService.setAuthToken(storedToken);
            if (kDebugMode) {
              print('Profile Setup - Token recovered, retrying setup...');
            }
            
            // Show snackbar and let user try again
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session restored. Please try again.'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          } else {
            // No token found - redirect to login
            if (kDebugMode) {
              print('Profile Setup - No stored token found, redirecting to login');
            }
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login, 
                (route) => false
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Profile Setup - Token recovery failed: $e');
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Authentication error. Please log in again.'),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login, 
              (route) => false
            );
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
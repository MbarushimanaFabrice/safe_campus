import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/cloudinary_service.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/avatar_with_fallback.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  bool _isUpdating = false;
  bool _isUploadingAvatar = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedDepartment;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateAvatar() async {
    final picker = ImagePicker();
    final image = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () async {
                final img = await picker.pickImage(source: ImageSource.camera);
                if (context.mounted) Navigator.pop(context, img);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                final img = await picker.pickImage(source: ImageSource.gallery);
                if (context.mounted) Navigator.pop(context, img);
              },
            ),
          ],
        ),
      ),
    );

    if (image == null) return;

    setState(() => _isUploadingAvatar = true);

    try {
      final cloudinaryService = CloudinaryService();
      final result = await cloudinaryService.uploadImage(
        imageBytes: await image.readAsBytes(),
        folder: AppConstants.cloudinaryProfilesFolder,
        compress: true,
      );

      await ref.read(authRepositoryProvider).updateUserProfile(
            photoUrl: result.url,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(currentUserDataProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getCloudinaryErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isUpdating = true);

    try {
      await ref.read(authRepositoryProvider).updateUserProfile(
            fullName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
            department: _selectedDepartment,
            phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
        ref.invalidate(currentUserDataProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _changePassword() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: currentPasswordController,
              label: 'Current Password',
              obscureText: true,
              showPasswordToggle: true,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: newPasswordController,
              label: 'New Password',
              obscureText: true,
              showPasswordToggle: true,
              validator: Validators.password,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: confirmPasswordController,
              label: 'Confirm New Password',
              obscureText: true,
              showPasswordToggle: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Would need Firebase re-authentication here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password change requires re-authentication. Please use "Forgot Password" on login screen.'),
                  duration: Duration(seconds: 5),
                ),
              );
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    await ref.read(authRepositoryProvider).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final userDataAsync = ref.watch(currentUserDataProvider);
    final isDarkMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                final userData = userDataAsync.value;
                if (userData != null) {
                  _nameController.text = userData.fullName;
                  _phoneController.text = userData.phone ?? '';
                  _selectedDepartment = userData.department;
                  setState(() => _isEditing = true);
                }
              },
            ),
        ],
      ),
      body: userDataAsync.when(
        data: (userData) {
          if (userData == null) {
            return const Center(child: Text('User data not found'));
          }

          final departmentOptions = [...AppConstants.departments];
          if (_selectedDepartment != null &&
              !departmentOptions.contains(_selectedDepartment)) {
            departmentOptions.insert(0, _selectedDepartment!);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Avatar
                Stack(
                  children: [
                    AvatarWithFallback(
                      imageUrl: userData.photoUrl,
                      name: userData.fullName,
                      size: 120,
                    ),
                    if (_isUploadingAvatar)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _isUploadingAvatar ? null : _updateAvatar,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Profile Info or Edit Form
                if (_isEditing) ...[
                  // Edit Form
                  AppTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    validator: Validators.name,
                    enabled: !_isUpdating,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedDepartment,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      prefixIcon: Icon(Icons.school),
                    ),
                    items: departmentOptions.map((dept) {
                      return DropdownMenuItem(value: dept, child: Text(dept));
                    }).toList(),
                    onChanged: _isUpdating
                        ? null
                        : (value) {
                            setState(() => _selectedDepartment = value);
                          },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _phoneController,
                    label: 'Phone (Optional)',
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                    enabled: !_isUpdating,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Cancel',
                          onPressed: _isUpdating
                              ? null
                              : () {
                                  setState(() => _isEditing = false);
                                },
                          type: AppButtonType.outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppButton(
                          text: 'Save',
                          onPressed: _saveProfile,
                          isLoading: _isUpdating,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Display Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            userData.fullName,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              userData.role == UserRole.staff ? 'Staff' : 'Student',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(Icons.email, userData.email),
                          _buildInfoRow(Icons.school, userData.department),
                          if (userData.phone != null)
                            _buildInfoRow(Icons.phone, userData.phone!),
                          _buildInfoRow(Icons.location_on, 'Kigali, Rwanda'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Settings Section
                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Dark Mode'),
                          subtitle: const Text('Toggle dark theme'),
                          value: isDarkMode,
                          onChanged: (value) {
                            ref.read(themeModeProvider.notifier).toggleTheme();
                          },
                          secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.lock),
                          title: const Text('Change Password'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _changePassword,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text('Logout', style: TextStyle(color: Colors.red)),
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).textTheme.bodySmall?.color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

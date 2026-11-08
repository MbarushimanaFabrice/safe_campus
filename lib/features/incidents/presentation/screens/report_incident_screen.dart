import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/cloudinary_service.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/incident_providers.dart';
import 'incident_details_screen.dart';

class ReportIncidentScreen extends ConsumerStatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  ConsumerState<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends ConsumerState<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationDetailsController = TextEditingController();
  
  IncidentCategory? _selectedCategory;
  IncidentPriority _selectedPriority = IncidentPriority.medium;
  String? _selectedLocation;
  List<Uint8List> _selectedImages = [];
  bool _isSubmitting = false;
  double _uploadProgress = 0.0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationDetailsController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= AppConstants.maxPhotosPerReport) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum ${AppConstants.maxPhotosPerReport} photos allowed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  final bytes = await image.readAsBytes();
                  if (!mounted) return;
                  setState(() {
                    _selectedImages.add(bytes);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final images = await picker.pickMultiImage();
                if (images.isNotEmpty) {
                  final remainingSlots = AppConstants.maxPhotosPerReport - _selectedImages.length;
                  final imagesToAdd = images.take(remainingSlots).toList();
                  final bytesToAdd = await Future.wait(
                    imagesToAdd.map((image) => image.readAsBytes()),
                  );
                  if (!mounted) return;
                  setState(() {
                    _selectedImages.addAll(bytesToAdd);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show unsaved changes warning on back
    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Report'),
        content: const Text('Are you sure you want to submit this incident report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (shouldSubmit != true) return;

    setState(() {
      _isSubmitting = true;
      _uploadProgress = 0.0;
    });

    try {
      final userData = ref.read(currentUserDataProvider).value;
      if (userData == null) {
        throw Exception('User not logged in');
      }

      // Upload images to Cloudinary
      final cloudinaryService = CloudinaryService();
      final photoUrls = <String>[];
      final photoPublicIds = <String>[];

      if (_selectedImages.isNotEmpty) {
        int uploaded = 0;
        for (final image in _selectedImages) {
          final result = await cloudinaryService.uploadImage(
            imageBytes: image,
            folder: AppConstants.cloudinaryIncidentsFolder,
            compress: true,
          );
          photoUrls.add(result.url);
          photoPublicIds.add(result.publicId);
          
          uploaded++;
          setState(() {
            _uploadProgress = uploaded / _selectedImages.length;
          });
        }
      }

      // Create incident
      final incidentId = await ref.read(incidentRepositoryProvider).createIncident(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        priority: _selectedPriority,
        location: _selectedLocation!,
        locationDetails: _locationDetailsController.text.trim().isEmpty
            ? null
            : _locationDetailsController.text.trim(),
        photoUrls: photoUrls,
        photoPublicIds: photoPublicIds,
        reporter: userData,
      );

      if (mounted) {
        // Show success and navigate to details
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
        
        // Navigate to incident details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IncidentDetailsScreen(incidentId: incidentId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getFirestoreErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_titleController.text.isNotEmpty ||
            _descriptionController.text.isNotEmpty ||
            _selectedCategory != null ||
            _selectedImages.isNotEmpty) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Discard Changes?'),
              content: const Text('You have unsaved changes. Do you want to discard them?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Discard'),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Report an Incident'),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Category Selection
                Text(
                  'Select a category',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: IncidentCategory.values.map((category) {
                    final isSelected = _selectedCategory == category;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).dividerColor,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              category.emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Title
                AppTextField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'Briefly describe the issue...',
                  validator: Validators.title,
                  enabled: !_isSubmitting,
                  maxLength: AppConstants.titleMaxLength,
                ),
                const SizedBox(height: 16),

                // Description
                AppTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Example: Water is leaking from the ceiling near Room 204.',
                  validator: Validators.description,
                  enabled: !_isSubmitting,
                  maxLines: 5,
                  maxLength: AppConstants.descriptionMaxLength,
                ),
                const SizedBox(height: 16),

                // Priority
                Text(
                  'Priority',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SegmentedButton<IncidentPriority>(
                  segments: IncidentPriority.values.map((priority) {
                    return ButtonSegment(
                      value: priority,
                      label: Text(priority.displayName),
                    );
                  }).toList(),
                  selected: {_selectedPriority},
                  onSelectionChanged: _isSubmitting
                      ? null
                      : (Set<IncidentPriority> selected) {
                          setState(() {
                            _selectedPriority = selected.first;
                          });
                        },
                ),
                const SizedBox(height: 16),

                // Location
                DropdownButtonFormField<String>(
                  value: _selectedLocation,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    prefixIcon: const Icon(Icons.location_on),
                    filled: true,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  ),
                  items: AppConstants.locations.map((location) {
                    return DropdownMenuItem(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          setState(() {
                            _selectedLocation = value;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Location Details
                AppTextField(
                  controller: _locationDetailsController,
                  label: 'Room / Details (Optional)',
                  hint: 'e.g., Room 204',
                  enabled: !_isSubmitting,
                ),
                const SizedBox(height: 24),

                // Photos
                Text(
                  'Add a photo (optional)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                // Photo previews
                if (_selectedImages.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  _selectedImages[index],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                // Add photo button
                InkWell(
                  onTap: _isSubmitting ? null : _pickImages,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to add photos',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                        ),
                        Text(
                          '${_selectedImages.length}/${AppConstants.maxPhotosPerReport}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Upload progress
                if (_isSubmitting && _selectedImages.isNotEmpty)
                  Column(
                    children: [
                      LinearProgressIndicator(value: _uploadProgress),
                      const SizedBox(height: 8),
                      Text(
                        'Uploading images... ${(_uploadProgress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // Submit Button
                AppButton(
                  text: 'Submit Report',
                  onPressed: _submitReport,
                  isLoading: _isSubmitting,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

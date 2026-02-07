import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:ragfree_plus_flutter/services/app_state.dart';
import 'package:ragfree_plus_flutter/services/complaint_service.dart';
import 'package:ragfree_plus_flutter/models/complaint_model.dart';
import 'package:ragfree_plus_flutter/services/parent_student_service.dart';
import 'package:ragfree_plus_flutter/models/parent_student_link_model.dart';

class AddComplaintDialog extends StatefulWidget {
  final VoidCallback onComplaintAdded;
  final ComplaintModel? editComplaint;
  final bool isParent;

  const AddComplaintDialog({
    super.key,
    required this.onComplaintAdded,
    this.editComplaint,
    this.isParent = false,
  });

  @override
  State<AddComplaintDialog> createState() => _AddComplaintDialogState();
}

class _AddComplaintDialogState extends State<AddComplaintDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedCategory = 'Harassment';
  String _selectedIncidentType = 'College';
  bool _isAnonymous = false;
  final List<File> _selectedImages = [];
  File? _selectedVideo;
  File? _selectedAudio;
  bool _isSubmitting = false;
  String? _selectedChildId;
  String? _selectedChildName;

  final ComplaintService _complaintService = ComplaintService();
  final ParentStudentService _parentStudentService = ParentStudentService();
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Harassment',
    'Bullying',
    'Discrimination',
    'Physical Violence',
    'Cyber Bullying',
    'Other',
  ];

  final List<String> _incidentTypes = ['Hostel', 'College', 'Other'];

  @override
  void initState() {
    super.initState();
    if (widget.editComplaint != null) {
      _titleController.text = widget.editComplaint!.title;
      _descriptionController.text = widget.editComplaint!.description;
      _locationController.text = widget.editComplaint!.location ?? '';
      _selectedCategory = widget.editComplaint!.category;
      _selectedIncidentType = widget.editComplaint!.incidentType;
      _isAnonymous = widget.editComplaint!.isAnonymous;
      _selectedChildId = widget.editComplaint!.studentId;
      _selectedChildName = widget.editComplaint!.studentName;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.report_problem,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.editComplaint != null
                            ? 'Edit Incident'
                            : 'Report Incident',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (!widget.isParent)
                    CheckboxListTile(
                      title: const Text('Submit anonymously'),
                      subtitle: const Text(
                        'Your identity will be kept confidential',
                      ),
                      value: _isAnonymous,
                      onChanged: (value) {
                        setState(() {
                          _isAnonymous = value ?? false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  if (widget.isParent) ...[
                    const Text(
                      'Select Child',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<List<ParentStudentLinkModel>>(
                      stream: _getLinkedStudentsStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return const LinearProgressIndicator();
                        final links = snapshot.data!;
                        if (links.isEmpty)
                          return const Text('No linked children found');

                        return DropdownButtonFormField<String>(
                          initialValue: _selectedChildId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Choose a child',
                          ),
                          items: links.map<DropdownMenuItem<String>>((link) {
                            return DropdownMenuItem<String>(
                              value: link.studentId,
                              child: Text(link.studentName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedChildId = value;
                                _selectedChildName = links
                                    .firstWhere((l) => l.studentId == value)
                                    .studentName;
                              });
                            }
                          },
                          validator: (value) {
                            if (!_isAnonymous && value == null)
                              return 'Please select a child';
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Brief description of the incident',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedIncidentType,
                    decoration: const InputDecoration(
                      labelText: 'Incident Type',
                      border: OutlineInputBorder(),
                    ),
                    items: _incidentTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedIncidentType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Detailed description of the incident',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submitComplaint(),
                    decoration: const InputDecoration(
                      labelText: 'Location (Optional)',
                      hintText: 'Where did this incident occur?',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedImages.isNotEmpty ||
                      _selectedVideo != null ||
                      _selectedAudio != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectedImages.isNotEmpty)
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _selectedImages[index],
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            size: 20,
                                          ),
                                          color: Colors.red,
                                          onPressed: () {
                                            setState(() {
                                              _selectedImages.removeAt(index);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        if (_selectedVideo != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.videocam, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Video selected: ${_selectedVideo!.path.split('/').last}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  color: Colors.red,
                                  onPressed: () {
                                    setState(() {
                                      _selectedVideo = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (_selectedAudio != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.audiotrack,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Audio selected: ${_selectedAudio!.path.split('/').last}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  color: Colors.red,
                                  onPressed: () {
                                    setState(() {
                                      _selectedAudio = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Image'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickVideo,
                          icon: const Icon(Icons.videocam),
                          label: const Text('Video'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickAudio,
                          icon: const Icon(Icons.audiotrack),
                          label: const Text('Audio'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submitComplaint,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              widget.editComplaint != null
                                  ? 'Update Report'
                                  : 'Submit Report',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Stream<List<ParentStudentLinkModel>> _getLinkedStudentsStream() {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;
    if (user == null) return Stream.value([]);
    return _parentStudentService.getLinkedStudents(user.uid);
  }

  Future<void> _pickImage() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((x) => File(x.path)).toList());
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _selectedVideo = File(video.path);
      });
    }
  }

  Future<void> _pickAudio() async {
    final XFile? audio = await _picker.pickMedia();
    if (audio != null) {
      final extension = audio.path.toLowerCase().split('.').last;
      if (['mp3', 'wav', 'm4a', 'aac', 'ogg'].contains(extension)) {
        setState(() {
          _selectedAudio = File(audio.path);
        });
      }
    }
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final user = appState.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      String? sId;
      String? sName;

      if (widget.isParent) {
        sId = _selectedChildId;
        sName = _selectedChildName;
      } else {
        sId = _isAnonymous ? null : user.uid;
        sName = _isAnonymous ? null : user.name;
      }

      if (widget.editComplaint != null) {
        // Update existing
        final updatedComplaint = widget.editComplaint!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          priority: widget.editComplaint!.priority, // Keep existing priority
          incidentType: _selectedIncidentType,
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          isAnonymous: _isAnonymous,
          studentId: sId,
          studentName: sName,
        );

        List<File> allMediaFiles = [];
        allMediaFiles.addAll(_selectedImages);
        if (_selectedVideo != null) allMediaFiles.add(_selectedVideo!);
        if (_selectedAudio != null) allMediaFiles.add(_selectedAudio!);

        await _complaintService.updateComplaintWithMedia(
          complaint: updatedComplaint,
          newMediaFiles: allMediaFiles.isNotEmpty ? allMediaFiles : null,
        );
      } else {
        // Create new
        final complaint = ComplaintModel(
          id: '',
          studentId: sId,
          studentName: sName,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          priority: 'Medium', // Default priority
          incidentType: _selectedIncidentType,
          status: 'Pending',
          createdAt: DateTime.now(),
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          isAnonymous: _isAnonymous,
          metadata: widget.isParent
              ? {'submittedByParent': user.uid, 'parentName': user.name}
              : null,
        );

        List<File> allMediaFiles = [];
        allMediaFiles.addAll(_selectedImages);
        if (_selectedVideo != null) allMediaFiles.add(_selectedVideo!);
        if (_selectedAudio != null) allMediaFiles.add(_selectedAudio!);

        await _complaintService.submitComplaint(
          complaint: complaint,
          mediaFiles: allMediaFiles.isNotEmpty ? allMediaFiles : null,
        );
      }

      if (context.mounted) {
        Navigator.pop(context);
        widget.onComplaintAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complaint submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (context.mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

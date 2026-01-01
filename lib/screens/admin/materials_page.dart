import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/material_service.dart';
import '../../services/cloudinary_service.dart';
import '../../models/material_model.dart';
import 'package:intl/intl.dart';

class AdminMaterialsPage extends StatefulWidget {
  const AdminMaterialsPage({super.key});

  @override
  State<AdminMaterialsPage> createState() => _AdminMaterialsPageState();
}

class _AdminMaterialsPageState extends State<AdminMaterialsPage> {
  final MaterialService _materialService = MaterialService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  String _selectedCategory = 'All';
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materials Management'),
        actions: [
          if (_isUploading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              ),
            )
          else
            IconButton(
              onPressed: () => _showUploadDialog(context),
              icon: const Icon(Icons.cloud_upload),
              tooltip: 'Upload New Material',
            ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategorySelector(),
            const SizedBox(height: 24),
            Text(
              'Available Materials',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildMaterialsList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = ['All', 'Documents', 'Videos', 'Guidance', 'Policies'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) => _buildCategoryChip(cat, _selectedCategory == cat)).toList(),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          setState(() {
            _selectedCategory = label;
          });
        },
        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        checkmarkColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildMaterialsList(BuildContext context) {
    return StreamBuilder<List<MaterialModel>>(
      stream: _materialService.getMaterials(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No materials found'));
        }

        final filtered = _selectedCategory == 'All'
            ? snapshot.data!
            : snapshot.data!.where((m) => m.category == _selectedCategory).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No materials in this category'));
        }

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final material = filtered[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getIconColor(material.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getIcon(material.type), color: _getIconColor(material.type)),
                ),
                title: Text(material.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${material.type} • ${material.size} • ${DateFormat('yyyy-MM-dd').format(material.updatedAt)}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'view', child: Text('View')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  onSelected: (value) async {
                    if (value == 'delete') {
                      await _materialService.deleteMaterial(material.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Material deleted')),
                        );
                      }
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'Document': return Icons.description;
      case 'Video': return Icons.movie;
      default: return Icons.insert_drive_file;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'Document': return Colors.red;
      case 'Video': return Colors.blue;
      default: return Colors.grey;
    }
  }

  void _showUploadDialog(BuildContext context) {
    final titleController = TextEditingController();
    String category = 'Documents';
    PlatformFile? pickedFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Upload Material'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
                items: ['Documents', 'Videos', 'Guidance', 'Policies']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setModalState(() => category = val!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles();
                  if (result != null) {
                    setModalState(() => pickedFile = result.files.first);
                  }
                },
                icon: const Icon(Icons.attach_file),
                label: Text(pickedFile?.name ?? 'Select File'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && pickedFile != null) {
                  Navigator.pop(context);
                  _performUpload(titleController.text, category, pickedFile!);
                }
              },
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performUpload(String title, String category, PlatformFile file) async {
    setState(() => _isUploading = true);
    try {
      final uploadUrl = await _cloudinaryService.uploadFile(
        file: File(file.path!),
        folder: 'materials',
      );

      if (uploadUrl != null) {
        final material = MaterialModel(
          id: '',
          title: title,
          category: category,
          type: file.extension?.toUpperCase() == 'MP4' ? 'Video' : 'Document',
          url: uploadUrl,
          size: '${(file.size / 1024 / 1024).toStringAsFixed(2)} MB',
          updatedAt: DateTime.now(),
        );
        await _materialService.addMaterial(material);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Material uploaded successfully'), backgroundColor: Colors.green),
          );
        }
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }
}

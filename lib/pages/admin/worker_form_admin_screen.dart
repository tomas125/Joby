import 'package:Joby/models/area_model.dart';
import 'package:flutter/material.dart';
import '../../models/worker_model.dart';
import '../../services/worker_service.dart';
import '../../services/area_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerFormAdminScreen extends StatefulWidget {
  final WorkerModel? worker;

  const WorkerFormAdminScreen({Key? key, this.worker}) : super(key: key);

  @override
  _WorkerFormAdminScreenState createState() => _WorkerFormAdminScreenState();
}

class _WorkerFormAdminScreenState extends State<WorkerFormAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workerService = WorkerService();
  final _areaService = AreaService();
  final List<String> _selectedAreaIds = [];

  late TextEditingController _nameController;
  late TextEditingController _imageUrlController;
  late TextEditingController _descriptionController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  String _selectedCategory = 'Particular';
  double _rating = 0.0;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.worker?.name ?? '');
    _imageUrlController = TextEditingController(text: widget.worker?.imageUrl ?? '');
    _descriptionController = TextEditingController(text: widget.worker?.description ?? '');
    _phoneController = TextEditingController(text: widget.worker?.phone ?? '');
    _emailController = TextEditingController(text: widget.worker?.email ?? '');
    _selectedCategory = widget.worker?.category ?? 'Particular';
    _rating = widget.worker?.rating ?? 0.0;
    _isAvailable = widget.worker?.isAvailable ?? true;
    
    if (widget.worker != null) {
      _selectedAreaIds.addAll(widget.worker!.areaIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.worker == null ? 'Nuevo Trabajador' : 'Editar Trabajador',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            _buildTextField(_nameController, 'Nombre', true),
            SizedBox(height: 16),
            _buildTextField(_emailController, 'Email', false),
            SizedBox(height: 16),
            _buildTextField(_phoneController, 'Teléfono', true),
            SizedBox(height: 16),
            _buildTextField(_imageUrlController, 'URL de imagen', false),
            SizedBox(height: 16),
            _buildCategoryDropdown(),
            SizedBox(height: 16),
            _buildDescriptionField(),
            SizedBox(height: 16.0),
            _buildAreaSelector(),
            SizedBox(height: 16.0),
            _buildAvailabilitySwitch(),
            SizedBox(height: 24.0),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool required) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: required ? (value) => value?.isEmpty ?? true ? 'Campo requerido' : null : null,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Categoría',
        border: OutlineInputBorder(),
      ),
      items: ['Particular', 'Local'].map((String category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() => _selectedCategory = value ?? 'Particular');
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Descripción',
        border: OutlineInputBorder(),
      ),
      maxLines: 6,
    );
  }

  Widget _buildAvailabilitySwitch() {
    return Card(
      child: SwitchListTile(
        title: Text('Disponible'),
        value: _isAvailable,
        onChanged: (value) => setState(() => _isAvailable = value),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _saveWorker,
      child: Text('Guardar'),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }

  Widget _buildAreaSelector() {
    return StreamBuilder<List<AreaModel>>(
      stream: _areaService.getAreas(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Áreas de trabajo'),
            if (_selectedAreaIds.isEmpty)
              Text(
                'Debe seleccionar al menos un área',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            Wrap(
              spacing: 8.0,
              children: snapshot.data!.map((area) {
                return FilterChip(
                  label: Text(area.name),
                  selected: _selectedAreaIds.contains(area.id),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAreaIds.add(area.id);
                      } else {
                        _selectedAreaIds.remove(area.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  void _saveWorker() async {
    if (_formKey.currentState!.validate() && _selectedAreaIds.isNotEmpty) {
      final worker = WorkerModel(
        id: widget.worker?.id ?? '',
        name: _nameController.text,
        imageUrl: _imageUrlController.text,
        rating: _rating,
        description: _descriptionController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        category: _selectedCategory,
        areaIds: _selectedAreaIds,
        location: const GeoPoint(0, 0),
        isAvailable: _isAvailable,
      );

      try {
        if (widget.worker == null) {
          await _workerService.addWorker(worker);
        } else {
          await _workerService.updateWorker(widget.worker!.id, worker);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
} 
import 'package:Joby/models/area_model.dart';
import 'package:flutter/material.dart';
import '../../models/worker_model.dart';
import '../../services/worker_service.dart';
import '../../services/area_service.dart';

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
  String? _selectedAreaId;

  late TextEditingController _nameController;
  late TextEditingController _imageUrlController;
  late TextEditingController _descriptionController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  String _selectedType = 'Electricista';
  String _selectedCategory = 'Particular';
  double _rating = 0.0;
  bool _isAvailable = true;

  final List<String> jobTypes = [
    'Electricista',
    'Plomero',
    'Albañil',
    'Jardinero',
    'Pintor',
    'Carpintero',
    'Limpiador',
    'Mudanza',
    'Técnico',
    'Cuidador',
  ];

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
    _selectedType = widget.worker?.type ?? 'Electricista';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.worker == null ? 'Nuevo Trabajador' : 'Editar Trabajador'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
              validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Teléfono'),
              validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
            ),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: jobTypes.map((String type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() => _selectedType = value ?? 'Electricista');
              },
              decoration: InputDecoration(labelText: 'Tipo de trabajo'),
              validator: (value) => value == null ? 'Campo requerido' : null,
            ),
            TextFormField(
              controller: _imageUrlController,
              decoration: InputDecoration(labelText: 'URL de imagen'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: ['Particular', 'Local'].map((String category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() => _selectedCategory = value ?? 'Particular');
              },
              decoration: InputDecoration(labelText: 'Categoría'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            Slider(
              value: _rating,
              min: 0,
              max: 5,
              divisions: 10,
              label: _rating.toString(),
              onChanged: (value) {
                setState(() => _rating = value);
              },
            ),
            SwitchListTile(
              title: Text('Disponible'),
              value: _isAvailable,
              onChanged: (bool value) {
                setState(() => _isAvailable = value);
              },
            ),
            StreamBuilder<List<AreaModel>>(
              stream: _areaService.getAreas(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                return DropdownButtonFormField<String>(
                  value: _selectedAreaId,
                  decoration: InputDecoration(
                    labelText: 'Servicio',
                  ),
                  items: snapshot.data!.map((area) {
                    return DropdownMenuItem(
                      value: area.id,
                      child: Text(area.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAreaId = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Por favor seleccione un servicio' : null,
                );
              },
            ),
            ElevatedButton(
              onPressed: _saveWorker,
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveWorker() async {
    if (_formKey.currentState!.validate() && _selectedAreaId != null) {
      final worker = WorkerModel(
        id: widget.worker?.id ?? '',
        name: _nameController.text,
        type: _selectedType, // Usar el tipo seleccionado
        imageUrl: _imageUrlController.text,
        rating: _rating,
        description: _descriptionController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        category: _selectedCategory,
        isAvailable: _isAvailable,
        areaId: _selectedAreaId!,
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
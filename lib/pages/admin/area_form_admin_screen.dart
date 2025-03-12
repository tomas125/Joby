import 'package:flutter/material.dart';
import '../../models/area_model.dart';
import '../../services/area_service.dart';

class AreaFormAdminScreen extends StatefulWidget {
  final AreaModel? area;

  AreaFormAdminScreen({this.area});

  @override
  _AreaFormAdminScreenState createState() => _AreaFormAdminScreenState();
}

class _AreaFormAdminScreenState extends State<AreaFormAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _areaService = AreaService();
  
  late TextEditingController _nameController;
  late TextEditingController _iconController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.area?.name ?? '');
    _iconController = TextEditingController(text: widget.area?.icon ?? '');
    _descriptionController = TextEditingController(text: widget.area?.description ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.area == null ? 'Nuevo Servicio' : 'Editar Servicio',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            _buildTextField(_nameController, 'Nombre del servicio', true),
            SizedBox(height: 16),
            _buildTextField(_iconController, 'Ícono', false),
            SizedBox(height: 16),
            _buildDescriptionField(),
            SizedBox(height: 24),
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
      validator: required ? (value) => value?.isEmpty ?? true ? 'Este campo es requerido' : null : null,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Descripción',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _saveArea,
      child: Text('Guardar'),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }

  void _saveArea() async {
    if (_formKey.currentState!.validate()) {
      final area = AreaModel(
        id: widget.area?.id ?? '',
        name: _nameController.text,
        icon: _iconController.text,
        description: _descriptionController.text,
      );

      try {
        if (widget.area == null) {
          await _areaService.addArea(area);
        } else {
          await _areaService.updateArea(area);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el servicio')),
        );
      }
    }
  }
} 
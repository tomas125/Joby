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
        title: Text(widget.area == null ? 'Nuevo Servicio' : 'Editar Servicio'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre del servicio'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Este campo es requerido' : null,
            ),
            TextFormField(
              controller: _iconController,
              decoration: InputDecoration(labelText: 'Ícono'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveArea,
              child: Text('Guardar'),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFD4451A),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
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
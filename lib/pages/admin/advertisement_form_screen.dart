import 'package:flutter/material.dart';
import '../../models/advertisement_model.dart';
import '../../services/advertisement_service.dart';

class AdvertisementFormScreen extends StatefulWidget {
  final AdvertisementModel? advertisement;

  const AdvertisementFormScreen({Key? key, this.advertisement}) : super(key: key);

  @override
  _AdvertisementFormScreenState createState() => _AdvertisementFormScreenState();
}

class _AdvertisementFormScreenState extends State<AdvertisementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _advertisementService = AdvertisementService();
  final _nameController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isAvailable = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.advertisement != null) {
      _nameController.text = widget.advertisement!.name;
      _imageUrlController.text = widget.advertisement!.imageUrl;
      _isAvailable = widget.advertisement!.isAvailable;
    }
  }

  void _saveAdvertisement() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final advertisement = AdvertisementModel(
          id: widget.advertisement?.id ?? '',
          name: _nameController.text,
          imageUrl: _imageUrlController.text,
          isAvailable: _isAvailable,
        );

        if (widget.advertisement == null) {
          await _advertisementService.addAdvertisement(advertisement);
        } else {
          await _advertisementService.updateAdvertisement(
            widget.advertisement!.id,
            advertisement,
          );
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.advertisement == null
            ? 'Nueva Publicidad'
            : 'Editar Publicidad'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Campo requerido' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(
                      labelText: 'URL de la imagen',
                      hintText: 'https://ejemplo.com/imagen.jpg',
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Ingrese una URL válida' : null,
                  ),
                  if (_imageUrlController.text.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(_imageUrlController.text),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                  SwitchListTile(
                    title: Text('Disponible'),
                    activeColor: Color(0xFFD4451A),
                    value: _isAvailable,
                    onChanged: (bool value) {
                      setState(() => _isAvailable = value);
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveAdvertisement,
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

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
} 
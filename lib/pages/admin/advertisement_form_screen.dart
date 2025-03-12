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
  final _linkController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  bool _isAvailable = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.advertisement != null) {
      _nameController.text = widget.advertisement!.name;
      _imageUrlController.text = widget.advertisement!.imageUrl;
      _linkController.text = widget.advertisement!.link ?? '';
      _phoneNumberController.text = widget.advertisement!.phoneNumber ?? '';
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
          link: _linkController.text.isEmpty ? null : _linkController.text,
          phoneNumber: _phoneNumberController.text.isEmpty ? null : _phoneNumberController.text,
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
        title: Text(
          widget.advertisement == null ? 'Nueva Publicidad' : 'Editar Publicidad',
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  _buildTextField(_nameController, 'Nombre', true),
                  SizedBox(height: 16),
                  _buildTextField(_imageUrlController, 'URL de la imagen', true, 'https://ejemplo.com/imagen.jpg'),
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
                  SizedBox(height: 16),
                  _buildTextField(_linkController, 'Link (opcional)', false, 'https://ejemplo.com'),
                  SizedBox(height: 16),
                  _buildTextField(_phoneNumberController, 'Número de teléfono (opcional)', false, '+54 9 11 1234-5678'),
                  SizedBox(height: 16),
                  _buildAvailabilitySwitch(),
                  SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool required, [String? hint]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(),
      ),
      validator: required ? (value) => value?.isEmpty ?? true ? 'Campo requerido' : null : null,
      keyboardType: label.contains('teléfono') ? TextInputType.phone : TextInputType.text,
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
      onPressed: _saveAdvertisement,
      child: Text('Guardar'),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _linkController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}
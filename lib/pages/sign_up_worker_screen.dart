import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/worker_model.dart';
import '../services/worker_service.dart';
import '../services/area_service.dart';
import '../services/drive_service.dart';
import '../models/area_model.dart';
import '../utils/app_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/help_button.dart';
class SignUpWorkerScreen extends StatefulWidget {
  const SignUpWorkerScreen({Key? key}) : super(key: key);

  @override
  _SignUpWorkerScreenState createState() => _SignUpWorkerScreenState();
}

class _SignUpWorkerScreenState extends State<SignUpWorkerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workerService = WorkerService();
  final _areaService = AreaService();
  final _driveService = DriveService();
  final _imagePicker = ImagePicker();
  final List<String> _selectedAreaIds = [];

  late TextEditingController _lastNameController;
  late TextEditingController _firstNameController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _descriptionController;
  late TextEditingController _documentController;
  File? _selectedImage;
  String _selectedCategory = 'Particular';
  bool _isSubmitting = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _lastNameController = TextEditingController();
    _firstNameController = TextEditingController();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _descriptionController = TextEditingController();
    _documentController = TextEditingController();
    _initializeDriveService();
  }

  Future<void> _initializeDriveService() async {
    try {
      await _driveService.initialize();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inicializando el servicio de Drive: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        // Verificar el tamaño del archivo
        final file = File(image.path);
        final fileSize = await file.length();
        final maxSize = 5 * 1024 * 1024; // 5MB en bytes
        
        if (fileSize > maxSize) {
          // Intentar comprimir la imagen primero a 2MB
          final compressedImage = await _compressImage(image, targetSize: 2);
          if (compressedImage != null) {
            setState(() {
              _selectedImage = compressedImage;
            });
            return;
          } else {
            // Si no se pudo comprimir a 2MB, intentar a 5MB
            final compressedImage5MB = await _compressImage(image, targetSize: 5);
            if (compressedImage5MB != null) {
              setState(() {
                _selectedImage = compressedImage5MB;
              });
              return;
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo comprimir la imagen. Por favor, seleccione una imagen más pequeña.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }
          }
        }

        // Verificar el formato de la imagen
        final extension = image.path.split('.').last.toLowerCase();
        final validExtensions = ['jpg', 'jpeg', 'png'];
        
        if (!validExtensions.contains(extension)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Solo se permiten imágenes en formato JPG o PNG'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedImage = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar la imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<File?> _compressImage(XFile image, {required int targetSize}) async {
    try {
      // Intentar comprimir con diferentes calidades hasta que el tamaño sea menor al objetivo
      List<int> qualities = [85, 70, 50, 30];
      
      for (int quality in qualities) {
        final XFile? compressedImage = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: quality,
        );

        if (compressedImage != null) {
          final file = File(compressedImage.path);
          final fileSize = await file.length();
          
          if (fileSize <= targetSize * 1024 * 1024) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Imagen comprimida exitosamente (${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB)'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            return file;
          }
        }
      }
      
      return null;
    } catch (e) {
      print('Error comprimiendo la imagen: $e');
      return null;
    }
  }

  Widget _buildImagePicker() {
    return Container(
      decoration: AppStyles.commonDecoration(borderRadius: 10.0),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.photo, color: AppStyles.textDarkColor),
              const SizedBox(width: 8),
              Text(
                'Imagen de perfil',
                style: TextStyle(
                  color: AppStyles.textDarkColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedImage != null) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    _selectedImage!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedImage = null),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close,
                        color: AppStyles.textDarkColor,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              splashColor: AppStyles.primaryColor.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),
              onTap: _pickImage,
              child: Ink(
                decoration: BoxDecoration(
                  color: _selectedImage == null ? AppStyles.primaryColor : Colors.transparent,
                  border: Border.all(
                    color: AppStyles.primaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Container(
                  width: 200,
                  height: 45,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _selectedImage == null ? Icons.add_photo_alternate : Icons.edit,
                        color: _selectedImage == null ? Colors.white : AppStyles.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedImage == null ? 'Seleccionar imagen' : 'Cambiar imagen',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _selectedImage == null ? Colors.white : AppStyles.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.primaryColor,
      appBar: AppBar(
        title: const Text(
          'Registro de Trabajador',
          style: TextStyle(color: AppStyles.textLightColor),
        ),
        backgroundColor: AppStyles.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppStyles.textLightColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          HelpButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _isSuccess 
          ? _buildSuccessMessage()
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/icon/logo-transparent.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Complete sus datos para solicitar el registro como trabajador',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppStyles.textLightColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 16),
                  if (_selectedCategory == 'Particular') ...[
                    _buildTextField(
                      controller: _lastNameController,
                      label: 'Apellido',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su apellido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _firstNameController,
                      label: 'Nombre',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _documentController,
                      label: 'CUIL',
                      icon: Icons.badge,
                      keyboardType: TextInputType.number,
                    ),
                  ] else ...[
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nombre del local',
                      icon: Icons.business,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el nombre del local';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _documentController,
                      label: 'CUIT',
                      icon: Icons.badge,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Correo electrónico',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su correo electrónico';
                      }
                      if (!value.contains('@')) {
                        return 'Por favor ingrese un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Teléfono',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su teléfono';
                      }
                      if (value.length < 8) {
                        return 'Por favor ingrese un teléfono válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildImagePicker(),
                  const SizedBox(height: 16),
                  _buildDescriptionField(),
                  const SizedBox(height: 16),
                  _buildAreaSelector(),
                  const SizedBox(height: 30),
                  _buildSubmitButton(),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: AppStyles.commonDecoration(borderRadius: 10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: AppStyles.textFieldDecoration(label).copyWith(
          prefixIcon: Icon(icon, color: AppStyles.textDarkColor),
        ),
        style: TextStyle(color: AppStyles.textDarkColor),
      ),
    );
  }

  // add font weight bold like input text placeholder and the same font size
  Widget _buildCategoryDropdown() {
    return Container(
      decoration: AppStyles.commonDecoration(borderRadius: 10.0),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: AppStyles.textFieldDecoration('Categoría').copyWith(
          prefixIcon: Icon(Icons.category, color: AppStyles.textDarkColor),
        ),
        dropdownColor: Colors.white,
        style: TextStyle(color: AppStyles.textDarkColor, fontWeight: FontWeight.w500, fontSize: 16),
        items: ['Particular', 'Local'].map((String category) {
          return DropdownMenuItem(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() => _selectedCategory = value ?? 'Particular');
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor seleccione una categoría';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: AppStyles.commonDecoration(borderRadius: 10.0),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 4,
        decoration: AppStyles.textFieldDecoration('Descripción de sus servicios').copyWith(
          prefixIcon: Icon(Icons.description, color: AppStyles.textDarkColor),
        ),
        style: TextStyle(color: AppStyles.textDarkColor),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor describa sus servicios';
          }
          if (value.length < 20) {
            return 'La descripción debe tener al menos 20 caracteres';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAreaSelector() {
    return StreamBuilder<List<AreaModel>>(
      stream: _areaService.getAreas(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        return Container(
          decoration: AppStyles.commonDecoration(borderRadius: 10.0),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.work, color: AppStyles.textDarkColor),
                  SizedBox(width: 8),
                  Text(
                    'Áreas de trabajo',
                    style: TextStyle(
                      color: AppStyles.textDarkColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: snapshot.data!.map((area) {
                  return FilterChip(
                    label: Text(area.name),
                    selected: _selectedAreaIds.contains(area.id),
                    selectedColor: AppStyles.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppStyles.primaryColor,
                    labelStyle: TextStyle(
                      color: _selectedAreaIds.contains(area.id)
                          ? AppStyles.primaryColor
                          : AppStyles.textDarkColor,
                    ),
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
              if (_selectedAreaIds.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Debe seleccionar al menos un área',
                    style: TextStyle(color: Colors.red[300], fontSize: 12),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        splashColor: AppStyles.primaryColor.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        onTap: _isSubmitting ? null : _submitRegistration,
        child: Ink(
          decoration: AppStyles.containerDecoration(borderRadius: 25.0),
          child: Container(
            width: 200,
            height: 45,
            alignment: Alignment.center,
            child: _isSubmitting
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppStyles.textDarkColor),
                    ),
                  )
                : Text(
                    'Enviar solicitud',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppStyles.textDarkColor,
                      letterSpacing: 0.3,
                      shadows: [
                        Shadow(
                          blurRadius: 1.0,
                          color: Colors.black.withOpacity(0.1),
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppStyles.textLightColor,
          ),
          const SizedBox(height: 20),
          const Text(
            '¡Solicitud enviada exitosamente!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppStyles.textLightColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Su solicitud de registro ha sido recibida y está siendo revisada. Le notificaremos cuando sea aprobada.',
            style: TextStyle(
              fontSize: 16,
              color: AppStyles.textLightColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              splashColor: AppStyles.primaryColor.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),
              onTap: () => Navigator.pop(context),
              child: Ink(
                decoration: AppStyles.containerDecoration(borderRadius: 25.0),
                child: Container(
                  width: 200,
                  height: 45,
                  alignment: Alignment.center,
                  child: Text(
                    'Volver al inicio',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppStyles.textDarkColor,
                      letterSpacing: 0.3,
                      shadows: [
                        Shadow(
                          blurRadius: 1.0,
                          color: Colors.black.withOpacity(0.1),
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos requeridos correctamente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedAreaIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione al menos un área de trabajo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _driveService.uploadImage(_selectedImage!);
      }

      final worker = WorkerModel(
        id: '', // Firestore generará el ID
        name: _selectedCategory == 'Particular' 
          ? '${_lastNameController.text}, ${_firstNameController.text}'
          : _nameController.text,
        imageUrl: imageUrl ?? '',
        rating: 0.0,
        description: _descriptionController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        category: _selectedCategory,
        areaIds: _selectedAreaIds,
        location: const GeoPoint(0, 0),
        isAvailable: false,
        status: 'pending',
        document: _documentController.text, // Agregar el campo de documento (CUIL/CUIT)
      );

      await _workerService.addWorker(worker);

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isSuccess = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar la solicitud: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _documentController.dispose();
    super.dispose();
  }
} 
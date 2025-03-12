import 'package:Joby/utils/auth.dart';
import 'package:flutter/material.dart';
import 'package:Joby/preferences/pref_user.dart';
import 'dart:async';
import '../services/area_service.dart';
import '../models/area_model.dart';
import '../services/advertisement_service.dart';
import '../models/advertisement_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../widgets/help_button.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:url_launcher/url_launcher.dart';
import 'package:Joby/utils/app_styles.dart';
class ListAreaScreen extends StatefulWidget {
  static const String routeName = '/list_area';

  @override
  _ListAreaScreenState createState() => _ListAreaScreenState();
}

class _ListAreaScreenState extends State<ListAreaScreen> {
  final AreaService _areaService = AreaService();
  final AdvertisementService _adService = AdvertisementService();
  List<AdvertisementModel> _cachedAds = [];
  String searchQuery = '';
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  void _loadAds() async {
    // Cargar anuncios una sola vez y mantenerlos en caché
    _adService.getAdvertisements().listen((ads) {
      if (!listEquals(_cachedAds, ads)) {
        setState(() {
          _cachedAds = ads;
        });
      }
    });
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: AppStyles.commonDecoration(borderRadius: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Saliendo de la aplicación',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.textDarkColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                '¿Estás seguro que deseas salir?',
                style: TextStyle(
                  color: AppStyles.textDarkColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      splashColor: AppStyles.primaryColor.withOpacity(0.2),
                      highlightColor: Colors.white.withOpacity(0.1),
                      onTap: () => Navigator.of(context).pop(false),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppStyles.textDarkColor.withOpacity(0.9),
                              AppStyles.textDarkColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text(
                            'No',
                            style: TextStyle(
                              color: AppStyles.textLightColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      splashColor: AppStyles.primaryColor.withOpacity(0.2),
                      highlightColor: Colors.white.withOpacity(0.1),
                      onTap: () => Navigator.of(context).pop(true),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppStyles.primaryColor.withOpacity(0.9),
                              AppStyles.primaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text(
                            'Sí',
                            style: TextStyle(
                              color: AppStyles.textLightColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ) ?? false;

    if (shouldPop) {
      // Salir de la aplicación
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final result = await _onWillPop();
        if (result && context.mounted) {
          SystemNavigator.pop();  // Cierra la app
        }
      },
      child: Scaffold(
        backgroundColor: AppStyles.primaryColor,
        appBar: AppBar(
          backgroundColor: AppStyles.primaryColor,
          title: Text('¿Qué servicio estás buscando?',
              style: TextStyle(color: AppStyles.textLightColor, fontSize: 20)),
          automaticallyImplyLeading: false,
          actions: [
            HelpButton(),
            IconButton(
              icon: Icon(Icons.logout, color: AppStyles.textLightColor),
              onPressed: () => _handleLogout(context),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchField(),
            _buildAdCarousel(),
            SizedBox(height: 8),
            Expanded(
              child: _buildAreaGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: AppStyles.commonDecoration(borderRadius: 10.0),
        child: TextField(
          decoration: AppStyles.textFieldDecoration('Buscar rubro...').copyWith(
            prefixIcon: Icon(Icons.search, color: AppStyles.textDarkColor),
          ),
          onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
          style: TextStyle(color: AppStyles.textDarkColor),
        ),
      ),
    );
  }

  Widget _buildAdCarousel() {
    if (_cachedAds.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 7,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: Text('No hay publicidades disponibles'),
          ),
        ),
      );
    }

    return StatefulBuilder(
      builder: (context, carouselSetState) {
        return AspectRatio(
          aspectRatio: 15 / 7,
          child: Container(
            child: Column(
              children: [
                Expanded(
                  child: carousel.CarouselSlider.builder(
                    itemCount: _cachedAds.length,
                    options: carousel.CarouselOptions(
                      aspectRatio: 15/6,
                      viewportFraction: 0.8,
                      enlargeCenterPage: true,
                      enlargeStrategy: carousel.CenterPageEnlargeStrategy.height,
                      enlargeFactor: 0.2,
                      enableInfiniteScroll: true,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 4),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      onPageChanged: (index, reason) {
                        carouselSetState(() {
                          _currentPage = index;
                        });
                      },
                    ),
                    itemBuilder: (context, index, realIndex) {
                      return GestureDetector(
                        onTap: () => _showAdDetailsDialog(context, _cachedAds[index]),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: Image.network(
                              _cachedAds[index].imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: Text('Error al cargar imagen'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _cachedAds.asMap().entries.map((entry) {
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == entry.key
                            ? AppStyles.primaryColor
                            : AppStyles.secondaryColor,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  void _showAdDetailsDialog(BuildContext context, AdvertisementModel ad) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: AppStyles.commonDecoration(borderRadius: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ad.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.textDarkColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                if (ad.link != null && ad.link!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        splashColor: AppStyles.primaryColor.withOpacity(0.2),
                        highlightColor: Colors.white.withOpacity(0.1),
                        onTap: () => _launchWebUrl(ad.link!),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppStyles.primaryColor.withOpacity(0.9),
                                AppStyles.primaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4.0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.language,
                                  color: AppStyles.textLightColor,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Visitar sitio web',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppStyles.textLightColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (ad.phoneNumber != null && ad.phoneNumber!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        splashColor: AppStyles.primaryColor.withOpacity(0.2),
                        highlightColor: Colors.white.withOpacity(0.1),
                        onTap: () => _launchWhatsApp(ad.phoneNumber!),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppStyles.primaryColor.withOpacity(0.9),
                                AppStyles.primaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4.0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: AppStyles.textLightColor,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Contactar por WhatsApp',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppStyles.textLightColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 10),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    splashColor: AppStyles.primaryColor.withOpacity(0.2),
                    highlightColor: Colors.white.withOpacity(0.1),
                    onTap: () => Navigator.of(context).pop(),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppStyles.textDarkColor.withOpacity(0.9),
                            AppStyles.textDarkColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text(
                          'Cerrar',
                          style: TextStyle(
                            color: AppStyles.textLightColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAreaGrid() {
    return StreamBuilder<List<AreaModel>>(
      stream: _areaService.getAreas(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar servicios'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final areas = snapshot.data ?? [];
        final filteredAreas = areas
            .where((area) => 
                area.name.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

        return GridView.count(
          crossAxisCount: 3,
          padding: EdgeInsets.all(12.0),
          mainAxisSpacing: 12.0,
          crossAxisSpacing: 12.0,
          children: filteredAreas.map((area) => _buildAreaCard(area.name)).toList(),
        );
      },
    );
  }

  // Función para obtener un icono según el nombre del área
  IconData _getIconForArea(String areaName) {
    // Mapeo de nombres de áreas a iconos
    final Map<String, IconData> iconMap = {
      'Carpintería': Icons.carpenter,
      'Bordados': Icons.design_services,
      'Aberturas': Icons.window,
      'Plomería': Icons.plumbing,
      'Construcción en Seco': Icons.architecture,
      'Construcción': Icons.construction,
      'Limpieza': Icons.cleaning_services,
      'Seguridad': Icons.security,
      'Arte': Icons.palette,
      'Electricidad': Icons.electrical_services,
      'Jardinería': Icons.grass,
      'Pintura': Icons.format_paint,
      'Herrería': Icons.handyman,
      'Albañilería': Icons.build,
      'Cerrajería': Icons.key,
      'Mecánica': Icons.car_repair,
      'Informática': Icons.computer,
      'Diseño': Icons.brush,
    };
    
    // Devolver el icono correspondiente o un icono predeterminado
    return iconMap[areaName] ?? Icons.home_repair_service;
  }

  Widget _buildAreaCard(String areaName) {
    // Determinar si el nombre es largo
    bool isLongName = areaName.length > 10 || areaName.contains(' ');
    
    return StreamBuilder<String>(
      stream: _areaService.getAreaIdByName(areaName),
      builder: (context, snapshot) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          child: GestureDetector(
            onTap: () {
              if (snapshot.hasData) {
                Navigator.pushNamed(
                  context,
                  '/list/workers',
                  arguments: snapshot.data,
                );
              }
            },
            child: Card(
              elevation: 4,
              color: AppStyles.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppStyles.textLightColor,
                      AppStyles.secondaryColor,
                    ],
                    stops: [0.0, 0.8],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: AppStyles.textLightColor.withOpacity(0.3),
                    width: 1.0,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20.0),
                    splashColor: AppStyles.primaryColor.withOpacity(0.2),
                    highlightColor: AppStyles.textLightColor.withOpacity(0.1),
                    onTap: () {
                      if (snapshot.hasData) {
                        Navigator.pushNamed(
                          context,
                          '/list/workers',
                          arguments: snapshot.data,
                        );
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,  
                          child: Text(
                            _formatAreaName(areaName),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppStyles.textDarkColor,
                              fontSize: isLongName ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
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
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Función para formatear el nombre del área y evitar cortes inadecuados
  String _formatAreaName(String name) {
    // Si el nombre contiene espacios, hacer salto de línea solo si hay más de una palabra
    if (name.contains(' ')) {
      List<String> words = name.split(' ');
      
      // Si hay al menos dos palabras, insertar un salto de línea después de la primera palabra
      if (words.length >= 2) {
        return name.replaceFirst(' ', '\n');
      }
    }
    
    // Si solo hay una palabra o no hay espacios, devolver el nombre sin cambios
    return name;
  }

  void _handleLogout(BuildContext context) async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: AppStyles.commonDecoration(borderRadius: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.textDarkColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  '¿Estás seguro de que quieres cerrar sesión?',
                  style: TextStyle(
                    color: AppStyles.textDarkColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        splashColor: AppStyles.primaryColor.withOpacity(0.2),
                        highlightColor: Colors.white.withOpacity(0.1),
                        onTap: () => Navigator.of(context).pop(false),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppStyles.textDarkColor.withOpacity(0.9),
                                AppStyles.textDarkColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4.0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                color: AppStyles.textLightColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        splashColor: AppStyles.primaryColor.withOpacity(0.2),
                        highlightColor: Colors.white.withOpacity(0.1),
                        onTap: () => Navigator.of(context).pop(true),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppStyles.primaryColor.withOpacity(0.9),
                                AppStyles.primaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4.0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Text(
                              'Cerrar sesión',
                              style: TextStyle(
                                color: AppStyles.textLightColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmLogout == true) {
      await UserPreference.logout();
      await AuthService().signOut();
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _launchWebUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el enlace')),
        );
      }
    }
  }

  void _launchWhatsApp(String phoneNumber) async {
    // Eliminar cualquier carácter no numérico del número de teléfono
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Asegurarse de que el número tenga el formato correcto para WhatsApp
    if (!formattedNumber.startsWith('+')) {
      // Si no tiene código de país, asumimos que es de Argentina (+54)
      if (!formattedNumber.startsWith('54')) {
        formattedNumber = '54$formattedNumber';
      }
    }
    
    // Mensaje predeterminado
    final String message = 'Hola, vi tu anuncio en la aplicación Joby. Me gustaría obtener más información.';
    
    try {
      // Intentar primero con la URL de la aplicación nativa
      final whatsappUrl = Uri.parse(
        'whatsapp://send?phone=$formattedNumber&text=${Uri.encodeFull(message)}'
      );
      
      // URL alternativa para navegador web
      final webWhatsappUrl = Uri.parse(
        'https://wa.me/$formattedNumber/?text=${Uri.encodeFull(message)}'
      );

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else if (await canLaunchUrl(webWhatsappUrl)) {
        await launchUrl(webWhatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'No se pudo abrir WhatsApp.';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir WhatsApp: $e')),
        );
      }
    }
  }
}

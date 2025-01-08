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
  PageController _pageController = PageController();
  Timer? _timer;
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
          if (_timer == null || !_timer!.isActive) {
            _startAutoScroll();
          }
        });
      }
    });
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_pageController.hasClients && _cachedAds.length > 1) {
        final nextPage = (_currentPage + 1) % _cachedAds.length;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Saliendo de la aplicación'),
        content: Text('¿Estás seguro que deseas salir?'),
        actions: [
          TextButton(
            child: Text('No'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF343030),
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Sí'),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFD4451A),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
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
        backgroundColor: const Color(0xFFD4451A),
        appBar: AppBar(
          backgroundColor: const Color(0xFFD4451A),
          title: Text('¿Qué servicio estás buscando?',
              style: TextStyle(color: const Color(0xFFE2E2E2))),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: const Color(0xFFE2E2E2)),
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
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar rubro...',
          hintStyle: TextStyle(color: const Color(0xFF343030)),
          prefixIcon: Icon(Icons.search, color: const Color(0xFF343030)),
          filled: true,
          fillColor: const Color(0xFFD2CACA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
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

    return AspectRatio(
      aspectRatio: 16 / 7,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _cachedAds.length,
        onPageChanged: (index) {
          _currentPage = index;
        },
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
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
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
          padding: EdgeInsets.all(8.0),
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          children: filteredAreas.map((area) => _buildAreaCard(area.name)).toList(),
        );
      },
    );
  }

  Widget _buildAreaCard(String areaName) {
    return StreamBuilder<String>(
      stream: _areaService.getAreaIdByName(areaName),
      builder: (context, snapshot) {
        return GestureDetector(
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
            color: const Color(0xFFD2CACA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  areaName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF343030),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  void _handleLogout(BuildContext context) async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar sesión'),
          content: Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF343030),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Cerrar sesión'),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFD4451A),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      await UserPreference.logout();
      await AuthService().signOut();
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}

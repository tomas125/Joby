import 'package:Joby/utils/auth.dart';
import 'package:flutter/material.dart';
import 'package:Joby/preferences/pref_user.dart';
import 'dart:async';
import '../services/area_service.dart';
import '../models/area_model.dart';

class ListAreaScreen extends StatefulWidget {
  static const String routeName = '/list_area';

  @override
  _ListAreaScreenState createState() => _ListAreaScreenState();
}

class _ListAreaScreenState extends State<ListAreaScreen> {
  final AreaService _areaService = AreaService();
  String searchQuery = '';
  PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 6), (timer) {
      if (_currentPage < 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchField(),
            SizedBox(height: 8),
            _buildAdCarousel(),
            SizedBox(height: 16),
            Container(
              height: MediaQuery.of(context).size.height - 300,
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
    return AspectRatio(
      aspectRatio: 16 / 7,
      child: PageView.builder(
        controller: _pageController,
        itemCount: 2,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    index == 0 ? 'assets/anuncio-1.png' : 'assets/anuncio-2.png',
                    fit: BoxFit.cover,
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
          padding: EdgeInsets.all(16.0),
          children: filteredAreas
              .map((area) => _buildAreaCard(
                  area.name,
                    area.icon))
              .toList(),
        );
      },
    );
  }

  Widget _buildAreaCard(String areaName, String icon) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/list/workers',
        arguments: areaName,
      ),
      child: Card(
        color: const Color(0xFFD2CACA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconFromHex(icon),
                size: 30,
                color: const Color(0xFF343030)
              ),
              SizedBox(height: 10),
              Text(
                areaName,
                textAlign: TextAlign.center,
                style: TextStyle(color: const Color(0xFF343030)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconFromHex(String hexString) {
    try {
      return IconData(
        int.parse(hexString, radix: 16),
        fontFamily: 'MaterialIcons'
      );
    } catch (e) {
      return Icons.build; // Ícono por defecto si hay error
    }
  }

  void _handleLogout(BuildContext context) async {
    // Mostrar un diálogo de confirmación
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar sesión'),
          content: Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Cerrar sesión'),
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

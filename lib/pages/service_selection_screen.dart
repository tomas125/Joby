import 'package:flutter/material.dart';
import 'worker.dart';
import 'dart:math';
import 'package:Joby/preferences/pref_usuarios.dart';

class ServiceSelectionScreen extends StatefulWidget {
  static const String routeName = '/service_selection';

  @override
  _ServiceSelectionScreenState createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  final List<Map<String, dynamic>> services = [
    {
      'name': 'Electricidad',
      'icon': Icons.electrical_services,
      'workers': generateRandomWorkers('Electricista')
    },
    {
      'name': 'Plomería',
      'icon': Icons.plumbing,
      'workers': generateRandomWorkers('Plomero')
    },
    {
      'name': 'Albañilería',
      'icon': Icons.construction,
      'workers': generateRandomWorkers('Albañil')
    },
    {
      'name': 'Jardinería',
      'icon': Icons.grass,
      'workers': generateRandomWorkers('Jardinero')
    },
    {
      'name': 'Pintura',
      'icon': Icons.format_paint,
      'workers': generateRandomWorkers('Pintor')
    },
    {
      'name': 'Carpintería',
      'icon': Icons.handyman,
      'workers': generateRandomWorkers('Carpintero')
    },
    {
      'name': 'Limpieza',
      'icon': Icons.cleaning_services,
      'workers': generateRandomWorkers('Limpiador')
    },
    {
      'name': 'Mudanzas',
      'icon': Icons.local_shipping,
      'workers': generateRandomWorkers('Mudanza')
    },
    {
      'name': 'Reparación de electrodomésticos',
      'icon': Icons.build,
      'workers': generateRandomWorkers('Técnico')
    },
    {
      'name': 'Cuidado de mascotas',
      'icon': Icons.pets,
      'workers': generateRandomWorkers('Cuidador')
    },
  ];

  String searchQuery = '';

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
      body: Column(
        children: [
          _buildSearchField(),
          _buildAdCarousel(),
          Expanded(child: _buildServiceGrid()),
        ],
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
    return Container(
      height: 140, // Ajusta la altura según tus necesidades
      child: PageView.builder(
        itemCount: 3, // Número de anuncios en el carrusel
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD2CACA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                // Aquí puedes agregar imágenes o iconos relacionados con el anuncio
                Center(
                  child: Text(
                    'Anuncio ${index + 1}',
                    style:
                        TextStyle(color: const Color(0xFF343030), fontSize: 18),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: ElevatedButton(
                    onPressed: () {
                      // Acción del botón
                    },
                    child: Text('Ir a Mercados'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4451A),
                      foregroundColor: const Color(0xFFE2E2E2),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceGrid() {
    return GridView.count(
      crossAxisCount: 3,
      padding: EdgeInsets.all(16.0),
      children: services
          .where(
              (service) => service['name'].toLowerCase().contains(searchQuery))
          .map((service) => _buildServiceCard(
              service['name'], service['icon'], service['workers']))
          .toList(),
    );
  }

  Widget _buildServiceCard(
      String serviceName, IconData icon, List<Worker> workers) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/worker_results', arguments: workers),
      child: Card(
        color: const Color(0xFFD2CACA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: const Color(0xFF343030)),
              SizedBox(height: 10),
              Text(serviceName,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: const Color(0xFF343030))),
            ],
          ),
        ),
      ),
    );
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
      await PreferenciasUsuario.logout();
      Navigator.of(context).pushReplacementNamed('/init');
    }
  }
}

List<Worker> generateRandomWorkers(String type) {
  final random = Random();
  return List.generate(10, (index) {
    return Worker(
      name: '${type} ${index + 1}',
      imageUrl: 'assets/persona1.jpg',
      rating: (random.nextDouble() * 5).roundToDouble(),
      type: type,
    );
  });
}

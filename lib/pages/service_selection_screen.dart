import 'package:flutter/material.dart';
import 'worker.dart';
import 'dart:math';

class ServiceSelectionScreen extends StatefulWidget {
  static const String routeName = '/serviceSelection';

  @override
  _ServiceSelectionScreenState createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  final List<Map<String, dynamic>> services = [
    {
      'name': 'Electricidad',
      'image': 'assets/electricista.jpg',
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
      backgroundColor: Color(0xFFD4451A),
      appBar: AppBar(
          title: Text('¿Qué servicio busca?'),
          backgroundColor: Color.fromARGB(255, 199, 50, 5) // color appbar
          ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar rubro...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              padding: EdgeInsets.all(16.0),
              children: services
                  .where((service) =>
                      service['name'].toLowerCase().contains(searchQuery))
                  .map((service) => _buildServiceCard(service['name'],
                      service['icon'], service['workers'], context))
                  .toList(),
            ),
          ),
          Container(
            height: 100,
            color: Color(0xFFF88C6A),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildAdCard('Publicidad 1'),
                _buildAdCard('Publicidad 2'),
                _buildAdCard('Publicidad 3'),
                _buildAdCard('Publicidad 4'),
                _buildAdCard('Publicidad 5'),
                _buildAdCard('Publicidad 6'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String serviceName, IconData icon,
      List<Worker> workers, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/worker_results',
          arguments: workers,
        );
      },
      child: Card(
        color: Color(0xFFF88C6A),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: Colors.black,
              ),
              SizedBox(height: 10),
              Text(serviceName, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdCard(String adText) {
    return Card(
      child: Container(
        width: 200,
        child: Center(
          child: Text(adText),
        ),
      ),
    );
  }
}

List<Worker> generateRandomWorkers(String type) {
  final random = Random();
  return List.generate(10, (index) {
    return Worker(
      name: '$type ${index + 1}',
      imageUrl: 'assets/worker_placeholder.png',
      rating: double.parse(
          (random.nextDouble() * 5).toStringAsFixed(1)), // Cambiado a double
      type: type,
    );
  });
}

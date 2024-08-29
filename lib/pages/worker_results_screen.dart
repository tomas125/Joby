import 'package:flutter/material.dart';
import 'worker.dart';

class WorkerResultsScreen extends StatefulWidget {
  final List<Worker> workers;

  WorkerResultsScreen({required this.workers});

  @override
  _WorkerResultsScreenState createState() => _WorkerResultsScreenState();
}

class _WorkerResultsScreenState extends State<WorkerResultsScreen> {
  String searchQuery = '';
  String filterType = 'Todos';

  @override
  Widget build(BuildContext context) {
    List<Worker> filteredWorkers = widget.workers.where((worker) {
      return worker.name.toLowerCase().contains(searchQuery.toLowerCase()) &&
          (filterType == 'Todos' || worker.type == filterType);
    }).toList();

    return Scaffold(
      backgroundColor: Color(0xFFD4451A),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 199, 50, 5),
        title: const Text('Trabajadores Disponibles'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar Trabajador',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Total de Trabajadores: ${filteredWorkers.length}'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF88C6A),
                ),
                onPressed: () {
                  setState(() {
                    filterType = 'Particulares';
                  });
                },
                child: Text('Particulares'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF88C6A),
                ),
                onPressed: () {
                  setState(() {
                    filterType = 'Locales';
                  });
                },
                child: Text('Locales'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredWorkers.length,
              itemBuilder: (context, index) {
                final worker = filteredWorkers[index];
                return WorkerCard(worker: worker);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WorkerCard extends StatelessWidget {
  final Worker worker;

  const WorkerCard({Key? key, required this.worker}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(worker.imageUrl),
        ),
        title: Text(worker.name),
        subtitle: Text('${worker.rating} ★'),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/worker_profile',
            arguments: worker,
          );
        },
      ),
    );
  }
}

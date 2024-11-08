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
      backgroundColor: const Color(0xFFD4451A),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4451A),
        title: Text('Trabajadores Disponibles',
            style: TextStyle(color: const Color(0xFFE2E2E2))),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color(0xFFE2E2E2)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildSearchField(),
          _buildFilterButtons(),
          _buildWorkerCount(filteredWorkers),
          Expanded(child: _buildWorkerList(filteredWorkers)),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar Trabajador...',
          hintStyle: TextStyle(color: const Color(0xFF343030)),
          prefixIcon: Icon(Icons.search, color: const Color(0xFF343030)),
          filled: true,
          fillColor: const Color(0xFFD2CACA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) => setState(() => searchQuery = value),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFilterButton('Particulares'),
        SizedBox(width: 10),
        _buildFilterButton('Locales'),
      ],
    );
  }

  Widget _buildFilterButton(String type) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: filterType == type
            ? const Color(0xFFF88C6A)
            : const Color(0xFFD2CACA),
        foregroundColor: const Color(0xFF343030),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => setState(() => filterType = type),
      child: Text(type),
    );
  }

  Widget _buildWorkerCount(List<Worker> workers) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Total de Trabajadores: ${workers.length}',
        style: TextStyle(color: const Color(0xFFE2E2E2), fontSize: 16),
      ),
    );
  }

  Widget _buildWorkerList(List<Worker> workers) {
    return ListView.builder(
      itemCount: workers.length,
      itemBuilder: (context, index) {
        final worker = workers[index];
        return WorkerCard(worker: worker);
      },
    );
  }
}

class WorkerCard extends StatelessWidget {
  final Worker worker;

  const WorkerCard({Key? key, required this.worker}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFD2CACA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(worker.imageUrl),
        ),
        title:
            Text(worker.name, style: TextStyle(color: const Color(0xFF343030))),
        subtitle: Text('${worker.rating} ★',
            style: TextStyle(color: const Color(0xFF343030))),
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

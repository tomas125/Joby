import 'package:flutter/material.dart';
import '../services/worker_service.dart';
import '../models/worker_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/help_button.dart';


class ListWorkerScreen extends StatefulWidget {
  final String selectedAreaId;

  ListWorkerScreen({required this.selectedAreaId});

  @override
  _ListWorkerScreenState createState() => _ListWorkerScreenState();
}

class _ListWorkerScreenState extends State<ListWorkerScreen> {
  final WorkerService _workerService = WorkerService();
  String searchQuery = '';
  String filterType = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4451A),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4451A),
        title: Text('Trabajadores disponibles',
            style: TextStyle(color: const Color(0xFFE2E2E2))),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color(0xFFE2E2E2)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          HelpButton(),
        ],
      ),
      body: Column(
        children: [
          _buildSearchField(),
          _buildFilterButtons(),
          Expanded(
            child: StreamBuilder<List<WorkerModel>>(
              stream: widget.selectedAreaId.isEmpty 
                  ? _workerService.getWorkers()
                  : _workerService.getWorkersByArea(widget.selectedAreaId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                List<WorkerModel> workers = snapshot.data ?? [];
                List<WorkerModel> filteredWorkers = workers.where((worker) {
                  bool matchesSearch = worker.name.toLowerCase().contains(searchQuery.toLowerCase());
                  bool matchesFilter = filterType == 'Todos' || worker.category == filterType;
                  return matchesSearch && matchesFilter;
                }).toList();

                return Column(
                  children: [
                    _buildWorkerCount(filteredWorkers),
                    Expanded(child: _buildWorkerList(filteredWorkers)),
                  ],
                );
              },
            ),
          ),
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
        _buildFilterButton('Todos'),
        SizedBox(width: 10),
        _buildFilterButton('Particular'),
        SizedBox(width: 10),
        _buildFilterButton('Local'),
      ],
    );
  }

  Widget _buildFilterButton(String type) {
    bool isSelected = filterType == type;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? const Color(0xFFF88C6A)
            : const Color(0xFFD2CACA),
        foregroundColor: const Color(0xFF343030),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => setState(() => filterType = type),
      child: Text(type),
    );
  }

  Widget _buildWorkerCount(List<WorkerModel> workers) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Total de Trabajadores: ${workers.length}',
        style: TextStyle(color: const Color(0xFFE2E2E2), fontSize: 16),
      ),
    );
  }

  Widget _buildWorkerList(List<WorkerModel> workers) {
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
  final WorkerModel worker;

  const WorkerCard({Key? key, required this.worker}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFD2CACA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(
            worker.category == 'Local' 
                ? 'assets/local.jpg'  // Nueva imagen para locales
                : 'assets/persona.jpg'       // Imagen existente para particulares
          ),
          child: worker.imageUrl.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    worker.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container();
                    },
                  ),
                )
              : null,
        ),
        title: Text(
          worker.name,
          style: TextStyle(color: const Color(0xFF343030)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(worker.category),
            FutureBuilder<List<String>>(
              future: _getAreaNames(worker.areaIds),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();
                return Text(
                  'Áreas: ${snapshot.data!.join(", ")}',
                  style: TextStyle(fontSize: 12),
                );
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/profile/worker',
            arguments: worker,
          );
        },
      ),
    );
  }

  Future<List<String>> _getAreaNames(List<String> areaIds) async {
    final areas = await FirebaseFirestore.instance
        .collection('areas')
        .where(FieldPath.documentId, whereIn: areaIds)
        .get();
    
    return areas.docs.map((doc) => doc.get('name') as String).toList();
  }
}

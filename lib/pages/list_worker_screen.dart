import 'package:flutter/material.dart';
import '../services/worker_service.dart';
import '../models/worker_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/help_button.dart';
import '../utils/app_styles.dart';

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
      backgroundColor: AppStyles.primaryColor,
      appBar: AppBar(
        backgroundColor: AppStyles.primaryColor,
        title: Text('Trabajadores disponibles',
            style: TextStyle(color: AppStyles.textLightColor)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppStyles.textLightColor),
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
      child: Container(
        decoration: AppStyles.commonDecoration(borderRadius: 10.0),
        child: TextField(
          decoration: AppStyles.textFieldDecoration('Buscar Trabajador...').copyWith(
            prefixIcon: Icon(Icons.search, color: AppStyles.textDarkColor),
          ),
          onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
          style: TextStyle(color: AppStyles.textDarkColor),
        ),
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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        splashColor: AppStyles.primaryColor.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        onTap: () => setState(() => filterType = type),
        child: Ink(
          decoration: isSelected 
              ? AppStyles.commonDecoration(borderRadius: 10.0)
              : BoxDecoration(
                  color: AppStyles.textDarkColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.0,
                  ),
                ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? AppStyles.textDarkColor : AppStyles.textLightColor,
                fontWeight: FontWeight.bold,
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

  Widget _buildWorkerCount(List<WorkerModel> workers) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Total de Trabajadores: ${workers.length}',
        style: TextStyle(color: AppStyles.textLightColor, fontSize: 16),
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: AppStyles.cardDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          splashColor: AppStyles.primaryColor.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/profile/worker',
              arguments: worker,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                _buildWorkerAvatar(worker),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worker.name,
                        style: TextStyle(
                          color: AppStyles.textDarkColor, 
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: worker.category == 'Local' 
                              ? AppStyles.primaryColor.withOpacity(0.2)
                              : AppStyles.textDarkColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          worker.category, 
                          style: TextStyle(
                            color: worker.category == 'Local' 
                                ? AppStyles.primaryColor
                                : AppStyles.textDarkColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      FutureBuilder<List<String>>(
                        future: _getAreaNames(worker.areaIds),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return Container();
                          return Text(
                            'Áreas: ${snapshot.data!.join(", ")}',
                            style: TextStyle(
                              fontSize: 12, 
                              color: AppStyles.textDarkColor,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppStyles.textDarkColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkerAvatar(WorkerModel worker) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppStyles.secondaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 3.0,
        ),
      ),
      child: ClipOval(
        child: worker.imageUrl.isNotEmpty
            ? Image.network(
                worker.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar(worker);
                },
              )
            : _buildDefaultAvatar(worker),
      ),
    );
  }

  Widget _buildDefaultAvatar(WorkerModel worker) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            worker.category == 'Local' 
                ? 'assets/local.jpg'
                : 'assets/persona.jpg'
          ),
          fit: BoxFit.cover,
        ),
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

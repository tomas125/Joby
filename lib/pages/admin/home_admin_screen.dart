import 'package:Joby/preferences/pref_user.dart';
import 'package:Joby/utils/auth.dart';
import 'package:flutter/material.dart';
import '../../models/worker_model.dart';
import '../../services/worker_service.dart';
import 'worker_form_admin_screen.dart';
import '../../models/area_model.dart';
import '../../services/area_service.dart';
import 'area_form_admin_screen.dart';
import '../../models/advertisement_model.dart';
import '../../services/advertisement_service.dart';
import 'advertisement_form_screen.dart';
import '../../models/job_model.dart';
import '../../services/job_service.dart';
import 'package:flutter/services.dart';

class HomeAdminScreen extends StatefulWidget {
  @override
  _HomeAdminScreenState createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> with SingleTickerProviderStateMixin {
  final WorkerService _workerService = WorkerService();
  final AreaService _areaService = AreaService();
  final AdvertisementService _adService = AdvertisementService();
  final JobService _jobService = JobService();
  late TabController _tabController;
  String _selectedAreaId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Sí'),
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
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Panel de Administración'),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Trabajadores'),
              Tab(text: 'Servicios'),
              Tab(text: 'Publicidades'),
              Tab(text: 'Trabajos'),
            ],
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => _handleLogout(context),
            ),
          ],
        ),
        floatingActionButton: _tabController.index != 3 ? FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  if (_tabController.index == 0) return WorkerFormAdminScreen();
                  if (_tabController.index == 1) return AreaFormAdminScreen();
                  return AdvertisementFormScreen();
                },
              ),
            );
          },
          child: Icon(Icons.add),
        ) : null,
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildWorkersList(),
            _buildAreasList(),
            _buildAdvertisementsList(),
            _buildJobsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkersList() {
    return Column(
      children: [
        _buildAreaDropdown(),
        Expanded(
          child: StreamBuilder<List<WorkerModel>>(
            stream: _selectedAreaId.isEmpty 
                ? _workerService.getWorkers()
                : _workerService.getWorkersByArea(_selectedAreaId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final workers = snapshot.data ?? [];

              return ListView.builder(
                itemCount: workers.length,
                itemBuilder: (context, index) {
                  final worker = workers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(
                        worker.category == 'Local' 
                            ? 'assets/local.jpg'
                            : 'assets/persona.jpg'
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
                    title: Text(worker.name),
                    subtitle: Text(worker.category),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkerFormAdminScreen(worker: worker),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _showDeleteWorkerDialog(context, worker),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAreaDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<List<AreaModel>>(
        stream: _areaService.getAreas(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          final areas = snapshot.data!;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedAreaId.isEmpty ? null : _selectedAreaId,
              hint: Text('Filtrar por área'),
              underline: Container(),
              items: [
                DropdownMenuItem<String>(
                  value: '',
                  child: Text('Todos los trabajadores'),
                ),
                ...areas.map((area) {
                  return DropdownMenuItem<String>(
                    value: area.id,
                    child: Text(area.name),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedAreaId = value ?? '';
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAreasList() {    
    return StreamBuilder<List<AreaModel>>(
      stream: _areaService.getAreas(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final areas = snapshot.data ?? [];

        return ListView.builder(
          itemCount: areas.length,
          itemBuilder: (context, index) {
            final area = areas[index];
            return ListTile(
              title: Text(area.name),
              subtitle: Text(area.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AreaFormAdminScreen(area: area),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _showDeleteAreaDialog(context, area),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAdvertisementsList() {
    return StreamBuilder<List<AdvertisementModel>>(
      stream: _adService.getAdvertisements(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final advertisements = snapshot.data ?? [];

        return ListView.builder(
          itemCount: advertisements.length,
          itemBuilder: (context, index) {
            final ad = advertisements[index];
            return ListTile(
              leading: Image.network(ad.imageUrl, width: 50, height: 50),
              title: Text(ad.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdvertisementFormScreen(advertisement: ad),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _showDeleteAdvertisementDialog(context, ad),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildJobsList() {
    return StreamBuilder<List<JobModel>>(
      stream: _jobService.getJobs(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final jobs = snapshot.data ?? [];

        return ListView.builder(
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return FutureBuilder<WorkerModel?>(
              future: _workerService.getWorkerById(job.workerId),
              builder: (context, workerSnapshot) {
                final workerName = workerSnapshot.data?.name ?? 'Trabajador no encontrado';
                
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(workerName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estado: ${job.done ? 'Realizado' : 'No realizado'}'),
                        if (job.description.isNotEmpty)
                          Text('Descripción: ${job.description}'),
                        Text('Fecha: ${_formatDate(job.createdAt)}'),
                      ],
                    ),
                    trailing: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: job.done ? Colors.green[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        job.done ? Icons.check_circle : Icons.cancel,
                        color: job.done ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteWorkerDialog(BuildContext context, WorkerModel worker) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar a ${worker.name}?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Eliminar'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await _workerService.deleteWorker(worker.id);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAreaDialog(BuildContext context, AreaModel area) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar el servicio ${area.name}?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Eliminar'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await _areaService.deleteArea(area.id);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAdvertisementDialog(BuildContext context, AdvertisementModel ad) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar la publicidad ${ad.name}?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Eliminar'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await _adService.deleteAdvertisement(ad.id);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
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
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
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
import 'package:Joby/preferences/pref_user.dart';
import 'package:Joby/utils/auth.dart';
import 'package:flutter/material.dart';
import '../../models/worker_model.dart';
import '../../services/worker_service.dart';
import 'worker_form_admin_screen.dart';
import '../../models/area_model.dart';
import '../../services/area_service.dart';
import 'area_form_admin_screen.dart';

class HomeAdminScreen extends StatefulWidget {
  @override
  _HomeAdminScreenState createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> with SingleTickerProviderStateMixin {
  final WorkerService _workerService = WorkerService();
  final AreaService _areaService = AreaService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Administración'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Trabajadores'),
            Tab(text: 'Servicios'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _tabController.index == 0 
                ? WorkerFormAdminScreen()
                : AreaFormAdminScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWorkersList(),
          _buildAreasList(),
        ],
      ),
    );
  }

  Widget _buildWorkersList() {
    return StreamBuilder<List<WorkerModel>>(
      stream: _workerService.getWorkers(),
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
                backgroundImage: worker.imageUrl.isNotEmpty ? NetworkImage(worker.imageUrl) : AssetImage('assets/persona2.jpg'),
              ),
              title: Text(worker.name),
              subtitle: Text('${worker.type} - ${worker.category}'),
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
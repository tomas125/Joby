import 'package:Joby/preferences/pref_user.dart';
import 'package:Joby/utils/auth.dart';
import 'package:flutter/material.dart';
import '../../models/worker_model.dart';
import '../../services/worker_service.dart';
import '../../services/notification_service.dart';
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
import '../../utils/app_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeAdminScreen extends StatefulWidget {
  @override
  _HomeAdminScreenState createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> with SingleTickerProviderStateMixin {
  final WorkerService _workerService = WorkerService();
  final AreaService _areaService = AreaService();
  final AdvertisementService _adService = AdvertisementService();
  final JobService _jobService = JobService();
  final NotificationService _notificationService = NotificationService();
  late TabController _tabController;
  String _selectedAreaId = '';
  String _selectedAvailabilityFilter = 'active';
  String _selectedStatusFilter = 'all';
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: AppStyles.commonDecoration(borderRadius: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Saliendo de la aplicación',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.textDarkColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                '¿Estás seguro que deseas salir?',
                style: TextStyle(
                  color: AppStyles.textDarkColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      splashColor: AppStyles.primaryColor.withOpacity(0.2),
                      highlightColor: Colors.white.withOpacity(0.1),
                      onTap: () => Navigator.of(context).pop(false),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppStyles.textDarkColor.withOpacity(0.9),
                              AppStyles.textDarkColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text(
                            'No',
                            style: TextStyle(
                              color: AppStyles.textLightColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      splashColor: AppStyles.primaryColor.withOpacity(0.2),
                      highlightColor: Colors.white.withOpacity(0.1),
                      onTap: () => Navigator.of(context).pop(true),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppStyles.primaryColor.withOpacity(0.9),
                              AppStyles.primaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text(
                            'Sí',
                            style: TextStyle(
                              color: AppStyles.textLightColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
              Tab(text: 'Solicitudes'),
              Tab(text: 'Trabajos'),
              Tab(text: 'Trabajadores'),
              Tab(text: 'Servicios'),
              Tab(text: 'Publicidades'),
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
        floatingActionButton: _tabController.index == 0 || _tabController.index == 1
            ? null  // Hide FAB for Solicitudes and Trabajos tabs
            : FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        switch (_tabController.index) {
                          case 2: // Trabajadores tab
                            return WorkerFormAdminScreen();
                          case 3: // Servicios tab
                            return AreaFormAdminScreen();
                          case 4: // Publicidades tab
                            return AdvertisementFormScreen();
                          default:
                            return WorkerFormAdminScreen();
                        }
                      },
                    ),
                  );
                },
                child: Icon(Icons.add),
              ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildRegistrationRequestsList(),
            _buildJobsList(),
            _buildWorkersList(),
            _buildAreasList(),
            _buildAdvertisementsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkersList() {
    return Column(
      children: [
        // Search and filter container
        Container(
          margin: EdgeInsets.all(8.0),
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppStyles.secondaryColor.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              // Search field
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar trabajador...',
                  prefixIcon: Icon(Icons.search, color: AppStyles.primaryColor),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: AppStyles.primaryColor),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: AppStyles.secondaryColor.withOpacity(0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: AppStyles.secondaryColor.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: AppStyles.primaryColor),
                  ),
                  fillColor: Colors.grey.shade50,
                  filled: true,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
              
              SizedBox(height: 8),
              
              // Filters row
              Row(
                children: [
                  // Area filter
                  Expanded(
                    child: StreamBuilder<List<AreaModel>>(
                      stream: _areaService.getAreas(),
                      builder: (context, snapshot) {
                        return _buildFilterDropdown(
                          value: _selectedAreaId.isEmpty ? null : _selectedAreaId,
                          hint: 'Áreas',
                          icon: Icons.business,
                          items: [
                            _buildDropdownItem('', 'Todos'),
                            if (snapshot.hasData)
                              ...snapshot.data!.map((area) => 
                                _buildDropdownItem(area.id, area.name)
                              ).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedAreaId = value ?? '';
                            });
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 4),
                  
                  // Status filter
                  Expanded(
                    child: _buildFilterDropdown(
                      value: _selectedStatusFilter,
                      hint: 'Estado',
                      icon: Icons.check_circle_outline,
                      items: [
                        _buildDropdownItem('all', 'Todos'),
                        _buildDropdownItem('approved', 'Aprobados'),
                        _buildDropdownItem('pending', 'Pendientes'),
                        _buildDropdownItem('rejected', 'Rechazados'),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatusFilter = value ?? 'all';
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 4),
                  
                  // Availability filter
                  Expanded(
                    child: _buildFilterDropdown(
                      value: _selectedAvailabilityFilter,
                      hint: 'Disponible',
                      icon: Icons.visibility,
                      items: [
                        _buildDropdownItem('all', 'Todos'),
                        _buildDropdownItem('active', 'Activos'),
                        _buildDropdownItem('inactive', 'Inactivos'),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedAvailabilityFilter = value ?? 'active';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Workers list
        Expanded(
          child: StreamBuilder<List<WorkerModel>>(
            stream: _getFilteredWorkers(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final workers = snapshot.data ?? [];
              
              // Filter workers based on search query
              final filteredWorkers = _searchQuery.isEmpty
                  ? workers
                  : workers.where((worker) {
                      return worker.name.toLowerCase().contains(_searchQuery) ||
                             worker.phone.toLowerCase().contains(_searchQuery) ||
                             worker.email.toLowerCase().contains(_searchQuery) ||
                             worker.description.toLowerCase().contains(_searchQuery) ||
                             (worker.document != null && worker.document!.toLowerCase().contains(_searchQuery));
                    }).toList();

              if (filteredWorkers.isEmpty) {
                return Center(
                  child: Text(
                    _searchQuery.isEmpty
                        ? 'No hay trabajadores disponibles'
                        : 'No se encontraron trabajadores con "$_searchQuery"',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppStyles.textDarkColor,
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredWorkers.length,
                itemBuilder: (context, index) {
                  final worker = filteredWorkers[index];
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(worker.category),
                        Text(
                          'Estado: ${_formatStatus(worker.status)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(worker.status),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: worker.isAvailable,
                          onChanged: (bool value) {
                            _toggleWorkerAvailability(worker, value);
                          },
                          activeColor: AppStyles.primaryColor,
                        ),
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

  Stream<List<WorkerModel>> _getFilteredWorkers() {
    // First check for area filter
    if (_selectedAreaId.isNotEmpty) {
      return _workerService.getWorkersByArea(_selectedAreaId);
    }

    // If no area filter, apply availability filter
    Stream<List<WorkerModel>> workersStream;
    switch (_selectedAvailabilityFilter) {
      case 'all':
        workersStream = _workerService.getAllWorkersForAdmin();
        break;
      case 'active':
        workersStream = _workerService.getActiveWorkersForAdmin();
        break;
      case 'inactive':
        workersStream = _workerService.getInactiveWorkersForAdmin();
        break;
      default:
        workersStream = _workerService.getActiveWorkersForAdmin();
    }

    // If status filter is not 'all', we need to apply it in memory
    // since we can't combine multiple 'where' clauses with different fields in Firestore
    if (_selectedStatusFilter != 'all') {
      return workersStream.map((workers) {
        return workers.where((worker) => worker.status == _selectedStatusFilter).toList();
      });
    }

    return workersStream;
  }

  Future<void> _toggleWorkerAvailability(WorkerModel worker, bool newValue) async {
    try {
      WorkerModel updatedWorker = WorkerModel(
        id: worker.id,
        name: worker.name,
        imageUrl: worker.imageUrl,
        description: worker.description,
        phone: worker.phone,
        email: worker.email,
        category: worker.category,
        areaIds: worker.areaIds,
        location: worker.location,
        isAvailable: newValue,
        status: worker.status,
        approvedBy: worker.approvedBy,
        processedAt: worker.processedAt,
        createdAt: worker.createdAt,
        document: worker.document,
      );

      await _workerService.updateWorker(worker.id, updatedWorker);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Estado actualizado a ${newValue ? 'activo' : 'inactivo'}'
            ),
            backgroundColor: newValue ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar el estado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  Widget _buildRegistrationRequestsList() {
    return StreamBuilder<List<WorkerModel>>(
      stream: _workerService.getRegistrationRequests(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return Center(
            child: Text(
              'No hay solicitudes pendientes',
              style: TextStyle(
                fontSize: 16,
                color: AppStyles.textDarkColor,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () => _showRequestDetailsDialog(context, request),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: request.imageUrl.isNotEmpty
                            ? NetworkImage(request.imageUrl)
                            : AssetImage(
                                request.category == 'Local' 
                                    ? 'assets/local.jpg'
                                    : 'assets/persona.jpg'
                              ) as ImageProvider,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Categoría: ${request.category}'),
                            Text('Teléfono: ${request.phone}'),
                            Text('Email: ${request.email}'),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () => _showApproveRequestDialog(context, request),
                          ),
                          IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => _showRejectRequestDialog(context, request),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showRequestDetailsDialog(BuildContext context, WorkerModel request) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.person, color: AppStyles.primaryColor),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Detalles de la solicitud',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (request.imageUrl.isNotEmpty) ...[
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          request.imageUrl,
                          height: 150,
                          width: MediaQuery.of(context).size.width * 0.8,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 150,
                              width: MediaQuery.of(context).size.width * 0.8,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / 
                                        loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 150,
                              width: MediaQuery.of(context).size.width * 0.8,
                              color: Colors.grey[300],
                              child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  _buildDetailSection(
                    'Información Personal',
                    [
                      _buildDetailRow('Nombre', request.name),
                      _buildDetailRow('Categoría', request.category),
                      _buildDetailRow('Teléfono', request.phone),
                      _buildDetailRow('Email', request.email),
                      if (request.document != null && request.document!.isNotEmpty)
                        _buildDetailRow(
                          request.category == 'Local' ? 'CUIT' : 'CUIL',
                          request.document!
                        ),
                    ],
                  ),
                  _buildDetailSection(
                    'Detalles del Servicio',
                    [
                      _buildDetailRow('Descripción', request.description),
                      StreamBuilder<List<AreaModel>>(
                        stream: _areaService.getAreas(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final areas = snapshot.data!;
                            final areaNames = request.areaIds.map((areaId) {
                              final area = areas.firstWhere(
                                (a) => a.id == areaId,
                                orElse: () => AreaModel(
                                  id: areaId,
                                  name: 'Área no encontrada',
                                  description: '',
                                  icon: 'error',
                                ),
                              );
                              return area.name;
                            }).join(', ');
                            return _buildDetailRow('Áreas', areaNames);
                          }
                          return _buildDetailRow('Áreas', 'Cargando...');
                        },
                      ),
                      _buildDetailRow('Disponible', request.isAvailable ? 'Sí' : 'No'),
                    ],
                  ),
                  _buildDetailSection(
                    'Estado de la Solicitud',
                    [
                      _buildDetailRow('Estado', request.status),
                      if (request.rejectionReason != null) 
                        _buildDetailRow('Motivo de rechazo', request.rejectionReason!),
                      if (request.approvedBy != null)
                        _buildDetailRow('Aprobado por', request.approvedBy!),
                      if (request.processedAt != null)
                        _buildDetailRow('Procesado', _formatDate(request.processedAt!)),
                      if (request.createdAt != null)
                        _buildDetailRow('Creado', _formatDate(request.createdAt!)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppStyles.primaryColor,
            ),
          ),
        ),
        ...children,
        Divider(color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppStyles.textDarkColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppStyles.textDarkColor),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
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

  Future<void> _showApproveRequestDialog(BuildContext context, WorkerModel request) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes iniciar sesión como administrador')),
      );
      return;
    }

    final shouldApprove = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Aprobar solicitud'),
          content: Text('¿Estás seguro de que deseas aprobar la solicitud de ${request.name}?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text('Aprobar'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (shouldApprove == true) {
      try {
        await _workerService.approveRequest(request.id, user.uid);
        
        // Enviar notificación de aprobación
        await _notificationService.sendApprovalNotification(request);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Solicitud aprobada exitosamente')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al aprobar la solicitud: $e')),
          );
        }
      }
    }
  }

  Future<void> _showRejectRequestDialog(BuildContext context, WorkerModel request) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes iniciar sesión como administrador')),
      );
      return;
    }

    final TextEditingController rejectionReasonController = TextEditingController();

    final shouldReject = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rechazar solicitud'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('¿Estás seguro de que deseas rechazar la solicitud de ${request.name}?'),
              SizedBox(height: 16),
              TextField(
                controller: rejectionReasonController,
                decoration: InputDecoration(
                  labelText: 'Motivo del rechazo (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text('Rechazar'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (shouldReject == true) {
      try {
        await _workerService.rejectRequest(
          request.id,
          user.uid,
          rejectionReasonController.text,
        );

        // Enviar notificación de rechazo
        await _notificationService.sendRejectionNotification(
          request,
          rejectionReasonController.text,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Solicitud rechazada exitosamente')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al rechazar la solicitud: $e')),
          );
        }
      }
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'approved':
        return 'Aprobado';
      case 'pending':
        return 'Pendiente';
      case 'rejected':
        return 'Rechazado';
      default:
        return 'Desconocido';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper method to build consistent filter dropdowns
  Widget _buildFilterDropdown({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppStyles.secondaryColor.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          icon: Icon(Icons.arrow_drop_down, color: AppStyles.primaryColor, size: 16),
          iconSize: 16,
          hint: icon != null 
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: AppStyles.primaryColor),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        hint,
                        style: TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : Text(
                  hint, 
                  style: TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
          style: TextStyle(
            color: AppStyles.textDarkColor,
            fontSize: 13,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Helper method to build dropdown items with consistent style
  DropdownMenuItem<String> _buildDropdownItem(String value, String text) {
    return DropdownMenuItem(
      value: value,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Text(
          text,
          style: TextStyle(fontSize: 13),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
} 
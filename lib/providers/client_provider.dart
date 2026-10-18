import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class ClientProvider extends ChangeNotifier {
  List<Client> _clients = [];
  bool _isLoading = false;
  String? _error;

  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  Future<void> loadClients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final clientsData = await StorageService.instance.getClients();
      _clients = clientsData.map((data) => Client.fromJson(data)).toList();
      _clients.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      _error = 'Failed to load clients: ${e.toString()}';
      debugPrint('Error loading clients: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Client> createClient(Client client) async {
    try {
      _error = null;
      const uuid = Uuid();
      final newClient = client.copyWith(
        id: uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _clients.add(newClient);
      _clients.sort((a, b) => a.name.compareTo(b.name));
      await _saveClients();
      notifyListeners();
      return newClient;
    } catch (e) {
      _error = 'Failed to create client: ${e.toString()}';
      debugPrint('Error creating client: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<Client> updateClient(Client updatedClient) async {
    try {
      final index = _clients.indexWhere((client) => client.id == updatedClient.id);
      if (index != -1) {
        final updated = updatedClient.copyWith(updatedAt: DateTime.now());
        _clients[index] = updated;
        _clients.sort((a, b) => a.name.compareTo(b.name));
        await _saveClients();
        notifyListeners();
        return updated;
      } else {
        throw Exception('Client not found');
      }
    } catch (e) {
      debugPrint('Error updating client: $e');
      rethrow;
    }
  }

  Future<void> deleteClient(String clientId) async {
    try {
      _clients.removeWhere((client) => client.id == clientId);
      await _saveClients();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting client: $e');
      rethrow;
    }
  }

  Future<void> addProjectToClient(String clientId, Project project) async {
    try {
      final clientIndex = _clients.indexWhere((client) => client.id == clientId);
      if (clientIndex != -1) {
        final updatedProjects = List<Project>.from(_clients[clientIndex].projects);
        updatedProjects.add(project);
        
        _clients[clientIndex] = _clients[clientIndex].copyWith(
          projects: updatedProjects,
          updatedAt: DateTime.now(),
        );
        
        await _saveClients();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding project to client: $e');
      rethrow;
    }
  }

  Future<void> updateProject(String clientId, Project updatedProject) async {
    try {
      final clientIndex = _clients.indexWhere((client) => client.id == clientId);
      if (clientIndex != -1) {
        final updatedProjects = List<Project>.from(_clients[clientIndex].projects);
        final projectIndex = updatedProjects.indexWhere((project) => project.id == updatedProject.id);
        
        if (projectIndex != -1) {
          updatedProjects[projectIndex] = updatedProject.copyWith(updatedAt: DateTime.now());
          
          _clients[clientIndex] = _clients[clientIndex].copyWith(
            projects: updatedProjects,
            updatedAt: DateTime.now(),
          );
          
          await _saveClients();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error updating project: $e');
      rethrow;
    }
  }

  Future<void> deleteProject(String clientId, String projectId) async {
    try {
      final clientIndex = _clients.indexWhere((client) => client.id == clientId);
      if (clientIndex != -1) {
        final updatedProjects = List<Project>.from(_clients[clientIndex].projects);
        updatedProjects.removeWhere((project) => project.id == projectId);
        
        _clients[clientIndex] = _clients[clientIndex].copyWith(
          projects: updatedProjects,
          updatedAt: DateTime.now(),
        );
        
        await _saveClients();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting project: $e');
      rethrow;
    }
  }

  Client? getClientById(String clientId) {
    try {
      return _clients.firstWhere((client) => client.id == clientId);
    } catch (e) {
      return null;
    }
  }

  Project? getProjectById(String clientId, String projectId) {
    try {
      final client = getClientById(clientId);
      if (client != null) {
        return client.projects.firstWhere((project) => project.id == projectId);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  List<Project> getAllProjects() {
    final allProjects = <Project>[];
    for (final client in _clients) {
      allProjects.addAll(client.projects);
    }
    return allProjects;
  }

  List<Project> getActiveProjects() {
    return getAllProjects().where((project) => project.status == ProjectStatus.active).toList();
  }

  Future<void> _saveClients() async {
    final clientsData = _clients.map((client) => client.toJson()).toList();
    await StorageService.instance.saveClients(clientsData);
  }

  List<Client> searchClients(String query) {
    if (query.isEmpty) return _clients;
    
    final lowercaseQuery = query.toLowerCase();
    return _clients.where((client) {
      return client.name.toLowerCase().contains(lowercaseQuery) ||
             client.email.toLowerCase().contains(lowercaseQuery) ||
             client.company?.toLowerCase().contains(lowercaseQuery) == true;
    }).toList();
  }
}

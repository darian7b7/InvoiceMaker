import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/client.dart';

class ContactsService {
  static final ContactsService _instance = ContactsService._internal();
  factory ContactsService() => _instance;
  ContactsService._internal();

  static ContactsService get instance => _instance;

  /// Request contacts permission
  Future<bool> requestContactsPermission() async {
    final status = await Permission.contacts.request();
    return status == PermissionStatus.granted;
  }

  /// Check if contacts permission is granted
  Future<bool> hasContactsPermission() async {
    final status = await Permission.contacts.status;
    return status == PermissionStatus.granted;
  }

  /// Get all contacts from phone
  Future<List<Contact>> getPhoneContacts() async {
    try {
      final hasPermission = await hasContactsPermission();
      if (!hasPermission) {
        final granted = await requestContactsPermission();
        if (!granted) {
          throw Exception('Contacts permission denied');
        }
      }

      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );
      return contacts.where((contact) => 
        contact.displayName.isNotEmpty &&
        contact.phones.isNotEmpty
      ).toList();
    } catch (e) {
      throw Exception('Failed to load contacts: $e');
    }
  }

  /// Convert phone contact to client model
  Client contactToClient(Contact contact) {
    final phone = contact.phones.isNotEmpty 
        ? contact.phones.first.number
        : '';
    
    final email = contact.emails.isNotEmpty
        ? contact.emails.first.address
        : '';

    final addressParts = _getContactAddressParts(contact);
    
    return Client(
      id: '', // Will be generated when saved
      name: contact.displayName.isNotEmpty ? contact.displayName : 'Unknown Contact',
      email: email,
      phone: phone,
      address: addressParts['address'] ?? '',
      city: addressParts['city'] ?? '',
      country: addressParts['country'] ?? '',
      company: contact.organizations.isNotEmpty ? contact.organizations.first.company : '',
      projects: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Extract address parts from contact
  Map<String, String> _getContactAddressParts(Contact contact) {
    if (contact.addresses.isNotEmpty) {
      final address = contact.addresses.first;
      final streetParts = <String>[];
      
      if (address.street.isNotEmpty) streetParts.add(address.street);
      if (address.state.isNotEmpty) streetParts.add(address.state);
      if (address.postalCode.isNotEmpty) streetParts.add(address.postalCode);
      
      return {
        'address': streetParts.join(', '),
        'city': address.city,
        'country': address.country,
      };
    }
    return {
      'address': '',
      'city': '',
      'country': '',
    };
  }

  /// Search contacts by name or phone
  List<Contact> searchContacts(List<Contact> contacts, String query) {
    if (query.isEmpty) return contacts;
    
    final lowercaseQuery = query.toLowerCase();
    return contacts.where((contact) {
      final name = contact.displayName.toLowerCase();
      final phone = contact.phones.isNotEmpty
          ? contact.phones.first.number.replaceAll(RegExp(r'[^\d]'), '')
          : '';
      final searchPhone = query.replaceAll(RegExp(r'[^\d]'), '');
      
      return name.contains(lowercaseQuery) || 
             phone.contains(searchPhone);
    }).toList();
  }
}

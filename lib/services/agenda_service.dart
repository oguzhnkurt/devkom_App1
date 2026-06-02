import 'package:flutter/foundation.dart';

/// Agenda Service Stub
class AgendaService {
  Future<List<dynamic>> getEvents(String userId) async {
    debugPrint('⚠️ AgendaService: Supabase migration pending');
    return [];
  }

  Future<void> addEvent(Map<String, dynamic> event) async {
    debugPrint('⚠️ AgendaService: Supabase migration pending');
  }

  Stream<List<dynamic>> getUserEvents(String userId) {
    debugPrint('⚠️ AgendaService.getUserEvents: Supabase migration pending');
    return Stream.value([]);
  }

  Future<void> deleteEvent(String eventId) async {
    debugPrint('⚠️ AgendaService.deleteEvent: Supabase migration pending');
  }
}

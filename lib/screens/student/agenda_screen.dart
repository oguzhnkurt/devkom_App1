// Turkish calendar support
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/agenda_event.dart';
import '../../services/agenda_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_localizations.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final AgendaService _agendaService = AgendaService();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<AgendaEvent>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<AgendaEvent> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final authProvider = context.watch<AuthProvider>();
    final userId = authProvider.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        body: Center(child: Text(loc.pleaseLogin)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.agenda),
        centerTitle: true,
      ),
      body: StreamBuilder<List<AgendaEvent>>(
        stream: _agendaService.getUserEvents(userId).map((events) => events.cast<AgendaEvent>().toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('${loc.error}: ${snapshot.error}'));
          }

          final events = snapshot.data ?? [];
          _events.clear();
          
          for (var event in events) {
            final normalizedDate = DateTime(
              event.date.year,
              event.date.month,
              event.date.day,
            );
            if (_events[normalizedDate] == null) {
              _events[normalizedDate] = [];
            }
            _events[normalizedDate]!.add(event);
          }

          final selectedEvents = _getEventsForDay(_selectedDay ?? DateTime.now());

          return Column(
            children: [
              TableCalendar<AgendaEvent>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                daysOfWeekStyle: DaysOfWeekStyle(
                  dowTextFormatter: (date, locale) {
                    // Day names (abbreviated)
                    final days = [loc.monday, loc.tuesday, loc.wednesday, loc.thursday, loc.friday, loc.saturday, loc.sunday];
                    return days[date.weekday - 1];
                  },
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                ),
                onDaySelected: _onDaySelected,
                onFormatChanged: (format) {
                  setState(() => _calendarFormat = format);
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
              const Divider(height: 1),
              Expanded(
                child: selectedEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_note,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              loc.noEventsOnThisDate,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: selectedEvents.length,
                        itemBuilder: (context, index) {
                          final event = selectedEvents[index];
                          return Dismissible(
                            key: Key(event.id),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(loc.deleteEvent),
                                    content: Text('${event.title} ${loc.deleteEventConfirmation}'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: Text(loc.cancel),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: Text(loc.delete),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDismissed: (direction) async {
                              try {
                                await _agendaService.deleteEvent(event.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${event.title} ${loc.deleted}'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${loc.error}: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: Text(
                                  event.typeIcon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                title: Text(
                                  event.title,
                                  style: TextStyle(
                                    decoration: event.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: event.description.isNotEmpty
                                    ? Text(
                                        event.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(loc.deleteEvent),
                                          content: Text('${event.title} ${loc.deleteEventConfirmation}'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: Text(loc.cancel),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              child: Text(loc.delete),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (confirm == true) {
                                      try {
                                        await _agendaService.deleteEvent(event.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${event.title} ${loc.deleted}'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${loc.error}: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddEventDialog(context, userId),
          child: const Icon(Icons.add),
          tooltip: loc.addEvent,
        ),
    );
  }
 void _showAddEventDialog(BuildContext context, String userId) {
      final loc = AppLocalizations.of(context);
      final titleController = TextEditingController();
      final descController = TextEditingController();
      EventType selectedType = EventType.note;

      showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(loc.addEvent, style: const TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleController, decoration: InputDecoration(labelText: loc.title,
  border: const OutlineInputBorder())),
                  const SizedBox(height: 16),
                  TextField(controller: descController, decoration: InputDecoration(labelText: loc.descriptionOptional, border: const OutlineInputBorder()), maxLines: 3),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<EventType>(
                    value: selectedType,
                    decoration: InputDecoration(labelText: loc.type, border: const OutlineInputBorder()),
                    items: [EventType.note, EventType.reminder, EventType.task].map((type) {
                      String label = type == EventType.note ? '📋 ${loc.note}' : type == EventType.reminder ? '🔔 ${loc.reminder}' : '✅ ${loc.task}';
                      return DropdownMenuItem(value: type, child: Text(label));
                    }).toList(),
                    onChanged: (value) => setState(() => selectedType = value!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(loc.cancel)),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(loc.pleasEnterTitle)));
                    return;
                  }
                  final event = AgendaEvent(id: '', title: titleController.text.trim(), description: descController.text.trim(), date: _selectedDay ?? DateTime.now(), type: selectedType, priority: EventPriority.medium, userId: userId, createdAt: DateTime.now(), isPublic: false);
                  try {
                    await _agendaService.addEvent(event.toMap());
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(loc.eventAdded)));
                    }
                  } catch (e) {
                    if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('${loc.error}: $e')));
                  }
                },
                child: Text(loc.add),
              ),
            ],
          ),
        ),
      );
    }
}

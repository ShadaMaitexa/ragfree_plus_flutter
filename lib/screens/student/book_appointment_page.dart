import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/app_state.dart';
import '../../services/appointment_service.dart';
import '../../services/chat_service.dart'; // To get counselors
import '../../models/appointment_slot_model.dart';
import '../../utils/responsive.dart';
import '../../widgets/animated_widgets.dart';

class StudentBookAppointmentPage extends StatefulWidget {
  const StudentBookAppointmentPage({super.key});

  @override
  State<StudentBookAppointmentPage> createState() =>
      _StudentBookAppointmentPageState();
}

class _StudentBookAppointmentPageState
    extends State<StudentBookAppointmentPage> {
  final ChatService _chatService = ChatService(); // Reusing to get counselors
  final AppointmentService _appointmentService = AppointmentService();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Counseling Session'),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.05),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _chatService.getAvailableCounselors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final counselors = snapshot.data ?? [];

                if (counselors.isEmpty) {
                  return const Center(child: Text('No counselors availalbe'));
                }

                return ListView.builder(
                  padding: Responsive.getPadding(context),
                  itemCount: counselors.length,
                  itemBuilder: (context, index) {
                    final counselor = counselors[index];
                    return AnimatedWidgets.slideIn(
                      beginOffset: const Offset(0, 0.1),
                      delay: Duration(milliseconds: index * 100),
                      child: Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: color.withValues(alpha: 0.1),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(20),
                          leading: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: color.withValues(alpha: 0.1),
                              child: Text(
                                counselor['name'].substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            counselor['name'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              counselor['department'] ?? 'Counselor',
                              style: TextStyle(color: Theme.of(context).hintColor),
                            ),
                          ),
                          trailing: FilledButton.icon(
                            onPressed: () => _showBookingSheet(context, counselor),
                            icon: const Icon(Icons.calendar_month, size: 18),
                            label: const Text('View Slots'),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showBookingSheet(
      BuildContext context, Map<String, dynamic> counselor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) =>
            _BookingSheetContent(
              counselor: counselor,
              scrollController: scrollController,
              appointmentService: _appointmentService,
            ),
      ),
    );
  }
}

class _BookingSheetContent extends StatelessWidget {
  final Map<String, dynamic> counselor;
  final ScrollController scrollController;
  final AppointmentService appointmentService;

  const _BookingSheetContent({
    required this.counselor,
    required this.scrollController,
    required this.appointmentService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Available Slots with ${counselor['name']}',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text('Select a time to book your session'),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: StreamBuilder<List<AppointmentSlotModel>>(
            stream: appointmentService.getAvailableSlots(counselor['id']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final slots = snapshot.data ?? [];

              if (slots.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No available slots'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: slots.length,
                itemBuilder: (context, index) {
                  final slot = slots[index];
                  final dateStr = DateFormat('EEE, MMM d').format(slot.date);
                  final timeStr = '${slot.startTime} - ${slot.endTime}';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading:
                          const Icon(Icons.access_time, color: Colors.blue),
                      title: Text(dateStr,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(timeStr),
                      trailing: ElevatedButton(
                        onPressed: () => _confirmBooking(context, slot),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        child: const Text('Book'),
                      ),
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

  void _confirmBooking(BuildContext context, AppointmentSlotModel slot) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Text(
            'Do you want to book specific session on ${DateFormat('MMM d').format(slot.date)} at ${slot.startTime}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              await _bookSlot(context, slot);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _bookSlot(BuildContext context, AppointmentSlotModel slot) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;
    if (user == null) return;

    try {
      await appointmentService.bookSlot(slot.id, user.uid, user.name);
      
      if (context.mounted) {
        Navigator.pop(context); // Close bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

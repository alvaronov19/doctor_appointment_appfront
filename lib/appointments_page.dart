import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController _reasonController = TextEditingController();

  Future<void> _generarHorariosDePrueba() async {
    final idMedico = 'dr_juan_perez_id';
    final WriteBatch batch = _firestore.batch();
    final now = DateTime.now();

    final manana = DateTime(now.year, now.month, now.day + 1, 9, 0);

    final slot1 = _firestore.collection('disponibilidad_medicos').doc();
    batch.set(slot1, {
      'id_medico': idMedico,
      'fecha_hora_inicio': Timestamp.fromDate(manana),
      'esta_disponible': true,
    });

    final slot2 = _firestore.collection('disponibilidad_medicos').doc();
    batch.set(slot2, {
      'id_medico': idMedico,
      'fecha_hora_inicio':
          Timestamp.fromDate(manana.add(const Duration(hours: 1))),
      'esta_disponible': true,
    });

    final slot3 = _firestore.collection('disponibilidad_medicos').doc();
    batch.set(slot3, {
      'id_medico': idMedico,
      'fecha_hora_inicio':
          Timestamp.fromDate(manana.add(const Duration(hours: 2))),
      'esta_disponible': true,
    });

    await batch.commit();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Horarios de prueba generados para mañana.')));
    }
  }

  void _showCreateAppointmentDialog() {
    _reasonController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 20,
              left: 20,
              right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Agendar Nueva Cita',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('1. Selecciona un horario disponible:'),
              SizedBox(
                height: 150,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('disponibilidad_medicos')
                      .where('esta_disponible', isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());
                    if (snapshot.data!.docs.isEmpty)
                      return const Center(
                          child: Text('No hay horarios disponibles.'));

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final slot = snapshot.data!.docs[index];
                        final slotData = slot.data() as Map<String, dynamic>;
                        final time =
                            (slotData['fecha_hora_inicio'] as Timestamp)
                                .toDate();

                        return ListTile(
                          title: Text('Dr. Juan Pérez (Hardcoded)'),
                          subtitle: Text(
                              DateFormat('dd/MM/yyyy - hh:mm a').format(time)),
                          onTap: () {
                            Navigator.pop(context);
                            _confirmAppointmentCreation(slot.id, time);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _confirmAppointmentCreation(String slotId, DateTime slotTime) {
    _reasonController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('2. Confirma tu cita'),
        content: TextField(
          controller: _reasonController,
          decoration: const InputDecoration(labelText: 'Motivo de la consulta'),
        ),
        actions: [
          TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context)),
          ElevatedButton(
            child: const Text('Confirmar Cita'),
            onPressed: () {
              if (_reasonController.text.isNotEmpty) {
                _addAppointment(slotId, slotTime, _reasonController.text);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addAppointment(
      String slotId, DateTime slotTime, String motivo) async {
    if (_currentUser == null) return;

    final WriteBatch batch = _firestore.batch();

    final slotDoc = _firestore.collection('disponibilidad_medicos').doc(slotId);
    batch.update(slotDoc, {'esta_disponible': false});

    final citaDoc = _firestore.collection('citas').doc();
    batch.set(citaDoc, {
      'motivo': motivo,
      'fecha_hora_inicio': Timestamp.fromDate(slotTime),
      'id_paciente': _currentUser!.uid,
      'id_medico': 'dr_juan_perez_id',
      'id_disponibilidad': slotId,
    });

    await batch.commit();
  }

  void _showUpdateDialog(DocumentSnapshot citaDoc) {
    final data = citaDoc.data() as Map<String, dynamic>;
    _reasonController.text = data['motivo'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Motivo de Cita'),
        content: TextField(
          controller: _reasonController,
          decoration: const InputDecoration(labelText: 'Motivo de la consulta'),
        ),
        actions: [
          TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context)),
          ElevatedButton(
            child: const Text('Actualizar'),
            onPressed: () {
              if (_reasonController.text.isNotEmpty) {
                _updateAppointment(citaDoc.id, _reasonController.text);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateAppointment(String docId, String newReason) async {
    await _firestore.collection('citas').doc(docId).update({
      'motivo': newReason,
    });
  }

  Future<void> _deleteAppointment(String citaId, String slotId) async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar Cancelación'),
            content:
                const Text('¿Estás seguro? Esta acción liberará el horario.'),
            actions: [
              TextButton(
                  child: const Text('No'),
                  onPressed: () => Navigator.pop(context, false)),
              TextButton(
                  child: const Text('Sí, cancelar'),
                  onPressed: () => Navigator.pop(context, true)),
            ],
          ),
        ) ??
        false;

    if (confirmDelete) {
      final WriteBatch batch = _firestore.batch();

      final citaDoc = _firestore.collection('citas').doc(citaId);
      batch.delete(citaDoc);

      final slotDoc = _firestore.collection('disponibilidad_medicos').doc(slotId);
      batch.update(slotDoc, {'esta_disponible': true});

      await batch.commit();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
          body: Center(child: Text("Error: Usuario no autenticado.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Citas'),
        backgroundColor: Colors.teal,
        actions: [
          Tooltip(
            message: 'Generar horarios de prueba',
            child: IconButton(
              icon: const Icon(Icons.add_task),
              onPressed: _generarHorariosDePrueba,
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('citas')
            .where('id_paciente', isEqualTo: _currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tienes citas programadas.'));
          }

          final appointments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final data = appointment.data() as Map<String, dynamic>;
              final time = (data['fecha_hora_inicio'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(data['motivo']),
                  subtitle:
                      Text(DateFormat('dd/MM/yyyy - hh:mm a').format(time)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteAppointment(
                        appointment.id, data['id_disponibilidad']),
                  ),
                  onTap: () => _showUpdateDialog(appointment),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateAppointmentDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
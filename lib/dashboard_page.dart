import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'routes.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  Widget _buildStatCard(String title, Stream<QuerySnapshot> stream, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.teal),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 36, 
                        width: 36, 
                        child: CircularProgressIndicator()
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Text('0',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold));
                    }
                    
                    String stat = '0';
                    if (title == 'Citas Pendientes') {
                      final now = Timestamp.now();
                      final pendingDocs = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return (data['fecha_hora_inicio'] as Timestamp).compareTo(now) > 0;
                      });
                      stat = pendingDocs.length.toString();
                    } else {
                      stat = snapshot.data!.docs.length.toString();
                    }

                    return Text(stat,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold));
                  },
                ),
                Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Stream<QuerySnapshot> _getUpcomingAppointmentsStream() {
    return _firestore
        .collection('citas')
        .where('id_medico', isEqualTo: _currentUser!.uid)
        .where('fecha_hora_inicio', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('fecha_hora_inicio', descending: false)
        .limit(5)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(body: Center(child: Text("No autorizado.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard del Médico'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildStatCard(
            'Total de Citas',
            _firestore
                .collection('citas')
                .where('id_medico', isEqualTo: _currentUser!.uid)
                .snapshots(),
            Icons.calendar_month
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'Citas Pendientes',
            _firestore
                .collection('citas')
                .where('id_medico', isEqualTo: _currentUser!.uid)
                .snapshots(),
            Icons.pending_actions
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'Total de Pacientes',
            _firestore
                .collection('usuarios')
                .where('rol', isEqualTo: 'Paciente')
                .snapshots(),
            Icons.groups
          ),
          
          const SizedBox(height: 16),
          Card(
            color: Colors.indigo[50],
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, Routes.graphics);
              },
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 30, color: Colors.indigo),
                    SizedBox(width: 10),
                    Text(
                      "Ver Reportes Gráficos",
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
          
          const Text(
            'Próximas 5 Citas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: StreamBuilder<QuerySnapshot>(
              stream: _getUpcomingAppointmentsStream(),
              builder: (context, snapshot) {
                 if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No tienes citas próximas.'),
                  ));
                }
                final appointments = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: appointments.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final doc = appointments[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final time = (data['fecha_hora_inicio'] as Timestamp).toDate();
                    return ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(data['motivo']),
                      subtitle: Text(DateFormat('dd/MM/yyyy - hh:mm a').format(time)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GraphicsPage extends StatefulWidget {
  const GraphicsPage({super.key});

  @override
  State<GraphicsPage> createState() => _GraphicsPageState();
}

class _GraphicsPageState extends State<GraphicsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // --- GRÁFICA DE PASTEL ---
  Widget _buildPieChart(List<QueryDocumentSnapshot> docs) {
    int pendientes = 0;
    int pasadas = 0;
    
    final now = DateTime.now();

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final fechaTimestamp = data['fecha_hora_inicio'] as Timestamp;
      final fecha = fechaTimestamp.toDate();

      if (fecha.isAfter(now)) {
        pendientes++;
      } else {
        pasadas++;
      }
    }

    if (docs.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("No hay datos de citas suficientes")),
      );
    }

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 0,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              color: Colors.orangeAccent,
              value: pendientes.toDouble(),
              title: '$pendientes',
              radius: 50,
              titleStyle: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              color: Colors.teal,
              value: pasadas.toDouble(),
              title: '$pasadas',
              radius: 60,
              titleStyle: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // --- GRÁFICA DE BARRAS ---
  Widget _buildBarChart(List<QueryDocumentSnapshot> docs) {
    Map<int, int> citasPorMes = {};
    
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final fechaTimestamp = data['fecha_hora_inicio'] as Timestamp;
      final mes = fechaTimestamp.toDate().month;
      citasPorMes[mes] = (citasPorMes[mes] ?? 0) + 1;
    }

    List<BarChartGroupData> barGroups = [];
    for (int i = 1; i <= 12; i++) {
      if (citasPorMes.containsKey(i)) {
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: citasPorMes[i]!.toDouble(),
                color: Colors.blueAccent,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              )
            ],
          ),
        );
      }
    }

    if (docs.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("No hay datos para la gráfica de barras")),
      );
    }

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (citasPorMes.values.isNotEmpty 
                  ? citasPorMes.values.reduce((a, b) => a > b ? a : b) 
                  : 10).toDouble() + 2,
          
          // 1. Aquí pasamos los datos de las barras
          barGroups: barGroups, 

          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style = TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  );
                  String text;
                  switch (value.toInt()) {
                    case 1: text = 'Ene'; break;
                    case 2: text = 'Feb'; break;
                    case 3: text = 'Mar'; break;
                    case 4: text = 'Abr'; break;
                    case 5: text = 'May'; break;
                    case 6: text = 'Jun'; break;
                    case 7: text = 'Jul'; break;
                    case 8: text = 'Ago'; break;
                    case 9: text = 'Sep'; break;
                    case 10: text = 'Oct'; break;
                    case 11: text = 'Nov'; break;
                    case 12: text = 'Dic'; break;
                    default: text = '';
                  }
                  
                  // 2. CORRECCIÓN FINAL: Usamos 'meta' en lugar de 'axisSide'
                  return SideTitleWidget(
                    meta: meta, // <-- Esto soluciona el error rojo
                    space: 4,
                    child: Text(text, style: style),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(body: Center(child: Text("No autorizado.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas Médicas'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('citas')
            // .where('id_medico', isEqualTo: _currentUser!.uid) // Filtro comentado para ver datos
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay suficientes datos para generar gráficas.'));
          }

          final docs = snapshot.data!.docs;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Estado de Citas",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildPieChart(docs),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendItem(Colors.orangeAccent, "Pendientes"),
                            const SizedBox(width: 24),
                            _buildLegendItem(Colors.teal, "Completadas/Pasadas"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Citas por Mes",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        _buildBarChart(docs),
                        const SizedBox(height: 10),
                        const Text("Meses con actividad", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
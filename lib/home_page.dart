import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final List<Map<String, dynamic>> specialists = [
    {'name': 'Cardiología', 'icon': Icons.favorite_border},
    {'name': 'Dermatología', 'icon': Icons.healing_outlined},
    {'name': 'Pediatría', 'icon': Icons.child_friendly_outlined},
    {'name': 'Neurología', 'icon': Icons.psychology_outlined},
    {'name': 'Ginecología', 'icon': Icons.female_outlined},
  ];

  final List<Map<String, String>> popularDoctors = [
    {
      'name': 'Dr. Juan Pérez',
      'spec': 'Cardiólogo',
      'rating': '4.9',
      'imgUrl': 'https://via.placeholder.com/150/0000FF/FFFFFF?Text=Dr.P'
    },
    {
      'name': 'Dra. Ana Gómez',
      'spec': 'Dermatóloga',
      'rating': '4.8',
      'imgUrl': 'https://via.placeholder.com/150/FF0000/FFFFFF?Text=Dra.G'
    },
    {
      'name': 'Dr. Luis Vega',
      'spec': 'Pediatra',
      'rating': '4.9',
      'imgUrl': 'https://via.placeholder.com/150/00FF00/FFFFFF?Text=Dr.V'
    },
    {
      'name': 'Dra. María Sol',
      'spec': 'Neuróloga',
      'rating': '4.7',
      'imgUrl': 'https://via.placeholder.com/150/FFFF00/000000?Text=Dra.S'
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
    case 0:
      break;
    case 1:
      Navigator.pushNamed(context, Routes.messages); 
      break;
    case 2:
      Navigator.pushNamed(context, Routes.profile);
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    String userName = currentUser?.email?.split('@')[0] ?? 'Usuario';
    userName = userName[0].toUpperCase() + userName.substring(1);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mensajes'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _buildWelcomeHeader(userName, context),
            const SizedBox(height: 30),
            _buildActionCards(),
            const SizedBox(height: 30),
            _buildSectionTitle('Especialistas'),
            const SizedBox(height: 16),
            _buildSpecialistsList(),
            const SizedBox(height: 30),
            _buildSectionTitle('Doctores Populares'),
            const SizedBox(height: 16),
            _buildPopularDoctorsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String userName, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¡Hola, $userName!',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('¿En qué podemos ayudarte?',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, Routes.profile),
          child: const CircleAvatar(
            radius: 25,
            backgroundImage:
                NetworkImage('https://via.placeholder.com/150/AAAAAA/FFFFFF?Text=User'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCards() {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            color: Colors.deepPurple[400],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, Routes.appointments);
              },
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Column(
                  children: [
                    Icon(Icons.add_circle_outline,
                        color: Colors.white, size: 32),
                    SizedBox(height: 12),
                    Text('Agendar Cita',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Realiza una cita',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 2,
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Column(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        color: Colors.teal[400], size: 32),
                    const SizedBox(height: 12),
                    Text('Consejos',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Consejos médicos',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildSpecialistsList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: specialists.length,
        itemBuilder: (context, index) {
          final item = specialists[index];
          return Container(
            width: 90,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item['icon'] as IconData,
                        color: Colors.teal, size: 30),
                    const SizedBox(height: 8),
                    Text(item['name'] as String,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularDoctorsGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: popularDoctors.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final doctor = popularDoctors[index];
        return _DoctorCard(
          name: doctor['name']!,
          spec: doctor['spec']!,
          rating: doctor['rating']!,
          imgUrl: doctor['imgUrl']!,
        );
      },
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final String name;
  final String spec;
  final String rating;
  final String imgUrl;

  const _DoctorCard({
    required this.name,
    required this.spec,
    required this.rating,
    required this.imgUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage(imgUrl),
              ),
              const SizedBox(height: 12),
              Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(spec,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber[700], size: 16),
                    const SizedBox(width: 4),
                    Text(rating,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
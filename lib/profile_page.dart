import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    String userName = currentUser?.email?.split('@')[0] ?? 'Usuario';
    userName = userName[0].toUpperCase() + userName.substring(1);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileHeader(context, userName),
          const SizedBox(height: 20),
          _buildSettingsCard(
            context: context,
            title: 'CUENTA',
            children: [
              _buildListTile(
                context,
                title: 'Perfil',
                icon: Icons.person_outline,
                onTap: () {
                  Navigator.pushNamed(context, Routes.profileForm);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingsCard(
            context: context,
            title: 'INFORMACIÓN',
            children: [
              _buildListTile(
                context,
                title: 'Privacidad',
                icon: Icons.security_outlined,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.infoPage,
                    arguments: {
                      'title': 'Política de Privacidad',
                      'content':
                          'Aquí va el texto completo sobre la política de privacidad de la aplicación. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua...'
                    },
                  );
                },
              ),
              _buildListTile(
                context,
                title: 'Sobre Nosotros',
                icon: Icons.info_outline,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.infoPage,
                    arguments: {
                      'title': 'Sobre Nosotros',
                      'content':
                          'Esta aplicación fue desarrollada como un proyecto. Citas Médicas App v1.0.0. Lorem ipsum dolor sit amet, consectetur adipiscing elit...'
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String userName) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundImage:
              NetworkImage('https://via.placeholder.com/150/AAAAAA/FFFFFF?Text=User'),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              FirebaseAuth.instance.currentUser?.email ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSettingsCard(
      {required BuildContext context,
      required String title,
      required List<Widget> children}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.redAccent),
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(
              fontWeight: FontWeight.w500, color: Colors.redAccent),
        ),
        onTap: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.login,
            (route) => false,
          );
        },
      ),
    );
  }
}
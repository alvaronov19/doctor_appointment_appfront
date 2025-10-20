import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    
    return Scaffold(
      appBar: AppBar(title: const Text("Menú Principal")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Este será la pantalla de 'menú principal'",
              style: TextStyle(fontSize: 18),
            ), // Text
            const SizedBox(height: 20),

            //Boton para ir a perfil
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.profile);
              },    
              child: const Text("Ir a Perfil"),
            ),

            const SizedBox(height: 20),

            //Boton para cerrar sesion
            ElevatedButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushReplacementNamed(context, Routes.login);
              },
              child: const Text("Cerrar Sesión"),
            ),
          ],
        ),
      ),
    );
  }
}


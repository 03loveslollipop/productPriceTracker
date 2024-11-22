import 'package:flutter/material.dart';
import '../../class/auth/auth.dart';
import '../auth/login.dart';

class Navbar extends AppBar {

  Navbar({
    super.key, 
    required BuildContext context,
    String title = "Alerta de precios MK"
  }) : super(
          title: Text(
            title,
            style: TextStyle(
              //make it bold
              fontWeight: FontWeight.bold,
              //change text size
              fontSize: 18,
            )
          ),
          centerTitle: true,
          actions: [
            // Sign out button with FutureBuilder
            FutureBuilder<bool>(
              future: AuthService.isSignedIn(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () async {
                      await AuthService.signOut(); // Assuming you have this method
                      //message to user
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sesión cerrada'),
                        ),
                      );
                      // Add navigation or state refresh logic here
                      pushToLogin() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      }

                      pushToLogin();
                    },
                  );
                }
                return SizedBox.shrink(); // Returns empty widget when not signed in
              },
            ),
          ],
        );
}
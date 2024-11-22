import 'package:flutter/material.dart';
import '../navbar/navbar.dart';
import 'signin.dart';
import 'utils.dart';
import '../../class/auth/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Selection/selection.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _emailError = false;
  bool _passwordError = false;

  void pushToSelection() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Selection()),
      (route) => false,
    );
  }

  Future<bool> _validateForm() async {
    setState(() {
      _emailError = validateEmail(_email.text) != null;
      _passwordError = _password.text.isEmpty;
    });

    if (_emailError || _passwordError) {
      print('Error en el formulario');
      //push error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Corrija los errores en el formulario'),
        ),
      );
      return false;
    }
    print('Formulario válido');
    User? user;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Iniciando sesión...'),
          ],
        ),
      ),
    );
    try {
      user = await AuthService.signIn(_email.text, _password.text);
    } on FirebaseAuthException catch (e) {
      print("error relacionado con firebase: ${e.code}");
      if (e.code == 'invalid-credential') {
        //push error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Correo electrónico o contraseña incorrectos'),
          ),
        );
        return false;
      }
    }
    if (user == null) {
      print('Error al iniciar sesión');
      //push error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar sesión'),
        ),
      );
      return false;
    }
    print('Inicio de sesión exitoso');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    const paddingInputs = EdgeInsets.symmetric(horizontal: 40, vertical: 8);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: Navbar(context: context, title: "Iniciar sesión"),
      body: Center(
        child: Container(
          width: 500,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Bienvenido',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Inicia sesión para ver tus alertas de precios',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 400,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: paddingInputs,
                      child: TextField(
                        controller: _email,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Correo electrónico',
                          errorText: _emailError
                              ? 'Correo electrónico inválido'
                              : null,
                        ),
                      ),
                    ),
                    Padding(
                      padding: paddingInputs,
                      child: TextField(
                        controller: _password,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Contraseña',
                          errorText: _passwordError
                              ? 'Contraseña no puede estar vacía'
                              : null,
                        ),
                        obscureText: true,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async{
                  final result = await _validateForm();
                  if (result) {
                    pushToSelection();
                  }
                },
                child: Text('Iniciar sesión'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("¿No tienes una cuenta?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignIn()),
                      );
                      
                    },
                    child: Text('Crear cuenta'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

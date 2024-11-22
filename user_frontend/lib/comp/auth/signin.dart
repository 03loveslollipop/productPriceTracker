import 'package:flutter/material.dart';
import '../navbar/navbar.dart';
import 'login.dart';
import 'utils.dart';
import '../../class/auth/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../selection/selection.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repeatPassword = TextEditingController();
  bool _acceptPolicy = false;

  bool _nameError = false;
  bool _emailError = false;
  bool _passwordError = false;
  bool _repeatPasswordError = false;
  bool _acceptPolicyError = false;

  void pushToSelection() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Selection()),
      (route) => false,
    );
  }

  bool _validateForm() {
    setState(() {
      _nameError = _name.text.isEmpty;
      _emailError = validateEmail(_email.text) != null;
      _passwordError = validatePassword(_password.text) != null;
      _repeatPasswordError = _password.text != _repeatPassword.text;
      _acceptPolicyError = !_acceptPolicy;
    });

    if (_nameError || _emailError || _passwordError || _repeatPasswordError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor corrija los errores del formulario'),
        ),
      );
      return false;
    } else if (_acceptPolicyError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor acepte la política de tratamiento de datos'),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    const paddingInputs = EdgeInsets.symmetric(horizontal: 40, vertical: 8);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor, // Or any color you want
      appBar: Navbar(context: context, title: "Crear cuenta"),
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
              //title
              Text(
                'Bienvenido',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Crea tu cuenta para recibir alertas de precios de tus productos y combinaciones favoritas!',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              //name input
              SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: paddingInputs,
                        child: TextField(
                          controller: _name,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Nombre',
                            errorText:
                                _nameError ? 'El nombre es requerido' : null,
                          ),
                        ),
                      ),
                      Padding(
                        padding: paddingInputs,
                        child: TextField(
                          controller: _email,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Correo electrónico',
                            errorText: _emailError
                                ? validateEmail(_email.text)
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
                                ? validatePassword(_password.text)
                                : null,
                          ),
                          obscureText: true,
                        ),
                      ),
                      Padding(
                        padding: paddingInputs,
                        child: TextField(
                          controller: _repeatPassword,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Repetir contraseña',
                            errorText: _repeatPasswordError
                                ? 'Las contraseñas no coinciden'
                                : null,
                          ),
                          obscureText: true,
                        ),
                      ),
                    ],
                  )),
              //accept data treatment policy
              Padding(
                padding: paddingInputs,
                child: Row(
                  children: [
                    Checkbox(
                      value: _acceptPolicy,
                      onChanged: (value) {
                        setState(() {
                          _acceptPolicy = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _acceptPolicy = !_acceptPolicy;
                          });
                        },
                        child: Text(
                          'Acepto la política de tratamiento de datos',
                          style: TextStyle(
                            fontSize: 10,
                            color: _acceptPolicyError ? Colors.red : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //button to sign in
              ElevatedButton(
                onPressed: () async{
                  if (!_validateForm()) {
                    print("Form is not valid");
                    return;
                  }
                  print("log is valid");
                  //create a spinner
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 20),
                          Text('Creando cuenta...'),
                        ],
                      ),
                    ),
                  );
                  User? user;
                  try{
                    print("Creating user with email: ${_email.text} and password: ${_password.text}");
                    user = await AuthService.createUsr(_email.text, _password.text);
                  }on FirebaseAuthException catch(e){
                    if (e.code == 'weak-password') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('La contraseña es muy débil, recuerde que debe tener al menos 6 caracteres'),
                        ),
                      );
                    } else if (e.code == 'email-already-in-use') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('El correo utilizado ya está en uso, si olvidó su contraseña puede recuperarla'),
                        ),
                      );
                    }
                  }
                  if (user != null) {
                    //remove the spinner
                    pushToSelection();
                  }


                  print(
                      "Sign in with:\nname: ${_name.text}\nemail: ${_email.text}\npassword: ${_password.text}\nrepeat password: ${_repeatPassword.text}\naccept policy: $_acceptPolicy");
                },
                child: Text('Crear cuenta'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Ya tienes una cuenta?"),
                  TextButton(
                    onPressed: () {
                      //reset the stack and push the login screen
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => Login()),
                        (route) => false,
                      );
                    },
                    child: Text('Inicia sesión'),
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

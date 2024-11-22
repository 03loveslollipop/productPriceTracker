import 'package:flutter/material.dart';
import '../navbar/navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../class/auth/auth.dart';

class Selection extends StatefulWidget {
  @override
  _SelectionState createState() => _SelectionState();
}

class _SelectionState extends State<Selection> {
  final _searchController = TextEditingController();
  List<String> selectedProducts = [];
  String searchText = '';
  
  @override
  void initState() {
    super.initState();
    _loadUserTrackings();
  }

  Future<void> _loadUserTrackings() async {
    try {
      final user = await AuthService.currentUser();
      if (user != null) {
        final trackings = await FirebaseFirestore.instance
            .collection('track')
            .where('userId', isEqualTo: user.uid)
            .get();
            
        setState(() {
          selectedProducts = trackings.docs
              .expand((doc) => List<String>.from(doc['products']))
              .toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los seguimientos')),
      );
    }
  }

  Future<void> _saveTrackings() async {
    try {
      final user = await AuthService.currentUser();
      if (user != null) {
        await FirebaseFirestore.instance.collection('track').add({
          'userId': user.uid,
          'products': selectedProducts,
          'createdAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Seguimientos guardados correctamente')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar los seguimientos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: Navbar(context: context, title: "Selecciona tus productos"),
      body: Center(
        child: Container(
          width: 500,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar productos...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Expanded(
                child: Row(
                  children: [
                    // Products list
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('products')
                            .where('name', isGreaterThanOrEqualTo: searchText)
                            .where('name', isLessThan: searchText + 'z')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                          }
                          
                          final products = snapshot.data!.docs;
                          
                          return ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return ListTile(
                                title: Text(product['name']),
                                trailing: IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      selectedProducts.add(product.id);
                                    });
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 20),
                    // Selected products
                    Expanded(
                      child: Column(
                        children: [
                          Text('Productos seleccionados',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: ListView.builder(
                              itemCount: selectedProducts.length,
                              itemBuilder: (context, index) {
                                return FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('products')
                                      .doc(selectedProducts[index])
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return ListTile(title: Text('Cargando...'));
                                    }
                                    
                                    final product = snapshot.data!;
                                    return ListTile(
                                      title: Text(product['name']),
                                      trailing: IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed: () {
                                          setState(() {
                                            selectedProducts.removeAt(index);
                                          });
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTrackings,
                child: Text('Guardar seguimientos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
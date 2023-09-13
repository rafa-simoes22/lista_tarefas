import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'user_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, password TEXT)',
        );
      },
      version: 1,
    );

    final List<Map<String, dynamic>> users = await database.query(
      'users',
      where: 'name = ? AND password = ?',
      whereArgs: [nameController.text, passwordController.text],
    );

    if (users.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login bem-sucedido')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha no login. Verifique suas credenciais.')),
      );
    }
  }

  Future<void> _register(BuildContext context) async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'user_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, password TEXT)',
        );
      },
      version: 1,
    );

    // Verifica se o usuário já existe antes de inserir
    final List<Map<String, dynamic>> existingUsers = await database.query(
      'users',
      where: 'name = ?',
      whereArgs: [nameController.text],
    );

    if (existingUsers.isEmpty) {
      // Se não existir um usuário com o mesmo nome, insira o novo usuário
      await database.insert(
        'users',
        {
          'name': nameController.text,
          'password': passwordController.text,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cadastro realizado com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário já existente. Escolha outro nome de usuário.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro e Login de Usuário'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nome de Usuário',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: () => _register(context),
              child: Text('Cadastro'),
            ),
          ],
        ),
      ),
    );
  }
}

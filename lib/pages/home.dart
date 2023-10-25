import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "NURGENT",
          style: TextStyle(
            color: Color(0xff0d0d0d),
            fontSize: 24,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: const Color(0xffffdc6c),
        elevation: 0,
        centerTitle: true,
      ),
      body: const Center(
        child: Text("Home Page Content"),
      ),
      backgroundColor: const Color(0xffffdc6c),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black54,
              ),
              child: Text("Drawer Header"),
            ),
            ListTile(
              title: const Text("Stats"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Happy Hour"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}



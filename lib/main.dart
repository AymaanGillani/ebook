import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List file = new List();
  List filesOnly = new List();

  @override
  void initState() {
    permission();
    super.initState();
  }

  void _getFilesList() async {
    setState(() {
      file = io.Directory("/storage/emulated/0/").listSync();
    });
  }

  void onlyFiles() {
    int i = 0;
    while (file.isNotEmpty) {
      io.FileSystemEntity entity = file[i % file.length];
      i = i + 1;
      if (entity is io.Link) {
        file.remove(entity);
      } else if (entity is io.File) {
        file.remove(entity);
        if (entity.path.split("/").last.split(".").last.toUpperCase() ==
            "EPUB") {
          filesOnly.add(entity);
        }
      } else if (entity is io.Directory) {
        try {
          file.addAll(entity.listSync());
        } catch (ex) {
          print('catch: ${entity.path}, $ex');
          file.remove(entity);
        }
      }
    }
  }

  void permission() async {
    var status = await Permission.storage.status;
    if (status.isUndetermined) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
    }
    _getFilesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: filesOnly.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Text(filesOnly[index].toString());
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

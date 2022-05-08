import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController note = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextFormField(
                controller: note,
                decoration: const InputDecoration(
                  label: Text("Write a note"),
                ),
                onChanged: (val) {
                  setState(() {
                    note.text = val;
                  });
                },
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(onPressed: () async {
              FirebaseFirestore.instance.collection("notes").add({
                "title": note.text,
              });
              setState(() {
                note.text = "";
              });
            }, child: const Text("Submit")),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("notes")
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasData) {
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    snapshot.data.docs[index]["title"],
                                    style: const TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold),
                                  ),

                                  Row(
                                    children: [
                                      InkWell(
                                          child: const Icon(Icons.delete, color: Colors.red,),
                                      onTap: () async {
                                            var id = snapshot.data.docs[index].id;
                                            FirebaseFirestore.instance.collection("notes").doc(id).delete();
                                      },),
                                      const SizedBox(width: 10,),
                                      InkWell(
                                        child: const Icon(Icons.edit, color: Colors.grey,),
                                        onTap: () async {
                                          setState(() {
                                            note.text = snapshot.data.docs[index]["title"];
                                          });
                                          var id = snapshot.data.docs[index].id;
                                          FirebaseFirestore.instance.collection("notes").doc(id).update({"title": "YoYo"});
                                        },),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          });
                    } else {
                      return const Center(
                        child: Text("No Notes Available"),
                      );
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}

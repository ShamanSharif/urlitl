import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urlitl/controller/data_fetcher.dart';
import 'package:urlitl/model/auth.dart';

class ArchivedScreen extends StatefulWidget {
  const ArchivedScreen({Key? key}) : super(key: key);

  @override
  _ArchivedScreenState createState() => _ArchivedScreenState();
}

class _ArchivedScreenState extends State<ArchivedScreen> {
  final DataFetcher _dataFetcher = DataFetcher();
  CollectionReference docs = FirebaseFirestore.instance.collection('docs');
  Stream<QuerySnapshot>? _docsStream;
  String? userUID;
  bool loading = false;

  @override
  initState() {
    userUID = Provider.of<Auth>(context, listen: false).uid;
    _docsStream = FirebaseFirestore.instance
        .collection('docs')
        .doc(userUID)
        .collection("urlitl")
        .where("archived", isEqualTo: true)
        .snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
    );
  }
}

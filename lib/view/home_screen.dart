import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urlitl/controller/data_fetcher.dart';
import 'package:urlitl/model/auth.dart';
import 'package:urlitl/model/response.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DataFetcher _dataFetcher = DataFetcher();
  TextEditingController inputTextController = TextEditingController();
  TextEditingController shortUrlTextController = TextEditingController();
  CollectionReference docs = FirebaseFirestore.instance.collection('docs');
  final Stream<QuerySnapshot> _docsStream =
      FirebaseFirestore.instance.collection('docs').snapshots();

  String? shortUrl;
  bool loading = false;

  _fetchShortUrl({required String longUrl}) async {
    GoTinyResponse? response = await _dataFetcher.goTiny(longUrl: longUrl);
    if (response != null) {
      setState(() {
        loading = false;
        shortUrl = response.shortUrl;
        shortUrlTextController.text = shortUrl!;
      });
      _pushDataToFireStore(null, response);
    }
  }

  _pushDataToFireStore(String? urlName, GoTinyResponse response) {
    return docs.add({
      'userID': Provider.of<Auth>(context, listen: false).uid,
      'urlName': urlName,
      'longUrl': response.longUrl,
      'shortUrl': response.shortUrl,
    }).then(
      (value) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Synced with Cloud"),
          behavior: SnackBarBehavior.floating,
        ),
      ),
    );
  }

  List<int> line = [1, 2, 3, 4, 5, 6, 7, 8, 9];

  @override
  void dispose() {
    inputTextController.dispose();
    shortUrlTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/images/2.png",
              width: 30,
            ),
            const Text("Urlittl")
          ],
        ),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Color(0xFF3F51B5),
        ),
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            loading ? const LinearProgressIndicator() : const SizedBox(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  color: const Color(0xFF3F51B5),
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: TextFormField(
                            controller: inputTextController,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            keyboardType: TextInputType.url,
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              hintText: "Paste or Write URL",
                              hintStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              isDense: true,
                              filled: true,
                              fillColor: Colors.indigo.shade400,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                        shortUrl != null
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: TextFormField(
                                  controller: shortUrlTextController,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor: Colors.indigo.shade400,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: shortUrl != null
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          FlutterClipboard.copy(
                                                  shortUrlTextController.text)
                                              .then((value) {
                                            FocusManager.instance.primaryFocus!
                                                .unfocus();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content:
                                                    Text("Copied to Clipboard"),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          });
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.teal),
                                        ),
                                        child: const Center(
                                          child: Text("COPY TO CLIPBOARD"),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        FocusManager.instance.primaryFocus!
                                            .unfocus();
                                        setState(() {
                                          inputTextController.text = "";
                                          shortUrlTextController.text = "";
                                          shortUrl = null;
                                        });
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.redAccent),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.backspace_outlined),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                const Color(0xFF646FD8)),
                                      ),
                                      onPressed: () {
                                        FlutterClipboard.paste().then((value) {
                                          FocusManager.instance.primaryFocus!
                                              .unfocus();
                                          setState(() {
                                            inputTextController.text = value;
                                          });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text("Paste From Clipboard"),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        });
                                      },
                                      child: const Center(
                                        child: Icon(Icons.paste),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          FocusManager.instance.primaryFocus!
                                              .unfocus();
                                          setState(() {
                                            loading = true;
                                          });
                                          _fetchShortUrl(
                                              longUrl:
                                                  inputTextController.text);
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color(0xFF6DBAA1)),
                                        ),
                                        child: const Center(
                                          child: Text("Urlittl-it"),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text("Previous UrLittl's"),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _docsStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Something went wrong'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: Text("Loading"));
                    }

                    return ListView(
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        return Dismissible(
                          background: Card(
                            elevation: 0,
                            color: Color(0xFF9CA0FF),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: const [
                                  Icon(
                                    Icons.share,
                                    size: 32,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            ),
                          ),
                          secondaryBackground: Card(
                            elevation: 0,
                            color: const Color(0xFFEB5D63),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: const [
                                  Icon(
                                    Icons.delete,
                                    size: 32,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            ),
                          ),
                          key: ValueKey<String>(document.id),
                          child: Card(
                            elevation: 0,
                            child: ListTile(
                              onTap: () {
                                FlutterClipboard.copy(data['shortUrl'])
                                    .then((value) {
                                  FocusManager.instance.primaryFocus!.unfocus();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Copied to Clipboard"),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                });
                              },
                              onLongPress: () {
                                // TODO: show Modal
                              },
                              title: Text(data['name'] ?? data['longUrl']),
                              subtitle: Text(data['shortUrl']),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

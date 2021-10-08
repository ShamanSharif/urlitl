import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
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
  Stream<QuerySnapshot>? _docsStream;
  String? userUID;
  String? shortUrl;
  bool loading = false;

  @override
  initState() {
    userUID = Provider.of<Auth>(context, listen: false).uid;
    _docsStream = FirebaseFirestore.instance
        .collection('docs')
        .doc(userUID)
        .collection("urlitl")
        .where("archived", isEqualTo: false)
        .snapshots();
    super.initState();
  }

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
    return docs.doc(userUID).collection("urlitl").add({
      'urlName': urlName,
      'longUrl': response.longUrl,
      'shortUrl': response.shortUrl,
      'archived': false,
      'expired': false,
    }).then(
      (value) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Synced with Cloud"),
          behavior: SnackBarBehavior.floating,
        ),
      ),
    );
  }

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
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.archive)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.info)),
        ],
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Color(0xFF3F51B5),
        ),
        actionsIconTheme: const IconThemeData(color: Color(0xFF3F51B5)),
        shadowColor: Colors.transparent,
        backgroundColor: Colors.grey[50],
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _docsStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Something went wrong'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Text("Loading"));
                    }

                    return ListView(
                      children: snapshot.data!.docs.isNotEmpty
                          ? snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                              Map<String, dynamic> data =
                                  document.data()! as Map<String, dynamic>;
                              if (data["archived"] == false) {
                                return Dismissible(
                                  key: ValueKey<String>(document.id),
                                  onDismissed: (direction) {
                                    if (direction ==
                                        DismissDirection.startToEnd) {
                                      docs
                                          .doc(userUID)
                                          .collection("urlitl")
                                          .doc(document.id)
                                          .update({"archived": true});
                                    } else {
                                      docs
                                          .doc(userUID)
                                          .collection("urlitl")
                                          .doc(document.id)
                                          .delete();
                                    }
                                  },
                                  background: Card(
                                    elevation: 0,
                                    color: const Color(0xFFF9F871),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 20.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: const [
                                          Icon(
                                            Icons.archive,
                                            size: 32,
                                            color: Color(0xFF464555),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  secondaryBackground: Card(
                                    elevation: 0,
                                    color: const Color(0xFFEB5D63),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 20.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
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
                                  child: Card(
                                    elevation: 0,
                                    child: ListTile(
                                      onTap: () {
                                        Share.share(data['shortUrl'],
                                            subject: 'Shortened by UrLitl');
                                      },
                                      onLongPress: () {
                                        showModalBottomSheet(
                                          isScrollControlled: true,
                                          context: context,
                                          builder: (context) {
                                            double keyboardHeight =
                                                MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom;

                                            return AnimatedPadding(
                                              padding: EdgeInsets.only(
                                                  bottom: keyboardHeight),
                                              duration:
                                                  Duration(milliseconds: 200),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(25.0),
                                                child: Container(
                                                  height: 300,
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF3F51B5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const TextField(
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                        decoration:
                                                            InputDecoration(
                                                          filled: true,
                                                          fillColor:
                                                              Colors.white10,
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            gapPadding: 2.0,
                                                            borderSide:
                                                                BorderSide(
                                                              color:
                                                                  Colors.white,
                                                              width: 2.0,
                                                            ),
                                                          ),
                                                          border:
                                                              OutlineInputBorder(
                                                            gapPadding: 2.0,
                                                            borderSide:
                                                                BorderSide(
                                                              color:
                                                                  Colors.white,
                                                              width: 2.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const Text(
                                                        "Actual URL",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(data["longUrl"]),
                                                      const Text("Shorted URL"),
                                                      Text(data["shortUrl"]),
                                                      Text(data["archived"]
                                                          .toString()),
                                                      MaterialButton(
                                                        onPressed: () {},
                                                        child: Text("Save"),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          backgroundColor: Colors.white70,
                                          barrierColor: Colors.white70,
                                        );
                                      },
                                      title:
                                          Text(data['name'] ?? data['longUrl']),
                                      subtitle: Text(data['shortUrl']),
                                    ),
                                  ),
                                );
                              } else {
                                return const SizedBox();
                              }
                            }).toList()
                          : [
                              const Icon(
                                Icons.sailing,
                                size: 64.0,
                                color: Colors.grey,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: Text(
                                  "No Short Links",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
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

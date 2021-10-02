import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:urlitl/controller/data_fetcher.dart';
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
    }
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
        title: const Text("Urlittl"),
        shadowColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            loading ? const LinearProgressIndicator() : const SizedBox(),
            Container(
              color: Colors.indigo,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
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
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
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
                                            behavior: SnackBarBehavior.floating,
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
                                    backgroundColor: MaterialStateProperty.all(
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
                                          content: Text("Paste From Clipboard"),
                                          behavior: SnackBarBehavior.floating,
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
                                          longUrl: inputTextController.text);
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.teal),
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
            Expanded(
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}

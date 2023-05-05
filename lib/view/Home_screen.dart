import 'package:chat_app/Authentication/APIs.dart';
import 'package:chat_app/view/profile_screen.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../animation/page_transition_screen.dart';
import '../models/chat_user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? userMap;
  List<Chatuser> _list = [];
  final List<Chatuser> _searchlist = [];
  bool _isSearching = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    FirebaseServices.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name, Email...',
                    ),
                    autofocus: true,
                    style: GoogleFonts.abel(fontSize: 17, letterSpacing: 0.5),
                    onChanged: (val) {
                      _searchlist.clear();
                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchlist.add(i);
                        }
                        setState(() {
                          _searchlist;
                        });
                      }
                    },
                  )
                : Text(
                    'Chaterge',
                    style: GoogleFonts.abel(
                        fontSize: 18,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold),
                  ),
            leading: IconButton(
              icon: const Icon(CupertinoIcons.home),
              onPressed: () async {
                await refreshData();
                // Here you can update the UI after refreshing the data
              },
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled
                      : CupertinoIcons.search)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      SlideTopRightRoute(
                        builder: (context) =>
                            ProfileScreen(user: FirebaseServices.me),
                      ),
                    );
                  },
                  icon: const Icon(CupertinoIcons.ellipsis_vertical)),
            ],
            elevation: 1,
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: FloatingActionButton(
              backgroundColor: Colors.greenAccent,
              onPressed: () {},
              child: const Icon(
                CupertinoIcons.add_circled_solid,
              ),
            ),
          ),
          body: StreamBuilder(
              stream: FirebaseServices.getAllUsers(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  //if some or all data is loaded th show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    _list = data
                            ?.map((e) => Chatuser.fromJson(e.data()))
                            .toList() ??
                        [];

                    if (_list.isNotEmpty) {
                      return Padding(
                        padding: EdgeInsets.only(top: size.height * 0.01),
                        child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _isSearching
                                ? _searchlist.length
                                : _list.length,
                            itemBuilder: (context, index) {
                              return ChatUserCard(
                                  user: _isSearching
                                      ? _searchlist[index]
                                      : _list[index]);
                            }),
                      );
                    } else {
                      return Center(
                        child: Text(
                          "No Connection Found!",
                          style: GoogleFonts.acme(
                            fontSize: 30,
                          ),
                        ),
                      );
                    }
                }
              }),
        ),
      ),
    );
  }
}

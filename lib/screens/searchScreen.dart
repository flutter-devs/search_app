import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:search_app/bloc/userBloc.dart';
import 'package:search_app/models/userModel.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  void initState() {
    fetchUsers();
    super.initState();
  }

  List<UserModel> totalUsers = [];

  void search(String searchQuery) {
    List<UserModel> searchResult = [];

    userBloc.userController.sink.add(null);

    if (searchQuery.isEmpty) {
      userBloc.userController.sink.add(totalUsers);
      return;
    }
    totalUsers.forEach((user) {
      if (user.first.toLowerCase().contains(searchQuery.toLowerCase()) ||
          user.last.toLowerCase().contains(searchQuery.toLowerCase())) {
        searchResult.add(user);
      }
    });
    userBloc.userController.sink.add(searchResult);
  }

  Future<void> fetchUsers() async {
    final url = 'https://randomuser.me/api/?results=100';
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      final Iterable list = body["results"];
      // map each json object to model and addto list and return the list of models
      totalUsers = list.map((model) => UserModel.fromJson(model)).toList();
      userBloc.userController.sink.add(totalUsers);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (text) => search(text),
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.search),
                  hintText: 'Search',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 3.1, color: Colors.red),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            Container(
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.green),
                  ),
                ),
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 10),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Users',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            Expanded(child: usersWidget())
          ],
        ),
      ),
    );
  }

  Widget usersWidget() {
    return StreamBuilder(
      stream: userBloc.userController.stream,
      builder:
          (BuildContext buildContext, AsyncSnapshot<List<UserModel>> snapshot) {
        if (snapshot == null) {
          return CircularProgressIndicator();
        }
        return snapshot.connectionState == ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      leading: Image.network('${snapshot.data[index].picture}'),
                      title: Text(
                        '${snapshot.data[index].first} ${snapshot.data[index].last}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              );
      },
    );
  }
}

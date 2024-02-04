import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchNameQuery = '';
  String searchRegionQuery = '';

  void _updateSearchNameQuery(String newQuery) {
    setState(() {
      searchNameQuery = newQuery.toLowerCase();
    });
  }

  void _updateSearchRegionQuery(String newQuery) {
    setState(() {
      searchRegionQuery = newQuery.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Home', style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w500,
          fontSize: 30,
        )),
      ),
      body: Column(
        children: [
          SearchBar(
            onNameSearchChanged: _updateSearchNameQuery,
            onRegionSearchChanged: _updateSearchRegionQuery,
          ),
          Expanded(child: UserList(searchNameQuery: searchNameQuery, searchRegionQuery: searchRegionQuery)),
        ],
      ),
    );
  }
}


class UserList extends StatelessWidget {
  final String searchNameQuery;
  final String searchRegionQuery;
  UserList({required this.searchNameQuery, required this.searchRegionQuery});

  @override
  Widget build(BuildContext context) {

    Stream<QuerySnapshot> stream = FirebaseFirestore.instance.collection('users').snapshots();


      if (searchNameQuery.isNotEmpty) {
        stream = FirebaseFirestore.instance
            .collection('users')
            .where('name', isEqualTo: searchNameQuery)
            .snapshots();
      } else if (searchRegionQuery.isNotEmpty) {
        if(searchRegionQuery != 'all'){
          stream = FirebaseFirestore.instance
              .collection('users')
              .where('region', isEqualTo: searchRegionQuery)
              .snapshots();
        }
      }




    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No users found.'));
        }

        var filteredDocs = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            var user = filteredDocs[index];
            return UserCard(
              name: user['name'] ?? '',
              email: user['email'] ?? '',
              phone: user['phone'] ?? '',
              avatarUrl: user['avatar'] ?? '',
              region: user['region'] ?? '',
              social: user['social'] ?? '',
              description: user['description'] ?? '',
            );
          },
        );
      },
    );
  }
}
class SearchBar extends StatefulWidget {
  final Function(String) onNameSearchChanged;
  final Function(String) onRegionSearchChanged;

  SearchBar({required this.onNameSearchChanged, required this.onRegionSearchChanged});

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  String? selectedRegion;
  List<String> regions = ['all', 'jedd', 'makkah']; // قائمة المناطق

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search by Name',
              suffixIcon: Icon(Icons.search),
            ),
            onChanged: widget.onNameSearchChanged,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: DropdownButton<String>(
            value: selectedRegion,
            hint: Text('Select a Region'),
            isExpanded: true,
            onChanged: (newValue) {
              setState(() {
                selectedRegion = newValue;
              });
              widget.onRegionSearchChanged(newValue ?? '');
            },
            items: regions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class UserCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String region;
  final String social;
  final String description;

  UserCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.region,
    required this.social,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: ListTile(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(name),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Image.network(avatarUrl, fit: BoxFit.cover),
                      SizedBox(height: 16),
                      Text('Name: $name'),
                      Text('Email: $email'),
                      Text('Phone: $phone'),
                      Text('Region: $region'),
                      Text('Social: $social'),
                      Text('Description: $description'),

                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        leading: CircleAvatar(
          backgroundImage: NetworkImage(avatarUrl),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: $email'),
            Text('Phone: $phone'),
            Text('Region: $region'),
          ],
        ),
      ),
    );
  }
}
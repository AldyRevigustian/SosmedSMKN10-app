import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smkn10sosmed/models/api_response.dart';
import 'package:smkn10sosmed/models/search.dart';
import 'package:smkn10sosmed/models/user.dart';
import 'package:smkn10sosmed/screens/login_screen.dart';
import 'package:smkn10sosmed/screens/main/search/detail_search.dart';
import 'package:smkn10sosmed/services/user_service.dart';
import 'package:smkn10sosmed/widget/constant.dart';

class Search extends StatefulWidget {
  const Search({Key key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController search = new TextEditingController();
  List<dynamic> _searchList = [];

  bool _loading = true;

  void searchU({name = ""}) async {
    ApiResponse response = await searchUser(name);
    if (response.error == null) {
      setState(() {
        // user = response.data;
        _searchList = response.data as List<dynamic>;
        _loading = _loading ? !_loading : _loading;
      });
      print(_searchList);
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false)
          });
    } else {
      kErrorSnackbar(context, '${response.error}');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchU();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          title: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: TextField(
                onChanged: (content) {},
                controller: search,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        // print('oke');

                        searchU(name: search.text);
                        // /* Clear the search field */
                      },
                    ),
                    hintText: 'Search...',
                    border: InputBorder.none),
              ),
            ),
          )),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: _searchList.length,
            itemBuilder: (BuildContext context, int index) {
              SearchModel search = _searchList[index];
              return ListTile(
                  leading: CircleAvatar(
                    radius: 17,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        width: 160,
                        height: 160,
                        imageUrl: baseURLMobile + search.image,
                        placeholder: (context, url) => Center(
                          // child: Image.asset('assets/images/user0.png'),
                          child: Container(
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                  title: Text(
                    "@" + search.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DetailSearch(
                          id: search.id,
                        ),
                      ),
                    );
                  });
            }),
      )),
    );
  }
}

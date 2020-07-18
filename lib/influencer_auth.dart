import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:simple_auth/simple_auth.dart' as simpleAuth;
import 'package:simple_auth_flutter/simple_auth_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class InfluencerPage extends StatefulWidget {
  @override
  _InfluencerPageState createState() => _InfluencerPageState();
}

class _InfluencerPageState extends State<InfluencerPage> {
  int _currentindex = 0;
  final List<Widget> pages = [
    HomePage(),
    AdsPage(),
    MessagePage(),
    ProfilePage()
  ];
  void changePage(int index) {
    setState(() {
      _currentindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
        bottomNavigationBar: BottomNavigationBar(

            backgroundColor: Colors.blueAccent,
            unselectedItemColor: Colors.blue,
            selectedItemColor: Colors.black,
            currentIndex: _currentindex,
            onTap: changePage,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), title: Text('Home')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today), title: Text('Ads')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.message), title: Text('Messages')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), title: Text('Profile')),
            ]),
        
        body: pages[_currentindex]);
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text('Users Home Page',style: TextStyle(fontSize:20,fontWeight: FontWeight.bold,color: Colors.green),),),
    );
  }
}

class MessagePage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          'Your Messages Here',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ),
    );
  }
}

class AdsPage extends StatefulWidget {
  @override
  _AdsPageState createState() => _AdsPageState();
}

class _AdsPageState extends State<AdsPage> {
  final List<dynamic> loadedAds = [];
  var _isinit = true;
  var isLoading = false;
  @override
  Future<void> didChangeDependencies() async {
    if (_isinit) {
      setState(() {
        isLoading = true;
      });
      final url = 'https://adgram-7aac5.firebaseio.com/advertisments.json';
      final response = await http.get(url);
      print(response.body);
      var data = json.decode(response.body);
      data.forEach((ad, adData) {
        loadedAds.add({
          'purpose': adData['purpose'].toString(),
          'average_bid': adData['average_bid'].toString(),
          'total_bid': adData['total_bid'].toString(),
          'description': adData['description'].toString(),
          'followers_needed': adData['followers_needed'].toString(),
          'image_url': adData['image_url'].toString(),
        });
      });
    }

    setState(() {
      isLoading = false;
    });
    _isinit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height:50),
        Expanded(
                  child: ListView.builder(
            itemCount: loadedAds.length,
            itemBuilder: (ctx, i) => Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color.fromRGBO(45, 45, 45, 1)),
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              height: 350,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  
                  Text(
                    'Influencer Needed',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    'Purpose - ' + loadedAds[i]['purpose'],
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                          height: 100,
                          width: 100,
                          child: Image.network(
                            loadedAds[i]['image_url'],
                            fit: BoxFit.contain,
                          )),
                      Icon(
                        Icons.account_circle,
                        size: 50,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            'Followers Needed:',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            loadedAds[i]['followers_needed'],
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )
                        ],
                      )
                    ],
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      
                      loadedAds[i]['description'],
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            'Total Bids:',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            loadedAds[i]['total_bid'],
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            'Average Bids:',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            loadedAds[i]['average_bid'],
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  SharedPreferences prefs;
  static const igClientId = '283315049551141';
  static const igClientSecret = '5b7abbe3748600ab9863bca7d3cc0ef6';
  static const igRedirectURL = 'https://myflutterapp.com/';
  var userName = '';
  var isLoading = false;
  String _errorMsg;
  Map _userData;
  simpleAuth.OAuthAccount user;
  final simpleAuth.InstagramApi _igApi = simpleAuth.InstagramApi(
    "instagram",
    igClientId,
    igClientSecret,
    igRedirectURL,
    scopes: [
      'user_profile', // For getting username, account type, etc.
      'user_media', // For accessing media count & data like posts, videos etc.
    ],
  );
  var isSaved = false;
  var _isinit = true;

  var profile_picture;
  var followers_count;
  var media_count;
  var full_name;
  var account_type;
  var username;
  var biography;
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if (_isinit) {
      setState(() {
        isLoading = true;
      });

      SimpleAuthFlutter.init(context);
      try {
        prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey('userData')) {
          final data = json.decode(prefs.getString('userData'));
          profile_picture = data['profile_picture'].toString();
          followers_count = data['followers_count'].toString();
          media_count = data['media_count'].toString();
          full_name = data['full_name'].toString();
          username = data['username'].toString();
          biography = data['biography'].toString();
          account_type = data['account_type'].toString();
        }
        setState(() {
          isSaved = prefs.containsKey('userData');
          isLoading = false;
        });
      } catch (e) {
        print(e);
      }
    }
    _isinit = false;
  }

  Future<void> loginAndGetData() async {
    _igApi.authenticate().then(
      (simpleAuth.Account _user) async {
        user = _user;

        var igUserResponse =
            await Dio(BaseOptions(baseUrl: 'https://graph.instagram.com')).get(
          '/me',
          queryParameters: {
            // Get the fields you need.
            // https://developers.facebook.com/docs/instagram-basic-display-api/reference/user
            "fields": "username,id,account_type,media_count",
            "access_token": user.token,
          },
        );

        setState(() async {
          isLoading = true;
          _userData = igUserResponse.data;
          userName = _userData['username'].toString();
          saveData();
          _errorMsg = null;
          isLoading = false;
        });
      },
    ).catchError(
      (Object e) {
        setState(() => _errorMsg = e.toString());
      },
    );
  }

  Future<void> saveData() async {
    var userdata1;
    print(_userData.toString());
    try {
      print(userName);
      if (userName != null) {
        final response =
            await http.get('https://api.instagram.com/$userName/?__a=1');
        print(response.body);
        userdata1 = json.decode(response.body);
      } else {}
    } catch (e) {
      print(e);
    }

    final url = 'https://adgram-7aac5.firebaseio.com/influencers.json';
    await http.post(url,
        body: json.encode({
          'username': userdata1['graphql']['user']['username'],
          'account_type': _userData['account_type'],
          'media_count': _userData['media_count'],
          'full_name': userdata1['graphql']['user']['full_name'],
          'profile_picture': userdata1['graphql']['user']['profile_pic_url'],
          'followers_count': userdata1['graphql']['user']['edge_followed_by']
              ['count'],
          'biography': userdata1['graphql']['user']['biography']
        }));
    final saveData = json.encode({
      'username': userdata1['graphql']['user']['username'],
      'account_type': _userData['account_type'],
      'media_count': _userData['media_count'],
      'full_name': userdata1['graphql']['user']['full_name'],
      'profile_picture': userdata1['graphql']['user']['profile_pic_url'],
      'followers_count': userdata1['graphql']['user']['edge_followed_by']
          ['count'],
      'biography': userdata1['graphql']['user']['biography']
    });
    prefs.setString('userData', saveData);
    setState(() {
      isSaved = prefs.containsKey('userData');
      final data = json.decode(prefs.getString('userData'));
      profile_picture = data['profile_picture'].toString();
      followers_count = data['followers_count'].toString();
      media_count = data['media_count'].toString();
      full_name = data['full_name'].toString();
      username = data['username'].toString();
      biography = data['biography'].toString();
      account_type = data['account_type'].toString();
    });
  }

  Future<void> getImage() async {
    final url =
        'https://api.instagram.com/$userName/media?access_token=${user.token}';
    final response = await http.get(url);
    print(user.token);
    print(response.statusCode);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : prefs != null && isSaved
            ? Container(
                alignment: Alignment.center,
                child: Column(
                  
                  children: <Widget>[
                    SizedBox(height:50),
                    SizedBox(height: 20),
                    Text(
                      'Welcome ' + full_name,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color.fromRGBO(45, 45, 45, 1)),
                      height: 200,
                      width: 400,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              CircleAvatar(
                                backgroundImage: NetworkImage(profile_picture),
                                radius: 60,
                              ),
                              Text(username,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,color: Colors.white)),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Icon(Icons.image),
                              Text(media_count,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,color: Colors.white)),
                              Icon(Icons.message),
                              Text(account_type,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,color: Colors.white))
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Icon(Icons.portrait),
                              Text(followers_count,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,color: Colors.white)),
                              Icon(Icons.linked_camera),
                              Text(media_count,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,color: Colors.white)),
                            ],
                          )
                        ],
                      ),
                    ),
                    //FlatButton(child: Text('saveData'),onPressed: saveData,),
                  ],
                ))
            : isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.all(20),
                    height: 400,
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: loginAndGetData,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height:50),
                          Text('Connect with Instagram',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white)),
                          SizedBox(height: 20),
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/ig.jpg'),
                            radius: 80,
                            backgroundColor: Colors.black,
                          )
                        ],
                      ),
                    ),
                  );
  }
}

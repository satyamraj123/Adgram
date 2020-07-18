import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HttpException implements Exception {
  final message;
  HttpException(this.message);
  @override
  String toString() {
    return message;
  }
}

class AdvertiserPage extends StatefulWidget {
  @override
  _AdvertiserPageState createState() => _AdvertiserPageState();
}

class _AdvertiserPageState extends State<AdvertiserPage> {
  int _currentindex = 0;
  final List<Widget> pages = [
    HomePage(),
    AdPage(),
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
    ;
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var isLoading = false;
  final _formkey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  String _userEmail = '';

  String _userPassword = '';
  var _token;
  var _userId;
  var _expiryDate;
  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBPGru-PSqcAKjaKGzxfOPJRDvAWf3rWmw';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      print(json.decode(response.body));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );

      final userAuth = json.encode(
          {'email': _userEmail, 'userId': _userId, 'password': _userPassword});
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userAuth', userAuth);
      responseData['error'] == null
          ? Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (ctx) => AdvertiserPage()),
              (route) => true)
          : null;
    } catch (error) {
      print(error);
      showDialog(
          context: context,
          child: AlertDialog(
            title: Text(error.toString()),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Okay'))
            ],
          ));
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userAuth')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userAuth')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;

    return true;
  }

  void _trySubmit() {
    final isValid = _formkey.currentState.validate();

    FocusScope.of(context).unfocus();

    if (isValid) {
      _formkey.currentState.save();
      if (_isLogin) {
        login(_userEmail, _userPassword);
      } else {
        signup(_userEmail, _userPassword);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 100),
          Container(
            height: 200,
            width: 300,
            child: Image.asset(
              'assets/ad.png',
              fit: BoxFit.fill,
            ),
          ),
          Card(
            margin: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        key: ValueKey('email'),
                        validator: (value) {
                          if (value.isEmpty || !value.contains('@')) {
                            return 'Please enter a valid Email Address';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: 'Email Address'),
                        onSaved: (value) {
                          _userEmail = value;
                        },
                      ),
                      TextFormField(
                        key: ValueKey('password'),
                        controller: _passwordController,
                        validator: (value) {
                          if (value.isEmpty || value.length < 6) {
                            return 'Password must be atleast 6 characters long.';
                          }
                          return null;
                        },
                        obscureText: true,
                        decoration: InputDecoration(labelText: 'Password'),
                        onSaved: (value) {
                          _userPassword = value;
                        },
                      ),
                      if (!_isLogin)
                        TextFormField(
                          key: ValueKey('password'),
                          validator: (value) {
                            if (value.isEmpty || value.length < 6) {
                              return 'Password must be atleast 6 characters long.';
                            } else if (value.toString() !=
                                _passwordController.text.toString()) {
                              return 'Password do not match';
                            }
                            return null;
                          },
                          obscureText: true,
                          decoration:
                              InputDecoration(labelText: 'Confirm Password'),
                          onSaved: (value) {
                            _userPassword = value;
                          },
                        ),
                      SizedBox(
                        height: 12,
                      ),
                      isLoading
                          ? CircularProgressIndicator()
                          : RaisedButton(
                              color: Colors.blue,
                              child: Text(_isLogin ? 'Login' : 'Signup',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              onPressed: _trySubmit,
                            ),
                      FlatButton(
                        textColor: Theme.of(context).primaryColor,
                        child: Text(_isLogin
                            ? 'Haven\'t registered yet? '
                            : 'Already have an Account?'),
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> influencersData = [];
  Map<String, dynamic> test = {};
  var isLoading = false;
  var _isinit = true;
  @override
  Future<void> didChangeDependencies() async {
    if (_isinit) {
      setState(() {
        isLoading = true;
      });
      final response = await http
          .get('https://adgram-7aac5.firebaseio.com/influencers.json');
      final data = json.decode(response.body);
      data.forEach((influencerId, influencerData) {
        influencersData.add({
          'username': influencerData['username'].toString(),
          'account_type': influencerData['account_type'].toString(),
          'media_count': influencerData['media_count'].toString(),
          'full_name': influencerData['full_name'].toString(),
          'profile_picture': influencerData['profile_picture'].toString(),
          'followers_count': influencerData['followers_count'].toString(),
          'biography': influencerData['biography'].toString(),
        });
      });
    }
    print(influencersData.toString());
    setState(() {
      isLoading = false;
    });
    _isinit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading || influencersData.isEmpty
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            children: <Widget>[
              SizedBox(height: 50),
              Text('Influencers List',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold,color:Colors.white)),
              Container(
                height: 640,
                child: ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: influencersData.length,
                  itemBuilder: (ctx, i) => Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
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
                              backgroundImage: NetworkImage(
                                  influencersData[i]['profile_picture']),
                              radius: 60,
                            ),
                            Text(influencersData[i]['username'],
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold,color:Colors.white)),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Icon(Icons.image),
                            Text(influencersData[i]['media_count'],
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold,color:Colors.white)),
                            Icon(Icons.message),
                            Text(influencersData[i]['account_type'],
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold,color:Colors.white))
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Icon(Icons.portrait),
                            Text(influencersData[i]['followers_count'],
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold,color:Colors.white)),
                            Icon(Icons.linked_camera),
                            Text(influencersData[i]['media_count'],
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold,color:Colors.white)),
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

class AdPage extends StatefulWidget {
  @override
  _AdPageState createState() => _AdPageState();
}

class _AdPageState extends State<AdPage> {
  var prefs;
  var isLoading = false;
  List<dynamic> loadedAds = [];
  var _isinit = true;
  @override
  Future<void> didChangeDependencies() async {
    if (_isinit) {
      setState(() {
        isLoading = true;
      });
      prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('advertisments')) {
        setState(() {
          loadedAds = json.decode(prefs.getString('advertisments'))['list'];
        });
      }

      setState(() {
        isLoading = false;
      });
    }

    _isinit = false;
    super.didChangeDependencies();
  }

  void advertise(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            child: NewAdd(),
            behavior: HitTestBehavior.opaque,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        child: Column(
          children: <Widget>[
            SizedBox(height: 50),
            FlatButton(
                color: Color.fromRGBO(45, 45, 45, 1),
                onPressed: () => advertise(context),
                child: Text(
                  'Post New Ad',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                )),
            Container(
              height: 640,
              child: loadedAds.isEmpty
                  ? Container()
                  : isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          itemCount: loadedAds.length,
                          itemBuilder: (ctx, i) => Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Color.fromRGBO(45, 45, 45, 1)),
                                margin: EdgeInsets.all(10),
                                padding: EdgeInsets.all(10),
                                height: 350,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
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
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
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
                              )),
            )
          ],
        ),
      ),
    );
  }
}

class NewAdd extends StatefulWidget {
  @override
  _NewAddState createState() => _NewAddState();
}

class _NewAddState extends State<NewAdd> {
  final _totalBidFocusNode = FocusNode();
  final _averageBidFocusNode = FocusNode();
  final _followersCountFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = true;
  var _isLoading = false;
  var purpose;
  var followersCount;
  var totalBid;
  var averageBid;
  var description;
  var imageUrl =
      'https://www.inventiva.co.in/wp-content/uploads/2020/02/Instagram-Marketing.jpg';
  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _averageBidFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    //List<Map<String, dynamic>> ads = [];
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final url = 'https://adgram-7aac5.firebaseio.com/advertisments.json';

      await http.post(url,
          body: json.encode({
            'purpose': purpose.toString(),
            'average_bid': averageBid.toString(),
            'total_bid': totalBid.toString(),
            'description': description.toString(),
            'followers_needed': followersCount.toString(),
            'image_url': imageUrl.toString(),
          }));

      if (prefs.containsKey('advertisments')) {
        var prevads = json.decode(prefs.getString('advertisments'))['list'];
        prevads.add({
          'purpose': purpose.toString(),
          'average_bid': averageBid.toString(),
          'total_bid': totalBid.toString(),
          'description': description.toString(),
          'followers_needed': followersCount.toString(),
          'image_url': imageUrl.toString(),
        });
        prefs.setString('advertisments', json.encode({'list': prevads}));
      } else {
        var prevads = [
          {
            'purpose': purpose.toString(),
            'average_bid': averageBid.toString(),
            'total_bid': totalBid.toString(),
            'description': description.toString(),
            'followers_needed': followersCount.toString(),
            'image_url': imageUrl.toString(),
          }
        ];
        prefs.setString('advertisments', json.encode({'list': prevads}));
      }
    } catch (e) {
      print(e);

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text('Something went wrong.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (ctx) => AdvertiserPage()));
    /* 
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('An error occurred!'),
                content: Text('Something went wrong.'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Okay'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  )
                ],
              ),
        );
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
    // Navigator.of(context).pop(); */
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _form,
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    initialValue: _initValues['title'],
                    decoration: InputDecoration(labelText: 'Purpose'),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_averageBidFocusNode);
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please provide a value.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      purpose = value;
                    },
                  ),
                  TextFormField(
                    initialValue: _initValues['price'],
                    decoration: InputDecoration(labelText: 'Average Bids'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    focusNode: _averageBidFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_totalBidFocusNode);
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a price.';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number.';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Please enter a number greater than zero.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      averageBid = value;
                    },
                  ),
                  TextFormField(
                    initialValue: _initValues['price'],
                    decoration: InputDecoration(labelText: 'Total Bids'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    focusNode: _totalBidFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context)
                          .requestFocus(_followersCountFocusNode);
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a price.';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number.';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Please enter a number greater than zero.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      totalBid = value;
                    },
                  ),
                  TextFormField(
                    initialValue: _initValues['price'],
                    decoration:
                        InputDecoration(labelText: 'Minimum Followers Needed'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    focusNode: _followersCountFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode);
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a price.';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number.';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Please enter a number greater than zero.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      followersCount = value;
                    },
                  ),
                  TextFormField(
                    initialValue: _initValues['description'],
                    decoration: InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    focusNode: _descriptionFocusNode,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a description.';
                      }
                      if (value.length < 10) {
                        return 'Should be at least 10 characters long.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      description = value;
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        width: 100,
                        height: 100,
                        margin: EdgeInsets.only(
                          top: 8,
                          right: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          ),
                        ),
                        child: _imageUrlController.text.isEmpty
                            ? Text('Enter a URL')
                            : FittedBox(
                                child: Image.network(
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration:
                              InputDecoration(labelText: 'Image URL(optional)'),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          controller: _imageUrlController,
                          focusNode: _imageUrlFocusNode,
                          onFieldSubmitted: (_) {
                            _saveForm();
                          },
                          validator: (value) {
                            if (value.isEmpty) return null;
                            if (!value.startsWith('http') &&
                                !value.startsWith('https')) {
                              return 'Please enter a valid URL.';
                            }
                            if (!value.endsWith('.png') &&
                                !value.endsWith('.jpg') &&
                                !value.endsWith('.jpeg')) {
                              return 'Please enter a valid image URL.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            if (value.isEmpty) {
                            } else {
                              imageUrl = value;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  FlatButton(
                    onPressed: _saveForm,
                    child: Text('Post',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    color: Colors.blue,
                  )
                ],
              ),
            ),
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

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var _isnit = true;
  var isLoading = false;
  var userAuth;
  var prefs;
  @override
  Future<void> didChangeDependencies() async {
    if (_isnit) {
      setState(() {
        isLoading = true;
      });
      prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('userAuth')) {
        userAuth = json.decode(prefs.getString('userAuth'));
      } else {
        userAuth = null;
      }
    }
    setState(() {
      isLoading = false;
    });
    _isnit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: isLoading == false
            ? Column(
                children: <Widget>[
                  SizedBox(height: 100),
                  Text(
                    isLoading || userAuth == null
                        ? 'No Profile'
                        : 'Your Profile:',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color.fromRGBO(45, 45, 45, 1)),
                    height: 200,
                    width: 400,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        
                        Text(
                          'Your Email: ' + userAuth['email'],
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          'Your User Id: ' + userAuth['userId'],
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          'Your Password: ' + userAuth['password'],
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  )
                ],
              )
            : Container(),
      ),
    );
  }
}

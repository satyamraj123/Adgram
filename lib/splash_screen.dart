import 'package:adgram/advertiser_auth.dart';
import 'package:adgram/influencer_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var _isnit = true;
  var isLoading = false;
  var _isLogin = false;
  var prefs;
  @override
  Future<void> didChangeDependencies() async {
    if (_isnit) {
      setState(() {
        isLoading = true;
      });
      prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('userAuth')) {
        _isLogin = true;
      }else{
        _isLogin=false;
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
    return Scaffold(
      body: Container(
          child: Center(
              child: Column(
        children: <Widget>[
          SizedBox(
            height: 80,
          ),
          Container(
            height: 200,
            width: 300,
            child: Image.asset(
              'assets/ad.png',
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(height: 120),
          FlatButton(
            color: Colors.blue,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => InfluencerPage(),
              ));
            },
            child: Text('INFLUENCER',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          SizedBox(
            height: 20,
          ),
          FlatButton(
            color: Colors.green,
            onPressed: () {
              if (_isLogin) {
                !isLoading
                    ? Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AdvertiserPage(),
                      ))
                    : null;
              } else {
                !isLoading
                    ? Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ))
                    : null;
              }
            },
            child: Text('ADVERTISER',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ],
      ))),
    );
  }
}

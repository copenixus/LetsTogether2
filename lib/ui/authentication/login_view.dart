import 'package:flutter/material.dart';
import 'package:letstogether/core/helper/shared_manager.dart';
import 'package:letstogether/core/model/authentication/firebase_auth_error.dart';
import 'package:letstogether/core/model/authentication/firebase_auth_success.dart';
import 'package:letstogether/core/model/authentication/user_request.dart';
import 'package:letstogether/core/model/authentication/users_service.dart';
import 'package:letstogether/core/others/firebase_service.dart';
import 'package:letstogether/core/services/google_signin.dart';
import 'package:letstogether/ui/base/app_localizations.dart';
import 'package:letstogether/ui/other/tabbar_view.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String username;
  String password;
  FirebaseService service = FirebaseService();
  UsersService _usersService = new UsersService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((val) {
      if (SharedManager.instance.getStringValue(SharedKeys.TOKEN).isNotEmpty) {
        navigateToHome();
      }
    });
  }

  GlobalKey<ScaffoldState> scaffold = GlobalKey();
  @override
  Widget build(BuildContext context) {
    // print(SharedManager.instance.getStringValue(SharedKeys.TOKEN));
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "tag",
        child: Icon(Icons.exit_to_app),
        onPressed: () async {
          await GoogleSignHelper.instance.signOut();
        },
      ),
      key: scaffold,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              usernameTextField(),
              emptySizedBox(),
              passwordTextField(),
              emptySizedBox(),
              Wrap(
                spacing: 10,
                children: <Widget>[
                  FloatingActionButton.extended(
                    heroTag: "w10",
                    backgroundColor: Colors.green,
                    label: Text(AppLocalizations.of(context).translate('googleLogin')),
                    icon: Icon(Icons.outlined_flag),
                    onPressed: () async {
                      var data = await GoogleSignHelper.instance.signIn();
                      if (data != null) {
                        var userData =
                        await GoogleSignHelper.instance.firebaseSignin();
                        print(userData);
                        navigateToHome();
                      }
                    },
                  ),
                  customLoginFABButton(context)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void navigateToHome() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => TabbarView()));
  }

  FloatingActionButton customLoginFABButton(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: "tt",
      onPressed: () async {
        var result = await _usersService.postUser(UserRequest(
            email: username, password: password, returnSecureToken: true));

        if (result is FirebaseAuthError) {
          scaffold.currentState.showSnackBar(SnackBar(
            content: Text(result.error.message),
          ));
        } else if(result is FirebaseAuthSuccess) {
          await SharedManager.instance
            .saveString(SharedKeys.TOKEN, result.idToken);
         
          navigateToHome();
        }
      },
      label: Text(AppLocalizations.of(context).translate('login')),
      icon: Icon(Icons.android),
    );
  }

  TextField passwordTextField() {
    return TextField(
      onChanged: (val) {
        setState(() {
          password = val;
        });
      },
      decoration:
      InputDecoration(border: OutlineInputBorder(), 
      labelText: AppLocalizations.of(context).translate('passwordLabel'),
      hintText: AppLocalizations.of(context).translate('passwordHint')
      ),
    );
  }

  SizedBox emptySizedBox() => SizedBox(height: 10);

  TextField usernameTextField() {
    return TextField(
      onChanged: (val) {
        setState(() {
          username = val;
        });
      },
      decoration: InputDecoration(
          border: OutlineInputBorder(), 
          labelText: AppLocalizations.of(context).translate('userNameLabel'),
          hintText: AppLocalizations.of(context).translate('userNameHint'),
    )
    );
  }
}
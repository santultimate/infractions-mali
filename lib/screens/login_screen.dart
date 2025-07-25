import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('login')),
        centerTitle: true,
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : user == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_error != null) ...[
                        Text(_error!, style: TextStyle(color: Colors.red)),
                        SizedBox(height: 16),
                      ],
                      ElevatedButton.icon(
                        icon: Icon(Icons.login),
                        label: Text(tr('login') + ' Google'),
                        onPressed: _signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: Icon(Icons.facebook),
                        label: Text(tr('login') + ' Facebook'),
                        onPressed: _signInWithFacebook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null,
                        child: user.photoURL == null
                            ? Icon(Icons.person, size: 40)
                            : null,
                      ),
                      SizedBox(height: 16),
                      Text('Connecté en tant que'),
                      Text(user.displayName ?? user.email ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: Icon(Icons.logout),
                        label: Text(tr('logout')),
                        onPressed: _signOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _authService.signInWithGoogle();
      setState(() {});
    } catch (e) {
      setState(() {
        _error = 'Erreur Google: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _authService.signInWithFacebook();
      setState(() {});
    } catch (e) {
      setState(() {
        _error = 'Erreur Facebook: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _authService.signOut();
      setState(() {});
    } catch (e) {
      setState(() {
        _error = 'Erreur déconnexion: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

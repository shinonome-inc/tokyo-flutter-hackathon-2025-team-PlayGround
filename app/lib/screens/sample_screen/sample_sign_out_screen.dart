import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

/// ログアウト画面
class SampleSignOutScreen extends StatefulWidget {
  const SampleSignOutScreen({super.key});

  @override
  State<SampleSignOutScreen> createState() => _SampleSignOutScreenState();
}

class _SampleSignOutScreenState extends State<SampleSignOutScreen> {
  bool _isLoading = false;
  bool _isSignedIn = false;
  String _message = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  /// 現在の認証状態を確認する
  Future<void> _checkAuthStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();
        setState(() {
          _isSignedIn = true;
          _userEmail = user.username;
        });
      } else {
        setState(() {
          _isSignedIn = false;
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _message = 'エラー: ${e.message}';
        _isSignedIn = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// ログアウトを行う
  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await Amplify.Auth.signOut();
      setState(() {
        _isSignedIn = false;
        _userEmail = '';
        _message = 'ログアウトしました';
      });
    } on AuthException catch (e) {
      setState(() {
        _message = 'エラー: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// グローバルログアウトを行う（全デバイスからログアウト）
  Future<void> _globalSignOut() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await Amplify.Auth.signOut(
        options: const SignOutOptions(globalSignOut: true),
      );
      setState(() {
        _isSignedIn = false;
        _userEmail = '';
        _message = '全デバイスからログアウトしました';
      });
    } on AuthException catch (e) {
      setState(() {
        _message = 'エラー: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ログアウト'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            if (_isLoading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (_isSignedIn) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.account_circle, size: 64),
                      const SizedBox(height: 16),
                      const Text('ログイン中'),
                      const SizedBox(height: 8),
                      Text(
                        _userEmail,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _signOut,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('ログアウト'),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _globalSignOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('全デバイスからログアウト'),
                ),
              ),
            ] else ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.account_circle_outlined, size: 64),
                      SizedBox(height: 16),
                      Text('ログインしていません'),
                    ],
                  ),
                ),
              ),
            ],
            if (_message.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                _message,
                style: TextStyle(
                  color: _message.startsWith('エラー') ? Colors.red : Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:app/config/amplify_initializer.dart';
import 'package:flutter/foundation.dart';

/// プラットフォームに応じたコールバックURLを取得する
String _getSignInRedirectURI() {
  if (kIsWeb) {
    return 'https://genkaimeshi-recipe-web-dev.s3.ap-northeast-1.amazonaws.com/';
  } else {
    return 'myapp://callback';
  }
}

String _getSignOutRedirectURI() {
  if (kIsWeb) {
    return 'https://genkaimeshi-recipe-web-dev.s3.ap-northeast-1.amazonaws.com/';
  } else {
    return 'myapp://logout';
  }
}

/// 環境に応じたAmplifyの設定を生成する。
String get amplifyconfig {
  final signInRedirectURI = _getSignInRedirectURI();
  final signOutRedirectURI = _getSignOutRedirectURI();

  return '''
{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify-cli/0.1.0",
        "Version": "0.1.0",
        "IdentityManager": {
          "Default": {}
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "${currentEnv.cognitoUserPoolId}",
            "AppClientId": "${currentEnv.cognitoAppClientId}",
            "Region": "${currentEnv.awsRegion}"
          }
        },
        "CredentialsProvider": {
          "CognitoIdentity": {
            "Default": {
              "PoolId": "${currentEnv.cognitoIdentityPoolId}",
              "Region": "${currentEnv.awsRegion}"
            }
          }
        },
        "Auth": {
          "Default": {
            "OAuth": {
              "WebDomain": "${currentEnv.cognitoDomain}.auth.${currentEnv.awsRegion}.amazoncognito.com",
              "AppClientId": "${currentEnv.cognitoAppClientId}",
              "SignInRedirectURI": "$signInRedirectURI",
              "SignOutRedirectURI": "$signOutRedirectURI",
              "Scopes": ["openid", "email", "profile"]
            },
            "authenticationFlowType": "USER_SRP_AUTH",
            "socialProviders": ["GOOGLE"],
            "usernameAttributes": ["EMAIL"],
            "signupAttributes": ["EMAIL"],
            "passwordProtectionSettings": {
              "passwordPolicyMinLength": 8,
              "passwordPolicyCharacters": [
                "REQUIRES_LOWERCASE",
                "REQUIRES_UPPERCASE",
                "REQUIRES_NUMBERS"
              ]
            },
            "mfaConfiguration": "OPTIONAL",
            "mfaTypes": ["TOTP"]
          }
        }
      }
    }
  },
  "storage": {
    "plugins": {
      "awsS3StoragePlugin": {
        "bucket": "${currentEnv.s3BucketName}",
        "region": "${currentEnv.awsRegion}"
      }
    }
  }
}''';
}

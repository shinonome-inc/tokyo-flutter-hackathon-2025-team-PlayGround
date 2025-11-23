import 'package:app/config/env.dart';

/// 環境に応じたAmplifyの設定を生成する。
String get amplifyconfig =>
    '''
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
        "Auth": {
          "Default": {
            "OAuth": {
              "WebDomain": "${currentEnv.cognitoDomain}.auth.${currentEnv.awsRegion}.amazoncognito.com",
              "AppClientId": "${currentEnv.cognitoAppClientId}",
              "SignInRedirectURI": "myapp://callback",
              "SignOutRedirectURI": "myapp://logout",
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
  }
}''';

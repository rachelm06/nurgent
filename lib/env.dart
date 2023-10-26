import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: 'secret.env') //Path of your secret.env file
abstract class Env {
  @EnviedField(varName: 'MAPSAPIKEY', obfuscate: true)
  static String myApiKey = _Env.myApiKey;
}

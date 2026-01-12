final Env env = Env.fromDefine();

class Env {
  final String host;
  final String user;
  final String password;
  final String version;

  Env(
      {required this.host,
      required this.user,
      required this.password,
      required this.version});

  static const String _appEnv =
      String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  static const String _apiHost =
      String.fromEnvironment('API_HOST', defaultValue: '');
  static const String _appVersion =
      String.fromEnvironment('APP_VERSION', defaultValue: '');

  static Env fromDefine() {
    final base = _appEnv.toLowerCase() == 'prod' ? Env.prod : Env.dev;

    final overrideHost = _apiHost.trim();
    final overrideVersion = _appVersion.trim();

    return Env(
      host: overrideHost.isNotEmpty ? overrideHost : base.host,
      user: base.user,
      password: base.password,
      version: overrideVersion.isNotEmpty ? overrideVersion : base.version,
    );
  }

  static final dev = Env(
      host: 'https://wyread.tocmcc.cn',
      user: 'wannayoung',
      password: '',
      version: '0.0.1');

  static final prod =
      Env(host: '', user: '', password: '', version: '0.1.1-202601051');
}

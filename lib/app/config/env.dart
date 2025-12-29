final Env env = Env.dev;

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

  static final dev = Env(
      host: 'https://wyread.tocmcc.cn',
      user: 'wannayoung',
      password: '52111314',
      version: '0.0.1');

  static final prod =
      Env(host: 'https://', user: '', password: '', version: '0.0.1-202505291');
}

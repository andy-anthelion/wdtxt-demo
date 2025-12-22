import 'dart:math';

class RandomService {

  RandomService({
    String? nonceLetters,
    int? nonceLength,
  }):
  _nonceLetters = nonceLetters ?? "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz-",
  _nonceLength = nonceLength ?? 9;

  final String _nonceLetters;
  final int _nonceLength;

  Future<String> generateNonce() async {
    final len = _nonceLetters.length;
    String nonce = '';
    final random = Random.secure();
    var size = _nonceLength;
    while (0 < size--) {
      nonce += _nonceLetters[random.nextInt(len)];
    }
    return nonce;
  }

}
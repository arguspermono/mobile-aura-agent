import 'dart:async';

class FcmService {
  FcmService._();

  static final FcmService instance = FcmService._();

  final StreamController<String> _messageController = StreamController<String>.broadcast();

  Stream<String> get messages => _messageController.stream;

  void publishClaimUpdate(String message) {
    _messageController.add(message);
  }

  void dispose() {
    _messageController.close();
  }
}

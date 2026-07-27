class Session {
  final String sessionId;
  final String userId;
  final DateTime loginTime;
  final DateTime lastActivity;
  final String deviceName;
  final bool isLocked;

  const Session({
    required this.sessionId,
    required this.userId,
    required this.loginTime,
    required this.lastActivity,
    required this.deviceName,
    this.isLocked = false,
  });

  Duration get duration => DateTime.now().difference(loginTime);
  Duration get idleTime => DateTime.now().difference(lastActivity);

  Session copyWith({
    String? sessionId,
    String? userId,
    DateTime? loginTime,
    DateTime? lastActivity,
    String? deviceName,
    bool? isLocked,
  }) {
    return Session(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      loginTime: loginTime ?? this.loginTime,
      lastActivity: lastActivity ?? this.lastActivity,
      deviceName: deviceName ?? this.deviceName,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

void _startCountdown() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? loginTimeStr = prefs.getString('loginTime');

  if (loginTimeStr == null) return;

  DateTime loginTime = DateTime.parse(loginTimeStr);
  Duration totalDuration = const Duration(minutes: 6); // session duration

  countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    final now = DateTime.now();
    final elapsed = now.difference(loginTime);
    final remaining = totalDuration - elapsed;

    if (remaining.isNegative) {
      setState(() {
        countdownText = "Session expired!";
      });
      timer.cancel();

      // Optional: Auto logout
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
    } else {
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes % 60;
      final seconds = remaining.inSeconds % 60;

      // Notify at 5 min left
      if (!notified5MinLeft && remaining.inMinutes == 5) {
        _send5MinuteWarning();
        notified5MinLeft = true;
      }

      setState(() {
        countdownText = "App closing in: ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
      });
    }
  });
}

void _send5MinuteWarning() {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("⏰ App will close in 5 minutes!")),
  );
}
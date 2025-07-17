import 'package:flutter/material.dart';
import 'pumps_map_screen.dart';
import 'inapp_webview_screen.dart';


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> messages = [];
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> englishMessages = [
    {'text': "Hello, welcome to My Jio BP Customer App.", 'isBot': true},
    {'text': "I am Tia, how may I assist you today? 😄", 'isBot': true},
  ];

  final List<Map<String, dynamic>> hindiMessages = [
    {'text': "नमस्ते, माय जिओ बीपी कस्टमर ऐप में आपका स्वागत है।", 'isBot': true},
    {'text': "मैं टिया हूँ, मैं आपकी कैसे मदद कर सकती हूँ? 😄", 'isBot': true},
  ];


  final TextEditingController _controller = TextEditingController();
  bool isTyping = false;
  bool showChips = false;
  bool isHindi = false;

  String chipCategory = 'main'; // 'main', 'fuel', 'payment', etc.

  final List<String> mainChipsEnglish = [
    "Fuel Related Issues",
    "Payment Related Issues",
    "Customer Support & Help",
    "Rewards & Programs",
    "Services & Others",
    "भाषा बदलों",
  ];

  final List<String> mainChipsHindi = [
    "ईंधन से संबंधित समस्याएं",
    "भुगतान से संबंधित समस्याएं",
    "ग्राहक सहायता और मदद",
    "रिवॉर्ड्स और प्रोग्राम्स",
    "सेवाएं और अन्य",
    "भाषा बदलों", // Keep this as "भाषा बदलों" in both for toggle
  ];


  @override
  void initState() {
    super.initState();
    _showDefaultMessages();
  }

  Future<void> _showDefaultMessages() async {
    final msgs = isHindi ? hindiMessages : englishMessages;

    for (var msg in msgs) {
      setState(() {
        isTyping = true;
      });

      await Future.delayed(Duration(seconds: 2));

      setState(() {
        isTyping = false;
        messages.add(msg);
      });

      _scrollToBottom();
      await Future.delayed(Duration(milliseconds: 500));
    }

    setState(() {
      showChips = true;
      chipCategory = 'main';
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00993A), // Jio BP Green
        iconTheme: const IconThemeData(color: Colors.white), // Makes icons white
        title: Row(
          children: [
            Image.asset(
              'assets/images/tia.png',
              height: 35,
            ),
            const SizedBox(width: 10),
            const Text(
              "Tia",
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),

      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                    message['isBot'] ? MainAxisAlignment.start : MainAxisAlignment.end,
                    children: [
                      // Show avatar only for bot messages
                      if (message['isBot']) ...[
                        const CircleAvatar(
                          radius: 18,
                          backgroundImage: AssetImage("assets/images/tia.png"),
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Message bubble
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: message['isBot']
                                ? Colors.white
                                : const Color(0xFF00993A),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4),
                            ],
                          ),
                          child: Text(
                            message['text'],
                            style: TextStyle(
                              color: message['isBot'] ? Colors.black87 : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );

              },
            ),


    ),
          if (isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 10),
              child: TypingIndicator(),
            ),

          // Option Chips
          if (showChips && chipCategory == 'main')
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...(isHindi ? mainChipsHindi : mainChipsEnglish)
                      .map((label) => _buildMainChip(label))
                      .toList(),
                ],
              ),
            )

          else if (chipCategory == 'fuel')
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildFollowUpChip(isHindi ? "रीफिल बुक करें" : "Book Refill"),
                  _buildFollowUpChip(isHindi ? "नज़दीकी पंप खोजें" : "Find Pumps near me"),
                  _buildFollowUpChip(isHindi ? "वर्तमान ईंधन कीमतें" : "Current Fuel Prices"),
                  _buildFollowUpChip(isHindi ? "ईंधन बुकिंग रद्द करें" : "Cancel Fuel Booking"),
                  _buildFollowUpChip(isHindi ? "वापस जाएं" : "Move back"),
                ],
              ),
            )

          else if (chipCategory == 'payment')
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildFollowUpChip(isHindi ? "वॉलेट रिचार्ज करें" : "Recharge Wallet"),
                    _buildFollowUpChip(isHindi ? "भुगतान विधि अपडेट करें" : "Update Payment Method"),
                    _buildFollowUpChip(isHindi ? "लेनदेन इतिहास दिखाएं" : "Show Transactions History"),
                    _buildFollowUpChip(isHindi ? "अन्य" : "Others"),
                    _buildBackToMainChip(), // This will work as it is because the label is inside the function
                  ],
                ),
              )

            else if (chipCategory == 'customer_support')
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildCustomerSupportChip(isHindi ? "हाँ" : "Yes"),
                      _buildCustomerSupportChip(isHindi ? "नहीं" : "No"),
                      _buildBackToMainChip(),
                    ],
                  ),
                ),



          // Input Field
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white, // 🔵 White background for input area
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.grid_view, color: Color(0xFF00993A)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF00993A)),
                      onPressed: () {
                        if (_controller.text.trim().isNotEmpty) {
                          setState(() {
                            messages.add({
                              'text': _controller.text.trim(),
                              'isBot': false,
                            });
                          });
                          _controller.clear();
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          )

        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          messages.add({
            'text': label,
            'isBot': false,
          });
        });
      },
      child: Chip(
        backgroundColor: Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(color: Color(0xFF00993A)),
        ),
        label: Text(
          label,
          style: const TextStyle(color: Color(0xFF00993A)),
        ),
      ),
    );
  }
  Widget _buildMainChip(String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          messages.add({'text': label, 'isBot': false});  // User message (once for all labels)

          if ((isHindi && label == "ईंधन से संबंधित समस्याएं") || (!isHindi && label == "Fuel Related Issues")) {
            sendBotMessage(isHindi ? "ईंधन से संबंधित आपकी कौन सी समस्या है?" : "What issue do you have related to Fuel?")
                .then((_) {
              setState(() {
                chipCategory = 'fuel'; // Show fuel chips after Tia's message
              });
            });
          }

          else if ((isHindi && label == "भुगतान से संबंधित समस्याएं") || (!isHindi && label == "Payment Related Issues")) {
            sendBotMessage(isHindi ? "कृपया भुगतान से संबंधित समस्या चुनें।" : "Sure! What kind of payment issue are you facing?")
                .then((_) {
              setState(() {
                chipCategory = 'payment';
              });
            });
          }
          else if ((isHindi && label == "ग्राहक सहायता और मदद") || (!isHindi && label == "Customer Support & Help")) {
            sendBotMessage(isHindi
                ? "क्या आप चाहते हैं कि हमारा ग्राहक सेवा कार्यकारी आपसे संपर्क करे?"
                : "Do you want our Customer Support Executive to contact you?"
            ).then((_) {
              setState(() {
                chipCategory = 'customer_support';
              });
            });

          } else if ((isHindi && label == "रिवॉर्ड्स और प्रोग्राम्स") || (!isHindi && label == "Rewards & Programs")) {
            sendBotMessage(isHindi
                ? "जरूर, हम आपको रिवॉर्ड्स और प्रोग्राम्स स्क्रीन पर ले जा रहे हैं..."
                : "Sure, we are redirecting you to Rewards & Programs screen..."
            ).then((_) {
              Future.delayed(Duration(seconds: 2), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InAppWebViewScreen(
                      url: "https://www.jiobp.com/products-and-services/jio-bp-4ever",
                      title: isHindi ? "रिवॉर्ड्स और ऑफर्स" : "Rewards & Offers",
                    ),
                  ),
                );
              });
            });

          } else if ((isHindi && label == "सेवाएं और अन्य") || (!isHindi && label == "Services & Others")) {
            sendBotMessage(isHindi
                ? "जरूर, हम आपको हमारी सेवाओं की स्क्रीन पर ले जा रहे हैं..."
                : "Sure, we are redirecting you to our Services screen..."
            ).then((_) {
              Future.delayed(Duration(seconds: 2), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InAppWebViewScreen(
                      url: "https://www.jiobp.com/",
                      title: isHindi ? "सेवाएं" : "Services",
                    ),
                  ),
                );
              });
            });
          }
          if (label == "भाषा बदलों") {
            setState(() {
              isHindi = !isHindi; // Toggle language
                // Clear chat
              showChips = false;  // Hide chips temporarily
            });

            sendBotMessage(isHindi ? "आपकी भाषा बदल दी गई है।" : "Language changed back to English.")
                .then((_) => _showDefaultMessages());
          }






          // Other categories...
        });
        _scrollToBottom();
      },
      child: Chip(
        backgroundColor: Colors.transparent,
        shape: StadiumBorder(side: BorderSide(color: Color(0xFF00993A))),
        label: Text(label, style: const TextStyle(color: Color(0xFF00993A))),
      ),
    );
  }

  Future<void> sendBotMessage(String text) async {
    setState(() {
      isTyping = true;
    });

    await Future.delayed(const Duration(seconds: 1)); // 👈 typing delay

    setState(() {
      isTyping = false;
      messages.add({'text': text, 'isBot': true});
    });

    _scrollToBottom();

    return Future.value();
  }


  Widget _buildFollowUpChip(String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          messages.add({'text': label, 'isBot': false});

          // Handle 'Move back' (Hindi + English)
          if ((!isHindi && label == "Move back") || (isHindi && label == "वापस जाएं")) {
            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() {
                messages.add({
                  'text': isHindi
                      ? "ज़रूर, कृपया एक श्रेणी चुनें।"
                      : "Sure, please choose a category again.",
                  'isBot': true
                });
                chipCategory = 'main';
              });
              _scrollToBottom();
            });
          }

          // Handle 'Find Pumps near me'
          else if ((!isHindi && label == "Find Pumps near me") || (isHindi && label == "नज़दीकी पंप खोजें")) {
            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() {
                messages.add({
                  'text': isHindi
                      ? "आपको नजदीकी पंप्स की जानकारी दी जा रही है... 🗺️"
                      : "Redirecting you to nearby pumps... 🗺️",
                  'isBot': true,
                });
              });
              _scrollToBottom();

              Future.delayed(const Duration(milliseconds: 1000), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PumpsMapScreen()),
                );
              });
            });
          }

          // Handle 'Book Refill' or 'Cancel Fuel Booking'
          else if ((!isHindi && (label == "Book Refill" || label == "Cancel Fuel Booking")) ||
              (isHindi && (label == "रीफिल बुक करें" || label == "ईंधन बुकिंग रद्द करें"))) {
            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() {
                messages.add({
                  'text': isHindi
                      ? "आपने $label चुना है। मैं आपकी सहायता करूंगा। 🚀"
                      : "You selected $label. Let me help you with that! 🚀",
                  'isBot': true
                });
              });
              _scrollToBottom();

              Future.delayed(const Duration(milliseconds: 800), () {
                setState(() {
                  messages.add({
                    'text': isHindi
                        ? "$label फ़ंक्शन जल्द ही उपलब्ध होगा। 🚧"
                        : "$label function coming soon. 🚧",
                    'isBot': true
                  });
                });
                _scrollToBottom();
              });
            });
          }

          // Default case
          else {
            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() {
                messages.add({
                  'text': isHindi
                      ? "आपने $label चुना है। मैं आपकी सहायता करूंगा। 🚀"
                      : "You selected $label. Let me help you with that! 🚀",
                  'isBot': true
                });
              });
              _scrollToBottom();
            });
          }
        });
      },
      child: Chip(
        backgroundColor: Colors.transparent,
        shape: const StadiumBorder(side: BorderSide(color: Color(0xFF00993A))),
        label: Text(label, style: const TextStyle(color: Color(0xFF00993A))),
      ),
    );
  }



  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildBackToMainChip() {
    return GestureDetector(
      onTap: () {
        setState(() {
          chipCategory = 'main';
        });
      },
      child: Chip(
        backgroundColor: Colors.transparent,
        shape: StadiumBorder(side: BorderSide(color: Color(0xFF00993A))),
        label: Text("⬅️ Move Back", style: const TextStyle(color: Color(0xFF00993A))),
      ),
    );
  }


  Widget _buildCustomerSupportChip(String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          messages.add({'text': label, 'isBot': false});
          if (label == "Yes") {
            messages.add({
              'text':
              "Sure, we have forwarded your request to our Customer Service Executive. They will contact you very soon.",
              'isBot': true
            });
            _scrollToBottom();
            showChips = false;
          } else if (label == "No") {
            messages.add({
              'text':
              "No problem! Let me know if you need help with anything else 😊",
              'isBot': true
            });
            _scrollToBottom();
            chipCategory = 'main'; // return to main options
          }
        });
        _scrollToBottom();
      },
      child: Chip(
        backgroundColor: Colors.transparent,
        shape: StadiumBorder(side: BorderSide(color: Color(0xFF00993A))),
        label: Text(label, style: const TextStyle(color: Color(0xFF00993A))),
      ),
    );
  }


}

class TypingIndicator extends StatefulWidget {
  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();

    _dotCount = IntTween(begin: 1, end: 3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotCount,
      builder: (context, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage("assets/images/tia.png"),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00993A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "Typing${'.' * (_dotCount.value)}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


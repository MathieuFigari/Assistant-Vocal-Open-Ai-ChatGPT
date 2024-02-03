import 'package:nicole/feature_box.dart';
import 'package:nicole/openai_service.dart';
import 'package:nicole/pallete.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;
  bool isPromptRecorded = false;
  bool isLoading = false;
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
    flutterTts.setStartHandler(() {
      setState(() {
        isSpeaking = true;
      });
    });
    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  void downloadFile(String url) async {
    try {
      await FileDownloader.downloadFile(
          url: url, notificationType: NotificationType.all);
    } catch (e) {
      print('Download error: $e');
    }
  }

  Future<void> startListening() async {
    print('isPromptRecorded: $isPromptRecorded');
    await speechToText.listen(
        onResult: onSpeechResult, listenFor: const Duration(minutes: 2));
    setState(() {
      isPromptRecorded = false;
    });
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    print('isPromptRecorded: $isPromptRecorded');
    print('Result: ${result.recognizedWords}');
    setState(() {
      lastWords = result.recognizedWords;
      isPromptRecorded = true;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          child: const Text(
            'Nicole',
            style: TextStyle(fontSize: 38),
          ),
        ),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Transform.translate(
                      offset: const Offset(0, 0),
                      child: Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(1),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(4, 8),
                            ),
                          ],
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/images/AvatarMaker.png',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            isLoading
                ? Center(child: LoadingDots())
                : Column(
                    children: [
                      // virtual assistant picture

                      // chat bubble
                      FadeInRight(
                        child: Visibility(
                          visible: generatedImageUrl == null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 40)
                                .copyWith(
                              top: 30,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Pallete.borderColor,
                              ),
                              borderRadius: BorderRadius.circular(20).copyWith(
                                topLeft: Radius.zero,
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Text(
                                generatedContent == null
                                    ? 'Bonjour ! Comment puis-je vous aider ?'
                                    : generatedContent!,
                                style: TextStyle(
                                  fontFamily: 'Cera Pro',
                                  color: Pallete.mainFontColor,
                                  fontSize: generatedContent == null ? 25 : 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (generatedImageUrl != null)
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(generatedImageUrl!),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    downloadFile(generatedImageUrl!),
                                child: const Text('Télécharger l\'image'),
                              ),
                            ],
                          ),
                        ),
                      SlideInLeft(
                        child: Visibility(
                          visible: generatedContent == null &&
                              generatedImageUrl == null,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.only(top: 10, left: 22),
                          ),
                        ),
                      ),
                      // features list
                      Visibility(
                        visible: generatedContent == null &&
                            generatedImageUrl == null,
                        child: Column(
                          children: [
                            SlideInLeft(
                              delay: Duration(milliseconds: start),
                              child: FeatureBox(
                                color: Pallete.firstSuggestionBoxColor,
                                headerText: 'ChatGPT',
                                descriptionText:
                                    'Nicole est capable de répondre à vos questions et de vous aider à résoudre des problèmes avec ChatGPT',
                                boxShadow: BoxShadow(
                                  color: Colors.grey.withOpacity(1),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(5, 10),
                                ),
                                border:
                                    Border.all(color: Colors.black, width: 3),
                              ),
                            ),
                            SlideInLeft(
                              delay: Duration(milliseconds: start + delay),
                              child: FeatureBox(
                                color: Pallete.secondSuggestionBoxColor,
                                headerText: 'Dall-E',
                                descriptionText:
                                    'Laissez-vous inspirer et restez créatif avec Nicole qui utilisera Dall-E Pour Créer des Images Uniques Pour Vous',
                                boxShadow: BoxShadow(
                                  color: Colors.grey.withOpacity(1),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(5, 10),
                                ),
                                border:
                                    Border.all(color: Colors.black, width: 3),
                              ),
                            ),
                            SlideInLeft(
                              delay: Duration(milliseconds: start + 2 * delay),
                              child: FeatureBox(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromRGBO(165, 231, 244, 1),
                                    Color.fromRGBO(162, 238, 239, 1),
                                  ],
                                ),
                                headerText: 'Assistant vocal intelligent',
                                descriptionText:
                                    'Obtenez le meilleur des deux mondes avec Nicole qui deviendra votre meilleure amie',
                                boxShadow: BoxShadow(
                                  color: Colors.grey.withOpacity(1),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(5, 10),
                                ),
                                border:
                                    Border.all(color: Colors.black, width: 3),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
          ],
        ),
      ),
      floatingActionButton: isLoading
          ? null
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isPromptRecorded)
                  FloatingActionButton(
                    backgroundColor: Pallete.secondSuggestionBoxColor,
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      final speech =
                          await openAIService.isArtPromptAPI(lastWords);
                      if (speech.contains('https')) {
                        generatedImageUrl = speech;
                        generatedContent = null;
                        setState(() {});
                      } else {
                        generatedImageUrl = null;
                        generatedContent = speech;
                        setState(() {});
                        await systemSpeak(speech);
                      }
                      setState(() {
                        lastWords = '';
                        isPromptRecorded = false;
                        isLoading = false;
                      });
                    },
                    child: const Icon(Icons.send),
                  ),
                const SizedBox(width: 10),
                isSpeaking
                    ? FloatingActionButton(
                        backgroundColor: Pallete.secondSuggestionBoxColor,
                        onPressed: () async {
                          await flutterTts.stop();
                          setState(() {
                            isSpeaking = false;
                          });
                        },
                        child: const Icon(Icons.stop),
                      )
                    : FloatingActionButton(
                        backgroundColor: speechToText.isListening
                            ? Colors.green
                            : Colors.blue,
                        onPressed: speechToText.isListening
                            ? null
                            : () async {
                                if (await speechToText.hasPermission &&
                                    speechToText.isNotListening) {
                                  await startListening();
                                } else if (speechToText.isListening) {
                                  await stopListening();
                                } else {
                                  initSpeechToText();
                                }
                              },
                        child: Icon(
                          Icons.mic,
                          color: speechToText.isListening
                              ? Colors.black
                              : Colors
                                  .white, // Change icon color based on listening state
                        ),
                      ),
              ],
            ),
    );
  }
}

class LoadingDots extends StatefulWidget {
  @override
  _LoadingDotsState createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        String text = 'Je réfléchis';
        int value = (controller.value * 4).floor();
        for (int i = 0; i < value; i++) {
          text += '.';
        }
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}

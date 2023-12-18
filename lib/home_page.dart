import 'package:allen/features_box.dart';
import 'package:allen/openai_service.dart';
import 'package:allen/pallete.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';



class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200 ;
  int delay = 200 ;
  late SharedPreferences prefs;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int maxAttempts = 3;
  int minutesToWait = 1;


  @override
  void initState() {
    super.initState();
    initSharedPreferences();
  }
  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }




  Future<void> _startListening() async {
    int attempts = prefs.getInt('attempts') ?? 0;
    int lastAttemptTimestamp = prefs.getInt('lastAttemptTimestamp') ?? 0;
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;

    if (attempts >= maxAttempts &&
        currentTimestamp - lastAttemptTimestamp < minutesToWait * 60 * 1000) {
      // Afficher un message indiquant à l'utilisateur d'attendre
      print('Vous avez dépassé le nombre maximal de tentatives. Veuillez attendre $minutesToWait minutes.');
      return;
    }

    try {
      await speechToText.listen(onResult: _onSpeechResult);
      setState(() {});
    } catch (e) {
      print('Erreur lors du démarrage de la reconnaissance vocale: $e');
    }
  }


  Future<void> _stopListening() async {
    try {
      await speechToText.stop();
      prefs.setInt('attempts', (prefs.getInt('attempts') ?? 0) + 1);
      prefs.setInt('lastAttemptTimestamp', DateTime.now().millisecondsSinceEpoch);
      setState(() {});
    } catch (e) {
      print('Erreur lors de l\'arrêt de la reconnaissance vocale: $e');
    }
  }


  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
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
  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }


  @override
  Widget build(BuildContext context){
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: BounceInDown(child: const Text('Hos')),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _openDrawer();
            },
          ),
          centerTitle: true,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Menu '),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('CHATGPT'),
                onTap: () {
                  // Ajoutez ici le code pour gérer le clic sur Option 1
                  Navigator.pop(context); // Ferme le Drawer
                },
              ),
              ListTile(
                title: Text('DALL-E'),
                onTap: () {
                  // Ajoutez ici le code pour gérer le clic sur Option 2
                  Navigator.pop(context); // Ferme le Drawer
                },
              ),
              // Ajoutez d'autres options du menu ici
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // virtual assistant picture
              ZoomIn(
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        height: 120,
                        width: 120,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: const BoxDecoration(
                          color: Pallete.assistantCircleColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Container(
                      height: 123,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/unnamed.png',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // chat bubble
              FadeInRight(
                child: Visibility(
                  visible: generatedImageUrl == null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
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
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        generatedContent == null
                            ? 'Good Morning, what task can i do for you ?'
                            : generatedContent!, style: TextStyle(
                        fontFamily: 'Cera Pro',
                        color: Pallete.mainFontColor,
                        fontSize: generatedContent == null ? 25 : 18,
                      ),),
                    ),
                  ),
                ),
              ),
              if(generatedImageUrl != null)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(generatedImageUrl!),),
                ),
              SlideInLeft(
                child: Visibility(
                  visible: generatedContent == null &&
                      generatedImageUrl == null,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(top: 10, left: 22),
                    child: const Text(
                      'Here are a few features ', style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),),
                  ),
                ),
              ),
              // features list
              Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Column(
                  children: [
                    SlideInLeft(
                      delay: Duration(milliseconds: start),
                      child: const FeaturesBox(
                        color: Pallete.firstSuggestionBoxColor,
                        headerText: 'ChatGPT',
                        descriptionText: 'A smarter way to stay organized and informed with ChatGPT.',
                      ),
                    ),
                    SlideInLeft(
                      delay: Duration(milliseconds: start + delay),
                      child: const FeaturesBox(
                        color: Pallete.secondSuggestionBoxColor,
                        headerText: 'Dall-E',
                        descriptionText: 'Get inspired and stay creative  with your personal assistant powered by Dall-E.',
                      ),
                    ),
                    SlideInLeft(
                      delay: Duration(milliseconds: start + 2 * delay),
                      child: const FeaturesBox(
                        color: Pallete.thirdSuggestionBoxColor,
                        headerText: 'Smart Voive Assistant',
                        descriptionText: 'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT.',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: ZoomIn(
          delay: Duration(milliseconds: start + 3 * delay),
          child: FloatingActionButton(
            backgroundColor: Pallete.firstSuggestionBoxColor,
            onPressed: () async {
              if (await speechToText.hasPermission &&
                  speechToText.isNotListening) {
                await _startListening();
              } else if (speechToText.isListening) {
                final speech = await openAIService.isArtPromptAPI(lastWords);
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
                await _stopListening();
              } else {
                initSharedPreferences();              }
            },
            child: Icon(speechToText.isListening ? Icons.stop : Icons.mic,),
          ),
        ),
      );
    }
  }


import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:video_player/video_player.dart'; 

/// 🔤 OBJECT NAMES (ADD HERE — TOP LEVEL)
const Map<String, String> objectNames = {
  'A': 'Apple',
  'B': 'Ball',
  'C': 'Car',
  'D': 'Drum',
  'E': 'Egg',
  'F': 'Fan',
  'G': 'Grapes',
  'H': 'Hat',
  'I': 'Igloo',
  'J': 'Joker',
  'K': 'Key',
  'L': 'Leaf',
  'M': 'Moon',
  'N': 'Nest',
  'O': 'Orange',
  'P': 'Pencil',
  'Q': 'Quill',
  'R': 'Rocket',
  'S': 'Sun',
  'T': 'Tap',
  'U': 'Umbrella',
  'V': 'Violin',
  'W': 'Watermelon',
  'X': 'X-ray',
  'Y': 'Yoyo',
  'Z': 'Zip',
};

/// 🔓 LEVEL STATES
bool level2Unlocked = false;
bool level3Unlocked = false;
bool level4Unlocked = false;
bool level5Unlocked = false;

void main() {
  runApp(const SoundSortingApp());
}

class SoundSortingApp extends StatelessWidget {
  const SoundSortingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}


/// ================= HOME PAGE =================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  late AudioPlayer _player;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    /// 🎬 Play button animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    /// 🔊 Audio setup
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> toggleMusic() async {
    if (isPlaying) {
      await _player.pause();
    } else {
      await _player.play(
        AssetSource('music/home.mp3'),
        volume: 1.0,
      );
    }
    setState(() => isPlaying = !isPlaying);
  }

  Future<void> _onPlayTap() async {
    await _controller.forward();
    await _controller.reverse();

    /// 🔇 stop music when leaving home
    await _player.stop();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LevelPage(), // your existing page
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🌄 Background Image
          Image.asset(
            'assets/page/start.png',
            fit: BoxFit.cover,
          ),

          /// 🔊 Audio Button (Top-Right)
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              iconSize: 38,
              icon: Icon(
                isPlaying ? Icons.volume_up : Icons.volume_off,
                color: Colors.white,
              ),
              onPressed: toggleMusic,
            ),
          ),

          /// ▶ Play Button Center
          Center(
            child: GestureDetector(
              onTap: _onPlayTap,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Image.asset(
                  'assets/page/play.png',
                  width: 260,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// ================= LEVEL PAGE =================
class LevelPage extends StatefulWidget {
  const LevelPage({super.key});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Levels'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🌄 BACKGROUND
          Image.asset(
            'assets/page/level.png',
            fit: BoxFit.cover,
          ),

          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// ================= ROW 1 =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _levelTile(context, 1, true, 'A', 'E'),
                      _levelTile(context, 2, level2Unlocked, 'F', 'J'),
                      _levelTile(context, 3, level3Unlocked, 'K', 'O'),
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// ================= ROW 2 =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 90),
                      _levelTile(context, 4, level4Unlocked, 'P', 'T'),
                      _levelTile(context, 5, level5Unlocked, 'U', 'Z'),
                      const SizedBox(width: 90),
                    ],
                  ),

                  const SizedBox(height: 50),

                  /// ================= ROW 3 (FINAL GAME) =================
                  AnimatedBuilder(
                    animation: _floatAnim,
                    builder: (_, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnim.value),
                        child: child,
                      );
                    },
                    child: GestureDetector(
                      onTap: level5Unlocked
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const FinalGamePage(),
                                ),
                              );
                            }
                          : null,
                      child: Opacity(
                        opacity: level5Unlocked ? 1 : 0.4,
                        child: Image.asset(
                          'assets/level/lfg.png', // your final game image
                          height: 120,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= LEVEL TILE =================
  Widget _levelTile(
    BuildContext context,
    int level,
    bool unlocked,
    String start,
    String end,
  ) {
    return GestureDetector(
      onTap: unlocked
          ? () async {
              await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => AlphabetPage(
      startLetter: start,
      endLetter: end,
    ),
  ),
);

/// 🔓 UNLOCK LOGIC
setState(() {
  if (level == 1) {
    level2Unlocked = true;
  } else if (level == 2) {
    level3Unlocked = true;
  } else if (level == 3) {
    level4Unlocked = true;
  } else if (level == 4) {
    level5Unlocked = true;
  }
  // ⚠️ DO NOT unlock final game here
});

            }
          : null,
      child: AnimatedBuilder(
        animation: _floatAnim,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, unlocked ? _floatAnim.value : 0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/level/l$level.png',
                  height: 110,
                  fit: BoxFit.contain,
                ),
                if (!unlocked)
                  Container(
                    height: 110,
                    width: 110,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Color.fromARGB(255, 87, 66, 3),
                      size: 36,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ================= FINAL GAME PAGE =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Final Game"),
      ),
      body: const Center(
        child: Text(
          "🎉 Final Game Unlocked!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


  
/// ================= ALPHABET PAGE ================= ///

class AlphabetPage extends StatefulWidget {
  final String startLetter, endLetter;

  const AlphabetPage({
    super.key,
    required this.startLetter,
    required this.endLetter,
  });

  @override
  State<AlphabetPage> createState() => _AlphabetPageState();
}

class _AlphabetPageState extends State<AlphabetPage>
    with TickerProviderStateMixin {

  late String currentLetter;
  bool showObject = false;
  int tapCount = 0;

  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  /// 🔊 TTS (FIXED)
  late FlutterTts tts;

  @override
  void initState() {
    super.initState();
    currentLetter = widget.startLetter;

    /// 🔊 INIT TTS
    tts = FlutterTts();
    tts.setLanguage("en-US");
    tts.setSpeechRate(0.4);
    tts.setPitch(1.1);

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnim = Tween(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _bounceAnim = Tween(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    tts.stop();
    _floatCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  /// 🔊 SPEAK: "A for Apple"
  Future<void> _speak() async {
    final object = objectNames[currentLetter] ?? '';
    await tts.stop();
    await tts.speak("$currentLetter for $object");
  }

  void _onAlphabetTap() {
    setState(() {
      showObject = true;
      tapCount++;
    });

    _bounceCtrl.forward(from: 0);

    _speak(); // 🔊 TTS trigger

    if (tapCount >= 5) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _next(context);
      });
    }
  }

  void _next(BuildContext context) {
    tapCount = 0;

    if (currentLetter != widget.endLetter) {
      setState(() {
        currentLetter =
            String.fromCharCode(currentLetter.codeUnitAt(0) + 1);
        showObject = false;
      });
    } else {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MatchAssessmentPage(
            start: widget.startLetter,
            end: widget.endLetter,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Alphabet $currentLetter'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/page/learning.png',
            fit: BoxFit.cover,
          ),

          Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  /// 🔤 ALPHABET
                  GestureDetector(
                    onTap: _onAlphabetTap,
                    child: AnimatedBuilder(
                      animation: _floatAnim,
                      builder: (_, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnim.value),
                          child: ScaleTransition(
                            scale: _bounceAnim,
                            child: child,
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/alphabets/$currentLetter.png',
                        height: h * 0.34,
                      ),
                    ),
                  ),

                  /// 🧸 OBJECT
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: showObject ? 1 : 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ScaleTransition(
                          scale: _bounceAnim,
                          child: Image.asset(
                            'assets/images/img$currentLetter.png',
                            height: h * 0.36,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          objectNames[currentLetter] ?? '',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: ElevatedButton(
        onPressed: () => _next(context),
        child: const Text('NEXT ▶'),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
    );
  }
}


/// ================= MATCH ASSESSMENT ================= ///

class MatchAssessmentPage extends StatefulWidget {
  final String start;
  final String end;

  const MatchAssessmentPage({
    super.key,
    required this.start,
    required this.end,
  });

  @override
  State<MatchAssessmentPage> createState() => _MatchAssessmentPageState();
}

class _MatchAssessmentPageState extends State<MatchAssessmentPage>
    with TickerProviderStateMixin {
  late final List<String> letters;
  late final List<String> targets;

  final Map<String, bool> matched = {};
  String? wrongTarget;

  late final AnimationController starCtrl;

  /// 🔊 SOUND PLAYER
  final AudioPlayer _soundPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    letters = List.generate(
      widget.end.codeUnitAt(0) - widget.start.codeUnitAt(0) + 1,
      (i) => String.fromCharCode(widget.start.codeUnitAt(0) + i),
    );

    targets = List.from(letters)..shuffle();

    starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    starCtrl.dispose();
    _soundPlayer.dispose();
    super.dispose();
  }

  /// 🔊 SOUND FUNCTIONS
  Future<void> _playCorrectSound() async {
    await _soundPlayer.stop();
    await _soundPlayer.play(
      AssetSource('music/correct.mp3'),
    );
  }

  Future<void> _playWrongSound() async {
    await _soundPlayer.stop();
    await _soundPlayer.play(
      AssetSource('music/wrong.mp3'),
    );
  }

  void _handleMatch(String dragged, String target) {
    if (dragged == target && matched[target] != true) {
      _playCorrectSound(); // ✅ correct sound

      setState(() {
        matched[target] = true;
        wrongTarget = null;
      });

      if (matched.length == letters.length) {
        starCtrl.forward();
        Future.delayed(const Duration(milliseconds: 900), _goNext);
      }
    } else {
      _playWrongSound(); // ❌ wrong sound

      setState(() => wrongTarget = target);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        setState(() => wrongTarget = null);
      });
    }
  }

  void _goNext() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ObjectBasketAssessmentPage(
          start: widget.start,
          end: widget.end,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Match the Following'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/page/match2.png',
            fit: BoxFit.cover,
          ),
          Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (matched.length == letters.length)
                  ScaleTransition(
                    scale: Tween(begin: 0.6, end: 1.3).animate(
                      CurvedAnimation(
                        parent: starCtrl,
                        curve: Curves.elasticOut,
                      ),
                    ),
                    child: const Icon(
                      Icons.star,
                      size: 130,
                      color: Colors.amber,
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: letters.map((l) {
                            final done = matched[l] == true;

                            return Padding(
                              padding: const EdgeInsets.all(12),
                              child: done
                                  ? Opacity(
                                      opacity: 0.3,
                                      child: _alphabet(l, h * 0.13),
                                    )
                                  : Draggable<String>(
                                      data: l,
                                      feedback: _alphabet(l, h * 0.15),
                                      childWhenDragging: Opacity(
                                        opacity: 0.2,
                                        child: _alphabet(l, h * 0.13),
                                      ),
                                      child: _alphabet(l, h * 0.13),
                                    ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: targets.map((l) {
                            final isMatched = matched[l] == true;
                            final isWrong = wrongTarget == l;

                            return DragTarget<String>(
                              onAccept: (d) => _handleMatch(d, l),
                              builder: (_, __, ___) => AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 300),
                                margin: const EdgeInsets.all(12),
                                height: h * 0.12,
                                width: h * 0.12,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(18),
                                  border: Border.all(
                                    width: 3,
                                    color: isMatched
                                        ? Colors.green
                                        : isWrong
                                            ? Colors.red
                                            : Colors.transparent,
                                  ),
                                  boxShadow: isMatched
                                      ? [
                                          BoxShadow(
                                            color: Colors.green
                                                .withOpacity(0.6),
                                            blurRadius: 16,
                                            spreadRadius: 4,
                                          )
                                        ]
                                      : isWrong
                                          ? [
                                              BoxShadow(
                                                color: Colors.red
                                                    .withOpacity(0.6),
                                                blurRadius: 12,
                                              )
                                            ]
                                          : [],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Image.asset(
                                    'assets/images/img$l.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _alphabet(String l, double size) {
    return SizedBox(
      height: size,
      width: size,
      child: Image.asset(
        'assets/alphabets/$l.png',
        fit: BoxFit.contain,
      ),
    );
  }
}


/// ================= OBJECT BASKET ASSESTMENT ================= ///


class ObjectBasketAssessmentPage extends StatefulWidget {
  final String start, end;

  const ObjectBasketAssessmentPage({
    super.key,
    required this.start,
    required this.end,
  });

  @override
  State<ObjectBasketAssessmentPage> createState() =>
      _ObjectBasketAssessmentPageState();
}

class _ObjectBasketAssessmentPageState
    extends State<ObjectBasketAssessmentPage>
    with SingleTickerProviderStateMixin {
  late final List<String> letters;
  late final List<String> objects;

  int index = 0;
  bool finished = false;

  String? glowingBasket;
  String? shakingBasket;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  /// 🔊 SOUND PLAYER
  final AudioPlayer _soundPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    letters = List.generate(
      widget.end.codeUnitAt(0) - widget.start.codeUnitAt(0) + 1,
      (i) => String.fromCharCode(widget.start.codeUnitAt(0) + i),
    );

    objects = List.from(letters)..shuffle();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _shakeAnim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _soundPlayer.dispose();
    super.dispose();
  }

  /// 🔊 SOUND FUNCTIONS
  Future<void> _playCorrectSound() async {
    await _soundPlayer.stop();
    await _soundPlayer.play(
      AssetSource('music/correct.mp3'),
    );
  }

  Future<void> _playWrongSound() async {
    await _soundPlayer.stop();
    await _soundPlayer.play(
      AssetSource('music/wrong.mp3'),
    );
  }

  /// ✅ FINISH SAFELY
  void _finish() {
    if (finished || !mounted) return;
    finished = true;

    if (widget.start == 'A') level2Unlocked = true;
    if (widget.start == 'F') level3Unlocked = true;
    if (widget.start == 'K') level4Unlocked = true;
    if (widget.start == 'P') level5Unlocked = true;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LevelPage()),
      (_) => false,
    );
  }

  /// 🎯 DROP HANDLER (sound added only)
  void _onDrop(String dragged, String target) {
    if (dragged == target) {
      _playCorrectSound(); // ✅ correct sound

      setState(() => glowingBasket = target);

      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;

        setState(() {
          glowingBasket = null;
          index++;
        });

        if (index >= objects.length) _finish();
      });
    } else {
      _playWrongSound(); // ❌ wrong sound

      setState(() => shakingBasket = target);
      _shakeCtrl.forward(from: 0);

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() => shakingBasket = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (index >= objects.length) {
      return const SizedBox();
    }

    final size = MediaQuery.of(context).size;
    final topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight;
    final current = objects[index];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Basket Assessment'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/page/basket.png',
            fit: BoxFit.cover,
          ),
          Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Draggable<String>(
                  data: current,
                  feedback: Image.asset(
                    'assets/images/img$current.png',
                    height: size.height * 0.25,
                  ),
                  childWhenDragging:
                      SizedBox(height: size.height * 0.25),
                  child: Image.asset(
                    'assets/images/img$current.png',
                    height: size.height * 0.25,
                  ),
                ),
                const SizedBox(height: 40),
                Wrap(
                  spacing: 25,
                  runSpacing: 25,
                  alignment: WrapAlignment.center,
                  children: letters.map((l) {
                    final glow = glowingBasket == l;
                    final shake = shakingBasket == l;

                    return DragTarget<String>(
                      onAccept: (d) => _onDrop(d, l),
                      builder: (_, __, ___) {
                        return AnimatedBuilder(
                          animation: _shakeAnim,
                          builder: (_, child) {
                            return Transform.translate(
                              offset:
                                  Offset(shake ? _shakeAnim.value : 0, 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: glow
                                      ? const [
                                          BoxShadow(
                                            color: Color.fromARGB(255, 255, 238, 7),
                                            blurRadius: 20,
                                            spreadRadius: 6,
                                          )
                                        ]
                                      : [],
                                ),
                                child: child,
                              ),
                            );
                          },
                          child: Image.asset(
                            'assets/basket/b$l.png',
                            height: size.height * 0.35,
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


/// ================= FINAL TRAIN GAME ================= ///

class FinalGamePage extends StatefulWidget {
  const FinalGamePage({super.key});

  @override
  State<FinalGamePage> createState() => _FinalGamePageState();
}

class _FinalGamePageState extends State<FinalGamePage>
    with TickerProviderStateMixin {
  late VideoPlayerController _videoController;

  late AnimationController _moveController;
  late AnimationController _floatController;
  late AnimationController _shakeController;
  late AnimationController _fallController;

  late Animation<double> _floatAnim;
  late Animation<double> _shakeAnim;
  late Animation<double> _fallAnim;

  List<String> letters =
      List.generate(26, (i) => String.fromCharCode(65 + i));

  late List<String> objects;
  int currentIndex = 0;

  String? fallingLetter;

  @override
  void initState() {
    super.initState();

    /// 🎥 Video
    _videoController =
        VideoPlayerController.asset('assets/video/train.mp4')
          ..initialize().then((_) {
            if (mounted) {
              setState(() {});
              _videoController
                ..setLooping(true)
                ..play();
            }
          });

    objects = List.from(letters)..shuffle();

    /// 🔤 Horizontal movement
    _moveController =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();

    /// ⬆⬇ Floating animation
    _floatController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -10, end: 10).animate(
        CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    /// 🧸 Shake animation (object)
    _shakeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
          ..repeat(reverse: true);

    _shakeAnim = Tween<double>(begin: -6, end: 6).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    /// ⬇ Falling animation
    _fallController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _fallAnim = Tween<double>(begin: 0, end: 300).animate(
        CurvedAnimation(parent: _fallController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _videoController.dispose();
    _moveController.dispose();
    _floatController.dispose();
    _shakeController.dispose();
    _fallController.dispose();
    super.dispose();
  }

  void _onTapLetter(String letter) {
    if (letter == objects[currentIndex]) {
      setState(() {
        fallingLetter = letter;
      });

      _fallController.forward(from: 0);

      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;

        setState(() {
          currentIndex++;
          fallingLetter = null;
        });

        if (currentIndex >= objects.length) {
          currentIndex = 0;
          objects.shuffle();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (!_videoController.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          /// 🎥 Background Video
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            ),
          ),

          /// 🔤 Moving Alphabets (Top)
          Positioned(
            top: 80,
            child: AnimatedBuilder(
              animation: _moveController,
              builder: (_, __) {
                return Transform.translate(
                  offset: Offset(
                      -_moveController.value * size.width, 0),
                  child: Row(
                    children: letters.map((l) {
                      return AnimatedBuilder(
                        animation: _floatAnim,
                        builder: (_, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnim.value),
                            child: child,
                          );
                        },
                        child: GestureDetector(
                          onTap: () => _onTapLetter(l),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Image.asset(
                              'assets/alphabets/$l.png',
                              height: 70,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),

          /// 🧸 Object at bottom center
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _shakeAnim,
                builder: (_, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnim.value, 0),
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/images/img${objects[currentIndex]}.png',
                  height: 140,
                ),
              ),
            ),
          ),

          /// ⬇ Falling Alphabet Animation
          if (fallingLetter != null)
            Positioned(
              top: 80,
              left: size.width / 2 - 35,
              child: AnimatedBuilder(
                animation: _fallAnim,
                builder: (_, child) {
                  return Transform.translate(
                    offset: Offset(0, _fallAnim.value),
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/alphabets/$fallingLetter.png',
                  height: 70,
                ),
              ),
            ),
        ],
      ),
    );
  }
}


/// ================= HELPERS ================= /// 


PreferredSizeWidget _appBar(BuildContext c, String t) => AppBar(
      title: Text(t),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(c),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.popUntil(c, (r) => r.isFirst),
        )
      ],
    );

Widget _bgImage(String p) => Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(p), fit: BoxFit.cover),
      ),
    );

Widget _overlay() => Container(color: Colors.black.withOpacity(0.3));




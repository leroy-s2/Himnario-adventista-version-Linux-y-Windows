import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../utils/background_manager.dart';
import 'home_screen.dart';

class PlayerScreen extends StatefulWidget {
  final Map<String, dynamic> himno;
  final String tipoAudio;

  const PlayerScreen({
    super.key,
    required this.himno,
    required this.tipoAudio,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late List<Map<String, dynamic>> _sections;
  int _currentSectionIndex = 0;
  String _backgroundPath = 'assets/images/background.png';
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isAudioMode = false;
  bool _isNavigatingHome = false; // Evitar navegar múltiples veces
  String? _errorMessage;
  Duration _audioDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _stateSubscription;

  @override
  void initState() {
    super.initState();
    _buildSections();
    _isAudioMode = widget.tipoAudio != 'letra';
    
    _backgroundPath = BackgroundManager.getBackgroundForHymn(
      widget.himno['numero'] as int,
      widget.himno['titulo'] as String,
    );
    
    _stateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isLoading = state.processingState == ProcessingState.loading ||
                       state.processingState == ProcessingState.buffering;
        });
        
        if (state.processingState == ProcessingState.completed) {
          debugPrint('=== Audio completed, calling _goHome ===');
          _goHome();
        }
      }
    });
    
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() => _audioDuration = duration);
      }
    });
    
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        _currentPosition = position;
        _updateSectionBasedOnPosition();
        
        // Fallback para Linux/mpv: detectar fin por posición
        if (_audioDuration.inSeconds > 0 && 
            position.inSeconds >= _audioDuration.inSeconds - 1 &&
            !_isNavigatingHome) {
          debugPrint('=== Audio completed (position fallback) ===');
          _goHome();
        }
      }
    });
    
    if (_isAudioMode) {
      _startAudio();
    }
  }
  
  List<String> _splitLongText(String text, {int maxChars = 150}) {
    if (text.length <= maxChars) return [text];
    
    List<String> parts = [];
    List<String> lines = text.split('\n');
    String currentPart = '';
    
    for (String line in lines) {
      if (currentPart.isEmpty) {
        currentPart = line;
      } else if ((currentPart.length + line.length + 1) <= maxChars) {
        currentPart += '\n$line';
      } else {
        parts.add(currentPart);
        currentPart = line;
      }
    }
    
    if (currentPart.isNotEmpty) {
      parts.add(currentPart);
    }
    
    return parts.isEmpty ? [text] : parts;
  }
  
  void _buildSections() {
    _sections = [];
    final estrofas = List<String>.from(widget.himno['estrofas'] ?? []);
    final coro = widget.himno['coro'] as String?;
    final referencia = widget.himno['referenciaBiblica'] as String?;
    
    // Agregar sección INTRO primero (solo título y referencia, sin letra)
    _sections.add({
      'type': 'intro',
      'content': '',  // Sin letra durante el intro
      'number': null,
      'referencia': referencia,
    });
    
    // Agregar estrofas SIN dividir en partes (cada estrofa completa es UNA sección)
    int estrofaNum = 1;
    for (int i = 0; i < estrofas.length; i++) {
      // NO usar _splitLongText - cada estrofa es UNA sección completa
      _sections.add({
        'type': 'estrofa',
        'content': estrofas[i].replaceAll('\r\n', '\n').replaceAll('\r', '\n'),
        'number': estrofaNum,
        'part': null,
      });
      estrofaNum++;
      
      // Agregar coro después de cada estrofa si existe
      if (coro != null && coro.isNotEmpty) {
        _sections.add({
          'type': 'coro',
          'content': coro.replaceAll('\r\n', '\n').replaceAll('\r', '\n'),
          'number': null,
          'part': null,
        });
      }
    }
    
    // Caso especial: solo coro sin estrofas
    if (estrofas.isEmpty && coro != null && coro.isNotEmpty) {
      _sections.add({
        'type': 'coro',
        'content': coro.replaceAll('\r\n', '\n').replaceAll('\r', '\n'),
        'number': null,
        'part': null,
      });
    }
  }
  
  void _updateSectionBasedOnPosition() {
    if (!_isAudioMode || _sections.isEmpty || _audioDuration == Duration.zero) return;
    
    final stanzaTimestamps = widget.himno['stanza_timestamps'] as List?;
    
    // Anticipación: mostrar letra 2 segundos antes del timestamp real
    const double anticipationSeconds = 2.0;
    
    if (stanzaTimestamps != null && stanzaTimestamps.isNotEmpty) {
      // Añadir anticipación para que la letra aparezca antes
      final currentSeconds = _currentPosition.inSeconds.toDouble() + anticipationSeconds;
      
      // El primer timestamp es cuando empieza el canto (fin del intro)
      final firstStanzaStart = (stanzaTimestamps[0]['start'] as num?)?.toDouble() ?? 0.0;
      
      // Si estamos antes del primer timestamp (menos anticipación), mostrar intro
      if (currentSeconds < firstStanzaStart) {
        if (_currentSectionIndex != 0) {
          setState(() => _currentSectionIndex = 0);
        }
        return;
      }
      
      // Después del intro, buscar qué sección de letra mostrar
      int newSection = 1;
      
      for (int i = 0; i < stanzaTimestamps.length; i++) {
        final timestamp = stanzaTimestamps[i];
        final startTime = (timestamp['start'] as num?)?.toDouble() ?? 0.0;
        
        if (currentSeconds >= startTime) {
          newSection = i + 1;  // +1 porque sección 0 es intro
        }
      }
      
      newSection = newSection.clamp(0, _sections.length - 1);
      
      if (newSection != _currentSectionIndex) {
        setState(() => _currentSectionIndex = newSection);
      }
    } else {
      // Fallback: dividir tiempo equitativamente
      final totalSections = _sections.length;
      final msPerSection = _audioDuration.inMilliseconds / totalSections;
      final currentSection = (_currentPosition.inMilliseconds / msPerSection).floor();
      final clampedSection = currentSection.clamp(0, totalSections - 1);
      
      if (clampedSection != _currentSectionIndex) {
        setState(() => _currentSectionIndex = clampedSection);
      }
    }
  }
  
  Future<void> _startAudio() async {
    final numero = widget.himno['numero'];
    final tipo = widget.tipoAudio;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final assetPath = 'assets/audio/$tipo/$numero.mp3';
      
      try {
        await rootBundle.load(assetPath);
        await _audioPlayer.setAsset(assetPath);
        await _audioPlayer.play();
        return;
      } catch (e) {
        debugPrint('Audio local no disponible: $e');
      }
      
      String? url;
      if (tipo == 'cantado') {
        url = widget.himno['mp3Cantado'];
      } else if (tipo == 'instrumental') {
        url = widget.himno['mp3Instrumental'];
      }
      
      if (url != null && url.isNotEmpty) {
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
      } else {
        setState(() => _errorMessage = 'Audio no disponible');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar audio';
          _isLoading = false;
        });
      }
    }
  }
  
  void _nextSection() {
    if (_isAudioMode && _isPlaying) {
      final newPos = _currentPosition + const Duration(seconds: 15);
      _audioPlayer.seek(newPos);
    } else {
      if (_currentSectionIndex < _sections.length - 1) {
        setState(() => _currentSectionIndex++);
      }
    }
  }
  
  void _prevSection() {
    if (_isAudioMode && _isPlaying) {
      final newPos = _currentPosition - const Duration(seconds: 15);
      _audioPlayer.seek(newPos.isNegative ? Duration.zero : newPos);
    } else {
      if (_currentSectionIndex > 0) {
        setState(() => _currentSectionIndex--);
      }
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _stateSubscription?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _goHome() {
    // Evitar llamadas múltiples
    if (_isNavigatingHome) return;
    _isNavigatingHome = true;
    
    debugPrint('=== _goHome executing (single call) ===');
    
    // Cancelar suscripciones primero
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _stateSubscription?.cancel();
    
    // Detener audio sin esperar
    _audioPlayer.stop();
    
    if (mounted) {
      debugPrint('Popping to first route...');
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _backgroundPath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
          Container(color: Colors.black.withOpacity(0.55)),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildContent()),
                _buildBottomIndicator(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Himno ${widget.himno['numero']}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.himno['titulo'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black87),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.6)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Cargando...',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                  ),
                ],
              ),
            ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade300, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_sections.isEmpty) {
      return const Center(
        child: Text('Sin contenido', style: TextStyle(color: Colors.white54, fontSize: 20)),
      );
    }
    
    final section = _sections[_currentSectionIndex];
    final sectionType = section['type'] as String;
    
    // Vista especial para INTRO (solo mostrar referencia bíblica, sin letra)
    if (sectionType == 'intro') {
      final referencia = section['referencia'] as String?;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mostrar referencia bíblica si existe
            if (referencia != null && referencia.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  referencia,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 28,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    shadows: const [
                      Shadow(offset: Offset(1, 1), blurRadius: 4, color: Colors.black87),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 40),
            // Indicador visual de que es el intro
            Text(
              '♪ Introducción ♪',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 20,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      );
    }
    
    // Vista normal para ESTROFA/CORO (mostrar letra)
    final content = section['content'] as String;
    
    // Calcular tamaño de fuente dinámico según longitud del contenido
    // Más texto = fuente más pequeña, menos texto = fuente más grande
    double fontSize;
    double horizontalPadding;
    
    final contentLength = content.length;
    final lineCount = content.split('\n').length;
    
    if (contentLength < 100 && lineCount <= 4) {
      // Texto muy corto (como coros simples) - fuente grande
      fontSize = 48;
      horizontalPadding = 24;
    } else if (contentLength < 200 && lineCount <= 6) {
      // Texto medio - fuente mediana
      fontSize = 40;
      horizontalPadding = 28;
    } else if (contentLength < 350 && lineCount <= 10) {
      // Texto largo - fuente más pequeña
      fontSize = 32;
      horizontalPadding = 32;
    } else {
      // Texto muy largo - fuente pequeña
      fontSize = 26;
      horizontalPadding = 24;
    }
    
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
          child: Text(
            content,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              height: 1.35,
              fontWeight: FontWeight.w600,
              shadows: const [
                Shadow(offset: Offset(2, 2), blurRadius: 6, color: Colors.black87),
                Shadow(offset: Offset(-1, -1), blurRadius: 3, color: Colors.black54),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomIndicator() {
    if (_sections.isEmpty) return const SizedBox.shrink();
    
    final section = _sections[_currentSectionIndex];
    final sectionType = section['type'] as String;
    final number = section['number'];
    final part = section['part'];
    
    // Determinar texto del indicador según el tipo de sección
    String indicatorText;
    if (sectionType == 'intro') {
      indicatorText = '♪';  // Símbolo musical durante intro
    } else if (sectionType == 'estrofa') {
      indicatorText = part != null ? '$number ($part)' : '$number';
    } else {
      indicatorText = part != null ? 'coro ($part)' : 'coro';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _prevSection,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('|', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 28)),
          ),
          
          Text(
            indicatorText,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('|', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 28)),
          ),
          
          GestureDetector(
            onTap: _nextSection,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 48),
          
          GestureDetector(
            onTap: _goHome,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

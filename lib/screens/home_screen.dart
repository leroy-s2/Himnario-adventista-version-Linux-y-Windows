import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _numberFocus = FocusNode();
  final FocusNode _textFocus = FocusNode();

  final List<String> _tabs = ['Solo letra', 'Cantado', 'Instrumental'];
  
  List<Map<String, dynamic>> _himnos = [];
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedHimno;
  bool _showResults = false;
  
  // Flag para evitar que los listeners se disparen al establecer texto programáticamente
  bool _isProgrammaticChange = false;

  @override
  void initState() {
    super.initState();
    _loadHimnos();
    _numberController.addListener(_onNumberChanged);
    _textController.addListener(_onTextChanged);
  }

  Future<void> _loadHimnos() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/himnos.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        _himnos = jsonList.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint('Error loading himnos: $e');
    }
  }

  void _onNumberChanged() {
    if (_isProgrammaticChange) return;
    
    final query = _numberController.text;
    if (query.isEmpty) {
      setState(() {
        _selectedHimno = null;
        _searchResults = [];
        _showResults = false;
      });
      return;
    }
    
    // Limpiar campo de texto cuando se escribe número
    if (_textController.text.isNotEmpty) {
      _isProgrammaticChange = true;
      _textController.clear();
      _isProgrammaticChange = false;
    }
    
    final results = _himnos.where((h) => 
      h['numero'].toString().startsWith(query)
    ).take(10).toList();
    
    setState(() {
      _searchResults = results;
      _showResults = results.isNotEmpty;
      
      // Auto-select si hay coincidencia exacta
      final exactMatch = _himnos.where((h) => h['numero'].toString() == query).toList();
      if (exactMatch.isNotEmpty) {
        _selectedHimno = exactMatch.first;
        _showResults = false;
        // Llenar el campo de título
        _isProgrammaticChange = true;
        _textController.text = exactMatch.first['titulo'];
        _isProgrammaticChange = false;
      } else {
        _selectedHimno = null;
      }
    });
  }

  void _onTextChanged() {
    if (_isProgrammaticChange) return;
    
    final query = _textController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showResults = false;
      });
      return;
    }
    
    // Limpiar campo de número cuando se escribe texto
    if (_numberController.text.isNotEmpty) {
      _isProgrammaticChange = true;
      _numberController.clear();
      _isProgrammaticChange = false;
    }
    
    final results = _himnos.where((h) => 
      (h['titulo'] as String).toLowerCase().contains(query)
    ).take(10).toList();
    
    setState(() {
      _searchResults = results;
      _showResults = results.isNotEmpty;
      _selectedHimno = null;
    });
  }

  void _selectHimno(Map<String, dynamic> himno) {
    _isProgrammaticChange = true;
    
    setState(() {
      _selectedHimno = himno;
      _showResults = false;
      _searchResults = [];
    });
    
    // Actualizar campos
    _numberController.text = himno['numero'].toString();
    _textController.text = himno['titulo'];
    
    _isProgrammaticChange = false;
    
    // Quitar focus
    FocusScope.of(context).unfocus();
  }
  
  void _clearSelection() {
    _isProgrammaticChange = true;
    
    setState(() {
      _selectedHimno = null;
      _searchResults = [];
      _showResults = false;
    });
    
    _numberController.clear();
    _textController.clear();
    
    _isProgrammaticChange = false;
  }

  void _playHimno() {
    if (_selectedHimno == null) return;
    
    String tipoAudio;
    switch (_selectedTabIndex) {
      case 1:
        tipoAudio = 'cantado';
        break;
      case 2:
        tipoAudio = 'instrumental';
        break;
      default:
        tipoAudio = 'letra';
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          himno: _selectedHimno!,
          tipoAudio: tipoAudio,
        ),
      ),
    );
  }

  void _closeApp() {
    exit(0);
  }

  @override
  void dispose() {
    _numberController.dispose();
    _textController.dispose();
    _numberFocus.dispose();
    _textFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 50),
                  _buildTitle(),
                  const SizedBox(height: 60),
                  _buildTabsAndSearch(),
                  const Spacer(),
                ],
              ),
              Positioned(
                top: 8,
                right: 12,
                child: _buildCloseButton(),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: _buildDedication(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: _closeApp,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade700.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Cerrar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDedication() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.brown.shade800.withOpacity(0.85),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'Iglesia Adventista del Séptimo Día\nPuerto San Francisco\nAño 2025',
        style: TextStyle(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'HIMNARIO',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Colors.brown.shade800,
            letterSpacing: 6,
            shadows: [
              Shadow(
                offset: const Offset(2, 2),
                blurRadius: 4,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
        ),
        Text(
          'ADVENTISTA',
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
            color: Colors.brown.shade900,
            letterSpacing: 3,
            shadows: [
              Shadow(
                offset: const Offset(2, 2),
                blurRadius: 4,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabsAndSearch() {
    return Center(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFD4C4A8).withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tabs
            Row(
              children: List.generate(_tabs.length, (index) {
                final isSelected = _selectedTabIndex == index;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF8B7355)
                              : const Color(0xFFE8DCC8),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: const Color(0xFF8B7355),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _tabs[index],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF5D4E37),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),
            
            // Search Row
            Row(
              children: [
                // Number Field
                SizedBox(
                  width: 70,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F0E6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCDBBA8)),
                    ),
                    child: TextField(
                      controller: _numberController,
                      focusNode: _numberFocus,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '#',
                        hintStyle: TextStyle(color: Colors.brown.shade400, fontSize: 18),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                
                // Title Field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F0E6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCDBBA8)),
                    ),
                    child: TextField(
                      controller: _textController,
                      focusNode: _textFocus,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Buscar por título...',
                        hintStyle: TextStyle(color: Colors.brown.shade400, fontSize: 15),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        suffixIcon: _selectedHimno != null
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.brown.shade400, size: 20),
                                onPressed: _clearSelection,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                
                // Play Button
                GestureDetector(
                  onTap: _selectedHimno != null ? _playHimno : null,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _selectedHimno != null
                          ? const Color(0xFF8B7355)
                          : const Color(0xFFCDBBA8),
                      shape: BoxShape.circle,
                      boxShadow: _selectedHimno != null
                          ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))]
                          : null,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: _selectedHimno != null ? Colors.white : Colors.white.withOpacity(0.5),
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
            
            // Search Results List
            if (_showResults && _searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCDBBA8)),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final himno = _searchResults[index];
                    return InkWell(
                      onTap: () => _selectHimno(himno),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: index < _searchResults.length - 1
                              ? Border(bottom: BorderSide(color: const Color(0xFFCDBBA8).withOpacity(0.5)))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B7355),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${himno['numero']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                himno['titulo'],
                                style: TextStyle(
                                  color: Colors.brown.shade800,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.brown.shade400,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

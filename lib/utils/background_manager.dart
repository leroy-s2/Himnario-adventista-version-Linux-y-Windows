/// Gestor inteligente de fondos para himnos
/// Asigna automáticamente imágenes según el tema detectado en el título
class BackgroundManager {
  
  // Imágenes disponibles por tema
  static final Map<String, List<String>> _backgroundsByTheme = {
    'adoracion': [
      'assets/backgrounds/adoracion/adoracion_1.jpg',
      'assets/backgrounds/adoracion/adoracion_2.jpg',
      'assets/backgrounds/adoracion/adoracion_4.jpg',
      'assets/backgrounds/adoracion/adoracion_5.jpg',
    ],
    
    'cruz': [
      'assets/backgrounds/cruz/cruz_1.jpg',
      'assets/backgrounds/cruz/cruz_2.jpg',
      'assets/backgrounds/cruz/cruz_3.jpg',
      'assets/backgrounds/cruz/cruz_4.jpg',
      'assets/backgrounds/cruz/cruz_5.jpg',
    ],
    
    'navidad': [
      'assets/backgrounds/navidad/navidad_1.jpg',
      'assets/backgrounds/navidad/navidad_2.jpg',
      'assets/backgrounds/navidad/navidad_3.jpg',
    ],
    
    'resurreccion': [
      'assets/backgrounds/resurreccion/resurreccion_1.jpg',
      'assets/backgrounds/resurreccion/resurreccion_2.jpg',
      'assets/backgrounds/resurreccion/resurreccion_3.jpg',
      'assets/backgrounds/resurreccion/resurreccion_4.jpg',
    ],
    
    'segunda_venida': [
      'assets/backgrounds/segunda_venida/segunda_venida_1.jpg',
      'assets/backgrounds/segunda_venida/segunda_venida_2.jpg',
    ],
    
    'oracion': [
      'assets/backgrounds/oracion/oracion_2.jpg',
      'assets/backgrounds/oracion/oracion_3.jpg',
      'assets/backgrounds/oracion/oracion_4.jpg',
    ],
    
    'fe': [
      'assets/backgrounds/fe/fe_1.jpg',
      'assets/backgrounds/fe/fe_2.jpg',
      'assets/backgrounds/fe/fe_3.jpg',
    ],
    
    'naturaleza': [
      'assets/backgrounds/naturaleza/naturaleza_1.jpg',
      'assets/backgrounds/naturaleza/naturaleza_2.jpg',
      'assets/backgrounds/naturaleza/naturaleza_3.jpg',
      'assets/backgrounds/naturaleza/naturaleza_4.jpg',
      'assets/backgrounds/naturaleza/naturaleza_5.jpg',
      'assets/backgrounds/naturaleza/naturaleza_6.jpg',
    ],
    
    'cielo': [
      'assets/backgrounds/cielo/cielo_1.jpg',
      'assets/backgrounds/cielo/cielo_2.jpg',
    ],
    
    'espiritu': [
      'assets/backgrounds/espiritu/espiritu_1.jpg',
      'assets/backgrounds/espiritu/espiritu_2.jpg',
    ],
    
    'evangelismo': [
      'assets/backgrounds/evangelismo/evangelismo_1.jpg',
    ],
    
    'familia': [
      'assets/backgrounds/familia/familia_1.jpg',
      'assets/backgrounds/familia/familia_2.jpg',
      'assets/backgrounds/familia/familia_3.jpg',
      'assets/backgrounds/familia/familia_4.jpg',
    ],
    
    'bautismo': [
      'assets/backgrounds/bautismo/bautismo_1.jpg',
    ],
    
    'comunion': [
      'assets/backgrounds/comunion/comunion_1.jpg',
    ],
    
    'iglesia': [
      'assets/backgrounds/iglesia/iglesia_1.jpg',
    ],
  };

  // Imágenes por defecto
  static final List<String> _defaultBackgrounds = [
    'assets/backgrounds/naturaleza/naturaleza_1.jpg',
    'assets/backgrounds/naturaleza/naturaleza_2.jpg',
    'assets/backgrounds/naturaleza/naturaleza_3.jpg',
    'assets/backgrounds/naturaleza/naturaleza_4.jpg',
    'assets/backgrounds/naturaleza/naturaleza_5.jpg',
    'assets/backgrounds/naturaleza/naturaleza_6.jpg',
    'assets/backgrounds/cielo/cielo_1.jpg',
    'assets/backgrounds/cielo/cielo_2.jpg',
  ];

  // Palabras clave para detectar temas - MÁS COMPLETO
  static final Map<String, List<String>> _themeKeywords = {
    'navidad': [
      // Palabras directas
      'navidad', 'navideño', 'navideña', 'noel', 'nochebuena',
      'belén', 'belen', 'pesebre', 'portal',
      'nació', 'nacido', 'nacimiento', 'natividad',
      'estrella', 'pastores', 'magos', 'reyes',
      'maría', 'maria', 'jose', 'josé', 'emmanuel', 'emanuel',
      'niño jesús', 'niño jesus', 'niño dios',
      // Títulos famosos de himnos navideños
      'al mundo paz', 'noche de paz', 'oh santísimo', 'venid fieles',
      'angeles cantando', 'ángeles cantando', 'gloria in excelsis',
      'oh aldehuela', 'allá en el pesebre', 'campana', 'campanas',
      'dulce jesús', 'el tamborilero', 'los peces', 'arre borriquito',
      'blanca navidad', 'cascabel', 'feliz navidad', 'rey ha nacido',
      'tu scendi dalle stelle', 'adeste fideles', 'infant holy',
      'go tell it', 'joy to the world', 'silent night', 'away in a manger',
      'hark the herald', 'o come all ye', 'first noel', 'what child is this',
    ],
    
    'adoracion': [
      'alabanza', 'alabar', 'alabad', 'adoración', 'adorar', 'adorad',
      'gloria', 'glorioso', 'glorifica', 'santo', 'santidad', 'majestad',
      'cantad', 'canto', 'aleluya', 'hosanna', 'exaltad', 'magnifica',
      'bendito', 'bendecir', 'engrandecer', 'exaltar',
    ],
    
    'cruz': [
      'cruz', 'calvario', 'gólgota', 'golgotha', 'sangre', 'sacrificio',
      'murió', 'morir', 'muerte', 'getsemaní', 'getsemani', 'pasión',
      'sufrimiento', 'corona', 'espinas', 'clavos', 'heridas',
      'consumado', 'cordero', 'inmolado',
    ],
    
    'resurreccion': [
      'resurrección', 'resurreccion', 'resucitó', 'resucito', 'victoria',
      'vive', 'viviente', 'triunfo', 'vencedor', 'tumba vacía', 
      'tumba vacia', 'levantó', 'levanto', 'tercer día', 'tercer dia',
      'cristo vive', 'él vive', 'el vive',
    ],
    
    'segunda_venida': [
      'viene', 'vendrá', 'vendra', 'regresará', 'regresara', 'regreso',
      'segunda venida', 'pronto viene', 'nubes', 'ángeles', 'angeles',
      'trompeta', 'arrebatados', 'manifestación', 'manifestacion',
      'maranata', 'ven señor', 'ven senor',
    ],
    
    'oracion': [
      'oración', 'oracion', 'ora', 'orar', 'ruego', 'clamo', 'clamar',
      'suplico', 'súplica', 'suplica', 'intercesión', 'intercesion',
      'pedir', 'rogad', 'hablar con dios', 'háblame', 'hablame',
    ],
    
    'fe': [
      'fe', 'confía', 'confia', 'confianza', 'confiar', 'creo', 'creer',
      'fiel', 'firme', 'seguro', 'seguridad', 'refugio', 'amparo',
      'roca', 'fortaleza', 'baluarte', 'esperanza',
    ],
    
    'naturaleza': [
      'creación', 'creacion', 'tierra', 'monte', 'montaña',
      'montana', 'mar', 'océano', 'oceano', 'río', 'rio', 'naturaleza',
      'aves', 'flores', 'jardín', 'jardin', 'campo', 'sol', 'luna',
    ],
    
    'cielo': [
      'cielo eterno', 'hogar celestial', 'mansión', 'mansion', 'mansiones',
      'paraíso', 'paraiso', 'gloria eterna', 'eternidad', 'reino',
      'ciudad celestial', 'nueva jerusalén', 'nueva jerusalen',
      'más allá', 'mas alla', 'hogar de dios',
    ],
    
    'espiritu': [
      'espíritu santo', 'espiritu santo', 'consolador', 'paloma',
      'pentecostés', 'pentecostes', 'fuego divino', 'llama divina', 
      'poder', 'unción', 'uncion', 'prometido', 'paráclito', 'paraclito',
    ],
    
    'evangelismo': [
      'evangelio', 'misión', 'mision', 'predica', 'predicar', 'testifica',
      'testificar', 'anuncia', 'anunciar', 'salva', 'salvar', 'salvación',
      'salvacion', 'mensaje', 'proclamad', 'id por todo', 'gran comisión',
    ],
    
    'familia': [
      'hogar', 'familia', 'padres', 'hijos', 'madre', 'padre', 'niños',
      'ninos', 'matrimonio', 'esposo', 'esposa', 'casa', 'unión familiar',
    ],
    
    'bautismo': [
      'bautismo', 'bautiza', 'bautizar', 'agua', 'sepultados',
      'regeneración', 'regeneracion', 'sumergir',
    ],
    
    'comunion': [
      'cena', 'comunión', 'comunion', 'pan', 'vino', 'copa', 'cáliz',
      'caliz', 'mesa del señor', 'memorial', 'partimiento',
    ],
    
    'iglesia': [
      'iglesia', 'congregación', 'congregacion', 'hermanos', 'pueblo',
      'congregad', 'reunión', 'reunion', 'asamblea', 'comunidad',
      'cuerpo de cristo', 'unidos',
    ],
  };

  /// Obtener el fondo apropiado para un himno
  static String getBackgroundForHymn(int numero, String titulo, {String? categoria}) {
    String theme = _detectTheme(titulo.toLowerCase());
    
    if (theme == 'default' && categoria != null) {
      theme = _detectTheme(categoria.toLowerCase());
    }
    
    List<String> backgrounds;
    if (theme == 'default' || !_backgroundsByTheme.containsKey(theme)) {
      backgrounds = _defaultBackgrounds;
    } else {
      backgrounds = _backgroundsByTheme[theme]!;
    }
    
    final index = numero % backgrounds.length;
    return backgrounds[index];
  }

  /// Detectar el tema basado en palabras clave
  static String _detectTheme(String text) {
    // Navidad primero porque tiene títulos específicos
    final priorityOrder = [
      'navidad', 'resurreccion', 'cruz', 'segunda_venida', 'bautismo',
      'comunion', 'espiritu', 'cielo', 'oracion', 'adoracion',
      'evangelismo', 'familia', 'iglesia', 'fe', 'naturaleza',
    ];
    
    for (final theme in priorityOrder) {
      final keywords = _themeKeywords[theme]!;
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          return theme;
        }
      }
    }
    
    return 'default';
  }

  static List<String> getAllThemes() {
    return _backgroundsByTheme.keys.toList();
  }
}

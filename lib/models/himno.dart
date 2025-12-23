class Himno {
  final int numero;
  final String titulo;
  final String letra;
  final String? audioInstrumentalPath;
  final String? audioCantadoPath;
  final String? partituraPath;
  final bool esFavorito;

  Himno({
    required this.numero,
    required this.titulo,
    required this.letra,
    this.audioInstrumentalPath,
    this.audioCantadoPath,
    this.partituraPath,
    this.esFavorito = false,
  });

  factory Himno.fromJson(Map<String, dynamic> json) {
    return Himno(
      numero: json['numero'] as int,
      titulo: json['titulo'] as String,
      letra: json['letra'] as String,
      audioInstrumentalPath: json['audioInstrumental'] as String?,
      audioCantadoPath: json['audioCantado'] as String?,
      partituraPath: json['partitura'] as String?,
      esFavorito: json['esFavorito'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'titulo': titulo,
      'letra': letra,
      'audioInstrumental': audioInstrumentalPath,
      'audioCantado': audioCantadoPath,
      'partitura': partituraPath,
      'esFavorito': esFavorito,
    };
  }

  Himno copyWith({
    int? numero,
    String? titulo,
    String? letra,
    String? audioInstrumentalPath,
    String? audioCantadoPath,
    String? partituraPath,
    bool? esFavorito,
  }) {
    return Himno(
      numero: numero ?? this.numero,
      titulo: titulo ?? this.titulo,
      letra: letra ?? this.letra,
      audioInstrumentalPath: audioInstrumentalPath ?? this.audioInstrumentalPath,
      audioCantadoPath: audioCantadoPath ?? this.audioCantadoPath,
      partituraPath: partituraPath ?? this.partituraPath,
      esFavorito: esFavorito ?? this.esFavorito,
    );
  }
}

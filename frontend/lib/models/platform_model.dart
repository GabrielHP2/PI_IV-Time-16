class PlatformModel {
  const PlatformModel({
    required this.id,
    required this.name,
    required this.logoPath,
  });

  final int id;
  final String name;
  final String logoPath;

  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w185';

  String get logoUrl {
    if (logoPath.isEmpty) return '';
    return '$_imageBaseUrl$logoPath';
  }

  factory PlatformModel.fromMap(Map<String, dynamic> map) {
    final rawId = map['platform_id'];

    if (rawId is! num) {
      throw const FormatException(
        'A plataforma recebida não possui um platform_id válido.',
      );
    }

    return PlatformModel(
      id: rawId.toInt(),
      name: map['name']?.toString() ?? '',
      logoPath: map['logo_path']?.toString() ?? '',
    );
  }
}

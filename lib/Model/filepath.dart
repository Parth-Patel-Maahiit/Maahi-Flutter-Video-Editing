class FilePath {
  final int vid_id, id, version;
  final String path, date;
  final String thumbnail;
  final String title;
  final int width;
  final int height;
  final String name;
  //final String script;

  FilePath({
    required this.id,
    required this.vid_id,
    required this.path,
    required this.thumbnail,
    required this.version,
    required this.title,
    required this.width,
    required this.height,
    required this.date,
    required this.name,
  });
}

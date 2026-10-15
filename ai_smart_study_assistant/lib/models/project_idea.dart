/// A single generated project idea.
class ProjectIdea {
  final String name;
  final String description;
  final List<String> features;
  final List<String> technologies;
  final String difficulty;
  final String estimatedTime;

  const ProjectIdea({
    required this.name,
    required this.description,
    required this.features,
    required this.technologies,
    required this.difficulty,
    required this.estimatedTime,
  });
}

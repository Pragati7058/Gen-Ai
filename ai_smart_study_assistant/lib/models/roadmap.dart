/// A single node in the learning roadmap timeline.
class RoadmapStep {
  final int step;
  final String topic;
  final String description;
  final String duration;
  final String difficulty;

  const RoadmapStep({
    required this.step,
    required this.topic,
    required this.description,
    required this.duration,
    required this.difficulty,
  });
}

/// A full generated learning roadmap.
class Roadmap {
  final String goal;
  final List<RoadmapStep> steps;

  const Roadmap({required this.goal, required this.steps});

  int get totalDurationWeeks {
    // Best-effort estimate from duration strings like "2 weeks".
    int total = 0;
    for (final step in steps) {
      final match = RegExp(r'(\d+)').firstMatch(step.duration);
      if (match != null) total += int.tryParse(match.group(1)!) ?? 0;
    }
    return total;
  }
}

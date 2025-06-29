class PredictedItemEntity {
  final String label;
  final double confidence;
  final String category;

  const PredictedItemEntity({
    required this.label,
    required this.confidence,
    this.category = "other",
  });
}

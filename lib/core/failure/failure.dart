class Failure {
  final Object error;
  Failure({required this.error});
/**{
    "status": "error",
    "error": "password is incorrect",
    "statuscode": 422,
    "data": []
} */

  @override
  String toString() {
    return 'Failure: ${error.toString()}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is Failure && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;
  String get message => error.toString();
  String get status => 'error';
  int get statusCode => 422; // Assuming a default status code for failure
  List<Object> get props => [error];
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'error': error.toString(),
      'statuscode': statusCode,
      'data': [], // Assuming no additional data for failure
    };
  }

  factory Failure.fromJson(Map<String, dynamic> json) {
    return Failure(
      error: Exception(json['error'] ?? 'Unknown error'),
    );
  }
  Failure copyWith({Error? error}) {
    return Failure(
      error: error ?? this.error,
    );
  }
}

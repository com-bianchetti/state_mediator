class Result<T> {
  final T? data;
  final bool isSuccess;
  final bool isLoading;
  final String? error;

  Result({
    required this.data,
    required this.isSuccess,
    required this.isLoading,
    this.error,
  });

  factory Result.success(T data) {
    return Result(data: data, isSuccess: true, isLoading: false);
  }

  factory Result.error(String error) {
    return Result(data: null, isSuccess: false, isLoading: false, error: error);
  }

  factory Result.loading([T? data]) {
    return Result(data: data, isSuccess: false, isLoading: true);
  }

  factory Result.empty() {
    return Result(data: null, isSuccess: false, isLoading: false, error: null);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Result &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          isSuccess == other.isSuccess &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode =>
      data.hashCode ^ isSuccess.hashCode ^ isLoading.hashCode ^ error.hashCode;
}

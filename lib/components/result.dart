/// A result is a class that represents the result of a command.
/// It contains the data, success, loading, and error states.
/// It is used to notify the widget when the state changes.
///
/// The [T] is the type of the data.
///
/// The [data] property is the data of the result.
/// The [isSuccess] property is a boolean that indicates if the result is successful.
/// The [isLoading] property is a boolean that indicates if the result is loading.
/// The [error] property is the error of the result.
class Result<T> {
  /// The data of the result.
  final T? data;

  /// A boolean that indicates if the result is successful.
  final bool isSuccess;

  /// A boolean that indicates if the result is loading.
  final bool isLoading;

  /// The error of the result.
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

import 'package:employee_book/core/domain/result/result.dart';

abstract interface class UseCase<Output, Input> {
  Future<Result<Output>> call(Input input);
}

final class NoParams {
  const NoParams();
}

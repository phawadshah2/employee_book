class EmployeePageRequest {
  const EmployeePageRequest({this.limit = 20, this.afterId});
  final int limit;
  final int? afterId;
}

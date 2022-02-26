extension ScopeFunctionExtensions<T extends Object?> on T {
  T let(Function(T self) action) {
    if (this != null) {
      action(this);
    }
    return this;
  }
}

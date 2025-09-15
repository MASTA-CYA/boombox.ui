enum EditMode {
  reorder,
  delete,
}

extension EditModeExtension on EditMode {
  String get mode {
    switch (this) {
      case EditMode.reorder:
        return "Reorder";
      case EditMode.delete:
        return "Delete";
    }
  }
}

abstract interface class SerializableModel<T> {
  List<String> get keys => this.keys;
  T get model => this.model;
  
  T modifyProperty(String field, dynamic value);
}

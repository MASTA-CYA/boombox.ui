abstract interface class PersistableService {
  Future<void> saveChangesAsync<T>({
    bool shouldNotifyListeners = false,
  });
}

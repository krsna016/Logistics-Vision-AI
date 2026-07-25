import '../entities/digital_register.dart';

abstract class RegisterRepository {
  Future<List<DigitalRegister>> getAllRegisters();
  Future<DigitalRegister?> getRegisterById(String id);
  Future<DigitalRegister?> getRegisterByWagonId(String wagonId);
  Future<void> updateRemarks(String registerId, String remarks);
  Future<void> incrementExportCount(String registerId);
  Future<void> updateLastOpened(String registerId);
}

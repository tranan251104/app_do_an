import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_client.dart';

class UserRepository {
  final ApiClient api;

  UserRepository(this.api);

  Future<Map<String, dynamic>> me() async {
    AppLogger.repo('USER', 'LOAD profile start');
    try {
      final response = await api.dio.get<Map<String, dynamic>>('/me');
      final data = Map<String, dynamic>.from(response.data?['data'] as Map);
      AppLogger.success(
        'USER',
        'LOAD profile success',
        {
          'id': AppLogger.mask(data['id']?.toString()),
          'email': AppLogger.mask(data['email']?.toString()),
          'phone': AppLogger.mask(data['phone']?.toString()),
        },
      );
      return data;
    } catch (error, stackTrace) {
      AppLogger.error('USER', 'LOAD profile failed', error: error, stackTrace: stackTrace);
      throw ApiClient.mapError(error);
    }
  }

  Future<Map<String, dynamic>> update({
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
  }) async {
    AppLogger.repo(
      'USER',
      'UPDATE profile start',
      {
        'fullNameChanged': fullName != null,
        'dateOfBirthChanged': dateOfBirth != null,
        'genderChanged': gender != null,
        'addressChanged': address != null,
      },
    );
    try {
      final response = await api.dio.patch<Map<String, dynamic>>(
        '/me',
        data: {
          if (fullName != null) 'fullName': fullName,
          'dateOfBirth': dateOfBirth == null
              ? null
              : '${dateOfBirth.year.toString().padLeft(4, '0')}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}',
          'gender': gender,
          'address': address,
        },
      );
      final data = Map<String, dynamic>.from(response.data?['data'] as Map);
      AppLogger.success('USER', 'UPDATE profile success');
      return data;
    } catch (error, stackTrace) {
      AppLogger.error('USER', 'UPDATE profile failed', error: error, stackTrace: stackTrace);
      throw ApiClient.mapError(error);
    }
  }
}

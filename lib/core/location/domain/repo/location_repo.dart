import '../../../network/base_response.dart';
import '../entities/current_location.dart';


  abstract class LocationRepository {
  Future<BaseResponse<CurrentLocation>> getCurrentLocation();
  }

import 'package:bloc_test/bloc_test.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/guest_browsing/guest_browsing_provider.dart';
import 'package:flower_app/core/location/location_model.dart';
import 'package:flower_app/core/location/location_service.dart';
import 'package:flower_app/features/Address/domain/entities/add_address_entity.dart';
import 'package:flower_app/features/Address/domain/entities/address_entity.dart';
import 'package:flower_app/features/Address/domain/entities/area_entity.dart';
import 'package:flower_app/features/Address/domain/entities/city_entity.dart';
import 'package:flower_app/features/Address/domain/entities/geocoded_location_result.dart';
import 'package:flower_app/features/Address/domain/use_cases/add_address_use_case.dart';
import 'package:flower_app/features/Address/domain/use_cases/get_areas_with_cities_use_case.dart';
import 'package:flower_app/features/Address/domain/use_cases/get_current_location_usecase.dart';
import 'package:flower_app/features/Address/domain/use_cases/get_saved_address_use_case.dart';
import 'package:flower_app/features/Address/domain/use_cases/resolve_location_with _areas_use_case.dart';
import 'package:flower_app/features/Address/domain/use_cases/set_default_address_use_case.dart';
import 'package:flower_app/features/Address/presentaion/manager/address_cubit.dart';
import 'package:flower_app/features/Address/presentaion/manager/address_events.dart';
import 'package:flower_app/features/Address/presentaion/manager/address_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'address_cubit_test.mocks.dart';

@GenerateMocks([
  GetSavedAddressesUseCase,
  AddAddressUseCase,
  SetDefaultAddressUseCase,
  GuestBrowsingProvider,
  GetAreasWithCitiesUseCase,
  GetCurrentLocationUseCase,
  ResolveLocationWithAreasUseCase,
  LocationService,
])
void main() {
  late AddressCubit cubit;
  late MockGetSavedAddressesUseCase mockGetSavedAddressesUseCase;
  late MockAddAddressUseCase mockAddAddressUseCase;
  late MockSetDefaultAddressUseCase mockSetDefaultAddressUseCase;
  late MockGuestBrowsingProvider mockGuestBrowsingProvider;
  late MockGetAreasWithCitiesUseCase mockGetAreasWithCitiesUseCase;
  late MockGetCurrentLocationUseCase mockGetCurrentLocationUseCase;
  late MockResolveLocationWithAreasUseCase mockResolveLocationWithAreasUseCase;
  late MockLocationService mockLocationService;

  provideDummy<BaseResponse<List<AddressEntity>>>(
    const SuccessResponse<List<AddressEntity>>([]),
  );

  provideDummy<BaseResponse<List<AreaEntity>>>(
    const SuccessResponse<List<AreaEntity>>([]),
  );

  provideDummy<BaseResponse<AddressEntity>>(
    const SuccessResponse<AddressEntity>(
      AddressEntity(id: 'dummy_id'),
    ),
  );

  provideDummy<BaseResponse<LatLng>>(
    SuccessResponse<LatLng>(const LatLng(0, 0)),
  );

  provideDummy<BaseResponse<GeocodedLocationResult>>(
    SuccessResponse<GeocodedLocationResult>(
      GeocodedLocationResult(
        location: const LatLng(0, 0),
        details: const LocationModel(lat: 0, lng: 0),
      ),
    ),
  );

  setUp(() {
    mockGetSavedAddressesUseCase = MockGetSavedAddressesUseCase();
    mockAddAddressUseCase = MockAddAddressUseCase();
    mockSetDefaultAddressUseCase = MockSetDefaultAddressUseCase();
    mockGuestBrowsingProvider = MockGuestBrowsingProvider();
    mockGetAreasWithCitiesUseCase = MockGetAreasWithCitiesUseCase();
    mockGetCurrentLocationUseCase = MockGetCurrentLocationUseCase();
    mockResolveLocationWithAreasUseCase = MockResolveLocationWithAreasUseCase();
    mockLocationService = MockLocationService();

    cubit = AddressCubit(
      mockGetSavedAddressesUseCase,
      mockAddAddressUseCase,
      mockSetDefaultAddressUseCase,
      mockGuestBrowsingProvider,
      mockGetAreasWithCitiesUseCase,
      mockGetCurrentLocationUseCase,
      mockResolveLocationWithAreasUseCase,
      mockLocationService,
    );
  });

  tearDown(() {
    cubit.close();
  });

  const tAddress = AddressEntity(
    id: 'addr_1',
    recipientName: 'Ahmed Hassan',
    recipientPhone: '01000000000',
    addressLine: 'Street 9, Maadi',
    cityId: 'city_cairo',
    areaId: 'area_maadi',
    lat: 29.96,
    lng: 31.25,
    label: 'Home',
    isDefault: false,
  );

  const tAddress2 = AddressEntity(
    id: 'addr_2',
    recipientName: 'Ahmed Hassan',
    recipientPhone: '01000000000',
    addressLine: 'Street 10, New Cairo',
    cityId: 'city_cairo',
    areaId: 'area_new_cairo',
    lat: 30.01,
    lng: 31.45,
    label: 'Work',
    isDefault: true,
  );

  const tAddAddressEntity = AddAddressEntity(
    recipientName: 'Ahmed Hassan',
    recipientPhone: '01000000000',
    addressLine: 'Street 9, Maadi',
    city: 'city_cairo',
    area: 'area_maadi',
    lat: 29.96,
    lng: 31.25,
    label: 'Home',
  );

  const tCity = CityEntity(id: 'city_cairo', name: 'Cairo');
  const tCity2 = CityEntity(id: 'city_giza', name: 'Giza');
  const tArea = AreaEntity(id: 'area_maadi', name: 'Maadi', cities: [tCity]);

  // ============================================================
  // INITIAL STATE
  // ============================================================
  test('initial state should match AddressState.initial()', () {
    expect(cubit.state, equals(AddressState.initial()));
  });

  // ============================================================
  // GET SAVED ADDRESSES
  // ============================================================
  group('GetSavedAddressesEvent', () {
    blocTest<AddressCubit, AddressState>(
      'emits guest state when user is a guest',
      build: () {
        when(mockGuestBrowsingProvider.isGuest()).thenAnswer((_) async => true);
        return cubit;
      },
      act: (cubit) => cubit.doEvents(GetSavedAddressesEvent()),
      expect: () => [
        AddressState.initial().copyWith(
          isGuest: true,
          addresses: const [],
          selectedAddress: null,
          getAddressesResource: Resource.initial(),
        ),
      ],
      verify: (_) {
        verify(mockGuestBrowsingProvider.isGuest()).called(1);
        verifyNever(mockGetSavedAddressesUseCase());
      },
    );

    blocTest<AddressCubit, AddressState>(
      'emits [loading, success] with default Address selected when available',
      build: () {
        when(mockGuestBrowsingProvider.isGuest()).thenAnswer((_) async => false);
        when(mockGetSavedAddressesUseCase()).thenAnswer(
              (_) async => const SuccessResponse<List<AddressEntity>>([tAddress, tAddress2]),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(GetSavedAddressesEvent()),
      expect: () => [
        AddressState.initial().copyWith(
          isGuest: false,
          getAddressesResource: Resource.loading(),
        ),
        AddressState.initial().copyWith(
          isGuest: false,
          addresses: const [tAddress, tAddress2],
          selectedAddress: tAddress2,
          getAddressesResource: Resource.success(const [tAddress, tAddress2]),
        ),
      ],
    );

    blocTest<AddressCubit, AddressState>(
      'emits [loading, error] when use case fails',
      build: () {
        when(mockGuestBrowsingProvider.isGuest()).thenAnswer((_) async => false);
        when(mockGetSavedAddressesUseCase()).thenAnswer(
              (_) async => ErrorResponse<List<AddressEntity>>(
            errMessage: 'Failed to load addresses',
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(GetSavedAddressesEvent()),
      expect: () => [
        AddressState.initial().copyWith(
          isGuest: false,
          getAddressesResource: Resource.loading(),
        ),
        AddressState.initial().copyWith(
          isGuest: false,
          getAddressesResource: Resource.error('Failed to load addresses'),
        ),
      ],
    );
  });

  // ============================================================
  // GET AREAS WITH CITIES
  // ============================================================
  group('GetAreasWithCitiesEvent', () {
    blocTest<AddressCubit, AddressState>(
      'emits [loading, success] with updated areas when use case succeeds',
      build: () {
        when(mockGetAreasWithCitiesUseCase()).thenAnswer(
              (_) async => const SuccessResponse<List<AreaEntity>>([tArea]),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(GetAreasWithCitiesEvent()),
      expect: () => [
        AddressState.initial().copyWith(
          areasResource: Resource.loading(),
        ),
        AddressState.initial().copyWith(
          areas: const [tArea],
          areasResource: Resource.success(const [tArea]),
        ),
      ],
    );

    blocTest<AddressCubit, AddressState>(
      'emits [loading, error] when use case returns ErrorResponse',
      build: () {
        when(mockGetAreasWithCitiesUseCase()).thenAnswer(
              (_) async => ErrorResponse<List<AreaEntity>>(
            errMessage: 'Failed to fetch areas',
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(GetAreasWithCitiesEvent()),
      expect: () => [
        AddressState.initial().copyWith(
          areasResource: Resource.loading(),
        ),
        AddressState.initial().copyWith(
          areasResource: Resource.error('Failed to fetch areas'),
        ),
      ],
    );
  });

  // ============================================================
  // ADD ADDRESS
  // ============================================================
  group('AddAddressEvent', () {
    blocTest<AddressCubit, AddressState>(
      'emits [loading, success] and clears selection fields on success',
      build: () {
        when(mockAddAddressUseCase(any)).thenAnswer(
              (_) async => const SuccessResponse<AddressEntity>(tAddress),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(AddAddressEvent(tAddAddressEntity)),
      expect: () => [
        AddressState.initial().copyWith(
          addAddressResource: Resource.loading(),
        ),
        AddressState.initial().copyWith(
          addresses: const [tAddress],
          selectedAddress: tAddress,
          addAddressResource: Resource.success(tAddress),
          selectedLocation: null,
          selectedLocationDetails: null,
          selectedCity: null,
          selectedArea: null,
        ),
      ],
    );

    blocTest<AddressCubit, AddressState>(
      'emits [loading, error] when use case fails',
      build: () {
        when(mockAddAddressUseCase(any)).thenAnswer(
              (_) async => ErrorResponse<AddressEntity>(
            errMessage: 'Address was not created',
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(AddAddressEvent(tAddAddressEntity)),
      expect: () => [
        AddressState.initial().copyWith(
          addAddressResource: Resource.loading(),
        ),
        AddressState.initial().copyWith(
          addAddressResource: Resource.error('Address was not created'),
        ),
      ],
    );
  });

  // ============================================================
  // RESET ADD ADDRESS STATE
  // ============================================================
  group('ResetAddAddressStateEvent', () {
    blocTest<AddressCubit, AddressState>(
      'resets addAddressResource back to initial',
      seed: () => AddressState.initial().copyWith(
        addAddressResource: Resource.success(tAddress),
      ),
      build: () => cubit,
      act: (cubit) => cubit.doEvents(ResetAddAddressStateEvent()),
      expect: () => [
        AddressState.initial().copyWith(
          addAddressResource: Resource.initial(),
        ),
      ],
    );
  });

  // ============================================================
  // SELECTION EVENTS
  // ============================================================
  group('Selection Events', () {
    blocTest<AddressCubit, AddressState>(
      'SelectAddressEvent updates selectedAddress in state',
      build: () => cubit,
      act: (cubit) => cubit.doEvents(SelectAddressEvent(tAddress)),
      expect: () => [
        AddressState.initial().copyWith(selectedAddress: tAddress),
      ],
    );

    blocTest<AddressCubit, AddressState>(
      'SelectAreaEvent keeps selectedCity if contained in the new area',
      seed: () => AddressState.initial().copyWith(
        selectedCity: tCity,
      ),
      build: () => cubit,
      act: (cubit) => cubit.doEvents(SelectAreaEvent(tArea)),
      expect: () => [
        AddressState.initial().copyWith(
          selectedArea: tArea,
          selectedCity: tCity,
        ),
      ],
    );

    blocTest<AddressCubit, AddressState>(
      'SelectAreaEvent resets selectedCity to null if not present in the new area',
      seed: () => AddressState.initial().copyWith(
        selectedCity: tCity2,
      ),
      build: () => cubit,
      act: (cubit) => cubit.doEvents(SelectAreaEvent(tArea)),
      expect: () => [
        AddressState.initial().copyWith(
          selectedArea: tArea,
          selectedCity: null,
        ),
      ],
    );

    blocTest<AddressCubit, AddressState>(
      'SelectCityEvent updates selectedCity in state',
      build: () => cubit,
      act: (cubit) => cubit.doEvents(SelectCityEvent(tCity)),
      expect: () => [
        AddressState.initial().copyWith(selectedCity: tCity),
      ],
    );
  });

  // ============================================================
  // LOCATION & RESOLUTION
  // ============================================================
  group('Location Events', () {
    final tLatLng = const LatLng(29.96, 31.25);
    const tLocationDetails = LocationModel(
      lat: 29.96,
      lng: 31.25,
      addressLine: 'Street 9, Maadi',
      city: 'Cairo',
      area: 'Maadi',
    );

    final tResolvedResult = GeocodedLocationResult(
      location: tLatLng,
      details: tLocationDetails,
      matchedArea: tArea,
      matchedCity: tCity,
    );

    blocTest<AddressCubit, AddressState>(
      'SelectLocationEvent emits loading then updates state with resolved location details',
      seed: () => AddressState.initial().copyWith(
        areas: const [tArea],
      ),
      build: () {
        when(
          mockResolveLocationWithAreasUseCase(
            location: tLatLng,
            areas: const [tArea],
          ),
        ).thenAnswer(
              (_) async => SuccessResponse<GeocodedLocationResult>(tResolvedResult),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(SelectLocationEvent(tLatLng)),
      expect: () => [
        AddressState.initial().copyWith(
          areas: const [tArea],
          selectedLocation: tLatLng,
          locationDetailsResource: Resource.loading(),
        ),
        AddressState.initial().copyWith(
          areas: const [tArea],
          selectedLocation: tLatLng,
          selectedLocationDetails: tLocationDetails,
          selectedArea: tArea,
          selectedCity: tCity,
          locationDetailsResource: Resource.success(tResolvedResult),
        ),
      ],
    );

    blocTest<AddressCubit, AddressState>(
      'GetCurrentLocationEvent resolves coordinates and calls selectLocation',
      seed: () => AddressState.initial().copyWith(
        areas: const [tArea],
      ),
      build: () {
        when(mockGetCurrentLocationUseCase()).thenAnswer(
              (_) async => SuccessResponse<LatLng>(tLatLng),
        );
        when(
          mockResolveLocationWithAreasUseCase(
            location: tLatLng,
            areas: const [tArea],
          ),
        ).thenAnswer(
              (_) async => SuccessResponse<GeocodedLocationResult>(tResolvedResult),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(GetCurrentLocationEvent()),
      expect: () => [
        AddressState.initial().copyWith(
          areas: const [tArea],
          selectedLocation: tLatLng,
          locationDetailsResource: Resource.loading(),
        ),
        AddressState.initial().copyWith(
          areas: const [tArea],
          selectedLocation: tLatLng,
          selectedLocationDetails: tLocationDetails,
          selectedArea: tArea,
          selectedCity: tCity,
          locationDetailsResource: Resource.success(tResolvedResult),
        ),
      ],
    );
  });

  // ============================================================
  // SET DEFAULT ADDRESS
  // ============================================================
  group('SetDefaultAddressEvent', () {
    final tUpdatedAddress = tAddress.copyWith(isDefault: true);

    blocTest<AddressCubit, AddressState>(
      'emits loading then success with updated default Address list',
      seed: () => AddressState.initial().copyWith(
        addresses: [tAddress, tAddress2],
      ),
      build: () {
        when(mockSetDefaultAddressUseCase('addr_1')).thenAnswer(
              (_) async => SuccessResponse<AddressEntity>(tUpdatedAddress),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(SetDefaultAddressEvent('addr_1')),
      expect: () => [
        AddressState.initial().copyWith(
          addresses: [tAddress, tAddress2],
          setDefaultAddressResource: Resource.loading(),
        ),
        AddressState.initial().copyWith(
          addresses: [tUpdatedAddress, tAddress2.copyWith(isDefault: false)],
          selectedAddress: tUpdatedAddress,
          setDefaultAddressResource: Resource.success(tUpdatedAddress),
        ),
      ],
    );

    blocTest<AddressCubit, AddressState>(
      'emits [loading, error] when setDefaultAddressUseCase fails',
      seed: () => AddressState.initial().copyWith(
        addresses: const [tAddress],
      ),
      build: () {
        when(mockSetDefaultAddressUseCase('addr_1')).thenAnswer(
              (_) async => ErrorResponse<AddressEntity>(errMessage: 'Update failed'),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(SetDefaultAddressEvent('addr_1')),
      expect: () => [
        AddressState.initial().copyWith(
          addresses: const [tAddress],
          setDefaultAddressResource: Resource.loading(),
        ),
        AddressState.initial().copyWith(
          addresses: const [tAddress],
          setDefaultAddressResource: Resource.error('Update failed'),
        ),
      ],
    );
  });

  // ============================================================
  // RESOLVE HOME ADDRESS
  // ============================================================
  group('ResolveHomeAddressEvent', () {
    final tGpsPosition = const LatLng(29.96, 31.25);

    blocTest<AddressCubit, AddressState>(
      'does nothing when user is guest',
      seed: () => AddressState.initial().copyWith(
        addresses: const [tAddress, tAddress2],
      ),
      build: () {
        when(mockGuestBrowsingProvider.isGuest()).thenAnswer((_) async => true);
        return cubit;
      },
      act: (cubit) => cubit.doEvents(ResolveHomeAddressEvent()),
      expect: () => [
        AddressState.initial().copyWith(
          isGuest: true,
          addresses: const [tAddress, tAddress2],
        ),
      ],
      verify: (_) {
        verifyNever(mockGetCurrentLocationUseCase());
        verifyNever(mockLocationService.getClosestAddress(any, any));
      },
    );

    blocTest<AddressCubit, AddressState>(
      'does nothing when authenticated user has no addresses',
      seed: () => AddressState.initial().copyWith(
        addresses: const [],
      ),
      build: () {
        when(mockGuestBrowsingProvider.isGuest()).thenAnswer((_) async => false);
        return cubit;
      },
      act: (cubit) => cubit.doEvents(ResolveHomeAddressEvent()),
      expect: () => [
        AddressState.initial().copyWith(
          isGuest: false,
          addresses: const [],
        ),
      ],
      verify: (_) {
        verifyNever(mockGetCurrentLocationUseCase());
      },
    );

    blocTest<AddressCubit, AddressState>(
      'finds closest Address and calls setDefaultAddress if not already default',
      seed: () => AddressState.initial().copyWith(
        addresses: [tAddress, tAddress2],
      ),
      build: () {
        when(mockGuestBrowsingProvider.isGuest()).thenAnswer((_) async => false);
        when(mockGetCurrentLocationUseCase()).thenAnswer(
              (_) async => SuccessResponse<LatLng>(tGpsPosition),
        );
        when(
          mockLocationService.getClosestAddress([tAddress, tAddress2], tGpsPosition),
        ).thenReturn(tAddress); // tAddress has isDefault: false

        when(mockSetDefaultAddressUseCase('addr_1')).thenAnswer(
              (_) async => SuccessResponse<AddressEntity>(tAddress.copyWith(isDefault: true)),
        );

        return cubit;
      },
      act: (cubit) => cubit.doEvents(ResolveHomeAddressEvent()),
      expect: () => [
        AddressState.initial().copyWith(
          addresses: [tAddress, tAddress2],
          setDefaultAddressResource: Resource.loading(),
        ),
        AddressState.initial().copyWith(
          addresses: [tAddress.copyWith(isDefault: true), tAddress2.copyWith(isDefault: false)],
          selectedAddress: tAddress.copyWith(isDefault: true),
          setDefaultAddressResource: Resource.success(tAddress.copyWith(isDefault: true)),
        ),
      ],
      verify: (_) {
        verify(mockSetDefaultAddressUseCase('addr_1')).called(1);
      },
    );

    blocTest<AddressCubit, AddressState>(
      'selects closest Address without API call if already default',
      seed: () => AddressState.initial().copyWith(
        addresses: const [tAddress, tAddress2],
      ),
      build: () {
        when(mockGuestBrowsingProvider.isGuest()).thenAnswer((_) async => false);
        when(mockGetCurrentLocationUseCase()).thenAnswer(
              (_) async => SuccessResponse<LatLng>(tGpsPosition),
        );
        when(
          mockLocationService.getClosestAddress(const [tAddress, tAddress2], tGpsPosition),
        ).thenReturn(tAddress2); // tAddress2 has isDefault: true

        return cubit;
      },
      act: (cubit) => cubit.doEvents(ResolveHomeAddressEvent()),
      expect: () => [
        AddressState.initial().copyWith(
          addresses: const [tAddress, tAddress2],
          setDefaultAddressResource: Resource.loading(),
        ),
        AddressState.initial().copyWith(
          addresses: const [tAddress, tAddress2],
          selectedAddress: tAddress2,
          setDefaultAddressResource: Resource.success(tAddress2),
        ),
      ],
      verify: (_) {
        verifyNever(mockSetDefaultAddressUseCase(any));
      },
    );

    blocTest<AddressCubit, AddressState>(
      'falls back to default Address when getCurrentLocation fails',
      seed: () => AddressState.initial().copyWith(
        addresses: const [tAddress, tAddress2],
      ),
      build: () {
        when(mockGuestBrowsingProvider.isGuest()).thenAnswer((_) async => false);
        when(mockGetCurrentLocationUseCase()).thenAnswer(
              (_) async => ErrorResponse<LatLng>(errMessage: 'Location disabled'),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(ResolveHomeAddressEvent()),
      expect: () => [
        AddressState.initial().copyWith(
          addresses: const [tAddress, tAddress2],
          setDefaultAddressResource: Resource.loading(),
        ),
        AddressState.initial().copyWith(
          addresses: const [tAddress, tAddress2],
          selectedAddress: tAddress2,
          setDefaultAddressResource: Resource.success(tAddress2),
        ),
      ],
    );

    blocTest<AddressCubit, AddressState>(
      'falls back to default Address when getClosestAddress returns null',
      seed: () => AddressState.initial().copyWith(
        addresses: const [tAddress, tAddress2],
      ),
      build: () {
        when(mockGuestBrowsingProvider.isGuest()).thenAnswer((_) async => false);
        when(mockGetCurrentLocationUseCase()).thenAnswer(
              (_) async => SuccessResponse<LatLng>(tGpsPosition),
        );
        when(
          mockLocationService.getClosestAddress(const [tAddress, tAddress2], tGpsPosition),
        ).thenReturn(null);
        return cubit;
      },
      act: (cubit) => cubit.doEvents(ResolveHomeAddressEvent()),
      expect: () => [
        AddressState.initial().copyWith(
          addresses: const [tAddress, tAddress2],
          setDefaultAddressResource: Resource.loading(),
        ),
        AddressState.initial().copyWith(
          addresses: const [tAddress, tAddress2],
          selectedAddress: tAddress2,
          setDefaultAddressResource: Resource.success(tAddress2),
        ),
      ],
    );
  });

  // ============================================================
  // RESET TO GUEST
  // ============================================================
  group('resetToGuest', () {
    blocTest<AddressCubit, AddressState>(
      'resets addresses, selectedAddress, and marks isGuest as true',
      seed: () => AddressState.initial().copyWith(
        isGuest: false,
        addresses: const [tAddress, tAddress2],
        selectedAddress: tAddress,
        getAddressesResource: Resource.success(const [tAddress, tAddress2]),
      ),
      build: () => cubit,
      act: (cubit) => cubit.resetToGuest(),
      expect: () => [
        AddressState.initial().copyWith(
          isGuest: true,
          addresses: const [],
          selectedAddress: null,
          getAddressesResource: Resource.initial(),
        ),
      ],
    );
  });
}
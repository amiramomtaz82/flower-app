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
import 'package:flower_app/features/Address/domain/use_cases/add_address_usecase.dart';
import 'package:flower_app/features/Address/domain/use_cases/get_areas_with_cities_usecase.dart';
import 'package:flower_app/features/Address/domain/use_cases/get_saved_address_useacse.dart';
import 'package:flower_app/features/Address/domain/use_cases/set_default_address_usecase.dart';
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
  LocationService,
  SetDefaultAddressUseCase,
  GuestBrowsingProvider,
  GetAreasWithCitiesUseCase,
])
void main() {
  late AddressCubit cubit;
  late MockGetSavedAddressesUseCase mockGetSavedAddressesUseCase;
  late MockAddAddressUseCase mockAddAddressUseCase;
  late MockLocationService mockLocationService;
  late MockSetDefaultAddressUseCase mockSetDefaultAddressUseCase;
  late MockGuestBrowsingProvider mockGuestBrowsingProvider;
  late MockGetAreasWithCitiesUseCase mockGetAreasWithCitiesUseCase;

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

  setUp(() {
    mockGetSavedAddressesUseCase = MockGetSavedAddressesUseCase();
    mockAddAddressUseCase = MockAddAddressUseCase();
    mockLocationService = MockLocationService();
    mockSetDefaultAddressUseCase = MockSetDefaultAddressUseCase();
    mockGuestBrowsingProvider = MockGuestBrowsingProvider();
    mockGetAreasWithCitiesUseCase = MockGetAreasWithCitiesUseCase();

    cubit = AddressCubit(
      mockGetSavedAddressesUseCase,
      mockAddAddressUseCase,
      mockLocationService,
      mockSetDefaultAddressUseCase,
      mockGuestBrowsingProvider,
      mockGetAreasWithCitiesUseCase,
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
      'emits [loading, success] with addresses list when use case succeeds',
      build: () {
        when(mockGetSavedAddressesUseCase()).thenAnswer(
              (_) async => const SuccessResponse<List<AddressEntity>>([tAddress]),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(GetSavedAddressesEvent()),
      expect: () => [
        AddressState.initial().copyWith(
          getAddressesResource: Resource.loading(),
        ),
        AddressState.initial().copyWith(
          addresses: [tAddress],
          getAddressesResource: Resource.success([tAddress]),
        ),
      ],
      verify: (_) {
        verify(mockGetSavedAddressesUseCase()).called(1);
      },
    );

    blocTest<AddressCubit, AddressState>(
      'emits [loading, error] when use case returns ErrorResponse',
      build: () {
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
          getAddressesResource: Resource.loading(),
        ),
        AddressState.initial().copyWith(
          getAddressesResource: Resource.error('Failed to load addresses'),
        ),
      ],
      verify: (_) {
        verify(mockGetSavedAddressesUseCase()).called(1);
      },
    );
  });

  // ============================================================
  // GET AREAS WITH CITIES
  // ============================================================
  group('GetAreasWithCitiesEvent', () {
    blocTest<AddressCubit, AddressState>(
      'emits state with updated areas when usecase returns SuccessResponse',
      build: () {
        when(mockGetAreasWithCitiesUseCase()).thenAnswer(
              (_) async => const SuccessResponse<List<AreaEntity>>([tArea]),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(GetAreasWithCitiesEvent()),
      expect: () => [
        AddressState.initial().copyWith(areas: [tArea]),
      ],
      verify: (_) {
        verify(mockGetAreasWithCitiesUseCase()).called(1);
      },
    );

    blocTest<AddressCubit, AddressState>(
      'emits nothing when usecase returns ErrorResponse',
      build: () {
        when(mockGetAreasWithCitiesUseCase()).thenAnswer(
              (_) async => ErrorResponse<List<AreaEntity>>(
            errMessage: 'Failed to fetch areas',
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(GetAreasWithCitiesEvent()),
      expect: () => [],
      verify: (_) {
        verify(mockGetAreasWithCitiesUseCase()).called(1);
      },
    );
  });

  // ============================================================
  // ADD ADDRESS
  // ============================================================
  group('AddAddressEvent', () {
    blocTest<AddressCubit, AddressState>(
      'emits [loading, success] and resets location/city/area form fields on success',
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
          addresses: [tAddress],
          selectedAddress: tAddress,
          addAddressResource: Resource.success(tAddress),
          selectedLocation: null,
          selectedLocationDetails: null,
          selectedCity: null,
          selectedArea: null,
        ),
      ],
      verify: (_) {
        verify(mockAddAddressUseCase(tAddAddressEntity)).called(1);
      },
    );

    blocTest<AddressCubit, AddressState>(
      'emits [loading, error] when use case returns ErrorResponse',
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
      verify: (_) {
        verify(mockAddAddressUseCase(tAddAddressEntity)).called(1);
      },
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
      'SelectAreaEvent keeps selectedCity if present in the new area',
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
          selectedCity: tCity2, // copyWith retains previous value when null is passed
          selectedArea: tArea,
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
  // LOCATION & REVERSE GEOCODING
  // ============================================================
  group('Location Events', () {
    final tLatLng = LatLng(29.96, 31.25);
    const tLocationDetails = LocationModel(
      lat: 29.96,
      lng: 31.25,
      addressLine: 'Street 9, Maadi',
      city: 'Cairo',
      area: 'Maadi',
    );

    blocTest<AddressCubit, AddressState>(
      'SelectLocationEvent performs reverse geocoding, matches city/area, and updates state',
      seed: () => AddressState.initial().copyWith(
        areas: [tArea],
      ),
      build: () {
        when(
          mockLocationService.reverseGeocode(
            lat: anyNamed('lat'),
            lng: anyNamed('lng'),
          ),
        ).thenAnswer((_) async => tLocationDetails);
        return cubit;
      },
      act: (cubit) => cubit.doEvents(SelectLocationEvent(tLatLng)),
      expect: () => [
        AddressState.initial().copyWith(
          areas: [tArea],
          selectedLocation: tLatLng,
        ),
        AddressState.initial().copyWith(
          areas: [tArea],
          selectedLocation: tLatLng,
          selectedLocationDetails: tLocationDetails,
          selectedCity: tCity,
          selectedArea: tArea,
        ),
      ],
      verify: (_) {
        verify(
          mockLocationService.reverseGeocode(
            lat: tLatLng.latitude,
            lng: tLatLng.longitude,
          ),
        ).called(1);
      },
    );

    blocTest<AddressCubit, AddressState>(
      'GetCurrentLocationEvent calls getCurrentLocation and selects the location',
      seed: () => AddressState.initial().copyWith(
        areas: [tArea],
      ),
      build: () {
        when(mockLocationService.getCurrentLocation()).thenAnswer(
              (_) async => tLatLng,
        );
        when(
          mockLocationService.reverseGeocode(
            lat: anyNamed('lat'),
            lng: anyNamed('lng'),
          ),
        ).thenAnswer((_) async => tLocationDetails);
        return cubit;
      },
      act: (cubit) => cubit.doEvents(GetCurrentLocationEvent()),
      expect: () => [
        AddressState.initial().copyWith(
          areas: [tArea],
          selectedLocation: tLatLng,
        ),
        AddressState.initial().copyWith(
          areas: [tArea],
          selectedLocation: tLatLng,
          selectedLocationDetails: tLocationDetails,
          selectedCity: tCity,
          selectedArea: tArea,
        ),
      ],
      verify: (_) {
        verify(mockLocationService.getCurrentLocation()).called(1);
      },
    );
  });

  // ============================================================
  // SET DEFAULT ADDRESS
  // ============================================================
  group('SetDefaultAddressEvent', () {
    final tInitialList = [
      tAddress.copyWith(isDefault: false),
      tAddress2.copyWith(isDefault: true),
    ];

    final tOptimisticList = [
      tAddress.copyWith(isDefault: true),
      tAddress2.copyWith(isDefault: false),
    ];

    final tBackendSuccessAddress = tAddress.copyWith(
      isDefault: true,
      recipientName: 'Ahmed Hassan Updated',
    );

    final tConfirmedList = [
      tBackendSuccessAddress,
      tAddress2.copyWith(isDefault: false),
    ];

    blocTest<AddressCubit, AddressState>(
      'optimistically updates badges and confirms when API succeeds',
      seed: () => AddressState.initial().copyWith(
        addresses: tInitialList,
        selectedAddress: tAddress2,
      ),
      build: () {
        when(mockSetDefaultAddressUseCase('addr_1')).thenAnswer(
              (_) async => SuccessResponse<AddressEntity>(tBackendSuccessAddress),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(SetDefaultAddressEvent('addr_1')),
      expect: () => [
        // 1. Optimistic emit
        AddressState.initial().copyWith(
          addresses: tOptimisticList,
          selectedAddress: tOptimisticList.first,
        ),
        // 2. Confirmed backend response emit
        AddressState.initial().copyWith(
          addresses: tConfirmedList,
          selectedAddress: tBackendSuccessAddress,
        ),
      ],
      verify: (_) {
        verify(mockSetDefaultAddressUseCase('addr_1')).called(1);
      },
    );

    blocTest<AddressCubit, AddressState>(
      'rolls back to previous state when API fails',
      seed: () => AddressState.initial().copyWith(
        addresses: tInitialList,
        selectedAddress: tAddress2,
      ),
      build: () {
        when(mockSetDefaultAddressUseCase('addr_1')).thenAnswer(
              (_) async => ErrorResponse<AddressEntity>(errMessage: 'Server failure'),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(SetDefaultAddressEvent('addr_1')),
      expect: () => [
        // 1. Optimistic emit
        AddressState.initial().copyWith(
          addresses: tOptimisticList,
          selectedAddress: tOptimisticList.first,
        ),
        // 2. Rollback emit
        AddressState.initial().copyWith(
          addresses: tInitialList,
          selectedAddress: tAddress2,
        ),
      ],
      verify: (_) {
        verify(mockSetDefaultAddressUseCase('addr_1')).called(1);
      },
    );
  });

  // ============================================================
  // RESOLVE HOME ADDRESS
  // ============================================================
  group('ResolveHomeAddressEvent', () {
    blocTest<AddressCubit, AddressState>(
      'sets isGuest to true and selectedAddress to null when user is guest',
      build: () {
        when(mockGuestBrowsingProvider.isGuest()).thenAnswer((_) async => true);
        return cubit;
      },
      act: (cubit) => cubit.doEvents(ResolveHomeAddressEvent()),
      expect: () => [
        AddressState.initial().copyWith(
          isGuest: true,
          selectedAddress: null,
        ),
      ],
      verify: (_) {
        verify(mockGuestBrowsingProvider.isGuest()).called(1);
        verifyNever(mockGetSavedAddressesUseCase());
      },
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
          selectedCity: tCity2, // copyWith retains previous value when null is passed
          selectedArea: tArea,
        ),
      ],
    );
    blocTest<AddressCubit, AddressState>(
      'automatically selects the only address if addresses length is 1',
      build: () {
        when(mockGuestBrowsingProvider.isGuest()).thenAnswer((_) async => false);
        when(mockGetSavedAddressesUseCase()).thenAnswer(
              (_) async => const SuccessResponse<List<AddressEntity>>([tAddress]),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(ResolveHomeAddressEvent()),
      expect: () => [
        AddressState.initial().copyWith(
          isGuest: false,
        ),
        AddressState.initial().copyWith(
          isGuest: false,
          getAddressesResource: Resource.loading(),
        ),
        AddressState.initial().copyWith(
          isGuest: false,
          addresses: [tAddress],
          getAddressesResource: Resource.success([tAddress]),
        ),
        AddressState.initial().copyWith(
          isGuest: false,
          addresses: [tAddress],
          getAddressesResource: Resource.success([tAddress]),
          selectedAddress: tAddress,
        ),
      ],
      verify: (_) {
        verifyNever(mockLocationService.getCurrentLocation());
      },
    );

    blocTest<AddressCubit, AddressState>(
      'selects closest address via LocationService when multiple addresses exist and GPS works',
      build: () {
        final tAddresses = [tAddress, tAddress2];
        final tCurrentLocation = LatLng(29.96, 31.25);

        when(mockGuestBrowsingProvider.isGuest()).thenAnswer((_) async => false);
        when(mockGetSavedAddressesUseCase()).thenAnswer(
              (_) async => SuccessResponse<List<AddressEntity>>(tAddresses),
        );
        when(mockLocationService.getCurrentLocation())
            .thenAnswer((_) async => tCurrentLocation);
        when(mockLocationService.getClosestAddress(tAddresses, tCurrentLocation))
            .thenReturn(tAddress);

        return cubit;
      },
      act: (cubit) => cubit.doEvents(ResolveHomeAddressEvent()),
      expect: () => [
        AddressState.initial().copyWith(
          isGuest: false,
        ),
        AddressState.initial().copyWith(
          isGuest: false,
          getAddressesResource: Resource.loading(),
        ),
        AddressState.initial().copyWith(
          isGuest: false,
          addresses: [tAddress, tAddress2],
          getAddressesResource: Resource.success([tAddress, tAddress2]),
        ),
        AddressState.initial().copyWith(
          isGuest: false,
          addresses: [tAddress, tAddress2],
          getAddressesResource: Resource.success([tAddress, tAddress2]),
          selectedAddress: tAddress,
        ),
      ],
    );

    blocTest<AddressCubit, AddressState>(
      'falls back to isDefault address if GPS throws an exception',
      build: () {
        final tAddresses = [tAddress, tAddress2];

        when(mockGuestBrowsingProvider.isGuest()).thenAnswer((_) async => false);
        when(mockGetSavedAddressesUseCase()).thenAnswer(
              (_) async => SuccessResponse<List<AddressEntity>>(tAddresses),
        );
        when(mockLocationService.getCurrentLocation())
            .thenThrow(Exception('GPS unavailable'));

        return cubit;
      },
      act: (cubit) => cubit.doEvents(ResolveHomeAddressEvent()),
      expect: () => [
        AddressState.initial().copyWith(
          isGuest: false,
        ),
        AddressState.initial().copyWith(
          isGuest: false,
          getAddressesResource: Resource.loading(),
        ),
        AddressState.initial().copyWith(
          isGuest: false,
          addresses: [tAddress, tAddress2],
          getAddressesResource: Resource.success([tAddress, tAddress2]),
        ),
        AddressState.initial().copyWith(
          isGuest: false,
          addresses: [tAddress, tAddress2],
          getAddressesResource: Resource.success([tAddress, tAddress2]),
          selectedAddress: tAddress2,
        ),
      ],
    );
  });
}
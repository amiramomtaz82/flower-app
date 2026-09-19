import 'dart:async';

import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/core/app_theme/app_theme.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';
import 'package:flower_app/features/profile/domain/use_cases/profile_use_case.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_cubit.dart';
import 'package:flower_app/features/profile/presentation/view/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'profile_view_test.mocks.dart';

// The view is driven through a real cubit with a mocked use case, so the test
// covers the wiring between the two rather than a stubbed-out state.
@GenerateMocks([GetProfileUseCase])
void main() {
  late MockGetProfileUseCase mockGetProfileUseCase;
  late ProfileCubit cubit;

  // no image url, so the avatar falls back to the icon instead of going to
  // the network, which widget tests cannot reach
  const profile = ProfileEntity(
    name: 'Hadi Heikal',
    email: 'hadi@test.com',
    profileImageUrl: '',
  );

  // mockito cannot build a value of a sealed type on its own
  setUpAll(() {
    provideDummy<BaseResponse<ProfileEntity>>(const SuccessResponse(profile));
  });

  // setup before each test, so mocks/stubs never leak between tests
  setUp(() {
    mockGetProfileUseCase = MockGetProfileUseCase();
    cubit = ProfileCubit(mockGetProfileUseCase);
  });

  tearDown(() => cubit.close());

  void stubProfile(BaseResponse<ProfileEntity> response) {
    when(mockGetProfileUseCase()).thenAnswer((_) async => response);
  }

  // the view reads its colors from the LightColors extension on the app theme
  Future<void> pumpView(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: BlocProvider<ProfileCubit>.value(
          value: cubit,
          child: const ProfileView(),
        ),
      ),
    );
  }

  // the view loads the profile by itself, nobody has to fire the event for it
  group('Profile Load Test', () {
    testWidgets('asks for the profile as soon as it opens', (tester) async {
      // Arrange
      stubProfile(const SuccessResponse(profile));

      // Act
      await pumpView(tester);

      // Assert
      verify(mockGetProfileUseCase()).called(1);
    });
  });

  group('Profile States Test', () {
    testWidgets('shows a spinner while the profile is loading', (
      tester,
    ) async {
      // Arrange: the request is left hanging so the loading state stays put
      final pending = Completer<BaseResponse<ProfileEntity>>();
      when(mockGetProfileUseCase()).thenAnswer((_) => pending.future);

      // Act
      await pumpView(tester);

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Hadi Heikal'), findsNothing);
    });

    testWidgets('shows the error message and a retry button when it fails', (
      tester,
    ) async {
      // Arrange
      stubProfile(
        ErrorResponse<ProfileEntity>(errMessage: 'No internet connection'),
      );

      // Act
      await pumpView(tester);
      await tester.pump(); // rebuild once the error comes back

      // Assert
      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
      expect(find.text('Hadi Heikal'), findsNothing);
    });

    testWidgets('tapping retry loads and shows the profile', (tester) async {
      // Arrange
      stubProfile(ErrorResponse<ProfileEntity>(errMessage: 'Server error'));
      await pumpView(tester);
      await tester.pump();
      // a later stub wins over the earlier one, so the retry succeeds
      stubProfile(const SuccessResponse(profile));

      // Act
      await tester.tap(find.text('Retry'));
      await tester.pump(); // dispatch the tap
      await tester.pump(); // rebuild once the profile comes back

      // Assert
      expect(find.text('Server error'), findsNothing);
      expect(find.text('Hadi Heikal'), findsOneWidget);
      verify(mockGetProfileUseCase()).called(2);
    });
  });

  // the loaded page: header, then the settings tiles
  group('Profile Content Test', () {
    testWidgets('renders the header and the menu tiles', (tester) async {
      // Arrange
      stubProfile(const SuccessResponse(profile));

      // Act
      await pumpView(tester);
      await tester.pump();

      // Assert
      expect(find.widgetWithText(AppBar, 'Profile'), findsOneWidget);
      expect(find.text('Hadi Heikal'), findsOneWidget);
      expect(find.text('hadi@test.com'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('My orders'), findsOneWidget);
      expect(find.text('Saved address'), findsOneWidget);
      expect(find.text('Notification'), findsOneWidget);
    });

    testWidgets('tapping the notification switch turns it off', (
      tester,
    ) async {
      // Arrange
      stubProfile(const SuccessResponse(profile));
      await pumpView(tester);
      await tester.pump();
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

      // Act
      await tester.tap(find.byType(Switch));
      await tester.pump();

      // Assert
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    });
  });
}

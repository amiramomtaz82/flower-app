class AppStrings {
  AppStrings._();
  static const String email = 'email';
  static const String submit = 'submit';
  static const String success = 'success';
  static const String home = 'commerce';
  static const String search = 'search';
  static const String profile = 'profile';
  static const String enterYourEmail = 'enter your email';
  static const String login = 'login';
  static const String password = 'password';
  static const String forgetPassword = 'forget password ';
  static const String forget_password = 'forget password ?';
  static const String continueAsGuest = 'continueAsGuest';
  static const String dontHaveAnAccount = 'dontHaveAnAccount';
  static const String signUp = 'signUp';
  static const String en = 'en';
  static const String ar = 'ar';
  static const String deviceId = 'device_id';
  static const String accessToken = 'accessToken';
  static const String pleaseFill = 'Please fill in all fields correctly';
  static const String enterEmailAssociatedToAccount =
      'Please enter your email associated to your account';
  static const String enterYourNewEmail = 'enter your new email';
  static const String confirm = 'confirm';
  static const String thisEmailIsNotValid = 'this email is not valid';
  static const String emailVerification = 'email verification';
  static const String enterCodeSentToEmail =
      'please enter your code that sent to your email address';
  static const String resend = 'resend';
  static const String dontReceiveCode = "don't receive code?";
  static const String invalidCode = 'invalid code';
  static const String resetPassword = 'reset password';
  static const String passwordRules =
      'password must not be empty and must contain 6 characters with upper case letter and one number at least';
  static const String codeSent = 'code sent successfully';
  static const String passwordsDoNotMatch = 'passwords do not match';
  static const String newPassword = 'new password';
  static const String enterYourPassword = 'enter your password';
  static const String confirmPassword = 'confirm password';
  static const String resetSessionExpired =
      'your reset code expired, please request a new one';

  // Error messages produced by `config/error` when the backend sends no
  // message of its own. The UI calls `.tr()` on whatever reaches it, so these
  // localize like any other key.
  static const String somethingWentWrong =
      'something went wrong, please try again';
  static const String checkYourConnection =
      'something went wrong, please check your connection';
  static const String connectionTimeout =
      'connection timeout, please try again';
  static const String noInternetConnection =
      'no internet connection, please check your network';
  static const String invalidCertificate =
      'invalid certificate, please try again later';
  static const String requestCancelled = 'request was cancelled';
  static const String invalidRequest =
      'invalid request, please check your input';
  static const String sessionExpired =
      'your session has expired, please log in again';
  static const String noPermission = "you don't have permission to do this";
  static const String dataNotFound = 'the requested data was not found';
  static const String conflictOccurred =
      'conflict occurred, the data might already exist';
  static const String invalidFields =
      'some fields are invalid, please check your input';
  static const String internalServerError =
      'internal server error, please try again later';

  // Empty states on the categories and occasions pages.
  static const String noCategoriesYet = 'no categories yet';
  static const String noOccasionsYet = 'no occasions yet';
  static const String noProductsInThisCategory =
      'no products in this category yet';
  static const String noProductsForThisOccasion =
      'no products for this occasion yet';
  static const String bloomWithBestSellers =
      'bloom with our exquisite best sellers';
  static const String sectionHasNoFilter =
      'this section has no occasion or category to load products for';
  static const String comingSoon = 'coming soon';
  static const String viewAll = 'View All';

  // Bottom nav bar labels.
  static const String navHome = 'Home';
  static const String navCategories = 'Categories';
  static const String navCart = 'Cart';
  static const String navProfile = 'Profile';
  static const String pleaseLoginOrRegisterToContinue="PleaseLoginOrRegisterToContinue";
  static const String loginRequired='Login required';
  static const String register="Register";
  static const String rememberMe="Remember me";
  static const String areasIsEmpty='Areas response is empty';
  static const String address='Address';
  static const String label='label';
  static const String addAddress='Add Address';
  static const String pleaseEnterALabel='Please enter a label';
  static const String recipientName='Recipient Name';
  static const String pleaseEnterRecipientName='Please enter recipient name';
  static const String recipientPhone='Recipient phone';
  static const String pleaseEnterPhoneNumber='Please enter phone number';
  static const String addressDetailsStreet='Address Details / Street';
  static const String pleaseEnterAddressDetails='Please enter address details';
  static const String area = 'area';
  static const String loadingAreas = 'loading_areas';
  static const String selectArea = 'select_area';
  static const String pleaseSelectArea = 'please_select_area';
  static const String city = 'city';
  static const String pickAreaFirst = 'pick_area_first';
  static const String noCities = 'no_cities';
  static const String selectCity = 'select_city';
  static const String pleaseSelectCity = 'please_select_city';
  static const String saveAddress = 'save_address';
  static const String pleaseSelectLocationOnMap = 'please_select_location_on_map';
  static const String defaultLabelHome = 'home';
static const String addressAddedSuccessfully='Address added successfully!';
  static const String failedToAddAddress = 'failed_to_add_address';
  static const String pleaseEnterLabel = 'please_enter_label';
  static const String phoneNumber = 'phone_number';

  static const String setAsDefault = 'sed as default';
  static const String cartId = 'cartId';
  static const String addressId = 'addressId';
  static const String checkoutTitle = 'checkout_title';
  static const String deliveryTime = 'delivery_time';
  static const String instant = 'instant';
  static const String arriveBy = 'arrive_by';
  static const String notDetermined = 'not_determined';
  static const String deliveryAddress = 'delivery_address';
  static const String noSavedAddresses = 'no_saved_addresses';
  static const String addNew = 'add_new';
  static const String paymentMethod = 'payment_method';
  static const String cashOnDelivery = 'cash_on_delivery';
  static const String creditCard = 'credit_card';
  static const String enterRecipientName = 'enter_recipient_name';
  static const String name = 'name';
  static const String enterRecipientPhone = 'enter_recipient_phone';

  static const String subTotal = 'sub_total';
  static const String deliveryFee = 'delivery_fee';
  static const String total = 'total';
  static const String placeOrder = 'place_order';
  static const String selectAddressWarning = 'select_address_warning';
  static const String orderFailedFallback = 'order_failed_fallback';

  static const String urlTemplate =  'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String userAgentPackageName = 'com.example.flower_app';
  static const String signInToAddAddress = 'sign_in_to_add_address';
  static const String noAddressFound = 'no_address_found';

  static const String defaultAddressFallback = 'default_address_fallback';
  static const String addressFallback = 'address_fallback';
  static const String addLabelTitle = 'add label title';
  static const String defaultBadge = 'default_badge';
  static const String addressDetailsRequired = 'Address details is required';

  static const String setAsDefaultAddress = 'set_as_default_address';
  static const String coordinatesFormat = 'coordinates_format';
  static const String egyptCurrency = 'Egy';
  static const String isGift = 'It is a gift';
  static const String tapMapToSelectLocation = 'tap_map_to_select_location';

}


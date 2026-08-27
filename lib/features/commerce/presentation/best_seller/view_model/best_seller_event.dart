sealed class BestSellerEvent {}

class LoadInitialBestSellers extends BestSellerEvent {}

class LoadMoreBestSellers extends BestSellerEvent {}

class RetryBestSellers extends BestSellerEvent {}

class RefreshBestSellers extends BestSellerEvent {}

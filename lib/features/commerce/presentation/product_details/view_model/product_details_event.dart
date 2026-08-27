sealed class ProductDetailsEvent {}

class LoadProductDetails extends ProductDetailsEvent {
  final String id;
  LoadProductDetails(this.id);
}

class UpdateImageIndex extends ProductDetailsEvent {
  final int index;
  UpdateImageIndex(this.index);
}

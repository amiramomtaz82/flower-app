sealed class MyOrdersEvent {}

class MyOrdersStarted extends MyOrdersEvent {}
class MyOrdersLoadMore extends MyOrdersEvent {}
class MyOrdersRetry extends MyOrdersEvent {}

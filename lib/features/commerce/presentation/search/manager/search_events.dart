sealed class SearchEvent {}

class SearchQueryChanged extends SearchEvent {
  SearchQueryChanged(this.keyword);
  final String keyword;
}

class SearchLoadMore extends SearchEvent {}

class SearchRetry extends SearchEvent {}

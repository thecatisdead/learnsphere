String getFriendlyError(dynamic e) {
  final errorText = e.toString().toLowerCase();

  if (errorText.contains('no_internet') ||
      errorText.contains('socketexception') ||
      errorText.contains('network') ||
      errorText.contains('failed host lookup')) {
    return "No internet connection. Please check your network.";
  }

  if (errorText.contains('rate_limit') ||
      errorText.contains('429') ||
      errorText.contains('rate limit') ||
      errorText.contains('resource exhausted')) {
    return "Rate limit reached. Please try again later.";
  }

  if (errorText.contains('timeout')) {
    return "The request timed out. Please try again.";
  }

  if (errorText.contains('server_error') ||
      errorText.contains('500') ||
      errorText.contains('502') ||
      errorText.contains('503')) {
    return "The AI server is temporarily unavailable. Please try again.";
  }

  return "Something went wrong. Please try again.";
}
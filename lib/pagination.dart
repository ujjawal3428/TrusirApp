import 'dart:convert';
import 'package:http/http.dart' as http;

class PaginationModule {
  bool _isLoading = false;

  /// Fetch data from the given URL and return the decoded response as a list of maps.
  /// This method prevents multiple concurrent requests by using `_isLoading`.
  Future<List<Map<String, dynamic>>> fetchData(String url) async {
    if (_isLoading) {
      throw Exception("Already loading data. Please wait.");
    }

    _isLoading = true;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Decoding the response as a List<Map<String, dynamic>> since the API returns an array
        List<dynamic> decodedResponse = jsonDecode(response.body);

        // Converting the dynamic list to a List<Map<String, dynamic>>
        return decodedResponse
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception(
            "Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching data: $e");
    } finally {
      _isLoading = false;
    }
  }
}

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:trusir/common/api.dart';

class DeleteUtility {
  static Future<bool> deleteItem(String model, int id) async {
    // If canceled, do nothing

    final String url = "$baseUrl/delete/$model/$id";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "$model Deleted Successfully");
        return true;
      } else {
        Fluttertoast.showToast(msg: "Error deleting $model with ID $id");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error deleting $model with ID $id: $e");
      return false;
    }
  }
}

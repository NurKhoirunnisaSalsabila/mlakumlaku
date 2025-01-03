import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';
import '../models/collections.dart';
import '../models/place.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class CollectionService {
  final String baseUrl = "https://nur-khoirunnisa-mlakumlaku2.pbp.cs.ui.ac.id";

  Future<List<Collection>> fetchCollections(CookieRequest request) async {
    final response = await request.get('$baseUrl/placeCollection/json/');
    if (response.isNotEmpty && response is List) {
      return response.map((json) => Collection.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch collections');
    }
  }

Future<void> createCollection(CookieRequest request, String name) async {
  try {
    print('Attempting to create collection with name: $name'); // Debug print

    final response = await request.post(
      '$baseUrl/placeCollection/create_collection_json/',
      {
        'name': name,
      },
    );

    print('Response received: $response'); // Debug print

    if (response['success'] == true) {
      print('Collection created: ${response['collection']}');
      // Handle successful creation
    } else {
      print('Failed to create collection: ${response['error']}');
      throw Exception(response['error'] ?? 'Unknown error');
    }
  } catch (e) {
    print('Error creating collection: $e');
    rethrow;
  }
}



Future<void> deleteCollection(CookieRequest request, int collectionId) async {
  try {
    final response = await request.post(
      '$baseUrl/placeCollection/delete_flut/$collectionId/',  // Make sure this matches your Django URL pattern
      json.encode({},)
    );

    if (response['success'] == true) {
      print("Collection deleted successfully");
    } else {
      throw Exception(response['error'] ?? 'Failed to delete collection');
    }
  } catch (e) {
    print('Error deleting collection: $e');
    rethrow;
  }
}

Future<String> getCsrfToken() async {
  final response = await http.get(Uri.parse('https://nur-khoirunnisa-mlakumlaku2.pbp.cs.ui.ac.id/placeCollection/get-csrf-token/'));
  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    return responseData['csrfToken'];
  } else {
    throw Exception('Failed to load CSRF token');
  }
}


Future<List<Place>> fetchCollectionPlaces(int collectionId, CookieRequest request) async {
  final response = await request.get('$baseUrl/placeCollection/$collectionId/places/json/');

  if (response['error'] == null) {
    // Assume the response is a list of places
    List<dynamic> jsonData = response['places']; // Adjust based on your API response
    return jsonData.map((placeJson) => Place.fromJson(placeJson)).toList();
  } else {
    throw Exception('Failed to load collection places: ${response['error']}');
  }
}

Future<bool> addPlaceToCollections(
  CookieRequest request,
  int placeId,
  List<int> collectionIds
) async {
  try {
    final response = await request.post(
      '$baseUrl/places/place/$placeId/add_to_collection/',
      json.encode({
        'collections': collectionIds,
        'X-Requested-With': 'XMLHttpRequest',  // Add header as part of the data
      },)
    );

    print('Sending request to: $baseUrl/places/place/$placeId/add_to_collection/');
    print('Request data: $collectionIds');
    print('Response received: $response');

    if (response['success'] == true) {
      return true;
    } else {
      throw Exception(response['error'] ?? 'Failed to add to collections');
    }
  } catch (e) {
    print('Error adding place to collections: $e');
    rethrow;
  }
}
}
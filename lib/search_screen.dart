
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// class SearchScreen extends StatefulWidget {
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _sourceController = TextEditingController();
//   final TextEditingController _destinationController = TextEditingController();
//   String? recommendedRouteId;
//   bool isLoading = false;

//   LatLng? sourceCoordinates;
//   LatLng? destinationCoordinates;

//   Future<void> fetchRecommendedRoute() async {
//     setState(() {
//       isLoading = true;
//       recommendedRouteId = null;
//       sourceCoordinates = null;
//       destinationCoordinates = null;
//     });

//     final String apiUrl = "http://127.0.0.1:8000/predict_route";

//     final Map<String, String> requestBody = {
//       "source_name": _sourceController.text,
//       "destination_name": _destinationController.text,
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(requestBody),
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         setState(() {
//           recommendedRouteId = data["recommended_route_id"];

//           // Extract coordinates from API response
//           sourceCoordinates = parseCoordinates(data["source_coordinates"]);
//           destinationCoordinates = parseCoordinates(data["dest_coordinates"]);
//         });
//       } else {
//         setState(() {
//           recommendedRouteId = "No route found";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         recommendedRouteId = "Error: Could not connect to server";
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   // Helper function to parse "lat, long" string into LatLng
//   LatLng? parseCoordinates(String? coordString) {
//     if (coordString == null) return null;
//     final parts = coordString.split(",");
//     if (parts.length != 2) return null;
//     return LatLng(double.parse(parts[0]), double.parse(parts[1]));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Bus Route Finder")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: _sourceController,
//               decoration: const InputDecoration(
//                 labelText: "Enter Source",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _destinationController,
//               decoration: const InputDecoration(
//                 labelText: "Enter Destination",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: isLoading ? null : fetchRecommendedRoute,
//               child: isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text("Find Best Route"),
//             ),
//             const SizedBox(height: 20),
//             if (recommendedRouteId != null)
//               Text(
//                 "Recommended Route ID: $recommendedRouteId",
//                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),

//             const SizedBox(height: 20),

//             // Display the map if coordinates are available
//             if (sourceCoordinates != null && destinationCoordinates != null)
//               Expanded(
//                 child: FlutterMap(
//                   options: MapOptions(
//                     initialCenter: sourceCoordinates!,  // ✅ Updated
//                     initialZoom: 13.0,                  // ✅ Updated
//                   ),
//                   children: [
//                     TileLayer(
//                       urlTemplate:
//                           "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                       subdomains: ['a', 'b', 'c'],
//                     ),
//                     MarkerLayer(
//                       markers: [
//                         Marker(
//                           point: sourceCoordinates!,
//                           width: 50.0,
//                           height: 50.0,
//                           child: const Icon(
//                             Icons.location_on,
//                             color: Colors.red,
//                             size: 30.0,
//                           ),
//                         ),
//                         Marker(
//                           point: destinationCoordinates!,
//                           width: 50.0,
//                           height: 50.0,
//                           child: const Icon(
//                             Icons.flag,
//                             color: Colors.green,
//                             size: 30.0,
//                           ),
//                         ),
//                       ],
//                     ),
//                     PolylineLayer(
//                       polylines: [
//                         Polyline(
//                           points: [sourceCoordinates!, destinationCoordinates!],
//                           color: Colors.blue,
//                           strokeWidth: 4.0,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// class SearchScreen extends StatefulWidget {
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _sourceController = TextEditingController();
//   final TextEditingController _destinationController = TextEditingController();
//   String? recommendedRouteId;
//   bool isLoading = false;

//   LatLng? sourceCoordinates;
//   LatLng? destinationCoordinates;
//   List<LatLng> stopCoordinates = [];

//   Future<void> fetchRecommendedRoute() async {
//     setState(() {
//       isLoading = true;
//       recommendedRouteId = null;
//       sourceCoordinates = null;
//       destinationCoordinates = null;
//       stopCoordinates.clear();
//     });

//     final String apiUrl = "http://127.0.0.1:8000/predict_route";

//     final Map<String, String> requestBody = {
//       "source_name": _sourceController.text,
//       "destination_name": _destinationController.text,
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(requestBody),
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         setState(() {
//           recommendedRouteId = data["recommended_route_id"];

//           // Extract coordinates from API response
//           sourceCoordinates = parseCoordinates(data["source_coordinates"]);
//           destinationCoordinates = parseCoordinates(data["dest_coordinates"]);

//           // Parse stop coordinates list
//           if (data["stop_coordinates"] != null) {
//             stopCoordinates = (data["stop_coordinates"] as List)
//                 .map((coord) => parseCoordinates(coord)!)
//                 .where((coord) => coord != null)
//                 .toList();
//           }
//         });
//       } else {
//         setState(() {
//           recommendedRouteId = "No route found";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         recommendedRouteId = "Error: Could not connect to server";
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   // Helper function to parse "lat, long" string into LatLng
//   LatLng? parseCoordinates(String? coordString) {
//     if (coordString == null || coordString.isEmpty) return null;
//     final parts = coordString.split(",");
//     if (parts.length != 2) return null;
//     return LatLng(double.parse(parts[0]), double.parse(parts[1]));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Bus Route Finder")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: _sourceController,
//               decoration: const InputDecoration(
//                 labelText: "Enter Source",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _destinationController,
//               decoration: const InputDecoration(
//                 labelText: "Enter Destination",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: isLoading ? null : fetchRecommendedRoute,
//               child: isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text("Find Best Route"),
//             ),
//             const SizedBox(height: 20),
//             if (recommendedRouteId != null)
//               Text(
//                 "Recommended Route ID: $recommendedRouteId",
//                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),

//             const SizedBox(height: 20),

//             // Display the map if coordinates are available
//             if (sourceCoordinates != null && destinationCoordinates != null)
//               Expanded(
//                 child: FlutterMap(
//                   options: MapOptions(
//                     initialCenter: sourceCoordinates!,
//                     initialZoom: 13.0,
//                   ),
//                   children: [
//                     TileLayer(
//                       urlTemplate:
//                           "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                       subdomains: ['a', 'b', 'c'],
//                     ),
//                     MarkerLayer(
//                       markers: [
//                         // Source Marker
//                         Marker(
//                           point: sourceCoordinates!,
//                           width: 50.0,
//                           height: 50.0,
//                           child: const Icon(
//                             Icons.location_on,
//                             color: Colors.red,
//                             size: 30.0,
//                           ),
//                         ),
//                         // Destination Marker
//                         Marker(
//                           point: destinationCoordinates!,
//                           width: 50.0,
//                           height: 50.0,
//                           child: const Icon(
//                             Icons.flag,
//                             color: Colors.green,
//                             size: 30.0,
//                           ),
//                         ),
//                         // Stop Markers
//                         for (var stop in stopCoordinates)
//                           Marker(
//                             point: stop,
//                             width: 40.0,
//                             height: 40.0,
//                             child: const Icon(
//                               Icons.stop_circle,
//                               color: Colors.orange,
//                               size: 25.0,
//                             ),
//                           ),
//                       ],
//                     ),
//                     // Draw polyline from source → stops → destination
//                     PolylineLayer(
//                       polylines: [
//                         Polyline(
//                           points: [
//                             sourceCoordinates!,
//                             ...stopCoordinates,
//                             destinationCoordinates!
//                           ],
//                           color: Colors.blue,
//                           strokeWidth: 4.0,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// class SearchScreen extends StatefulWidget {
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _sourceController = TextEditingController();
//   final TextEditingController _destinationController = TextEditingController();
//   String? recommendedRouteId;
//   bool isLoading = false;
//   List<LatLng> routeCoordinates = [];

//   Future<void> fetchRecommendedRoute() async {
//     setState(() {
//       isLoading = true;
//       recommendedRouteId = null;
//       routeCoordinates.clear();
//     });

//     final String apiUrl = "http://127.0.0.1:8000/predict_route";
//     final Map<String, String> requestBody = {
//       "source_name": _sourceController.text,
//       "destination_name": _destinationController.text,
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(requestBody),
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         setState(() {
//           recommendedRouteId = data["recommended_route_id"];

//           routeCoordinates = [
//             if (data["source_coordinates"] != null)
//               parseCoordinates(data["source_coordinates"]),
//             if (data["stop_coordinates"] != null)
//               ...parseStopCoordinates(data["stop_coordinates"]),
//             if (data["dest_coordinates"] != null)
//               parseCoordinates(data["dest_coordinates"]),
//           ].whereType<LatLng>().toList();
//         });
//       } else {
//         setState(() {
//           recommendedRouteId = "No route found";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         recommendedRouteId = "Error: Could not connect to server";
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   LatLng? parseCoordinates(String? coordString) {
//     if (coordString == null || !coordString.contains(",")) return null;
//     final parts = coordString.trim().split(",");
//     if (parts.length < 2) return null;
//     try {
//       return LatLng(double.parse(parts[0]), double.parse(parts[1]));
//     } catch (e) {
//       return null;
//     }
//   }

//   List<LatLng> parseStopCoordinates(List<dynamic> stopList) {
//     List<LatLng> stopCoords = [];
//     for (var stop in stopList) {
//       if (stop is String) {
//         var parsedCoord = parseCoordinates(stop);
//         if (parsedCoord != null) {
//           stopCoords.add(parsedCoord);
//         }
//       }
//     }
//     return stopCoords;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Bus Route Finder")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: _sourceController,
//               decoration: const InputDecoration(
//                 labelText: "Enter Source",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _destinationController,
//               decoration: const InputDecoration(
//                 labelText: "Enter Destination",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: isLoading ? null : fetchRecommendedRoute,
//               child: isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text("Find Best Route"),
//             ),
//             const SizedBox(height: 20),
//             if (recommendedRouteId != null)
//               Text(
//                 "Recommended Route ID: $recommendedRouteId",
//                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             const SizedBox(height: 20),
//             if (routeCoordinates.isNotEmpty)
//               Expanded(
//                 child: FlutterMap(
//                   options: MapOptions(
//                     initialCenter: routeCoordinates.first,
//                     initialZoom: 13.0,
//                   ),
//                   children: [
//                     TileLayer(
//                       urlTemplate:
//                           "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                       subdomains: ['a', 'b', 'c'],
//                     ),
//                     MarkerLayer(
//                       markers: routeCoordinates.map((point) {
//                         bool isSource = point == routeCoordinates.first;
//                         bool isDestination = point == routeCoordinates.last;
//                         return Marker(
//                           point: point,
//                           width: 50.0,
//                           height: 50.0,
//                           child: Icon(
//                             isSource
//                                 ? Icons.location_on
//                                 : isDestination
//                                     ? Icons.flag
//                                     : Icons.circle,
//                             color: isSource
//                                 ? Colors.red
//                                 : isDestination
//                                     ? Colors.green
//                                     : Colors.blue,
//                             size: isSource || isDestination ? 30.0 : 20.0,
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                     PolylineLayer(
//                       polylines: [
//                         Polyline(
//                           points: routeCoordinates,
//                           color: Colors.blue,
//                           strokeWidth: 4.0,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  String? recommendedRouteId;
  bool isLoading = false;
  List<LatLng> routeCoordinates = [];
  List<LatLng> stopCoordinates = [];
  LatLng? sourceCoordinate;
  LatLng? destinationCoordinate;

  Future<void> fetchRecommendedRoute() async {
    setState(() {
      isLoading = true;
      recommendedRouteId = null;
      routeCoordinates.clear();
      stopCoordinates.clear();
      sourceCoordinate = null;
      destinationCoordinate = null;
    });

    final String apiUrl = "http://127.0.0.1:8000/predict_route";
    final Map<String, String> requestBody = {
      "source_name": _sourceController.text,
      "destination_name": _destinationController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          recommendedRouteId = data["recommended_route_id"];

          // Assign Source & Destination separately
          sourceCoordinate = parseCoordinates(data["source_coordinates"]);
          destinationCoordinate = parseCoordinates(data["dest_coordinates"]);

          // Extract stops separately
          if (data["stop_coordinates"] != null) {
            stopCoordinates = parseStopCoordinates(data["stop_coordinates"]);
          }

          // Create route polyline path (excluding stops)
          routeCoordinates = [
            if (sourceCoordinate != null) sourceCoordinate!,
            if (destinationCoordinate != null) destinationCoordinate!,
          ];
        });
      } else {
        setState(() {
          recommendedRouteId = "No route found";
        });
      }
    } catch (e) {
      setState(() {
        recommendedRouteId = "Error: Could not connect to server";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  LatLng? parseCoordinates(String? coordString) {
    if (coordString == null || !coordString.contains(",")) return null;
    final parts = coordString.trim().split(",");
    if (parts.length < 2) return null;
    try {
      return LatLng(double.parse(parts[0]), double.parse(parts[1]));
    } catch (e) {
      return null;
    }
  }

  List<LatLng> parseStopCoordinates(List<dynamic> stopList) {
    List<LatLng> stopCoords = [];
    for (var stop in stopList) {
      if (stop is String) {
        var parsedCoord = parseCoordinates(stop);
        if (parsedCoord != null) {
          stopCoords.add(parsedCoord);
        }
      }
    }
    return stopCoords;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bus Route Finder")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _sourceController,
              decoration: const InputDecoration(
                labelText: "Enter Source",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: "Enter Destination",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : fetchRecommendedRoute,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Find Best Route"),
            ),
            const SizedBox(height: 20),
            if (recommendedRouteId != null)
              Text(
                "Recommended Route ID: $recommendedRouteId",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            if (routeCoordinates.isNotEmpty || stopCoordinates.isNotEmpty)
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: sourceCoordinate ?? const LatLng(15.2993, 74.1240),
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),

                    // 🔹 Stops as Orange Markers
                    MarkerLayer(
                      markers: stopCoordinates.map((point) {
                        return Marker(
                          point: point,
                          width: 40.0,
                          height: 40.0,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.orange,
                            size: 25.0,
                          ),
                        );
                      }).toList(),
                    ),

                    // 🔹 Source as Red Marker
                    if (sourceCoordinate != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: sourceCoordinate!,
                            width: 50.0,
                            height: 50.0,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 30.0,
                            ),
                          ),
                        ],
                      ),

                    // 🔹 Destination as Green Marker
                    if (destinationCoordinate != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: destinationCoordinate!,
                            width: 50.0,
                            height: 50.0,
                            child: const Icon(
                              Icons.flag,
                              color: Colors.green,
                              size: 30.0,
                            ),
                          ),
                        ],
                      ),

                    // 🔹 Route Path (excluding stops)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routeCoordinates,
                          color: Colors.blue,
                          strokeWidth: 4.0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}


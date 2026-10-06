import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:truck_manager_backend/core/models.dart';
import 'game_state.dart';
import 'operations_pages.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final transform = TransformationController();
  late final Future<Map<String, dynamic>> dataset = _load();
  bool showStations = true;
  bool showBorderStations = true;
  String selected = 'Select a truck or weigh station to see its details.';
  Future<Map<String, dynamic>> _load() async {
    final files = await Future.wait([
      rootBundle.loadString('assets/maps/us_states.json'),
      rootBundle.loadString('assets/maps/weigh_stations.json'),
      rootBundle.loadString('assets/maps/border_stations.json'),
    ]);
    return {
      'states': (jsonDecode(files[0]) as Map<String, dynamic>)['states'],
      'weigh': jsonDecode(files[1]) as Map<String, dynamic>,
      'borders': jsonDecode(files[2]) as Map<String, dynamic>,
    };
  }

  @override
  void dispose() {
    transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: truckGameState,
    builder: (context, _) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'U.S. OPERATIONS MAP',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Green: vehicles • Amber: real stations • Purple: simulated border stations',
              ),
              FilterChip(
                label: const Text('Real weigh stations'),
                selected: showStations,
                onSelected: (v) => setState(() => showStations = v),
              ),
              FilterChip(
                label: const Text('Simulated state-line stations'),
                selected: showBorderStations,
                onSelected: (v) => setState(() => showBorderStations = v),
              ),
              TextButton.icon(
                onPressed: () => transform.value = Matrix4.identity(),
                icon: const Icon(Icons.zoom_out_map),
                label: const Text('Reset view'),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: dataset,
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(
                    child: Text(
                      'Map data could not be loaded: ${snapshot.error}',
                    ),
                  );
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final data = snapshot.data!;
                final weigh = data['weigh'] as Map<String, dynamic>;
                final stations = (weigh['stations'] as List)
                    .cast<Map<String, dynamic>>();
                final borders = ((data['borders'] as Map)['stations'] as List)
                    .cast<Map<String, dynamic>>();
                final visibleStations = <Map<String, dynamic>>[
                  if (showStations) ...stations,
                  if (showBorderStations) ...borders,
                ];
                return Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${borders.length} simulated state-border stations • ${stations.length} real mapped stations • ${weigh['coverage']} • Location snapshot ${weigh['retrievedAt']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth < 850
                                ? 850.0
                                : constraints.maxWidth;
                            final height = width * .65;
                            return InteractiveViewer(
                              transformationController: transform,
                              constrained: false,
                              minScale: .4,
                              maxScale: 12,
                              boundaryMargin: const EdgeInsets.all(100),
                              child: SizedBox(
                                width: width,
                                height: height,
                                child: GestureDetector(
                                  onTapUp: (details) => _select(
                                    details.localPosition,
                                    Size(width, height),
                                    visibleStations,
                                  ),
                                  child: CustomPaint(
                                    painter: UsaMapPainter(
                                      states: (data['states'] as List)
                                          .cast<Map<String, dynamic>>(),
                                      stations: visibleStations,
                                      fleet: truckGameState.fleet,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${weigh['attribution']} • Real coverage incomplete; status unknown. Purple markers are fictional game facilities, not verified road crossings. AK/HI have no interstate land borders.',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(selected),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final vehicle in truckGameState.fleet)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: const Icon(
                        Icons.local_shipping,
                        size: 16,
                        color: green,
                      ),
                      label: Text(
                        'Unit ${vehicle.unitNumber} • ${vehicle.city}',
                      ),
                      onPressed: () =>
                          setState(() => selected = _vehicleDetails(vehicle)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  String _vehicleDetails(FleetVehicle vehicle) {
    final drivers = truckGameState.drivers.where(
      (d) => d.truckId == vehicle.id,
    );
    return 'Unit ${vehicle.unitNumber} • ${vehicle.name} • ${vehicle.city} • Driver: ${drivers.isEmpty ? 'Unassigned' : drivers.first.name}';
  }

  void _select(
    Offset position,
    Size size,
    List<Map<String, dynamic>> stations,
  ) {
    var nearest = 15.0;
    String? details;
    for (final vehicle in truckGameState.fleet) {
      final projected = projectUsa(vehicle.latitude, vehicle.longitude, size);
      if (projected == null) continue;
      final distance = (position - projected).distance;
      if (distance < nearest) {
        nearest = distance;
        details = _vehicleDetails(vehicle);
      }
    }
    if (details == null) {
      for (final station in stations) {
        final projected = projectUsa(
          (station['latitude'] as num).toDouble(),
          (station['longitude'] as num).toDouble(),
          size,
        );
        if (projected == null) continue;
        final distance = (position - projected).distance;
        if (distance < nearest) {
          nearest = distance;
          details =
              '${station['name']} • ${station['facilityType']} • Source: ${station['source']} • ${station['simulated'] == true ? 'Fictional gameplay location' : 'Operating status unknown'}';
        }
      }
    }
    if (details != null) setState(() => selected = details!);
  }
}

/// The same projection is used for boundaries, station points and game vehicles.
/// Alaska/Hawaii use labeled insets so the full U.S. remains useful on a desktop.
Offset? projectUsa(double latitude, double longitude, Size size) {
  double x, y;
  if (latitude >= 51 && (longitude < -129 || longitude > 170)) {
    if (longitude > 0) longitude -= 360;
    x = .03 + (longitude + 190) / 62 * .30;
    y = .73 + (72 - latitude) / 22 * .23;
  } else if (latitude >= 18 &&
      latitude <= 23 &&
      longitude >= -161 &&
      longitude <= -154) {
    x = .38 + (longitude + 161) / 7 * .18;
    y = .76 + (23 - latitude) / 5 * .16;
  } else if (latitude >= 24 &&
      latitude <= 50.5 &&
      longitude >= -125 &&
      longitude <= -66) {
    x = .03 + (longitude + 125) / 59 * .94;
    y = .03 + (50.5 - latitude) / 26.5 * .67;
  } else {
    return null;
  }
  return Offset(x * size.width, y * size.height);
}

class UsaMapPainter extends CustomPainter {
  const UsaMapPainter({
    required this.states,
    required this.stations,
    required this.fleet,
  });
  final List<Map<String, dynamic>> states, stations;
  final List<FleetVehicle> fleet;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF081521),
    );
    for (final state in states) {
      final path = Path()..fillType = PathFillType.evenOdd;
      for (final ring in state['rings'] as List) {
        var started = false;
        for (final point in ring as List) {
          final position = projectUsa(
            (point[1] as num).toDouble(),
            (point[0] as num).toDouble(),
            size,
          );
          if (position == null) continue;
          if (!started) {
            path.moveTo(position.dx, position.dy);
            started = true;
          } else {
            path.lineTo(position.dx, position.dy);
          }
        }
        if (started) path.close();
      }
      canvas.drawPath(path, Paint()..color = const Color(0xFF193143));
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF527088)
          ..style = PaintingStyle.stroke
          ..strokeWidth = .7,
      );
      final position = projectUsa(
        (state['latitude'] as num).toDouble(),
        (state['longitude'] as num).toDouble(),
        size,
      );
      if (position != null)
        _text(
          canvas,
          state['postal'] as String,
          position,
          color: Colors.white38,
          size: 11,
        );
    }
    _text(canvas, 'ALASKA', Offset(size.width * .06, size.height * .72));
    _text(canvas, 'HAWAII', Offset(size.width * .39, size.height * .74));
    for (final station in stations) {
      final position = projectUsa(
        (station['latitude'] as num).toDouble(),
        (station['longitude'] as num).toDouble(),
        size,
      );
      if (position != null)
        canvas.drawCircle(
          position,
          station['simulated'] == true ? 4 : 2.8,
          Paint()..color = station['simulated'] == true
              ? Colors.purpleAccent
              : Colors.amber,
        );
    }
    final locations = <String, int>{};
    for (final vehicle in fleet) {
      final position = projectUsa(vehicle.latitude, vehicle.longitude, size);
      if (position == null) continue;
      // Co-located vehicles share one marker with a count; their records remain selectable below.
      final key = '${vehicle.latitude}:${vehicle.longitude}';
      locations[key] = (locations[key] ?? 0) + 1;
      canvas.drawCircle(position, 7, Paint()..color = green);
      canvas.drawCircle(
        position,
        8,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    final labeled = <String>{};
    for (final vehicle in fleet) {
      final key = '${vehicle.latitude}:${vehicle.longitude}';
      if (!labeled.add(key)) continue;
      final position = projectUsa(vehicle.latitude, vehicle.longitude, size);
      if (position != null)
        _text(
          canvas,
          locations[key]! > 1
              ? '${locations[key]} units • ${vehicle.city}'
              : 'Unit ${vehicle.unitNumber}',
          position + const Offset(10, -15),
          color: green,
        );
    }
  }

  void _text(
    Canvas canvas,
    String text,
    Offset position, {
    Color color = Colors.white54,
    double size = 12,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: size),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant UsaMapPainter old) =>
      old.fleet != fleet || old.stations != stations || old.states != states;
}

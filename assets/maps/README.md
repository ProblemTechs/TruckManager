# Offline U.S. map data

State outlines: Natural Earth 1:50m admin-1 states/provinces, public domain:
https://www.naturalearthdata.com/about/terms-of-use/
Source GeoJSON:
https://github.com/martynafford/natural-earth-geojson/blob/master/50m/cultural/ne_50m_admin_1_states_provinces.json
Coordinates are rounded and simplified for game display; this is not navigation data.

Weigh-station snapshot: public ArcGIS point layers published by Alaska DOT,
California DOT, Florida DOT, Illinois DOT, North Carolina DOT and Oklahoma DOT.
Each record and the dataset's `sources` array retain the original source URL.
This is **partial coverage**, not a complete national directory. The UI displays
this limitation and snapshot date. Agency data may be outdated, inaccurate or
incomplete; no live open/closed status is supplied.

NC virtual facilities, Florida rest areas and proposed/future Oklahoma facilities
are excluded. Florida entries retain their weigh-in-motion facility type; these
are the facilities in the agency's motor-carrier weigh-station directory, not a
nationwide traffic-monitoring WIM dataset. Opposite travel directions remain
separate records. No private scales, driver contact details or invented station
coordinates are included.

Refresh the existing source snapshot with Python 3:

```bash
python3 scripts/update-weigh-stations.py
```

Failures or truncated responses abort before replacing the asset. Add verified
public sources to the importer before extending its coverage label. Keep
`complete: false` until a documented complete national inventory is available.

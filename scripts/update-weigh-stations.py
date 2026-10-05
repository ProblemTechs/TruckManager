#!/usr/bin/env python3
"""Refresh the bundled, incomplete public-agency station snapshot.

No API key needed. Abort on missing/truncated sources to preserve the old asset.
Use --cache-dir for previously downloaded ArcGIS JSON fixtures.
"""
import argparse
import datetime
import json
from pathlib import Path
import urllib.parse
import urllib.request

SOURCES = [
    ('AK', 'Alaska DOT', 'https://services.arcgis.com/r4A0V7UzH9fcLVvv/arcgis/rest/services/AKDOT_Weight_Scales/FeatureServer/0', 'Station_Name'),
    ('CA', 'California DOT', 'https://caltrans-gis.dot.ca.gov/arcgis/rest/services/CHhighway/Vehicle_Enforcement_Facilities/FeatureServer/0', 'FACILITY_NAME'),
    ('FL', 'Florida DOT', 'https://services1.arcgis.com/O1JpcwDW8sjYuddV/arcgis/rest/services/MCSAW%20WSD%20Assist/FeatureServer/0', 'Facility_N'),
    ('IL', 'Illinois DOT', 'https://services2.arcgis.com/aIrBD8yn1TDTEXoz/arcgis/rest/services/IDOT_Weigh_Stations__View_Only/FeatureServer/0', 'FACILITY_N'),
    ('NC', 'North Carolina DOT', 'https://services.arcgis.com/NuWFvHYDMVmmxMeM/arcgis/rest/services/Weigh_Stations_Feature_Layer/FeatureServer/0', 'WeighStation'),
    ('OK', 'Oklahoma DOT', 'https://services6.arcgis.com/RBtoEUQ2lmN0K3GY/arcgis/rest/services/PortsOfEntry_WeighStations/FeatureServer/0', 'FAC_DESC'),
]

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cache-dir', type=Path)
    args = parser.parse_args()
    stations, provenance = [], []
    for state, source, url, name_field in SOURCES:
        if args.cache_dir:
            data = json.loads((args.cache_dir / f'{state}-points.json').read_text())
        else:
            query = urllib.parse.urlencode(dict(f='json', where='1=1', outFields='*',
                outSR=4326, returnGeometry='true', resultRecordCount=2000))
            with urllib.request.urlopen(url + '/query?' + query, timeout=45) as response:
                data = json.load(response)
        if data.get('error') or data.get('exceededTransferLimit') or not data.get('features'):
            raise ValueError(f'{source}: incomplete or failed response; existing asset preserved')
        count = 0
        for feature in data['features']:
            attr = feature['attributes']
            if state == 'NC' and attr.get('Type') != 'Physical':
                continue
            if state == 'FL' and 'Weigh' not in str(attr.get('Facility_T')):
                continue
            if state == 'OK' and attr.get('FAC_STATUS') not in ('IN OPERATION', 'NOT IN OPERATION'):
                continue
            geo = feature.get('geometry') or {}
            points = geo.get('points', [])
            lon = geo.get('x', points[0][0] if points else None)
            lat = geo.get('y', points[0][1] if points else None)
            if lat is None or lon is None or not (18 <= lat <= 72 and -180 <= lon <= -66):
                raise ValueError(f'{source}: invalid coordinates; existing asset preserved')
            name = str(attr.get(name_field) or f'{state} weigh station').strip()
            if state == 'FL':
                name += ' • ' + str(attr.get('Direction', ''))
            object_id = attr.get('OBJECTID', attr.get('FID'))
            if object_id is None:
                raise ValueError(f'{source}: missing stable source ID')
            stations.append(dict(id=f'{state}:{object_id}', name=name, state=state,
                latitude=round(lat, 6), longitude=round(lon, 6), source=source,
                sourceUrl=url, facilityType=attr.get('Facility_T', 'Weigh station')))
            count += 1
        provenance.append(dict(state=state, source=source, url=url, count=count))
    output = dict(retrievedAt=datetime.date.today().isoformat(), complete=False,
        coverage='Partial coverage: AK, CA, FL, IL, NC, OK',
        attribution='State agency location data • Outlines: Natural Earth (public domain)',
        sources=provenance, stations=stations)
    target = Path(__file__).resolve().parent.parent / 'assets/maps/weigh_stations.json'
    temporary = target.with_suffix('.tmp')
    temporary.write_text(json.dumps(output, separators=(',', ':'), ensure_ascii=False) + '\n')
    temporary.replace(target)
    print(f'Saved {len(stations)} agency locations; nationwide coverage remains incomplete.')

if __name__ == '__main__':
    main()

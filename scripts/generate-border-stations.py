#!/usr/bin/env python3
"""Generate fictional gameplay facilities, one per shared state land border.
Points follow simplified map boundaries; they are not road crossings or real scales.
Alaska and Hawaii have no interstate land borders. DC is not a state.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
NEIGHBORS = {
 'AL':'FL GA MS TN', 'AR':'LA MO MS OK TN TX', 'AZ':'CA NM NV UT',
 'CA':'NV OR', 'CO':'KS NE NM OK UT WY', 'CT':'MA NY RI',
 'DE':'MD PA', 'FL':'GA', 'GA':'NC SC TN', 'IA':'IL MN MO NE SD WI',
 'ID':'MT NV OR UT WA WY', 'IL':'IN KY MO WI', 'IN':'KY MI OH',
 'KS':'MO NE OK', 'KY':'MO OH TN VA WV', 'LA':'MS TX',
 'MA':'NH NY RI VT', 'MD':'PA VA WV', 'ME':'NH', 'MI':'OH WI',
 'MN':'ND SD WI', 'MO':'NE OK TN', 'MS':'TN', 'MT':'ND SD WY',
 'NC':'SC TN VA', 'ND':'SD', 'NE':'SD WY', 'NH':'VT', 'NJ':'NY PA',
 'NM':'OK TX', 'NV':'OR UT', 'NY':'PA VT', 'OH':'PA WV',
 'OK':'TX', 'OR':'WA', 'PA':'WV', 'SD':'WY', 'TN':'VA',
 'UT':'WY', 'VA':'WV',
}

def generate():
 states = {s['postal']:s for s in json.loads((ROOT/'assets/maps/us_states.json').read_text())['states']}
 stations=[]
 for a, neighbors in sorted(NEIGHBORS.items()):
  for b in neighbors.split():
   first = [tuple(p) for r in states[a]['rings'] for p in r]
   second = [tuple(p) for r in states[b]['rings'] for p in r]
   shared = sorted(set(first) & set(second))
   if len(shared) > 2:
    lon,lat = shared[len(shared)//2]
   else:
    # Some simplified neighboring outlines retain different vertices.
    # Use the closest boundary vertices for an approximate game marker.
    p,q=min(((p,q) for p in first for q in second),key=lambda pq:sum((x-y)**2 for x,y in zip(*pq)))
    lon,lat = [(x+y)/2 for x,y in zip(p,q)]
   stations.append(dict(id=f'border:{a}:{b}',name=f'{a} / {b} State Line Weigh Station',
     latitude=round(lat,6),longitude=round(lon,6),states=[a,b],
     simulated=True,source='Truck Manager gameplay',facilityType='Simulated border weigh station'))
 return dict(coverage='Simulated facilities at every shared state land border',
  notes='Approximate gameplay locations, not real stations or highway crossings. AK and HI have no interstate land borders.',stations=stations)

if __name__ == '__main__':
 data=generate()
 (ROOT/'assets/maps/border_stations.json').write_text(json.dumps(data,separators=(',',':'))+'\n')
 print(f"Generated {len(data['stations'])} simulated state-border stations")

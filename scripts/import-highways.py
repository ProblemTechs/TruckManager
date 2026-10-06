#!/usr/bin/env python3
"""Bundle generalized US highway lines from public-domain Natural Earth data."""
import argparse,datetime,json,math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
SOURCE='https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_10m_roads.geojson'
def simplify(points,tolerance=.025):
 if len(points)<3: return points
 a,b=points[0],points[-1];dx,dy=b[0]-a[0],b[1]-a[1];den=dx*dx+dy*dy
 def distance(p):
  t=max(0,min(1,((p[0]-a[0])*dx+(p[1]-a[1])*dy)/den)) if den else 0
  return math.hypot(p[0]-a[0]-t*dx,p[1]-a[1]-t*dy)
 index=max(range(1,len(points)-1),key=lambda i:distance(points[i]))
 if distance(points[index])<=tolerance: return [a,b]
 return simplify(points[:index+1],tolerance)[:-1]+simplify(points[index:],tolerance)
def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('geojson',type=Path);args=parser.parse_args()
 roads=[]
 for f in json.loads(args.geojson.read_text())['features']:
  p=f['properties'];g=f['geometry'];level=p.get('level')
  if p.get('sov_a3')!='USA' or not (level in ('Interstate','Federal') or p.get('type')=='Major Highway' and level=='State'): continue
  lines=g['coordinates'] if g['type']=='MultiLineString' else [g['coordinates']]
  roads.append(dict(id=str(p['uident']),name=str(p.get('name') or ''),level=level,
   lines=[[[round(x,4),round(y,4)] for x,y in simplify(line)] for line in lines if len(line)>1]))
 assert len(roads)>5000
 out=dict(source='Natural Earth 1:10m roads (public domain)',sourceUrl=SOURCE,retrievedAt=str(datetime.date.today()),
  coverage='Generalized interstates, US highways and major state highways; source coverage may be incomplete.',roads=roads)
 (ROOT/'assets/maps/highways.json').write_text(json.dumps(out,separators=(',',':'))+'\n')
 print(f'Bundled {len(roads)} highway segments')
if __name__=='__main__':main()

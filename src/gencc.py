import sys
from iso3166 import countries
from iso3166_2 import Subdivisions
import json


#create subdivisions class
iso = Subdivisions(filter_attributes="name")

def converter(code):
  if '-' in code:
    code = code.replace('-', '')
  return code.ljust(5, '.')
#end

final_map = {}

for cc,data in iso.all.items():
  cname = countries.get(cc).name
  final_map[converter(cc)] = cname
  for subcc,info in data.items():
    #print(converter(subcc), info['name'],'(', cname,')')
    final_map[converter(subcc)] = info['name']+' ('+cname+')'
  #end for
#end for

# for c,n in final_map.items():
#   print(c, n)
#end for

print(json.dumps(final_map))

sys.exit(0)
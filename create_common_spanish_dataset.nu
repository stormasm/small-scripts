#!/bin/env nu
# combined.csv - https://github.com/brunerm99/duolingo-vocab-lists/blob/master/english-spanish/original/combined.csv
# spanish_occurences.csv - https://en.wiktionary.org/wiki/Wiktionary:Frequency_lists/Spanish1000
# ```python
# import pandas as pd
# pd.read_html('https://en.wiktionary.org/wiki/Wiktionary:Frequency_lists/Spanish1000')[0].to_csv('spanish_occurences.csv')
# ```

open combined.csv --raw | 
  from csv --noheaders | 
  rename word english |
  join --outer (open spanish_occurences.csv) word | 
  where english != null | 
  where rank != null | 
  select word english 'occurrences (ppm)' 'lemma forms' | 
  sort-by -r 'occurrences (ppm)' | 
  rename -c {word: spanish} | 

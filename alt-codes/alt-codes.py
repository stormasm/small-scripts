import pandas as pd
from sqlalchemy import create_engine

table = pd.read_html("https://en.wikipedia.org/wiki/Alt_code#List_of_codes")[1][
    ["Unicode.1", "CP437", "Unicode name"]
]

engine = create_engine(
    "sqlite:////home/marchall/documents/small_scripts/alt-codes/symbols.db", echo=False
)
with engine.begin() as connection:
    table.to_sql("symbols", con=connection, if_exists="replace")

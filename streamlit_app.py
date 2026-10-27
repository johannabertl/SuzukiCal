import re

import streamlit as st
import math
import pandas as pd
from ics_helper_functions import generate_ics
import re





def main() -> None:
    st.set_page_config(page_title="SuzukiCal")
    st.title("Download fællestimer til kalender (ics)")

    st.write("## Efterår 2026")

    # Inputs -------------------------------------------------------------------------------------- #

    # Gruppevalg: små bogstaver fra a til o

    gruppe = [chr(i) for i in range(ord('a'), ord('o') + 1)]
    valgt_gruppe = st.selectbox("Vælg gruppe:", gruppe, index=None)
    # regex til at finde den valgte gruppe i kolonnen "group_name". Det skal fx. matche "a" i "a, b, c", "a", "b, a", "b, a, c" men ikke "a" i "ab", "ba", "bac". 
    # Det skal især finde nogle enkelte bogstaver i ordet "Forældre". 
    # \b matches word boundary og kan være alt muligt, fx. white space, komma, etc.
    valgt_gruppe_regex = re.compile(rf"(?:^|\s|,){valgt_gruppe}(?:$|\s|,)")

    # Barnets navn
    navn = st.text_input("Indtast barnets navn (valgfrivi):", value="", max_chars=50)
    st.write("(Barnets navn bruges kun til at navngive events i kalenderen og bliver ikke gemt.)")

    # Generate ICS file -------------------------------------------------------------------------------------- #

    # load csv og filter
    if valgt_gruppe:
        plan_lang = pd.read_csv("plan_lang_efteraar_2026.csv")
        #st.write([repr(x) for x in plan_lang["group_name"].dropna().unique()])
        plan_lang["datetime"] = pd.to_datetime(plan_lang["datetime"]).dt.tz_localize("Europe/Copenhagen")
        plan_lang_filtered = plan_lang[plan_lang["group_name"].str.contains(valgt_gruppe_regex, case=True, na=False)]
        plan_lang_filtered["title"] = navn + " Fællestime"
        plan_lang_filtered["kage"] = False
        plan_lang_filtered = plan_lang_filtered.sort_values(by="datetime")
        st.markdown(f"## Fællestimer for {navn}, gruppe {valgt_gruppe}:", )
        st.write(f"Vælg den dag, hvor I skal have kage med, og ændr evt. kommentaren ved at dobbeltklikke i feltet. \
                  Tryk Enter efter ændringer.")
        
        plan_korr = st.data_editor(
            plan_lang_filtered[["datetime", "title", "room", "comment", "kage"]], 
            hide_index = True,
            disabled = ["datetime", "title"],
            num_rows = "delete")
        
        filename = f"faellestimeplan_{navn}_gruppe_{valgt_gruppe}_efteraar_2026.ics"

        # Download button (download ICS)
        cal = generate_ics(plan_korr)
        # write the calendar to a string variable just like we would write it to a file
        ics_string = str(cal)   
        # Write the calendar to an ICS file
        #with open(f'{filename}.ics', 'w') as f:
        #    f.writelines(cal)
        st.download_button("Download som ICS", data=ics_string, file_name=filename)

 
if __name__ == "__main__":
    main()

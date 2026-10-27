import pandas as pd
from ics import Calendar, Event
from datetime import timedelta

def generate_ics(plan_df) -> Calendar:
    """
    Generate an ICS file from a DataFrame containing event information.

    Args:
        plan_df (pd.DataFrame): DataFrame containing event information with columns 
        'datetime', 'title','comment', 'room' and 'location'.
        filename (str): The name of the ICS file to be created (without the .ics extension).

    Returns:
        Calendar: An ics.Calendar object containing the events from the DataFrame.
    """

    # Create a new calendar
    cal = Calendar()

    # Iterate through the DataFrame and create events
    for index, row in plan_df.iterrows():
        event = Event()
        event.name = row['title']
        event.begin = row['datetime']
        #event.end = row['datetime'] + timedelta(minutes=50)
        event.description = row['comment']
        event.location = row['room']
        cal.events.add(event)

    return cal
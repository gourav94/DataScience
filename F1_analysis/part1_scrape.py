# -*- coding: utf-8 -*-
"""
Created on Thu Aug  9 10:15:41 2018

@author: Gourav Sharan
"""
#Import the necessary packages
import requests
from bs4 import BeautifulSoup
import pandas as pd
#Since we are going to be extracting data from multiple URLs, declare an empty array.
url = []
GrandPrix = []
Date = []
Winner = []
Car = []
Laps = []
Timing = []
#Loop that runs through the different webpages of the website, and extracts the desired data
for year in range(1950,2018):
    url.append("https://www.formula1.com/en/results.html/"+str(year)+"/races.html")
    
    page = requests.get(url[year-1950])
    
    soup = BeautifulSoup(page.text, "html.parser")
    
    table = soup.find_all("table", {"class" : "resultsarchive-table"})
    
    tbody = soup.tbody
    
    rows = tbody.find_all("tr")
    
    #Data extraction from the webpage
    for i in range(len(rows)) :
        GrandPrix.append(rows[i].find('a').text.strip())
        Date.append(rows[i].find('td', {"class" : "dark hide-for-mobile"}).text)
        
        first_name = rows[i].find('span', {"class" : "hide-for-tablet"}).text
        last_name = rows[i].find('span', {"class" : "hide-for-mobile"}).text
        
        Winner.append( first_name + " "+ last_name)
        
        Car.append(rows[i].find_all('td')[4].text)
        
        Laps.append(rows[i].find('td', {"class":"bold hide-for-mobile"}).text)
        
        Timing.append(rows[i].find_all('td')[6].text)
    
#Stores the lists combined in a dataframe
df_1950_2017 = pd.DataFrame([GrandPrix, Date,Winner, Car, Laps, Timing]).transpose()
df_1950_2017.columns = ["GrandPrix", "DATE", "Winner", "Car", "Laps", "Timing"]

#Write the resulting dataframe to a csv file for further analysis
df_1950_2017.to_csv("F1_races.csv")

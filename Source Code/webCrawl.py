# -*- coding: utf-8 -*-
"""
Created on Fri Sep 30 19:57:59 2016

@author: Madhu
"""

from bs4 import BeautifulSoup
import urllib2
import csv
import sys
import requests

#site = sys.argv[1]
site = "http://www.webmd.com/drugs/drugreview-63163-adderall+oral.aspx?drugid=63163&drugname=adderall+oral&source=1"

try:
    site = site[:site.index("source=1")] + "pageIndex=0&sortby=3&conditionFilter=-1"
except:
   pass 

hdr = {'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11',
       'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
       'Accept-Charset': 'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
       'Accept-Encoding': 'none',
       'Accept-Language': 'en-US,en;q=0.8',
       'Connection': 'keep-alive'}
req = urllib2.Request(site, headers=hdr)       
html_page = urllib2.urlopen(req)
soup = BeautifulSoup(html_page)

completeData = list()
for uPostPage in soup.find_all('div',class_="postPaging"):
    pageText = uPostPage.get_text()
    numOfReviews = int(pageText[pageText.index("of")+3:].split(" ")[0])
    numOfPages = numOfReviews/5
    break

firstHalf = site[:site.index("pageIndex=")+10]
secondHalf = site[site.index("sortby=")-1:]


for pageno in range(0, int(numOfPages)+1):
    fullSite = firstHalf+""+str(pageno)+""+secondHalf
    print(fullSite)
    #fullSite = "http://www.webmd.com/drugs/drugreview-63163-Adderall+oral.aspx?drugid=63163&drugname=Adderall+oral&pageIndex=17&sortby=3&conditionFilter=-500"
    r = requests.get(fullSite)
    soup = BeautifulSoup(r.text)
    revNo = 1
    for uPost in soup.find_all('div',class_="userPost"):
        data = dict()
        soupuPost = BeautifulSoup(str(uPost))
        for cIn in soupuPost.find_all('div', class_="conditionInfo"):
            cInfo = cIn.get_text().split(": ")[1]
            data["conditionInfo"] = str(cInfo)
        for dt in soupuPost.find_all('div', class_="date"):            
            data["date"] = str(dt.get_text())
        for cSt in soupuPost.find_all('div', id="ctnStars"):
            categs = list()
            cstars = list()
            soupcSt = BeautifulSoup(str(cSt))
            for catG in soupcSt.find_all('p', class_="category"):
                categs.append(catG.get_text().strip())
            for ctnSt in soupcSt.find_all('p', class_="inlineRating starRating"):
                cstars.append(ctnSt.get_text().strip().split(": ")[1])
        for cmt in soupuPost.find_all('p', id="comFull"+str(revNo), class_="comment"):        
            uComment = str(cmt.get_text().strip().split(":")[1].strip())
            data["comment"] = ""
            try:
                data["comment"] = uComment[:uComment.index("Hide Full Comment")].strip()
            except:
                data["comment"] = uComment
            data["comment"] = data["comment"].replace(","," ")
        for uInfo in soupuPost.find_all('p', class_="reviewerInfo"):
            userInformation = uInfo.get_text().split(": ")[1]
            nameAge = userInformation.split(",")
            if len(nameAge) > 1:
                uIndex = 1
                data["name"] = str(nameAge[0].strip())
            else:                         
                data["name"] = ""
                uIndex = 0
            try:
                data["ageGroup"] = str(nameAge[uIndex][:nameAge[uIndex].index("on")-1].strip())
            except:
                data["ageGroup"] = nameAge[uIndex].split(" (")[0].strip()                
            if len(data["ageGroup"].split(" ")) > 1:
                data["sex"] = str(data["ageGroup"].split(" ")[1])
                data["ageGroup"] = str(data["ageGroup"].split(" ")[0])
            else:
                data["sex"] = ""
            try:
                data["ageGroup"].index("-")
            except:                
                if data["ageGroup"] == "Male" or data["ageGroup"] == "Female":
                    data["sex"] = data["ageGroup"]
                else:
                    data["name"] = data["ageGroup"]
                data["ageGroup"] = ""            
                
            try:
                data["loyality"] = str(nameAge[uIndex][nameAge[uIndex].index("for")+4:nameAge[uIndex].index("(")-1])
                data["userCategory"] = str(nameAge[uIndex][nameAge[uIndex].index("(")+1:nameAge[uIndex].index(")")])
            except:
                data["userCategory"] = None
                try:                    
                    data["loyality"] = str(nameAge[uIndex][nameAge[uIndex].index("for")+4:])                    
                except:
                    data["loyality"] =  None
                
        for hf in soupuPost.find_all('p', class_="helpful"):        
            helF = hf.get_text().split("\r")[0]
            data["helpful"] = int(helF)
            
        for i in range(0, len(categs)):
            data[str(categs[i])] = int(cstars[i])
        
        completeData.append(data)
        revNo = revNo+1
        


colnames = ["name","date","ageGroup", "sex", "userCategory", "loyality", "conditionInfo", "Satisfaction", "Effectiveness", "Ease of Use", "helpful","comment"]

with open('complete_data2.csv', 'wb') as fp:
    a = csv.writer(fp, delimiter=',')
    if colnames:
        a.writerow(colnames)
    for x in completeData:
        csv_conv = list()
        for val in colnames:
            if val == "ageGroup" and x[val] != "":
                x[val] = "("+x[val]+")"
            csv_conv.append(str(x[val]))
        a.writerow(csv_conv)        

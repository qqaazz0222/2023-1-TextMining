import requests as rq
from bs4 import BeautifulSoup
import openpyxl
import time

wb = openpyxl.Workbook()
ws = wb.active
ws['A1'] = 'title'

keyword = "인공지능"
lastPageNo = 200

pageNo = 0
rowNo = 2
for articleNo in range(1, lastPageNo*10, 10):
    pageNo += 1
    print(f'=============={pageNo}페이지==============')
    url = f"https://search.naver.com/search.naver?where=news&sm=tab_jum&query={keyword}&start={articleNo}"
    res = rq.get(url)
    html = res.content.decode("utf-8")
    soup = BeautifulSoup(html, 'lxml')

    words = soup.select('.news_tit')
    for word in words:
        title = word.attrs['title']
        link = word.attrs['href']
        print(title)
        ws[f'A{rowNo}'] = title
        rowNo += 1

wb.save('./크롤링데이터.xlsx')
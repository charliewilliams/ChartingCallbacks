#! python

from BeautifulSoup import BeautifulSoup

soup = BeautifulSoup(html)
all_text = ''.join(soup.findAll(text=True))

#!/usr/bin/python3
import argparse
import urllib3
from bs4 import BeautifulSoup
import re

class ItemsController(object):
  def __init__(self):
    self.args = ItemsController.parse_params()
    html = self.get_html()
    self.items = list(AmazonItem.html_to_items(html, self.args.limit, prime=self.args.prime))

  def parse_params():
    parser = argparse.ArgumentParser()
    parser.add_argument('query', help='what you want to search for')
    parser.add_argument('-l', '--limit', type=int, default=10, help='print at most LIMIT items')
    parser.add_argument('-s', '--sort', choices=['rating', 'price', 'name'], help='sort items by the available criteria')
    group = parser.add_mutually_exclusive_group()
    group.add_argument('-a', '--asc', action='store_true', help='sort items ascending')
    group.add_argument('-d', '--desc', action='store_true', help='sort items descending')
    parser.add_argument('-p', '--prime', action='store_true', help='return only Amazon Prime items')
    return parser.parse_args()

  def get_html(self):
    search_url = 'http://www.amazon.com/s/?field-keywords=' + self.args.query
    http = urllib3.PoolManager()
    response = http.request('GET', search_url)
    return BeautifulSoup(response.data)

  def sort_items(self):
    if self.args.sort:
      if self.args.asc:
        direction = 'asc'
      elif self.args.desc:
        direction = 'desc'
      else:
        direction = None
      self.items = AmazonItem.sort_items(self.items, self.args.sort, direction)

  def show_items(self):
    for item in self.items:
      item.print()
      print()


class AmazonItem(object):
  def __init__(self, html):
    self.html = html
    self.title = self.title()
    self.url = self.url()
    self.price = self.price()
    self.reviews = self.reviews()
    self.stars = self.stars()

  def title(self):
    title_element = self.html.find('h3', 'newaps')
    if title_element:
      return title_element.a.span.string.strip()
    else: raise

  def url(self):
    return self.html.find('h3', 'newaps').a['href']

  def price(self):
    price_element = self.html.find('li', 'newp')
    if price_element:
      return price_element.find(text=re.compile("\$")).strip()
    else:
      return self.html.find(text=re.compile("\$")).strip()

  def reviews(self):
    review_element = self.html.find('li', 'rvw')
    if review_element:
      return review_element.find('span', 'rvwCnt').a.string.strip()
    else:
      return 0

  def stars(self):
    review_element = self.html.find('li', 'rvw')
    if review_element:
      stars = review_element.find('span', 'asinReviewsSummary').a['alt']
      return round(float(stars.split()[0]))
    else:
      return 0

  def html_to_items(html, number, prime=False):
    num_of_items = 0
    iteration = 0
    while num_of_items < number:
      item = html.find(id = 'result_' + str(iteration))
      if not item:
        break
      iteration += 1
      try:
        if prime:
          if not item.find('span', 'sprPrime'): raise
        item = AmazonItem(item)
        num_of_items += 1
        yield item
      except:
        continue


  def sort_items(items, sort_by, direction):
    reverse = False
    if sort_by == 'rating':
      key = lambda item: -item.stars
      if direction == 'asc': reverse = True
    elif sort_by == 'price':
      key = lambda item: float(item.price[1:])
      if direction == 'desc': reverse = True
    elif sort_by == 'name':
      key = lambda item: item.title.lower()
      if direction == 'desc': reverse = True
    else:
      return items
    items.sort(key=key, reverse=reverse)
    return items

  def print(self):
    print(self.title)
    print("Price:", self.price)
    stars = '★'*self.stars + '☆'*(5 - self.stars)
    print("Rating:", stars, "(" + str(self.reviews) + " reviews)")
    print("Url:", self.url)


if __name__ == '__main__':
  controller = ItemsController()
  controller.sort_items()
  controller.show_items()

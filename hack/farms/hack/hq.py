#!/usr/bin/python3

from bs4 import BeautifulSoup
import argparse
import sys

def usage():
    return "usage: hq [-a|--attribute {attribute}] {css_selector}"

def parse_args():
    parser = argparse.ArgumentParser(prog="hq", description="jq-like tool but for HTML", 
                                    usage=usage())
    parser.add_argument("-a", "--attribute", action="store", default="", dest="attr",
                        help="extract the value of the attribute")
    parser.add_argument("selector", help="css selector")
    return parser.parse_args()

class HQ:
    def __init__(self, attr: str) -> None:
        self.elements = None
        self.soup = None
        self.attr = attr

    def __print_fn(self):
        if self.attr != "":
            def print_attr(element, out):
                try:
                    out.write(element[self.attr])
                except KeyError:
                    pass
            return print_attr
        return lambda element, out: out.write(element.text)

    def read_from(self, src):
        html = ""
        for line in src:
            html += line
        self.soup = BeautifulSoup(html, "html.parser")

    def find(self, selector) -> bool:
        self.elements = self.soup.select(selector)
        return len(self.elements) > 0

    def print_to(self, out) -> None:
        print = self.__print_fn()
        if len(self.elements) > 0:
            print(self.elements[0], out)

def hq():
    args = parse_args()
    hq = HQ(args.attr)
    hq.read_from(sys.stdin)
    try:
        if not hq.find(args.selector):
            print(f"selector '{args.selector}' yields no results")
            sys.exit(2)
    except:
        print(f"malformed query selector: {args.selector}")
        sys.exit(3)
    hq.print_to(sys.stdout)

if __name__ == "__main__":
    hq()

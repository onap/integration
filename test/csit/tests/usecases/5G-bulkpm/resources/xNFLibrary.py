'''
Created on Aug 18, 2017

@author: sw6830
'''
from robot.api import logger
from Queue import Queue
import uuid, time, json, threading,os, platform, subprocess,paramiko

class xNFLibrary(object):

    def __init__(self):
        pass

    def create_header_from_string(self, dictStr):
        logger.info("Enter create_header_from_string: dictStr")
        return dict(u.split("=") for u in dictStr.split(","))

    def Generate_UUID(self):
        """generate a uuid"""
        return uuid.uuid4()

if __name__ == '__main__':
    lib = xNFLibrary()
    time.sleep(100000)
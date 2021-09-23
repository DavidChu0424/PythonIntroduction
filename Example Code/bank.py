# -*- coding: utf-8 -*-
"""
Created on Thu Apr  8 22:53:32 2021

@author: user
"""

from abc import ABC, abstractmethod

class bank(ABC):
    @abstractmethod
    def __init__ (self,username,password):
        pass
    @abstractmethod
    def getbalance(self):
        pass
    @abstractmethod
    def savemoney(self,money):
        pass
    @abstractmethod   
    def withdrawmoney(self,money):
        pass
    @abstractmethod   
    def passwordforget(self,username):
        pass
    @abstractmethod
    def passwordreset(self,username,oldpassword,newpassword):
        pass
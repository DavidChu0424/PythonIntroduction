# -*- coding: utf-8 -*-
"""
Created on Thu Apr  8 21:35:41 2021

@author: David_Chu
"""
from bank import bank
import Database

class taiwanbank(bank):
    def __init__ (self,username,password):
        self.__username = username
        self.__password = password
        self.__balance = 0
        self.__money = 0
        print("帳戶創建成功")       
        Database.insert(self.__username, self.__password,self.__balance)
        
    def getbalance(self,username):
        Database.serch(self.__username)
        #print("餘額為",self.__balance)
        return self.__balance
    
    def savemoney(self,money):
        self.__balance = Database.serch(self.__username)
        self.__balance = int(self.__balance[0])
        self.__balance += money
        Database.moneychange( self.__balance,self.__username,)
        print(self.__username,"存入",money,"餘額為",self.__balance)
        return self.__balance
        
    def withdrawmoney(self,money):
        self.__balance = Database.serch(self.__username)
        self.__balance = int(self.__balance[0])       
        if self.__balance < money:
            print("餘額不足無法提領")
        else:
            self.__balance = Database.serch(self.__username)
            self.__balance = int(self.__balance[0])
            self.__balance -= money
            Database.moneychange( self.__balance,self.__username,)
            print(self.__username,"提領",money,"餘額為",self.__balance)
        return self.__balance
        
    def passwordforget(self,username):
        if username != self.__username:
            print("帳號輸入錯誤,請重新輸入")
        else:
            Database.passwordserch(self.__username)
            print(self.__username, self.__password)
    
    def passwordreset(self,username,oldpassword,newpassword):
        if (username != self.__username) or (oldpassword != self.__password):
            print("帳號密碼輸入錯誤,請重新輸入")
        else:
            self.__password = newpassword
            Database.passwordchange(self.__password, self.__username)
            print("密碼修改成功")


############# Test Code ###############
            
#創建台灣銀行帳戶
x = taiwanbank('David','Aa12345678')

#取得餘額
x.getbalance('David')

#存錢
x.savemoney(6000)

#領錢
x.withdrawmoney(5000)

#忘記密碼
x.passwordforget("David")

#修改密碼
x.passwordreset("David","Aa1234567","Aa123456789") #錯誤的密碼
x.passwordreset("David","Aa12345678","Aa123456789") #正確的密碼
x.passwordforget("David")


#創建第二個台灣銀行帳戶           
y = taiwanbank("Dennis","Bb12345678")

#取得餘額
y.getbalance("Dennis")

#存錢
y.savemoney(8000)

#領錢
y.withdrawmoney(5000)

#忘記密碼
y.passwordforget("Dennis")

#修改密碼
y.passwordreset("David","Bb12345678","Aa123456789") #錯誤的帳號
y.passwordreset("Dennis","Bb12345678","Aa123456789") #正確的帳號
y.passwordforget("Dennis")

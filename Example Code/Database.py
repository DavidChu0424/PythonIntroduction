
# -*- coding: utf-8 -*-
"""
Created on Sat Apr 10 10:48:27 2021

@author: David_Chu
"""

import pymysql

# 資料庫參數設定
db_settings = {
    "host": "127.0.0.1",
    "port": 3306,
    "user": "root",
    "password": "Aa123456",
    "db": "bankaccount",
    "charset": "utf8"
}


# 新建帳戶資料
def insert(value1,value2,value3):
    try:
    # 建立Connection物件
        conn = pymysql.connect(**db_settings)    
    # 建立Cursor物件
        
        with conn.cursor() as cursor:
             value = (value1,value2,value3)
             command = "INSERT INTO account(AccountID,Password,Balance)VALUES('%s','%s',%s)"%value
             cursor.execute(command)
             #result = cursor.fetchall()
             #print(result)
             conn.commit()
             #資料表相關操作
        
    except Exception as ex:
            print(ex)

# 取得餘額
def serch(value1):
    try:
    # 建立Connection物件
        conn = pymysql.connect(**db_settings)    
    # 建立Cursor物件
        
        with conn.cursor() as cursor:
             value = (value1)
             command = "SELECT Balance FROM account WHERE AccountID LIKE '%s'" %value            
             cursor.execute(command)
             result = cursor.fetchone()
             print(value1,"餘額為",result)
             return result
             conn.commit()
             #資料表相關操作
        
    except Exception as ex:
            print(ex)
 
# 存錢
def moneychange(value1,value2):
    try:
    # 建立Connection物件
        conn = pymysql.connect(**db_settings)    
    # 建立Cursor物件
        
        with conn.cursor() as cursor:
             value = (value1,value2)
             command = "UPDATE account SET Balance=%s WHERE AccountID='%s'" %value           
             cursor.execute(command)
             command = "SELECT Balance FROM account WHERE AccountID LIKE '%s'" %value2
             cursor.execute(command)
             #result = cursor.fetchone()
             #print(value2,"餘額為",result)
             conn.commit()
             #資料表相關操作
        
    except Exception as ex:
            print(ex)


# 修改密碼 
def passwordchange(value1,value2):
    try:
    # 建立Connection物件
        conn = pymysql.connect(**db_settings)    
    # 建立Cursor物件
        
        with conn.cursor() as cursor:
             value = (value1,value2)
             command = "UPDATE account SET Password='%s' WHERE AccountID='%s'" %value           
             cursor.execute(command)
             #result = cursor.fetchone()
             print(value2,"密碼修改為",value1)
             conn.commit()
             #資料表相關操作
        
    except Exception as ex:
            print(ex)


# 密碼查詢
def passwordserch(value1):
    try:
    # 建立Connection物件
        conn = pymysql.connect(**db_settings)    
    # 建立Cursor物件
        
        with conn.cursor() as cursor:
             value = (value1)
             command = "SELECT Password FROM account WHERE AccountID LIKE '%s'" %value            
             cursor.execute(command)
             result = cursor.fetchone()  # Return Response 
             print(value1 ,"密碼為",result)
             conn.commit()
             #資料表相關操作
        
    except Exception as ex:
            print(ex)
 
# 刪除帳戶資料
def delete(value1):
    try:
    # 建立Connection物件
        conn = pymysql.connect(**db_settings)    
    # 建立Cursor物件
        
        with conn.cursor() as cursor:
             value = (value1)
             command = "DELETE FROM account WHERE AccountID = '%s'"%value
             cursor.execute(command)
             #result = cursor.fetchall()
             #print(result)
             conn.commit()
             #資料表相關操作
        
    except Exception as ex:
            print(ex)

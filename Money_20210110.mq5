//+------------------------------------------------------------------+
//|                                                 ChartInChart.mq5 |
//|                                                            David |
//|                                            https://www.David.com |
//+------------------------------------------------------------------+
#property copyright "David"
#property link      "https://www.David.com"
#property version   "1.00"
//#include <MoneyManagement.mqh>
#include <Trade/Trade.mqh>
CTrade trade; //CTrade 宣告
MqlTradeResult result; //TradeResult 建立
MqlTradeRequest request; //TradeRequest 建立

datetime allowed_until = D'2022.01.01 00:00';                            
int password_status = -1;

//----------User 輸入參數----------//
//input double RiskPercent = 2;
//input double FixedVolume = 1;
input double TakeProfitB = 0.01;
input double StopLossB = 0.01;
input double RSIperiod = 90;
input double FixVolume = 2;
input double Volume = 0.01;
//----------User 輸入參數----------//
//----------固定參數---------------//
double stopLossPrice = 100;
double currentbuyPrice = 0;
double currentsellPrice = 0;
double oldbuystoploss = 0;
double oldsellstoploss = 0;
double selladdprice = 0;
double buyaddprice = 0;
double j2 = 0;
double i2 = 0;
int buycount = 0;
int sellcount = 0;
int oldPositionsTotal = 0;
bool glBuyPlaced, glSellPlaced;
long  deal_reason;
long deal_entry;
ulong deal_ticket;
//----------固定參數---------------//
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   printf("This EA is valid until %s", TimeToString(allowed_until, TIME_DATE|TIME_MINUTES));
   datetime now = TimeCurrent();
   
   if (now < allowed_until) 
         Print("EA time limit verified, EA init time : " + TimeToString(now, TIME_DATE|TIME_MINUTES));
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if (TimeCurrent() < allowed_until)
   {
   double rsi[]; //RSI陣列宣告
   ArraySetAsSeries(rsi,true); // rsi 指標
   int manHandle = iRSI(_Symbol,0,RSIperiod, PRICE_CLOSE);  //RSI 指標 建立
   CopyBuffer(manHandle, 0, 0, RSIperiod, rsi);
   double irsi = MathRound(rsi[0]);

   double open  = iOpen(_Symbol,Period(),0); //當前開盤價
   double close = iClose(NULL,PERIOD_CURRENT,0);  //當前收盤價

   double open2  = iOpen(_Symbol,Period(),4);  //前兩天開盤價
   double close2 = iClose(NULL,PERIOD_CURRENT,4); //前兩天收盤價
   
   double lowfour = iLowest(NULL,0,MODE_LOW,48,1);
   double lowprice = iLow(NULL,0,lowfour);
   
   double highfour = iHighest(NULL,0,MODE_HIGH,48,1);
   double highprice = iHigh(NULL,0,highfour);
   
   double HL = ((highprice-lowprice)/highprice)*100;
   
   //printf(HL + "HL");
   //printf(highprice*(1-StopLossB) + "HL");
   
   //printf(lowprice + "我是最低點");
   //printf(highprice + "我是最高點");
   
   
   ZeroMemory(request); //歸零
   ZeroMemory(result); //歸零

   int balance = AccountInfoDouble(ACCOUNT_BALANCE);
   //printf(balance +  "   餘額");

   int equity = AccountInfoDouble(ACCOUNT_EQUITY);
   //printf(equity +  "    帳戶淨值");
    
   double margin= AccountInfoDouble(ACCOUNT_MARGIN);
   //printf(margin + "入金金額");
   
   double tradeSize = balance * (Volume/100000);
   tradeSize = NormalizeDouble(tradeSize,2);
   
   if( tradeSize > FixVolume )
   {
     tradeSize = FixVolume;   
   }

   
   bool openPosition = PositionSelect(_Symbol); //查看是否已開倉
   long positionType = PositionGetInteger(POSITION_TYPE); //判斷多倉 or 空倉
   //printf(positionType + "   1 = 多倉, 0 = 空倉"); // 1 = 多倉, 0 = 空倉
   double currentVolume = 0;
   
   double Openprice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   //printf(Openprice + "     Openprice");
   
   PositionsTotal(); //未平倉總量
   //printf(PositionsTotal() + "未平倉總量");
   oldPositionsTotal = PositionsTotal();

   if(openPosition == true)
      {
    currentVolume = PositionGetDouble(POSITION_VOLUME); //如果是開倉，回傳倉位大小至 currentVolume
       } 
   
   
 /*printf(currentVolume + "   currentvolume");
   printf(tradeSize + "   資金管理");
   printf(irsi + "   RSI 數值");
   printf(open2 + "   前兩天開盤價");
   printf(close2 + "   前兩天收盤價");
   printf(open + "   現在開盤價");
   printf(close + "   現在收盤價");
   printf(j2 + "我是外面的j2");
   printf(i2 + "我是外面的i2");
   */
//-------------資金管理----------------//
// double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
// double stopLossDistance = StopPriceToPoints(_Symbol,stopLossPrice,currentPrice);
// double tradeSize = MoneyManagement(_Symbol,FixedVolume,RiskPercent,stopLossDistance);
//-------------資金管理----------------/

if ( HL < 1 ) //震盪幅度
{

//----------------Open buy market order---------------------//
   if((50 < irsi && irsi < 75)|| irsi < 25 )
     { 
    if( Openprice < (highprice*(1-(StopLossB*0.5))))
      {
     if( PositionsTotal() == 0)
      {
      request.action = TRADE_ACTION_DEAL; //下市價單
      request.type = ORDER_TYPE_BUY; //買入市價單
      request.symbol = _Symbol; // 交易商品代碼
      request.volume =  tradeSize; //交易手數量(tradeSize 資金管理 + currentVolume 現在的手數量)
      request.type_filling = ORDER_FILLING_FOK; //委託之數量需全部且立即成交，否則取消

      if(currentbuyPrice > 0)
        {
         oldbuystoploss = currentbuyPrice;
        }

      request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK); //開倉價格(ask->買單, bid->賣單)

      currentbuyPrice = request.price;
      oldbuystoploss = request.price;

      request.tp = currentbuyPrice / (1-TakeProfitB); //停利位
      request.sl = 0; //currentbuyPrice * (1-StopLossB);  //停損位
      OrderSend(request,result);//開倉
      //printf("多倉開倉成功");

      glBuyPlaced = true;
      glSellPlaced = false;
         }
     }
  }
//-------------------Open buy market order---------------------//

//------------------Open sell market order---------------------//
   else if((irsi > 25 && irsi < 50)|| irsi > 75 )
        {
        if( Openprice > (lowprice*(1+(StopLossB*0.5))))
        {
         if( PositionsTotal() == 0)
         {
         request.action = TRADE_ACTION_DEAL; //下市價單
         request.type = ORDER_TYPE_SELL; //買入市價單
         request.symbol = _Symbol; // 交易商品代碼
         request.volume = tradeSize ; //交易手數量(tradeSize 資金管理 + currentVolume 現在的手數量)
         request.type_filling = ORDER_FILLING_FOK; //委託之數量需全部且立即成交，否則取消

         if(currentsellPrice > 0)
           {
            oldsellstoploss = currentsellPrice;
           }

         request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID); //開倉價格(ask->買單, bid->賣單)

         currentsellPrice = request.price;
         oldsellstoploss = request.price;
           
         //printf(oldsellstoploss + "   oldsellstoploss");
         //printf(currentsellPrice + "   currentsellPrice");

         request.tp = currentsellPrice / (1+TakeProfitB); //停利位
         request.sl = 0; //(currentsellPrice * (1+StopLossB))*2; //停損位
         OrderSend(request,result);//開倉
         //printf("空倉開倉成功");

         glBuyPlaced = false;
         glSellPlaced = true;
           }
        }
     }
//------------------Open sell market order---------------------//


//--------------------------加多倉條件-------------------------//
   if(PositionsTotal() < 6 && PositionsTotal() > 0 && glBuyPlaced == true)
     {
      if( PositionsTotal() == 1)
        {
         j2 = tradeSize;
         //printf(j2 + "我是前面的j2");
        }
       
      if(irsi > 45  && currentbuyPrice > 0)    //
        {       
         if(PositionsTotal() <= 4 )
           {
            buyaddprice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double buyaddpricedigits = NormalizeDouble(currentbuyPrice * (1-StopLossB),8);
            //printf(buyaddprice + "  我是 buyaddprice ");
            //printf(buyaddpricedigits + "  我是 buyaddpricedigits ");
            //printf(j2 + "我是 j2");

           if( buyaddprice <= buyaddpricedigits )
            {
            request.action = TRADE_ACTION_DEAL; //下市價單
            request.type = ORDER_TYPE_BUY; //買入市價單
            request.symbol = _Symbol; // 交易商品代碼
            request.volume = j2; //交易手數量(tradeSize 資金管理 + currentVolume 現在的手數量)
            request.type_filling = ORDER_FILLING_FOK; //委託之數量需全部且立即成交，否則取消
            request.price = buyaddprice; //開倉價格(ask->買單, bid->賣單)

            request.tp = buyaddprice / (1-TakeProfitB); //停利位
            request.sl = 0;//buyaddprice * (1-StopLossB); //停損位
            OrderSend(request,result);//開倉
            //printf("加多倉成功");
            currentbuyPrice = buyaddprice;            
            j2 = j2 * 2;
            
            //while(PositionSelect(_Symbol)==false);
            //------------------------止盈止損修改-------------------------//

            /*request.action = TRADE_ACTION_SLTP; //修改未平倉的止損和獲利值
            do Sleep(100);while(PositionSelect(_Symbol)==false);
            request.position = result.order;
            request.tp = currentbuyPrice / (1-TakeProfitB); //停利位
            request.sl = currentbuyPrice * (1-StopLossB); //停損位
            OrderSend(request,result);//開倉 */

            

            //------------------------止盈止損修改-------------------------//
               }
           }
           
           if( PositionsTotal() == 5 )
           {
               buyaddprice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
               double buyaddpricedigits = NormalizeDouble(currentbuyPrice * (1-StopLossB),8);
               //printf(buyaddpricedigits + "  我是 buyaddpricedigits ");
               
            if( buyaddprice <= buyaddpricedigits )
            {
               request.action = TRADE_ACTION_DEAL; //下市價單
               request.type = ORDER_TYPE_BUY; //買入市價單
               request.symbol = _Symbol; // 交易商品代碼
               request.volume = j2; //交易手數量(tradeSize 資金管理 + currentVolume 現在的手數量)
               request.type_filling = ORDER_FILLING_FOK; //委託之數量需全部且立即成交，否則取消
               request.price = buyaddprice; //開倉價格(ask->買單, bid->賣單)
               request.tp = buyaddprice / (1-TakeProfitB); //停利位
               request.sl = buyaddprice * (1-StopLossB); //停損位
               OrderSend(request,result);//開倉
               //printf("加多倉成功"); 
                                  
            }
          }
        }         
     }

//------------------------加多倉條件---------------------------//


//--------------------------加空倉條件-------------------------//
   if(PositionsTotal() < 6 && PositionsTotal() > 0 && glSellPlaced == true)
     {
     
     if(PositionsTotal() == 1)
        {
        i2 = tradeSize;
        //printf(i2 + "我是前面的i2");
        }
        
      if(irsi < 55 && currentsellPrice > 0)  //
        {  

         if( PositionsTotal() <= 4 )
           {
           
           selladdprice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
           double selladdpricedigits = NormalizeDouble(currentsellPrice * (1+StopLossB),8);
           //printf(selladdpricedigits + "  我是 selladdpricedigits ");

           if( selladdprice >= selladdpricedigits )
            {
            request.action = TRADE_ACTION_DEAL; //下市價單
            request.type = ORDER_TYPE_SELL; //買入市價單
            request.symbol = _Symbol; // 交易商品代碼
            request.volume = i2; //交易手數量(tradeSize 資金管理 + currentVolume 現在的手數量)
            request.type_filling = ORDER_FILLING_FOK; //委託之數量需全部且立即成交，否則取消
            request.price = selladdprice; //開倉價格(ask->買單, bid->賣單)

            request.tp = selladdprice / (1+TakeProfitB); //停利位
            request.sl = 0; //(selladdprice * (1+StopLossB))*2; //停損位

            OrderSend(request,result);//開倉
            //printf("加空倉成功");
            currentsellPrice = selladdprice; 
            i2 = i2 * 2;

            //while(PositionSelect(_Symbol)==false);
            //------------------------止盈止損修改-------------------------//

            /*request.action = TRADE_ACTION_SLTP; //修改未平倉的止損和獲利值
            do Sleep(100);while(PositionSelect(_Symbol)==false);
            request.position = result.order;
            request.tp = currentsellPrice / (1+TakeProfitB); //停利位
            request.sl = currentsellPrice * (1+StopLossB); //停損位
            OrderSend(request,result);//開倉 */            
              }
           }
           
          if( PositionsTotal() == 5)
            {
                     selladdprice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
                     double selladdpricedigits = NormalizeDouble(currentsellPrice * (1+StopLossB),8);
                     //printf(selladdpricedigits + "  我是 selladdpricedigits ");

           if( selladdprice >= selladdpricedigits )
            {
                   request.action = TRADE_ACTION_DEAL; //下市價單
                   request.type = ORDER_TYPE_SELL; //買入市價單
                   request.symbol = _Symbol; // 交易商品代碼
                   request.volume = i2; //交易手數量(tradeSize 資金管理 + currentVolume 現在的手數量)
                   request.type_filling = ORDER_FILLING_FOK; //委託之數量需全部且立即成交，否則取消
                   request.price = selladdprice; //開倉價格(ask->買單, bid->賣單)

                   request.tp = selladdprice / (1+TakeProfitB); //停利位
                   request.sl = selladdprice * (1+StopLossB); //停損位
                   OrderSend(request,result);//開倉
                   //printf("加空倉成功");

              }
           }
        }
      //------------------------止盈止損修改-------------------------//
      /*if(irsi < 55 && PositionsTotal() > (8 * tradeSize) && oldsellstoploss > 0)   //
        {

         ZeroMemory(request); //歸零
         ZeroMemory(result); //歸零
         request.action = TRADE_ACTION_DEAL; //下市價單
         request.type = ORDER_TYPE_SELL; //買入市價單
         request.symbol = _Symbol; // 交易商品代碼
         request.volume = tradeSize; //交易手數量(tradeSize 資金管理 + currentVolume 現在的手數量)
         request.type_filling = ORDER_FILLING_FOK; //委託之數量需全部且立即成交，否則取消
         request.price = oldsellstoploss; //開倉價格(ask->買單, bid->賣單)

         request.tp = currentsellPrice / (1+TakeProfitB); //停利位
         request.sl = currentsellPrice * (1+StopLossB);  //停損位
         OrderSend(request,result);//開倉
         printf("加空倉成功");
        }*/
     }
//--------------------------加空倉條件-------------------------//
/*
   printf(oldsellstoploss + "   oldsellstoploss");
   printf(currentsellPrice + "  currentsellPrice");
   printf(oldbuystoploss + "    oldbuystoploss");
   printf(currentbuyPrice + "   currentbuyPrice");
   
   double closesellvalue = currentsellPrice * (1+StopLossB);
   printf(closesellvalue + "   我是closesellvalue");
   double closebuyvalue = currentbuyPrice * (1-StopLossB);
   printf(closebuyvalue + "    我是closebuyvalue");
*/   
    }
  }
  else Alert("EA expired.");
}
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---


  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| OnTradeTransaction function                                      |
//+------------------------------------------------------------------+
void OnTradeTransaction(
   const MqlTradeTransaction &trans, // 預先載入的參數，並以指定型態宣告
   const MqlTradeRequest &request,
   const MqlTradeResult &result
)
  {
   HistorySelect(TimeCurrent()-3600,TimeCurrent());
   if(trans.type==TRADE_TRANSACTION_DEAL_ADD && trans.deal_type==DEAL_TYPE_SELL )
     {
      if(HistoryDealGetInteger(trans.deal,DEAL_REASON)==DEAL_REASON_TP)
        {
         //Print("BUY + DEAL_REASON_TP");
         CloseAll();
         i2 = 0;
         j2 = 0;
         
        }
      if(HistoryDealGetInteger(trans.deal,DEAL_REASON)==DEAL_REASON_SL)
        {
         //Print("BUY + DEAL_REASON_SL");
         CloseAll();
         i2 = 0;
         j2 = 0;
         
        }
     }

   if(trans.type==TRADE_TRANSACTION_DEAL_ADD && trans.deal_type==DEAL_TYPE_BUY )
     {
      if(HistoryDealGetInteger(trans.deal,DEAL_REASON)==DEAL_REASON_TP)
        {
         //Print("SELL + DEAL_REASON_TP");
         CloseAll();
         i2 = 0;
         j2 = 0;
              
        }
      if(HistoryDealGetInteger(trans.deal,DEAL_REASON)==DEAL_REASON_SL)
        {
         //Print("SELL + DEAL_REASON_SL");
         CloseAll();
         i2 = 0;
         j2 = 0;
         
        }
     }

  }
//+------------------------------------------------------------------+
//+-----------------------平倉---------------------------------------+
void CloseAll()
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
        {
         if(!trade.PositionClose(PositionGetSymbol(i),5))
           {
            Print(PositionGetSymbol(i), "PositionClose() method failed. Return code=",trade.ResultRetcode(),
                  ". Code description: ",trade.ResultRetcodeDescription());
           }
         else
           {
            Print(PositionGetSymbol(i), "PositionClose() method executed successfully. Return code=",trade.ResultRetcode(),
                  " (",trade.ResultRetcodeDescription(),")");
           }
        }
     }
  }
//+-----------------------平倉---------------------------------------+

//+------------------------------------------------------------------+
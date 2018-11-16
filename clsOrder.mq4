//+------------------------------------------------------------------+
//|                                                     clsOrder.mq4 |
//|                                                      FutureRobot |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "FutureRobot"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double GetValueFromPercentage(double _Value,double _lotsize,int Mode) export
{  
    double stopLossPips=0;
    double balance   = AccountBalance();
    //double tickvalue = MarketInfo(_Symbol, MODE_TICKVALUE);
    double lotsize   = MarketInfo(_Symbol, MODE_LOTSIZE);
    double spread    = MarketInfo(_Symbol, MODE_SPREAD);
    //double point     = MarketInfo(_Symbol, MODE_POINT);
    double ticksize  = MarketInfo(_Symbol, MODE_TICKSIZE);
    
    // fix for extremely rare occasion when a change in ticksize leads to a change in tickvalue
    //double reliable_tickvalue = tickvalue * point / ticksize;           
    
    if (Mode == 1)
      stopLossPips = MathFloor((_Value/100) * (balance) / (_lotsize * lotsize * ticksize ) - spread);      
    else if (Mode == 0)
       stopLossPips = _Value;
      
    
    //double stopLossPips = _Prct * balance / (_lotsize * lotsize * reliable_tickvalue ) - spread;

   return (stopLossPips);
}

int OpenOrder(int OpenedOrder, int maxOpenPosition, int order,double lotsize, double stoploss,double takeprofit, int magicnumber) export
{
  if (OpenedOrder < maxOpenPosition)
   {  
      if (order == 1)
      {                      
         if(OrderSend(Symbol(),order,lotsize,Bid,3,Bid+(stoploss*Point),Bid - (takeprofit* Point),NULL,0+magicnumber,0,clrGreen))         
            {
               magicnumber++;
               return (OpenedOrder++);                        
               Print("Short transaction opened");
            }     
         else
            Print("Cannot open short transaction.");
      }
      else if (order == 0)
      {         
         if(OrderSend(Symbol(),order,lotsize,Ask,3,Ask - (stoploss * Point),Ask + (takeprofit * Point),NULL,0+magicnumber,0,clrGreen))
            {
               magicnumber++;
               return (OpenedOrder++); 
               Print("Long transaction opened");
            }
         else
            Print("Cannot open long transaction.");      
      }
   }
   return (OpenedOrder);
}

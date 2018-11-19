//+------------------------------------------------------------------+
//|                                                     clsOrder.mqh |
//|                                                      FutureRobot |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "FutureRobot"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class clsOrder
  {
private:
                     int arrOrderList[];
                     void SetArrayOrderList(int _magicnumber);
public:
                     double GetLotFromMoneyRisk(double _MoneyRiskPrct, double StopLoss);
                     double GetValueFromPercentage(double Value,double LotSize,int Mode);
                     int OpenOrder(int OpenedOrder, int maxOpenPosition, int order, double lotsize, double stoploss,
                                 double takeprofit, double MoneyRiskPrct, int _magicnumber);
                     bool CloseOrderByMagicNumber(int magicnumber);
                     bool CheckMagicNumber(int _magicNumber);
                     clsOrder();
                    ~clsOrder();
  };
double clsOrder::GetLotFromMoneyRisk(double _MoneyRiskPrct, double StopLoss) 
{
   double MoneyRiskValue = AccountBalance() * (_MoneyRiskPrct/100);
   double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
   double LotSize =NormalizeDouble(MoneyRiskValue/ (StopLoss * nTickValue),2);
   if (LotSize == 0.0) LotSize = 0.01;
   return (LotSize);
}
double clsOrder::GetValueFromPercentage(double _Value, double _lotsize, int Mode)
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

void clsOrder::SetArrayOrderList(int _magicnumber)
{
   int arrsize = ArraySize(arrOrderList);
   ArrayResize(arrOrderList,arrsize+1);   
   arrOrderList[arrsize]= _magicnumber;
}

int clsOrder::OpenOrder(int OpenedOrder, int maxOpenPosition, int order, double lotsize, double stoploss,
               double takeprofit, double MoneyRiskPrct, int _magicnumber)
{   
   switch((int)lotsize)
   {
      case 0: lotsize = GetLotFromMoneyRisk(MoneyRiskPrct,stoploss);
   }
     
  if (OpenedOrder < maxOpenPosition)
   {  
      if (order == 1)
      {  
         if (takeprofit!=0) takeprofit = Bid - (takeprofit* Point);
         if(OrderSend(Symbol(),order,lotsize,Bid,3,Bid+(stoploss*Point),takeprofit,NULL,_magicnumber,0,clrGreen))         
            {
               SetArrayOrderList(_magicnumber);
               return (OpenedOrder++);                        
               Print("Short transaction opened");
            }     
         else
            Print("Cannot open short transaction.");
      }
      else if (order == 0)
      {  
         if (takeprofit!=0) takeprofit = Ask + (takeprofit * Point);
         if(OrderSend(Symbol(),order,lotsize,Ask,3,Ask - (stoploss * Point) ,takeprofit,NULL,_magicnumber,0,clrGreen))
            {
               SetArrayOrderList(_magicnumber);
               return (OpenedOrder++); 
               Print("Long transaction opened");
            }
         else
            Print("Cannot open long transaction.");      
      }
   }
   return (OpenedOrder);
}
bool clsOrder::CloseOrderByMagicNumber(int magicnumber)
{
   for (int i=OrdersTotal()-1; i >= 0 ;i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber() == magicnumber)
            {
               if(OrderType()==OP_BUY)
                  if(!OrderClose(OrderTicket(),OrderLots(),Bid,3))
                     return(false);
               if(OrderType()==OP_SELL)   
                  if(!OrderClose(OrderTicket(),OrderLots(),Ask,3))
                     return(false);
                  
               return(true);
            }       
   }   
   return(false);
}
bool clsOrder::CheckMagicNumber(int _magicNumber)
{
   int arrsize = ArraySize(arrOrderList);
   
   for (int i=0; i<=arrsize-1; i++)
   {
      if (arrOrderList[i]==_magicNumber)
         return(true);
   }   
   return(false);
}

clsOrder::clsOrder()
  {
   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
clsOrder::~clsOrder()
  {
  }
//+------------------------------------------------------------------+

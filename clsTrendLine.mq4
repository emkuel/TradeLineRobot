//+------------------------------------------------------------------+
//|                                                 clsTrendLine.mq4 |
//|                                                      FutureRobot |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "FutureRobot"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

int nPeriod;
int nCurBar;
int Limit;
int AutoTimeframe;
int NumOfTrendLineForArr;
int NumOfTrendLine;
int order;
int CandleNumber;
double PriceDeviation;

double arrLowS[];
double arrLowST[];
double arrHighR[];
double arrHighRT[];

datetime arrTimeFuncLine[];
double arrFuncLine[][2];

int GetOrder(){return(order);};

bool GetValueByShiftInFuncLine() export
{
 
  for(int i=0;i<=NumOfTrendLine-1;i++)
  {
    int BarStart = iBarShift(_Symbol,0,arrTimeFuncLine[0]);
    double price=GetY(arrFuncLine[i][1],BarStart-CandleNumber,arrFuncLine[i][2]);
    double CloseBar= Close[CandleNumber];
    
    if(price < CloseBar && price+(PriceDeviation*Point) > CloseBar )
    {
      order=0;
      return (true); 
    }
    else if (price > CloseBar && price+(PriceDeviation*Point) < CloseBar )
    {
      order=1;
      return (true);
    }
  }
  return (false);
}
double GetY(double a, double x, double b)
{
  //y=ax+b
  double y = (a*x) + b;
  return (y);
}
double GetB(double a, double y, double x)
{
  double b= y-(a*x);
  return (b);
}
double GetA(double Xa, double Xb, double Ya, double Yb)
{
  //a=(Yb-Ya)/(Xb-Xa)

  double a = (Yb-Ya)/(Xb-Xa);
  return (a);
}

void SetArrayFunctionLine() export
{  
   int j=0;
   for (int i=0; i<=NumOfTrendLine-1; i++)
   {      
      //Low
      arrTimeFuncLine[j]=Time[(int)arrLowST[i]];
      arrFuncLine[j][0]=GetA(arrLowS[i],arrLowST[i],arrLowS[i+1],arrLowST[i+1]);
      arrFuncLine[j][1]=GetB(arrTimeFuncLine[0],arrLowS[i],arrLowST[i]);
      //High
      arrTimeFuncLine[j+1]=Time[(int)arrHighRT[i]];
      arrFuncLine[j+1][0]=GetA(arrHighR[i],arrHighRT[i],arrHighR[i+1],arrHighRT[i+1]);
      arrFuncLine[j+1][1]=GetB(arrTimeFuncLine[0],arrHighR[i],arrHighRT[i]); 
      
      j+=2;            
   }
}

void LoopArray(double & arr1[], double & arr2[],int number)
{
  for (int i=1; i<=number-1; i++)
  {
    arr1[i]=arr1[i-1];
    arr2[i]=arr2[i-1];
  }
}
void SetTrendLinePeriod()
{
    if(Bars<Limit) Limit=Bars-nPeriod;
    for(nCurBar=Limit; nCurBar>0; nCurBar--)
    {
      if(Low[nCurBar+(nPeriod-1)/2] == Low[iLowest(NULL,0,MODE_LOW,nPeriod,nCurBar)])
      {        
        arrLowS[0]=Low[nCurBar+(nPeriod-1)/2];
        arrLowST[0]=nCurBar+(nPeriod-1)/2;
        LoopArray(arrLowS,arrLowST,NumOfTrendLineForArr);

        //s6=s5; s5=s4; s4=s3; s3=s2; s2=s1; s1=Low[nCurBar+(nPeriod-1)/2];
        //st6=st5; st5=st4; st4=st3; st3=st2; st2=st1; st1=nCurBar+(nPeriod-1)/2;
      }
      if(High[nCurBar+(nPeriod-1)/2] == High[iHighest(NULL,0,MODE_HIGH,nPeriod,nCurBar)])
      {
        arrHighR[0]=Low[nCurBar+(nPeriod-1)/2];
        arrHighRT[0]=nCurBar+(nPeriod-1)/2;
        LoopArray(arrHighR,arrHighRT,NumOfTrendLineForArr);

        //r6=r5; r5=r4; r4=r3; r3=r2; r2=r1; r1=High[nCurBar+(nPeriod-1)/2];
        //rt6=rt5; rt5=rt4; rt4=rt3; rt3=rt2; rt2=rt1; rt1=nCurBar+(nPeriod-1)/2;
      }
    }
}

void initTrendLineClass(int _nPeriod, int _Limit, int _NumOfTrendLine, double _PriceDeviation, int _CandleNumber) export
  {
    nPeriod=_nPeriod;   
    nCurBar=0;
    Limit=_Limit;
    AutoTimeframe=60;
    NumOfTrendLineForArr=_NumOfTrendLine+1;
    NumOfTrendLine=_NumOfTrendLine;
    PriceDeviation=_PriceDeviation;
    CandleNumber=_CandleNumber;
    
    ArrayResize(arrLowS,NumOfTrendLineForArr);
    ArrayResize(arrLowST,NumOfTrendLineForArr);
    ArrayResize(arrHighR,NumOfTrendLineForArr);
    ArrayResize(arrHighRT,NumOfTrendLineForArr);
    ArrayResize(arrFuncLine,NumOfTrendLine*2);
    ArrayResize(arrTimeFuncLine,NumOfTrendLine*2);
    
    //check current period and change to correct period
    if (Period()<AutoTimeframe)
    {
        int AutoFactor = AutoTimeframe/Period();
        nPeriod=nPeriod*AutoFactor;
        Limit=Limit*AutoFactor;
    }
    else
      Limit = (int)ChartGetInteger(0,CHART_VISIBLE_BARS);
   
    //Set Trend Line
    SetTrendLinePeriod();
    SetArrayFunctionLine();
  }
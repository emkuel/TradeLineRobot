//+------------------------------------------------------------------+
//|                                            clsHelperFunction.mq4 |
//|                                                      FutureRobot |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "FutureRobot"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

void QucikSortArray(double &arr[][], int StartPos, int EndPos, bool SmallestToLarges) export
{
   if (ArraySize(arr)<1) return;
   
   double  v = arr[(StartPos+EndPos)/2][0];
   int i,j;
   double x;
   i=StartPos;
   j=EndPos;
   do{
      if (SmallestToLarges)
      {
         while (arr[i][0]<v) i++;
         while (arr[j][0]>v) j--;
      }
      else
      {
         while (arr[i][0]>v) i++;
         while (arr[j][0]<v) j--;
      }
      if (i<=j)
      {
         x=arr[i][0];
         arr[i][0]=arr[j][0];
         arr[j][0]=x;
         i++; j--;
      }      
      }while (i<=j);
   
   if (j>StartPos) QucikSortArray(arr,StartPos,j,SmallestToLarges);
   if (i<EndPos) QucikSortArray(arr,i,EndPos,SmallestToLarges);
}

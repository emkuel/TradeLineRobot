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

void QuickSortArray1Dimension(double &arr[], int StartPos, int EndPos, bool SmallestToLarges) export
{   
   double  v = arr[(StartPos+EndPos)/2];
   int i,j;
   double x;
   i=StartPos;
   j=EndPos;
   do{
      if (SmallestToLarges)
      {
         while (arr[i]<v) i++;
         while (arr[j]<v) j--;
      }
      else
      {
         while (arr[i]>v) i++;
         while (arr[j]<v) j--;
      }
      if (i<=j)
      {
         x=arr[i];
         arr[i]=arr[j];
         arr[j]=x;
         i++; j--;
      }      
      }while (i<=j);
   
   if (j>StartPos) QuickSortArray1Dimension(arr,StartPos,j,SmallestToLarges);
   if (i<EndPos) QuickSortArray1Dimension(arr,i,EndPos,SmallestToLarges);
}

void QuickSortArray2Dimension(double &arr[][], int StartPos, int EndPos, bool SmallestToLarges) export
{    
   double v = arr[(StartPos+EndPos)/2][0];
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
   
   
      if (j>StartPos) QuickSortArray2Dimension(arr,StartPos,j,SmallestToLarges);
      if (i<EndPos)  QuickSortArray2Dimension(arr,i,EndPos,SmallestToLarges);
  
}
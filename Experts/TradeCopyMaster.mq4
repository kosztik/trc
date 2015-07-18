//+------------------------------------------------------------------+
//|                                              TradeCopyMaster.mq4 |
//|                                                                  |
//| Copyright (c) 2011,2012 Vaclav Vobornik, Syslog.eu               |
//|                                                                  |
//| This program is free software: you can redistribute it and/or    |
//| modify it under the terms of the GNU General Public License      |
//| as published by the Free Software Foundation, either version 2   |
//| of the License, or (at your option) any later version.           |
//|                                                                  |
//| This program is distributed in the hope that it will be useful,  |
//| but WITHOUT ANY WARRANTY; without even the implied warranty of   |
//| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the     |
//| GNU General Public License for more details.                     |
//|                                                                  |
//| You should have received a copy of the GNU General Public        |
//| License along with this program.                                 |
//| If not, see http://www.gnu.org/licenses/gpl-2.0                  |
//| See legal implications: http://gpl-violations.org/               |
//|                                                                  |
//|                                                 http://syslog.eu |
//+------------------------------------------------------------------+

/*
   2015.05.01
      A módosításom itt, hogy az eredeti egy fájlba írja a kereskedéseket, az
      itteni verzió pedig httpGET paranccsal egy php fájl hív meg egy szerveren
      ami egy adatbázisba írja be ezeket az adatokat.
      
      pl. string http_result = httpGET("url.php");

*/


#include <mq4-http.mqh>

#property copyright "Copyright © 2011, Syslog.eu, rel. 2012-01-04"
#property link      "http://syslog.eu"

extern string cutStringFromSym="";

int delay=1000;
int start,TickCount;
int Size=0,PrevSize=0;
int cnt,TotalCounter;
string cmt;
string nl="\n";
string httpstring="";

int OrdId[],PrevOrdId[];
string OrdSym[],PrevOrdSym[];
int OrdTyp[],PrevOrdTyp[];
double OrdLot[],PrevOrdLot[];
double OrdPrice[],PrevOrdPrice[];
double OrdSL[],PrevOrdSL[];
double OrdTP[],PrevOrdTP[];


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   //int handle=FileOpen("TradeCopy.csv",FILE_CSV|FILE_WRITE,",");
   //FileClose(handle);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start() {

  while(!IsStopped()) {
    start=GetTickCount();
    cmt=start+nl+"Counter: "+TotalCounter;
    get_positions();
    if(compare_positions()) save_positions(); // vagyis csak akkor ment, amikor változás van!
    Comment(cmt);
    TickCount=GetTickCount()-start;
    if(delay>TickCount)Sleep(delay-TickCount-2);
  }
  Alert("end, TradeCopy EA stopped");
  Comment("");
  return(0);


//----

}


void get_positions() {
  Size=OrdersTotal();
  if (Size!= PrevSize) {
    ArrayResize(OrdId,Size);
    ArrayResize(OrdSym,Size);
    ArrayResize(OrdTyp,Size);
    ArrayResize(OrdLot,Size);
    ArrayResize(OrdPrice,Size);
    ArrayResize(OrdSL,Size);
    ArrayResize(OrdTP,Size);
  }

  for(int cnt=0;cnt<Size;cnt++) {
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
    OrdId[cnt]=OrderTicket();
    OrdSym[cnt]=OrderSymbol(); 
    OrdTyp[cnt]=OrderType();
    OrdLot[cnt]=OrderLots();
    OrdPrice[cnt]=OrderOpenPrice();
    OrdSL[cnt]=OrderStopLoss();
    OrdTP[cnt]=OrderTakeProfit();
    
    StringReplace(OrdSym[cnt], cutStringFromSym, "");
  }  
  cmt=cmt+nl+"Size: "+Size;  
}   
   
bool compare_positions() {
  if (PrevSize != Size)return(true);
  for(int i=0;i<Size;i++) {
    if (PrevOrdSL[i]!=OrdSL[i])return(true);
    if (PrevOrdTP[i]!=OrdTP[i])return(true);
    if (PrevOrdPrice[i]!=OrdPrice[i])return(true);
    if (PrevOrdId[i]!=OrdId[i])return(true);
    if (PrevOrdSym[i]!=OrdSym[i])return(true);
    if (PrevOrdPrice[i]!=OrdPrice[i])return(true);
    if (PrevOrdLot[i]!=OrdLot[i])return(true);
    if (PrevOrdTyp[i]!=OrdTyp[i])return(true);
  }    
  return(false);
}

void save_positions() {

  if (PrevSize != Size) {
    ArrayResize(PrevOrdId,Size);
    ArrayResize(PrevOrdSym,Size);
    ArrayResize(PrevOrdTyp,Size);
    ArrayResize(PrevOrdLot,Size);
    ArrayResize(PrevOrdPrice,Size);
    ArrayResize(PrevOrdSL,Size);
    ArrayResize(PrevOrdTP,Size);
    PrevSize=Size;
  }
  
  
  for(int i=0;i<Size;i++) {
    PrevOrdId[i]=OrdId[i];
    PrevOrdSym[i]=OrdSym[i];
    PrevOrdTyp[i]=OrdTyp[i];
    PrevOrdLot[i]=OrdLot[i];
    PrevOrdPrice[i]=OrdPrice[i];
    PrevOrdSL[i]=OrdSL[i];
    PrevOrdTP[i]=OrdTP[i];
  }

  // Size: hány aktív kereskedésünk van éppen. Ezt minden alkalommal újra és újra kiírja.
  
  int handle=FileOpen("TradeCopy.csv",FILE_CSV|FILE_WRITE,",");
  if(handle>0) {
    FileWrite(handle,TotalCounter);
    TotalCounter++;
    httpstring = "?";
    for(i=0;i<Size;i++) {
      FileWrite(handle,OrdId[i],OrdSym[i],OrdTyp[i],OrdLot[i],OrdPrice[i],OrdSL[i],OrdTP[i]);
      httpstring += "&size"+i+"="+Size+"&ordid"+i+"="+OrdId[i]+"&ordsym"+i+"="+OrdSym[i]+"&ordtyp"+i+"="+OrdTyp[i]+"&ordlot"+i+"="+OrdLot[i]+"&ordprice"+i+"="+OrdPrice[i]+"&ordsl"+i+"="+OrdSL[i]+"&ordtp"+i+"="+OrdTP[i]+"&";
    }
    FileClose(handle);
   
    // itt lehetne figyelni a visszatérést, amit az init.cgi ad esetleges hiba esetén
    httpGET("http://alfa.triak.hu/trc/init.cgi"+httpstring);    
    
  }else Print("File open has failed, error: ",GetLastError());

  /*
      A fenti FileWrite íráskor össze kell állítanom egy hosszú stringet. Ebben benne van az összes trade.
      Ezt küldöm el, a httpGET hívással a szervernek. Ami lejegyzi a kereskedéseket mysql adatbázisba!
      
      A string:
      ?t=OrdId[i],OrdSym[i],OrdTyp[i],OrdLot[i],OrdPrice[i],OrdSL[i],OrdTP[i],kib,
         OrdId[i],OrdSym[i],OrdTyp[i],OrdLot[i],OrdPrice[i],OrdSL[i],OrdTP[i],kib,
         OrdId[i],OrdSym[i],OrdTyp[i],OrdLot[i],OrdPrice[i],OrdSL[i],OrdTP[i],kib,
   
      string http_result = httpGET("savetrade.php?t=OrdId[i],OrdSym[i],OrdTyp[i],OrdLot[i],OrdPrice[i],OrdSL[i],OrdTP[i]");
  */

}



   
//+------------------------------------------------------------------+
 

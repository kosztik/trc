


Adatbázis terv
-

tradesOpen

- id
- OrdId
- OrdSym
- OrdTyp
- OrdLot
- OrdPrice
- OrdSL
- OrdTP

szerver:
- a szerver beírja a tradesOpen táblába a kereskedést amíg az megy. Ez mehetne url post -on keresztül is, nem tudom melyik a jobb. A haszna, hogy így nem kell beépíteni a mysql kezelést. Ezzel most egy ötletet adtam magamnak. Lehet így is fogom kipróbálni :)
- a szerver törli az adott kereskedést a tradesOpen táblából amikor annak vége 

Kliens:
- a kliens minden tick-nél lekérdezi ezt a táblát, az apache-on keresztül http protokollal. Vagyis egy php fájlt hivogat majd. Ezzel a terhelést tudom szabályozni (cachelni). Persze nem nagyon mert minden tick számít. Így a kliensekbe nem is kell beépíteni a mysql klienst. 
- Ellenőrzi, hogy a megfelelő trade-k vannak -e nyitva (ez most hogy megy ?)
- Amennyiben nem, a hiányzót megnyitja - ha az még tűréshatáron belül van
- Figyeli, ha bizonyos hiba van (adott számszor (pl market closed)) újra próbálkozik - amíg a tűréshatáron belül van!


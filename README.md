


Adatbázis terv
-

tradesOpen

id
OrdId
OrdSym
OrdTyp
OrdLot
OrdPrice
OrdSL
OrdTP

szerver:
- a szerver beírja a tradesOpen táblába a kereskedést amíg az megy
- a szerver törli az adott kereskedést a tradesOpen táblából amikor annak vége 

Kliens:
- a kliens minden tick-nél lekérdezi ezt a táblát (nem lesz ez túlterhelés a mysql szerver felé?)
- Ellenõrzi, hogy a megfelelõ trade-k vannak -e nyitva (ez most hogy megy ?)
- Amennyiben nem, a hiányzót megnyitja - ha az még tûréshatáron belül van
- Figyeli, ha bizonyos hiba van (adott számszor (pl market closed)) újra próbálkozik - amíg a tûréshatáron belül van!


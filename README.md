


Adatb�zis terv
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
- a szerver be�rja a tradesOpen t�bl�ba a keresked�st am�g az megy
- a szerver t�rli az adott keresked�st a tradesOpen t�bl�b�l amikor annak v�ge 

Kliens:
- a kliens minden tick-n�l lek�rdezi ezt a t�bl�t (nem lesz ez t�lterhel�s a mysql szerver fel�?)
- Ellen�rzi, hogy a megfelel� trade-k vannak -e nyitva (ez most hogy megy ?)
- Amennyiben nem, a hi�nyz�t megnyitja - ha az m�g t�r�shat�ron bel�l van
- Figyeli, ha bizonyos hiba van (adott sz�mszor (pl market closed)) �jra pr�b�lkozik - am�g a t�r�shat�ron bel�l van!


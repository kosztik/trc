#!/usr/bin/perl

use strict;
use English;
use Persistent::DBM;
use Persistent::File;

use CGI;

my $q = CGI->new;

print "Content-type: text/plain\n\n";

eval {

    

    # unlink </tmp/trades.txt*>; nem töröljük, helyette insert és delete :)
    my $openTrades = new Persistent::File('/tmp/trades.txt');
    
    $openTrades->add_attribute('id', 'id', 'Number', undef, 2);
    $openTrades->add_attribute('numtrades', 'persistent', 'Number', undef, 2);
    # Amikor frissítés alatt van a tábla, az "islive" jelzi, hogy az értékek nincsenek készen
    $openTrades->add_attribute('islive', 'persistent', 'Number', undef, 2); # 1 yes, 0 not-
    $openTrades->add_attribute('ordid', 'persistent', 'Number', undef, 20);
    $openTrades->add_attribute('ordsym', 'persistent', 'String', undef, 10);
    $openTrades->add_attribute('ordtyp', 'persistent', 'String', undef, 4);
    $openTrades->add_attribute('ordlot', 'persistent', 'String', undef, 5);
    $openTrades->add_attribute('ordprice', 'persistent', 'String', undef, 10);
    $openTrades->add_attribute('ordsl', 'persistent', 'String', undef, 10);
    $openTrades->add_attribute('ordtp', 'persistent', 'String', undef, 10);

    

    # A következő változónak mindenképpen lennie kell, különben nincs is aktív trade
    if ( $q->param('size0') ne '' ) 
	{
	    # de ha van, akkor bizony végig kell nyomnunk az új tradeket.
	    # először is a régiekben átírjuk az islive -t 0 -ra
	    
	    $openTrades->restore_all();
	    while ($openTrades->restore_next())
	    {
		$openTrades->islive(0);
		$openTrades->save;
	    }
	    
	    # Majd töröljük őket. Az előző lépés azért kellett, mert ha kérés ez művelet
	    # előtt történik, akkor is tudja, hogy már érvénytelen az adat.
	    
	    $openTrades->restore_all();
	    while ($openTrades->restore_next())
	    {
		$openTrades->delete;
		
	    }
	    # Ekkor már a kliensek ha le is kérik az adatokat látják
	    # hogy azok nem érvényesek. Vagy a select.cgi vissza sem adja :)
	    
	    # Most beírjuk az újakat:
	    for ( my $i = 0; $i < $q->param('size0'); $i++  ) 
	    {
		$openTrades->id($i);
		$openTrades->numtrades($q->param('size0'));
		$openTrades->islive(1);
		$openTrades->ordid($q->param('ordid'.$i));
		$openTrades->ordsym($q->param('ordsym'.$i));
		$openTrades->ordtyp($q->param('ordtyp'.$i));
	        $openTrades->ordlot($q->param('ordlot'.$i));
		$openTrades->ordprice($q->param('ordprice'.$i));
		$openTrades->ordsl($q->param('ordsl'.$i));
		$openTrades->ordtp($q->param('ordtp'.$i));		
		$openTrades->insert();	
	    }
	    
	    # és készen is vagyunk!
	    
	} else {
	    # nincs size0 valtozonk, akkor nincs kereskedesunk. mindent torlunk!
	    $openTrades->restore_all();
	    while ($openTrades->restore_next())
	    {
		$openTrades->delete;
		
	    }
	}


};

if ($EVAL_ERROR) {  ### catch those exceptions! ###
    print "An error occurred: $EVAL_ERROR\n";
}
__END__

egy példa url
?ordid0=72859023&ordsym0=EURUSD&ordtyp0=0&ordlot0=0.01&ordprice0=1.08504&ordsl0=0&ordtp0=0&ordid1=72859032&ordsym1=EURUSD&ordtyp1=0&ordlot1=0.01&ordprice1=1.08507&ordsl1=0&ordtp1=0&ordid2=72859042&ordsym2=EURUSD&ordtyp2=0&ordlot2=0.01&ordprice2=1.08495&ordsl2=0&ordtp2=0&ordid3=72859166&ordsym3=EURUSD&ordtyp3=0&ordlot3=0.01&ordprice3=1.08547&ordsl3=0&ordtp3=0&

Új árak felvitele:
- szerintem nem jó, hogy minden alkalommal, amikor változik a táblázat
  a trades.txt -t törölni kelljen, majd újra létrehozni. Helyette inkább
  a meglévő sorokat kellene updatelni, és azok amik nem kellenek pedig ki-
  törölni. Ez gyorsabb lenne.
  
  Amiket megkapok: - új adatok, dátum, és a /tmp/trades.txt létezik-e vagy sem
  
  1. a jelen táblázat összes során az islive mezőt 0-ra állítja
  2. felviszi az új elemeket inserttel és itt átállítja az islive-ot 1-re
  3. a tábla összes mezőjén végigmegy és törli azokat a sorokat, ahol 0-a 
  
  


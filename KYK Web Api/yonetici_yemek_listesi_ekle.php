<?php 

include("fonksiyon.php");
error_reporting(0);
$fonk = new Fonksiyon();
$fonk->headerEkle();

$jsonDizi = array();

$_metot = $_SERVER['REQUEST_METHOD'];

if ($_metot == "POST") {
    $token = $fonk->TokenOku();
    $parola = $fonk->SifreliTokenCoz($token)[0];
    $hataDurumu;

    $pztDizi = explode("+" ,$_POST["PZT"]);
    $salDizi = explode("+" ,$_POST["SAL"]);
    $carDizi = explode("+" ,$_POST["CAR"]);
    $perDizi = explode("+" ,$_POST["PER"]);
    $cumDizi = explode("+" ,$_POST["CUM"]);
    $cmtDizi = explode("+" ,$_POST["CMT"]);
    $pazDizi = explode("+" ,$_POST["PAZ"]);


    if (strlen($parola) == 32 ) { //&& $pzt != "" && $sal != "" && $car != "" && $per != "" && $cum != "" && $cmt != "" && $paz != ""
      $vt = new Veritabani();
      $fonk->BaslikAyarla(200);

      $hataDurumu = $vt->Prosedur("call sp_YONETICI_YEMEK_LISTESI_SIL('$parola');");
      if($hataDurumu[0]["@HATA"] == 0){

      		foreach ($pztDizi as $value) {
          	$hata = $vt->Prosedur("call sp_YONETICI_YEMEK_LISTESI_EKLE('$parola',1,'$value');");
          
          	if($hata[0]["@HATA"] != 0){
          		$hataDurumu = 1;
          	}
          	else{
          		$hataDurumu = 0;
          	}
      	}

      	foreach ($salDizi as $value) {
          	$hata = $vt->Prosedur("call sp_YONETICI_YEMEK_LISTESI_EKLE('$parola',2,'$value');");
          
          	if($hata[0]["@HATA"] != 0){
          		$hataDurumu = 1;
          	}
          	else{
          		$hataDurumu = 0;
          	}
      	}


      	foreach ($carDizi as $value) {
          	$hata = $vt->Prosedur("call sp_YONETICI_YEMEK_LISTESI_EKLE('$parola',3,'$value');");
          
          	if($hata[0]["@HATA"] != 0){
          		$hataDurumu = 1;
          	}
          	else{
          		$hataDurumu = 0;
          	}
      	}

      	foreach ($perDizi as $value) {
          	$hata = $vt->Prosedur("call sp_YONETICI_YEMEK_LISTESI_EKLE('$parola',4,'$value');");
          
          	if($hata[0]["@HATA"] != 0){
          		$hataDurumu = 1;
          	}
          	else{
          		$hataDurumu = 0;
          	}
      	}

      	foreach ($cumDizi as $value) {
          	$hata = $vt->Prosedur("call sp_YONETICI_YEMEK_LISTESI_EKLE('$parola',5,'$value');");
          
          	if($hata[0]["@HATA"] != 0){
          		$hataDurumu = 1;
          	}
          	else{
          		$hataDurumu = 0;
          	}
      	}

      	foreach ($cmtDizi as $value) {
          	$hata = $vt->Prosedur("call sp_YONETICI_YEMEK_LISTESI_EKLE('$parola',6,'$value');");
          
          	if($hata[0]["@HATA"] != 0){
          		$hataDurumu = 1;
          	}
          	else{
          		$hataDurumu = 0;
          	}
      	}

      	foreach ($pazDizi as $value) {
          	$hata = $vt->Prosedur("call sp_YONETICI_YEMEK_LISTESI_EKLE('$parola',7,'$value');");
          
          	if($hata[0]["@HATA"] != 0){
          		$hataDurumu = 1;
          	}
          	else{
          		$hataDurumu = 0;
          	}
      	}

      }


      if ($hataDurumu != 1) {
        //$fonk->pushSend("Bu haftanın yemek listesi paylaşılmıştır."); //Sunucu ya geçince aktif et.
        $jsonDizi["HATA"] = 0;
      }
      else{
        $jsonDizi["HATA"] = 1;
      }

      echo $fonk->json($jsonDizi);
    } 
}
else{
  	$fonk->BaslikAyarla(400);
}

?>
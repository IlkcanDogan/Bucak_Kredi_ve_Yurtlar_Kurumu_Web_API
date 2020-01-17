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

    if (strlen($parola) == 32 ) {
      $vt = new Veritabani();
      $fonk->BaslikAyarla(200);

      $hataDurumu = $vt->Prosedur("call sp_YONETICI_YEMEK_LISTESI_SIL('$parola');");

      if ($hataDurumu[0]["@HATA"] != 1) {
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
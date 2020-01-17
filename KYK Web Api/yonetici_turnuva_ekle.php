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

    $turnuva_adi = $_POST["TURNUVA_ADI"];
    $icerik = $_POST["ICERIK"]; 
    $baslangic_tarih = implode('-', array_reverse(explode('.', $_POST["BASVURU_BASLANGIC_TARIH"])));
    $bitis_tarih = implode('-', array_reverse(explode('.', $_POST["BASVURU_BITIS_TARIH"])));

    if (strlen($parola) == 32 && $turnuva_adi != "" && $icerik != "" && $baslangic_tarih != "" && $bitis_tarih != "") {
      $vt = new Veritabani();
      $hata = $vt->Prosedur("call sp_YONETICI_TURNUVA_EKLE('$parola','$turnuva_adi','$icerik','$baslangic_tarih','$bitis_tarih');");
      
      $fonk->BaslikAyarla(200);

      if ($hata != 1) {   
        $fonk->pushSend($turnuva_adi);  
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
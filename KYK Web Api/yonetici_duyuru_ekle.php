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

    $duyuru_baslik = htmlspecialchars($_POST["DUYURU_BASLIK"]);
    $icerik = $_POST["ICERIK"];
    $basvuru = $_POST["BASVURU"];
    $bitis_tarih = implode('-', array_reverse(explode('.', $_POST["BASVURU_BITIS_TARIH"])));

    if (strlen($parola) == 32 && $duyuru_baslik != "" && $icerik != "" && $basvuru != "" && $bitis_tarih != "") {
      $vt = new Veritabani();
      $hata = $vt->Prosedur("call sp_YONETICI_DUYURU_EKLE('$parola','$duyuru_baslik','$icerik','$basvuru','$bitis_tarih');");
      
      $fonk->BaslikAyarla(200);

      if ($hata[0]["@HATA"] != 1) {
        $fonk->pushSend($duyuru_baslik);
        $jsonDizi["HATA"] = $hata[0]["@HATA"];
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
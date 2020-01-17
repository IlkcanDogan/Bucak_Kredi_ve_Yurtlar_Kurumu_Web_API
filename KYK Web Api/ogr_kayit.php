<?php 

include("fonksiyon.php");

error_reporting(0);
$fonk = new Fonksiyon();
$fonk->headerEkle();
$_metot = $_SERVER['REQUEST_METHOD'];
$jsonDizi = array();

if (true) {
	$token = $fonk->TokenOku();
	$kod = $fonk->SifreliTokenCoz($token)[0];

	$ad = mb_convert_case($_POST["AD"],MB_CASE_TITLE,"UTF-8");
	$soyad = mb_convert_case($_POST["SOYAD"],MB_CASE_UPPER,"UTF-8");
	$cep_tel = "0".$_POST["CEP_TEL"];
	$player_id = $_POST["PLAYER_ID"];
			

	if(strlen($kod) == 32 && $ad != "" && $soyad != ""){
		if(strlen($cep_tel) == 11){
			$ip = $fonk->IpBul();

			$vt = new Veritabani();
			$veri = $vt->Prosedur("call sp_OGR_KAYIT('$ad','$soyad','$cep_tel','$kod','$player_id','$ip');");

			$jsonDizi["HATA"] = $veri[0]["@HATA"];
			echo $fonk->json($jsonDizi);
		}
		else{
			$jsonDizi["HATA"] = 3;
			echo $fonk->json($jsonDizi);
		}


	}
}
else{
	$fonk->BaslikAyarla(400);
}

?>
<?php 
include("fonksiyon.php");

error_reporting(0);
$fonk = new Fonksiyon();
$fonk->headerEkle();

$jsonDizi = array();

$_metot = $_SERVER['REQUEST_METHOD'];

if (true) {
	$vt = new Veritabani();

	/******************************************************/

	$yemek_pzt = $vt->Prosedur("call sp_YEMEK_LISTESI(1)");
	if($yemek_pzt != null){
		$jsonDizi["PZT"] = array();
		$jsonDizi["PZT"] = $yemek_pzt;
	}

	/******************************************************/

	$yemek_sal = $vt->Prosedur("call sp_YEMEK_LISTESI(2)");
	if($yemek_sal != null){
		$jsonDizi["SAL"] = array();
		$jsonDizi["SAL"] = $yemek_sal;
	}

	/******************************************************/

	$yemek_car = $vt->Prosedur("call sp_YEMEK_LISTESI(3)");
	if($yemek_car != null){
		$jsonDizi["CAR"] = array();
		$jsonDizi["CAR"] = $yemek_car;
	}

	/******************************************************/

	$yemek_per = $vt->Prosedur("call sp_YEMEK_LISTESI(4)");
	if($yemek_per != null){
		$jsonDizi["PER"] = array();
		$jsonDizi["PER"] = $yemek_per;
	}

	/******************************************************/

	$yemek_cum = $vt->Prosedur("call sp_YEMEK_LISTESI(5)");
	if($yemek_cum != null){
		$jsonDizi["CUM"] = array();
		$jsonDizi["CUM"] = $yemek_cum;
	}

	/******************************************************/

	$yemek_cmt = $vt->Prosedur("call sp_YEMEK_LISTESI(6)");
	if($yemek_cmt != null){
		$jsonDizi["CMT"] = array();
		$jsonDizi["CMT"] = $yemek_cmt;
	}

	/******************************************************/

	$yemek_paz = $vt->Prosedur("call sp_YEMEK_LISTESI(7)");
	if($yemek_paz != null){
		$jsonDizi["PAZ"] = array();
		$jsonDizi["PAZ"] = $yemek_paz;
	}

	/******************************************************/
	
	$fonk->BaslikAyarla(200);
	echo $fonk->json($jsonDizi);
}else{
	$fonk->BaslikAyarla(400);
}



 ?>
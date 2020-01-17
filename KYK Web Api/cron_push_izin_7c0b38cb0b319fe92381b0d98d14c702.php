<?php 

function sendMessage($mesaj) {

    	$content      = array(
        	"en" => $mesaj
    	);
    	$fields = array(
        	'app_id' => "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        	'large_icon' => 'http://www.domain.site/izin_logo.png',

        	'app_url' => 'https://gencizbiz.kyk.gov.tr/',
        	'included_segments' => array(
            	'All'
        	),
        	'contents' => $content
    	);
    
    	$fields = json_encode($fields);   
    	$ch = curl_init();
    	curl_setopt($ch, CURLOPT_URL, "https://onesignal.com/api/v1/notifications");
    	curl_setopt($ch, CURLOPT_HTTPHEADER, array(
        	'Content-Type: application/json; charset=utf-8',
        	'Authorization: Basic xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    	));
    	curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
    	curl_setopt($ch, CURLOPT_HEADER, FALSE);
    	curl_setopt($ch, CURLOPT_POST, TRUE);
    	curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
    	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
    
    	$response = curl_exec($ch);
    	curl_close($ch);
    
    	return $response;
	}


$response = sendMessage("Geceyi yurdun dışında geçirecekseniz izin almayı unutmayınız. \n\nİzin almak için tıklayınız.");



 ?>
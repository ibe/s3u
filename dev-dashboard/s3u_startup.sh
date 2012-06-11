#!/bin/bash

cd ../s3u_lmu_hl7interface-trunk
rails s -p 3001 &
cd perl_service
perl s3u_lmu_hl7interface.pl &
cd ../../s3u_lmu_studienmonitor-trunk
rails s -p 3000 &
cd ../s3u_lmu_aerzte_ui-trunk
rails s -p 3002 &
cd ../s3u_lmu_webrequest-trunk
rails s -p 3003 &
cd ../s3u_lmu_studiendatenbank_dummy-trunk
rails s -p 3004 &
cd ../s3u_lmu_consentmanager-trunk
rails s -p 3005 &
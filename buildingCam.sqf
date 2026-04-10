//Camera creating - always add to the script to make the camera work
_camera = "camera" camCreate [0,0,0];
_camera cameraEffect ["internal","back"];




//Initial camera setup, basic CamSetPos and CamSetTarget example.
_camera CamSetPos [position ofb select 0,(position ofb select 1), 70];
_camera CamSetTarget ofb; //(position ofb);
_camera camsetDir [0,0,0];
_camera CamCommit 0;

sleep 5;


//Camera destroying - terminates the 'camera view'
_camera CameraEffect ["Terminate","back"];
CamDestroy _camera;
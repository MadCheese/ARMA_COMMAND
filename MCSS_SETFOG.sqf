_handle = CreateDialog "MCSS_FOGDIALOG";

_fP = fogParams;
_fogVal = _fP select 0;
_fogDecay = _fP select 1;
_fogBase = _fp select 2;

sliderSetRange [10000,0,1]; 
sliderSetRange [10001,0,0.1]; 
sliderSetRange [10002,-1000,1000]; 

sliderSetPosition [10000, _fogVal]; 
sliderSetPosition [10001, _fogDecay]; 
sliderSetPosition [10002, _fogBase]; 

while {dialog} do {
	_fogVal =  sliderposition 10000; 
	_fogDecay =  sliderposition 10001;
	_fogBase =  sliderposition 10002;
	hintsilent (str [_fogVal,_fogDecay,_fogBase]);
	0 setfog [_fogVal,_fogDecay,_fogBase]; 
	sleep 0.1;
};



hintsilent format [" New FogParams: %1 ",[_fogVal,_fogDecay,_fogBase]];



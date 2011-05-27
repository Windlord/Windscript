/*
	 __       __)
	(, )  |  /  ,       /)             ,
	   | /| /    __   _(/  _   _  __    __  _/_
	   |/ |/  _(_/ (_(_(_ /_)_(__/ (__(_/_)_(__
	   /  |                          .-/
	_______________________________ (_/ ________
	                                 version 1.0
	                                 by Windlord	*/

local LocalPlayer = FindLocalPlayer();
local _pos     	= Vector( 0.0, 0.0, 0.0 );
local _inc_pos 	= Vector( 0.0, 0.0, 0.0 );
local _rot     	= Vector( 0.0, 0.0, 0.0 );
local _inc_rot 	= Vector( 0.0, 0.0, 0.0 );
local _target  	= null;
local _run     	= 0;
local _dur     	= 30;
local _fin_wait	= 0;
local _rad      = 0.0174532925;
local _dpi      = 6.283185307;
local _gui, _guilabel, _guihealth, _guiarmour;

function _Initiate ( source, target )
{
	_pos = source.Pos;
	_rot = Vector( 0.0, 0.0, 0.0 );
	_rot.z = ( source.Angle + 90 ) * _rad;
	_target = target;
	_CalcFinal();
	
	_Update();
	_run = 1;
}

function _Process ()
{
	if ( _run )
	{
		if ( _run < _dur + 1 )
		{
			if (_inc_pos.x) _pos.x += _inc_pos.x;
			if (_inc_pos.y) _pos.y += _inc_pos.y;
			if (_inc_pos.z) _pos.z += _inc_pos.z;
			
			if ( _inc_rot.x) _rot.x += _inc_rot.x;
			if ( _inc_rot.z) _rot.z += _inc_rot.z;
			_Update();
			_run++;
		}
		else
		{
			_run = false;
			_guilabel.Text = _target.Name;
			_guihealth.Value = _target.Health;
			_guiarmour.Value = _target.Armour;
			_gui.Visible = true;
			_fin_wait++;
		}
	}
	if ( _fin_wait ) {
		if ( _fin_wait > 30 )
		{
			ShakeCamera( 250 );
			RestoreCamera();
			_gui.Visible = false;
			_fin_wait = 0;
		}
		else
		{
			_PanAfterZoom();
			_fin_wait++;
		}
	}
}

function _CalcFinal ()
{
	local ang = ( _target.Angle + 90 ) * _rad;
	local _fin_pos = Vector( 0.0, 0.0, 0.0 );
	local _fin_rot = Vector( 0.0, 0.0, 0.0 );
	
	_fin_pos = _target.Pos;
	_fin_pos.x += RandNum( 30, 70 ) / 10  * cos( ang );
	_fin_pos.y += RandNum( 30, 70 ) / 10  * sin( ang );
	_fin_pos.z += RandNum( 120 ) / 50;
	
	local dx = _target.Pos.x - _fin_pos.x;
	local dy = _target.Pos.y - _fin_pos.y;
	local dz = _target.Pos.z - _fin_pos.z;
	local dist = sqrt( dx*dx + dy*dy + dz*dz );
	dx = dx / dist, dy = dy / dist, dz = dz / dist;
	
	_fin_rot.x = asin( dz );
	_fin_rot.z = atan2( dy, dx );
	
	_inc_pos.x = ( _fin_pos.x - _pos.x ) / _dur;
	_inc_pos.y = ( _fin_pos.y - _pos.y ) / _dur;
	_inc_pos.z = ( _fin_pos.z - _pos.z ) / _dur;
	_inc_rot.x = ( _fin_rot.x - _rot.x ) / _dur;
	_inc_rot.z = ReduceAngle(_fin_rot.z - _rot.z) / _dur;
}

function _Update ()
{
	local target = Vector( 0.0, 0.0, 0.0 );
	target.x = _pos.x + cos( _rot.x ) * cos( _rot.z );
	target.y = _pos.y + cos( _rot.x ) * sin( _rot.z );
	target.z = _pos.z + sin( _rot.x );
	SetCameraMatrix( _pos, target );
}

function _PanAfterZoom ()
{
	local _fin_rot = Vector( 0.0, 0.0, 0.0 );

	local dx = _target.Pos.x - _pos.x;
	local dy = _target.Pos.y - _pos.y;
	local dz = _target.Pos.z - _pos.z;
	local dist = sqrt( dx*dx + dy*dy + dz*dz );
	dx = dx / dist, dy = dy / dist, dz = dz / dist;
	
	_fin_rot.x = asin( dz );
	_fin_rot.z = atan2( dy, dx );
	local drx = _fin_rot.x - _rot.x;
	local drz = ReduceAngle(_fin_rot.z - _rot.z);
	
	if ( abs(drx) > 0.1 ) _inc_rot.x = drx / abs(drx) * 0.1;
	if ( abs(drz) > 0.1 ) _inc_rot.z = drz / abs(drz) * 0.1;
	_rot.x += _inc_rot.x;
	_rot.z += _inc_rot.z;
	_Update();
}

function onScriptLoad ()
{
	local pos = VectorScreen( ScreenWidth / 2 + 50, ScreenHeight - 200 );
	local size = ScreenSize( 250, 70 );
	_gui = GUIWindow( pos, size, "None" );
	_gui.Colour = Colour( 0, 0, 0 );
	_gui.Transparent = true;
	_gui.Moveable = false;
	_gui.Titlebar = false;
	_gui.Alpha = 150;
	
	pos = VectorScreen( 10, 23 );
	size = ScreenSize( 230, 20 );
	_guilabel = GUILabel( pos, size, "None" );
	_guilabel.FontName = "Verdana";
	_guilabel.FontSize = 20	;
	_guilabel.TextAlignment = ALIGN_MIDDLE_LEFT;
	_guilabel.TextColour = Colour( 255, 255, 255 );
	_gui.AddChild( _guilabel );
	
	pos = VectorScreen( 10, 50 );
	size = ScreenSize( 230, 12 );
	_guihealth = GUIProgressBar( pos, size );
	_guihealth.Thickness = 2;
	_guihealth.MaxValue = 100;
	_guihealth.StartColour = Colour( 255, 0, 0 );
	_guihealth.EndColour = Colour( 34, 139, 34 );
	_gui.AddChild( _guihealth );
	
	pos = VectorScreen( 10, 65 );
	size = ScreenSize( 230, 12 );
	_guiarmour = GUIProgressBar( pos, size );
	_guiarmour.Thickness = 2;
	_guiarmour.MaxValue = 100;
	_guiarmour.StartColour = Colour( 50, 50, 50 );
	_guiarmour.EndColour = Colour( 255, 255, 255 );
	_gui.AddChild( _guiarmour );
	
	AddGUILayer( _gui );
	SendGUILayerToFront( _gui );
	_gui.Visible = false;
}

function onClientRender()
	_Process();

function onClientDeath ( killer, weapon, bodypart )
{
	if ( killer ) _Initiate( LocalPlayer, killer );
}

function ReduceAngle ( ang )
{
	local absang = abs( ang );
	while ( absang > _dpi )
	{
		absang -= _dpi;
		if ( ang > 0 ) ang -= _dpi;
		else ang += _dpi;
	}
	
	if ( absang > PI )
	{
		if ( ang < 0 ) ang += _dpi;
		else ang = _dpi - ang;
	}
	return ang;
}

function RandNum ( start, ... )
{
        local end;
        if ( vargv.len() > 0 ) end = vargv[ 0 ];
        else { end = start; start = 1; }
        return start + ( rand() % ( end - start ) );
}

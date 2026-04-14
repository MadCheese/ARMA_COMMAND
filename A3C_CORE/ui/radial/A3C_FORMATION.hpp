
class A3C_RadialMenu_FORM
{
	idd = 100120;
	movingenable = false;
	class ControlsBackground {
		class A3C_RadialMenu_FORM_BG: A3C_RscPicture
		{
			idc = 1;
			text = "A3C_CORE\ui\pictures\BG_formation_bar.paa";
			x = 5.86 * GUI_GRID_W + GUI_GRID_X;
			y = 11.38 * GUI_GRID_H + GUI_GRID_Y;
			w = 28.5 * GUI_GRID_W;
			h = 23.5 * GUI_GRID_H;
		};
		
	};
		
	class Controls 
	{
		class A3C_MENU_FORM_COLUMN: A3C_RscPicture
		{
			idc = -1;
			text = "A3C_CORE\ui\pictures\icon_menu_form_Column.Paa";
			x = 7 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1.5* GUI_GRID_H;
		};
		class A3C_MENU_FORM_COLUMN_1: A3C_RscButton_Invisible
		{
			idc = -1;
			x = 7 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1.5* GUI_GRID_H;
			tooltip = "column";
			action = "['COLUMN'] spawn A3C_FNC_FORMMENU";
		};
		class A3C_MENU_FORM_ST_COLUMN: A3C_RscPicture
		{
			idc = -1;
			text = "A3C_CORE\ui\pictures\icon_menu_form_StaggColumn.Paa";
			x = 10 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1.5* GUI_GRID_H;
		};
		class A3C_MENU_FORM_ST_COLUMN_1: A3C_RscButton_Invisible
		{
			idc = -1;
			x = 10 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1.5* GUI_GRID_H;
			tooltip = "staggered column";
			action = "['STAG COLUMN'] spawn A3C_FNC_FORMMENU";
		};
		class A3C_MENU_FORM_WEDGE: A3C_RscPicture
		{
			idc = -1;
			text = "A3C_CORE\ui\pictures\icon_menu_form_Wedge.Paa";
			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1.5* GUI_GRID_H;
		};
		class A3C_MENU_FORM_WEDGE_1: A3C_RscButton_Invisible
		{
			idc = -1;
			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1.5* GUI_GRID_H;
			tooltip = "wedge";
			action = "['WEDGE'] spawn A3C_FNC_FORMMENU";
		};
		class A3C_MENU_FORM_ECH_L: A3C_RscPicture
		{
			idc = -1;
			text = "A3C_CORE\ui\pictures\icon_menu_form_Ech_Left.Paa";
			x = 16 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1.5* GUI_GRID_H;
		};
		class A3C_MENU_FORM_ECH_L_1: A3C_RscButton_Invisible
		{
			idc = -1;
			x = 16 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1.5* GUI_GRID_H;
			tooltip = "echelon left";
			action = "['ECH LEFT'] spawn A3C_FNC_FORMMENU";
		};
		class A3C_MENU_FORM_EH_R: A3C_RscPicture
		{
			idc = -1;
			text = "A3C_CORE\ui\pictures\icon_menu_form_Ech_Right.Paa";
			x = 19 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1.5* GUI_GRID_H;
		};
		class A3C_MENU_FORM_EH_R_1: A3C_RscButton_Invisible
		{
			idc = -1;
			x = 19 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1.5* GUI_GRID_H;
			tooltip = "echelon right";
			action = "['ECH RIGHT'] spawn A3C_FNC_FORMMENU";
		};
	
		class A3C_MENU_FORM_VEE: A3C_RscPicture
		{
			idc = -1;
			text = "A3C_CORE\ui\pictures\icon_menu_form_Vee.Paa";
			x = 22 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1.5* GUI_GRID_H;
		};
		class A3C_MENU_FORM_VEE_1: A3C_RscButton_Invisible
		{
			idc = -1;
			x = 22 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1.5* GUI_GRID_H;
			tooltip = "vee";
			action = "['VEE'] spawn A3C_FNC_FORMMENU";
		};
		class A3C_MENU_FORM_LINE: A3C_RscPicture
		{
			idc = -1;
			text = "A3C_CORE\ui\pictures\icon_menu_form_Line.Paa";
			x = 25 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1.5* GUI_GRID_H;			
		};
		class A3C_MENU_FORM_LINE_1: A3C_RscButton_Invisible
		{
			idc = -1;
			x = 25 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			tooltip = "line";
			action = "['LINE'] spawn A3C_FNC_FORMMENU";
		};
		class A3C_MENU_FORM_FILE: A3C_RscPicture
		{
			idc = -1;
			text = "A3C_CORE\ui\pictures\icon_menu_form_File.Paa";
			x = 28 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1.5* GUI_GRID_H;
		};
		class A3C_MENU_FORM_FILE_1: A3C_RscButton_Invisible
		{
			idc = -1;
			x = 28 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1.5* GUI_GRID_H;
			tooltip = "file";
			action = "['FILE'] spawn A3C_FNC_FORMMENU";
		};
		class A3C_MENU_FORM_DIAMOND: A3C_RscPicture
		{
			idc = -1;
			text = "A3C_CORE\ui\pictures\icon_menu_form_Diamond.Paa";
			x = 31 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1.5* GUI_GRID_H;
		};
		class A3C_MENU_FORM_DIAMOND_1: A3C_RscButton_Invisible
		{
			idc = -1;
			x = 31 * GUI_GRID_W + GUI_GRID_X;
			y = 12.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 2 * GUI_GRID_W;
			h = 1.5* GUI_GRID_H;
			tooltip = "diamond";
			action = "['DIAMOND'] spawn A3C_FNC_FORMMENU";
		};	
	};
												
};




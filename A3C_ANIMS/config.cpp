class CfgPatches
{
        class A3C_ANIMS
        {
                units[] = {};
                weapons[] = {};
                requiredVersion = 0.1;
                requiredAddons[] = {"A3_anims_f"};
                projectName = "ARMA COMMAND";
                author = "Mad_Cheese";            
        };
        

		
        class Disable_XEH_Logging
        {
                units[] = {};
                weapons[] = {};
                requiredVersion = 0.1;
                requiredAddons[] = {};
        };
        
 
};







class CfgMovesBasic;

class CfgMovesMaleSdr: CfgMovesBasic
{
        class States
    {
        class amovpercmstpsraswrfldnon; // STAND
        class A3C_anim_stand: amovpercmstpsraswrfldnon
        {
            speed = 0;
            collisionShape = "A3C_anims\empty_collision.p3d";
            hasCollShapeSafe = 0;
            collisionShapeSafe = "";
            InterpolateTo[] = {};
            ConnectTo[] = {};
        };
        class amovpknlmstpsraswrfldnon; // CROUCH
        class A3C_anim_crouch: amovpknlmstpsraswrfldnon
        {
            speed = 0;
            collisionShape = "A3C_anims\empty_collision.p3d";
            hasCollShapeSafe = 0;
            collisionShapeSafe = "";
            InterpolateTo[] = {};
            ConnectTo[] = {};
        };
        class amovppnemstpsraswrfldnon; // PRONE
        class A3C_anim_prone: amovppnemstpsraswrfldnon
        {
            speed = 0;
            collisionShape = "A3C_anims\empty_collision.p3d";
            hasCollShapeSafe = 0;
            collisionShapeSafe = "";
            InterpolateTo[] = {};
            ConnectTo[] = {};
        };
    };
};